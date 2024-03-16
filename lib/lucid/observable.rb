module Lucid
  module Observable

    #
    # An object that can notify observers when state changes.
    #
    module Subject
      def attach (observer, *keys)
        @observers ||= {}
        @observers[observer] = keys
      end

      def detach (observer)
        @observers.delete(observer)
      end

      def notify (data)
        @observers.each do |observer, keys|
          data.each do |key, value|
            observer.update(self, key, value) if keys.include?(key)
          end
        end
      end
    end

    #
    # An object that can observe a Subject.
    #
    module Observer
      def update (subject, key, value)
        raise NotImplementedError
      end
    end

  end
end