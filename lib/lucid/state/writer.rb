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

      def initialize (state = {})
        @state    = Stack.new(state)
        @segments = []
        @params   = Stack.new({})
      end

      def to_s
        "/" + @segments.join("/") + (
           if @params.top.any?
             "?" + Rack::Utils.build_nested_query(@params.top)
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
          write_state(state_map)
          write_nests(component.nests, on_route: on_route)
        end
      rescue State::Map::MissingValue => e
        raise Error.new(component, e.message)
      end
      
      def write_state (map)
        map.encode(@state.top, self)
      end

      def write_nests (nests, on_route:)
        nests.each do |(name, nest)|
          # TODO handle state for collections
          unless nest.collection?
            with_scope(name) do
              write_component(nest.component, on_route: nest.on_route? && on_route)
            end
          end
        end
      end

      def write_path_segment (segment)
        @segments << segment
      end

      def write_param (key, value)
        @params.top[key] = value
      end

      def write_message (message)
        Types.http_message[message]
        @params.base.merge!(message.query_params)
      end

      def with_scope (scope_key, &block)
        @state.with_scope(scope_key) do
          @params.with_scope(scope_key) do
            yield self
          end
        end
      end

    end
  end
end