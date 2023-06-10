require "lucid/state"
require "lucid/route"
require "lucid/link"

module Lucid
  class View
    class << self
      def state (&block) end

      def route (&block)
        @routes = Route::Map.build(route_config, &block)
      end

      def route_config
        {
           path_root: "/counter"
        }
      end

      def link (name, &block)
        define_method(name) do
          new_state = state.mutate(&block)
          Link.new(new_state, routes)
        end
      end
    end

    def initialize (state = {})
      @state  = State.new(state)
      @links  = SimpleDelegator.new(self)
    end

    attr_reader :state
    attr_reader :links

    def routes
      self.class.instance_variable_get(:@routes)
    end

    def to_s
      render
    end
  end
end
