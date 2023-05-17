require "lucid/link"
require "lucid/route"

module Lucid
  class View
    class MyRoute
      def initialize (params)
        @params = params
      end
      def to_s
        "/counter?#{@params}"
      end
    end

    class << self
      def state (&block)
      end

      def route (&block)
      end

      def link (name, text = nil, &block)
        define_method(name) do
          new_state = state.dup
          block.call(new_state) if block_given?
          route = Route.for(new_state, config)

          Link.new(new_state, text)

          # params = Route::Params.new(new_state.to_h).to_s
          # route = MyRoute.new(params)
          Link.new(route, text)
        end
      end
    end

    def initialize (state = {})
      @state = OpenStruct.new(state)
      @links = SimpleDelegator.new(self)
    end

    attr_reader :state
    attr_reader :links

    def to_s
      render
    end
  end
end
