module MultiCounter
  class Store
    #
    # Manage the counters in shared, class-level state.
    #
    class << self
      def reset!
        @counters = {}
      end

      attr_reader :counters

      def none?
        all.empty?
      end

      def all
        @counters.values
      end

      def [](index)
        all[index]
      end

      def find(id)
        @counters[id]
      end

      def create(name)
        Counter.new(name).tap do |counter|
          @counters[counter.id] = counter
        end
      end

      def delete(id)
        @counters.delete(id)
      end

      def inc(id)
        puts "INC: #{id}"
        @counters[id].inc
      end

      def dec(id)
        @counters[id].dec
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
      attr_reader :id, :name, :count

      def initialize(name)
        @id    = SecureRandom.uuid
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