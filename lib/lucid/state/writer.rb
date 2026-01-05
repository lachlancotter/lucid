module Lucid
  module State
    #
    # Accumulate the components of a URL from a state.
    # Path components and query params may be added to
    # the buffer to build up a URL.
    #
    class Writer

      #
      # Add context to errors raised during encoding.
      # 
      class Error < StandardError
        def initialize (component, reason)
          super("Error encoding component: #{component}: #{reason}")
        end
      end

      def initialize
        @namespaces = [Namespace.new("")]
        @segments   = []
        @params     = {}
      end

      def to_s
        "/" + @segments.join("/") + (
           if @params.any?
             "?" + Rack::Utils.build_nested_query(@params)
           else
             ""
           end
        )
      end

      def write_component (component, on_route:)
        Types.component[component]
        tap do
          state_map = component.class.state_map
          state_map = state_map.off_route unless on_route
          write_state(state_map, component.state.to_h)
          write_nests(component.nests, on_route: on_route)
        end
      rescue State::Map::MissingValue => e
        raise Error.new(component, e.message)
      end

      def write_state (map, hash)
        map.encode(hash, self)
      end

      def write_nests (nests, on_route:)
        nests.each do |(name, nest)|
          # TODO handle state for collections
          unless nest.collection?
            with_scope(Namespace.new(nest.component)) do
              write_component(nest.component, on_route: nest.on_route? && on_route)
            end
          end
        end
      end

      def write_path_segment (segment)
        @segments << segment
      end

      def write_param (key, value)
        @params[namespace.qualify(key)] = value
      end

      def namespace
        @namespaces.last
      end

      def write_message (message)
        Types.http_message[message]
        @params.base.merge!(message.query_params)
      end

      def with_scope (namespace)
        @namespaces.push Types.instance(Namespace)[namespace]
        yield self
      ensure
        @namespaces.pop
      end

    end
  end
end