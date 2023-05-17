module Lucid
  class State < SimpleDelegator
    def initialize (component)
      super(component)
      @component = component
    end

    attr_reader :component

    def route
      Route.new(data)
    end

    def data
      @component
    end
  end
end