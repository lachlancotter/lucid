module Lucid
  module Dispatch
    describe MessageFilter do
      
      describe "#match?" do
        context "no constraints" do
          it "matches the same message type" do
            message_class = Class.new(Message)
            filter        = MessageFilter.new(message_class)
            match         = filter.match?(message_class.new)
            expect(match).to be true
          end

          it "matches subclasses of the message type" do
            message_class = Class.new(Message)
            subclass      = Class.new(message_class)
            filter        = MessageFilter.new(message_class)
            match         = filter.match?(subclass.new)
            expect(match).to be true
          end

          it "does not match other types" do
            message_class       = Class.new(Message)
            other_message_class = Class.new(Message)
            filter              = MessageFilter.new(message_class)
            match               = filter.match?(other_message_class.new)
            expect(match).to be false
          end
        end

        context "static key-value constraint" do
          it "matches when the message conforms to the constraint" do
            message_class = Class.new(Message)
            filter        = MessageFilter.new(message_class, foo: "bar")
            message       = message_class.new(foo: "bar")
            match         = filter.match?(message)
            expect(match).to be true
          end

          it "does not match when the message violates the constraints" do
            message_class = Class.new(Message)
            filter        = MessageFilter.new(message_class, foo: "bar")
            message       = message_class.new(foo: "baz")
            match         = filter.match?(message)
            expect(match).to be false
          end
        end

        context "dynamic key match constraint" do
          it "matches when the message value matches in the context" do
            message_class = Class.new(Message)
            filter        = MessageFilter.new(message_class, :foo, :bar)
            message       = message_class.new(foo: "foo", bar: "bar")
            context       = { foo: "foo", bar: "bar" }
            match         = filter.match?(message, context)
            expect(match).to be true
          end

          it "does not match when a value is different in the context" do
            message_class = Class.new(Message)
            filter        = MessageFilter.new(message_class, :foo, :bar)
            message       = message_class.new(foo: "foo", bar: "bar")
            context       = { foo: "foo", bar: "qux" }
            match         = filter.match?(message, context)
            expect(match).to be false
          end
        end

        context "dynamic key-value lookup constraint" do
          it "matches when the message value matches the context" do
            message_class = Class.new(Message)
            filter        = MessageFilter.new(message_class, foo: :bar)
            message       = message_class.new(foo: "baz")
            context       = { bar: "baz" }
            match         = filter.match?(message, context)
            expect(match).to be true
          end

          it "does not match when the message value is different in the context" do
            message_class = Class.new(Message)
            filter        = MessageFilter.new(message_class, foo: :bar)
            message       = message_class.new(foo: "baz")
            context       = { bar: "qux" }
            match         = filter.match?(message, context)
            expect(match).to be false
          end
        end
      end

      describe "#call" do
        context "matching message" do
          it "calls the block" do
            called        = false
            message_class = Class.new(Message)
            filter        = MessageFilter.new(message_class) do
              called = true
            end
            filter.call(message_class.new)
            expect(called).to be true
          end
        end

        context "non-matching message" do
          it "does not call the block" do
            called        = false
            message_class = Class.new(Message)
            filter        = MessageFilter.new(message_class, foo: "bar") do
              called = true
            end
            filter.call(message_class.new)
            expect(called).to be false
          end
        end
      end

    end
  end
end