module Lucid
  class Template
    def initialize(view, &block)
      @view = view
      @block = block
    end

    def call(*args)
      @block.call(*args)
    end
  end
end
