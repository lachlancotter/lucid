module Lucid
  #
  # A uniform interface over state variables and calculated values that
  # provides a consistent way to access and observe changing values.
  #
  class Field
    include Observable

    #
    # Pass either a block to evaluate or an execution object that
    # will be called to calculate the value of the field.
    # 
    def initialize (context, exec = nil, &block)
      @context   = context
      @value     = nil
      @evaluated = false
      @exec      = exec ? Types.instance(Execution)[exec] : Execution.new(block)
      watch_dependencies
    end
    
    def value
      unless @evaluated
        @value     = @exec.call(@context, *args, **kwargs)
        @evaluated = true
      end
      @value
    end

    def invalidate
      @evaluated = false
      notify
    end

    #
    # Enables dynamic manipulation of the parameters that a block is called with.
    # Used for advanced signal configuration. E.g. when wrapping a block with
    # another block.
    # 
    class Execution
      attr_reader :block, :positional, :keywords

      def initialize (block)
        @block      = block
        @positional = block_params(block, :req, :opt)
        @keywords   = block_params(block, :keyreq)
      end

      def call (context, *args, **kwargs)
        context.instance_exec(*args, **kwargs, &@block)
      end

      def each_param (&block)
        @positional.each(&block)
        @keywords.each(&block)
      end

      def set_block (block)
        @block = block
        self
      end

      def set_positional (*params, from_block: nil)
        @positional = params.dup
        @positional.concat Execution.new(from_block).positional if from_block
        self
      end

      def set_keywords (*params, from_block: nil)
        @keywords = params.dup
        @keywords.concat Execution.new(from_block).keywords if from_block
        self
      end

      private

      # Returns a list of parameter names for the block of the given type.
      # The type can be :req, :opt, :key, :keyreq, or :block.
      def block_params (block, *types)
        block.parameters.select { |p| types.include?(p[0]) }.map { |p| p.last }
      end
    end

  end
end