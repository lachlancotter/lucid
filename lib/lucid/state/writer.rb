require "lucid/state/stack"

module Lucid
  module State
    #
    # Accumulate the components of a URL from a state.
    # Path components and query params may be added to
    # the buffer to build up a URL.
    #
    class Writer
      def initialize (state)
        @state    = Stack.new(state)
        @segments = []
        @params   = Stack.new({})
      end

      def write (map)
        map.rules.each do |rule|
          rule.encode(@state.top, self)
        end
      end

      def write_scoped (scope_key, map)
        @state.with_scope(scope_key) do
          @params.with_scope(scope_key) do
            write(map)
          end
        end
      end

      def write_path_segment (segment)
        @segments << segment
      end

      def write_param (key, value)
        @params.top[key] = value
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
    end
  end
end