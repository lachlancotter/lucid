module MultiCounter
  class Store
    #
    # Manage the counters in shared, class-level state.
    #
    class << self
      def reset!
        @counters = {}
      end

      def all
        @counters.values
      end

      def find(name)
        @counters[name]
      end

      def create(name)
        @counters[name] = Counter.new(name)
      end

      def delete(name)
        @counters.delete(name)
      end

      def inc(name)
        @counters[name].inc
      end

      def dec(name)
        @counters[name].dec
      end
    end

    #
    # The view will instantiate the store, but we want to share the
    # class-level state, so we delegate all instance methods to the
    # class.
    #
    private def method_missing(symbol, *args)
      self.class.send(symbol, *args)
    end

    class Counter
      attr_reader :name, :count

      def initialize(name)
        @name  = name
        @count = 0
      end

      def inc
        @count += 1
      end

      def dec
        @count -= 1
      end
    end
  end
end