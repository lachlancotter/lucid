module Lucid
  #
  # A uniform interface over state variables and calculated values that
  # provides a consistent way to access and observe changing values.
  #
  class Field
    include Observable

    def initialize (context, &block)
      @context   = context
      @block     = block
      @value     = nil
      @evaluated = false
      params.each do |param|
        @context.field(param).attach(self) { invalidate }
      end
    end

    def value
      unless @evaluated
        @value     = @block.call(*args)
        @evaluated = true
      end
      @value
    end

    def invalidate
      @evaluated = false
      notify
    end

    private

    def params
      @block.parameters.map { |param| param[1] }
    end

    def args
      params.map { |param| @context.field(param).value }
    end
  end
end