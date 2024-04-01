require "lucid/state/stack"

module Lucid
  module State
    #
    # Accumulate the components of a URL from a state.
    # Path components and query params may be added to
    # the buffer to build up a URL.
    #
    class Writer


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

      def write_component (component)
        tap do
          write_state(component.class.state_map)
          write_nests(component.nests)
        end
      end

      def write_state (map)
        map.rules.each do |rule|
          rule.encode(@state.top, self)
        end
      end

      def write_nests (nests)
        nests.each do |(name, sub)|
          with_scope(name) { write_component(sub) }
        end
      end

      def write_path_segment (segment)
        @segments << segment
      end

      def write_param (key, value)
        @params.top[key] = value
      end

      def write_message (message)
        Check[message].type(Message)
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