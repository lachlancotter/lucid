module Lucid
  class State < OpenStruct
    def mutate (&block)
      new_state = self.dup
      block.call(new_state) if block_given?
      new_state
    end
  end
end