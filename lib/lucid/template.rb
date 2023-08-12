module Lucid
  class Template
    def initialize(view, &block)
      @view = view
      @block = block
    end

    def call(*args)
      result = @block.call(*args)
      result.is_a?(Papercraft::Template) ? result.apply : result
    end
  end
end
