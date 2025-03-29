module Lucid
  #
  # An object that can notify observers when state changes.
  #
  module Observable
    def attach (observer, &block)
      @observers           ||= {}
      @observers[observer] = block
    end

    def detach (observer)
      @observers.delete(observer)
    end

    def notify
      (@observers || {}).each do |observer, block|
        block.call(self)
      end
    end
  end
end