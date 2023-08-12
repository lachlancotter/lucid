module Lucid
  class Template
    def initialize(&block)
      @block = block
    end

    def call(*args)
      @block.call(*args)
    end
  end
end
