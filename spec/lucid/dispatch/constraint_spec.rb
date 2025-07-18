module Lucid
  module Dispatch
    describe Constraint do

      describe "#match?" do
        context "no constraints" do
          it "matches the same message type" do
            message_class = Class.new(Message)
            constraint    = Constraint.new(message_class)
            match         = constraint.match?(message_class.new)
            expect(match).to be true
          end

          it "matches subclasses of the message type" do
            message_class = Class.new(Message)
            subclass      = Class.new(message_class)
            constraint    = Constraint.new(message_class)
            match         = constraint.match?(subclass.new)
            expect(match).to be true
          end

          it "does not match other types" do
            message_class       = Class.new(Message)
            other_message_class = Class.new(Message)
            constraint          = Constraint.new(message_class)
            match               = constraint.match?(other_message_class.new)
            expect(match).to be false
          end
        end

        context "static key-value constraint" do
          it "matches when the message conforms to the constraint" do
            message_class = Class.new(Message)
            constraint    = Constraint.new(message_class, foo: "bar")
            message       = message_class.new(foo: "bar")
            match         = constraint.match?(message)
            expect(match).to be true
          end

          it "does not match when the message violates the constraints" do
            message_class = Class.new(Message)
            constraint    = Constraint.new(message_class, foo: "bar")
            message       = message_class.new(foo: "baz")
            match         = constraint.match?(message)
            expect(match).to be false
          end
        end

        context "dynamic key match constraint" do
          it "matches when the message value matches in the context" do
            message_class = Class.new(Message)
            constraint    = Constraint.new(message_class, :foo, :bar)
            message       = message_class.new(foo: "foo", bar: "bar")
            context       = { foo: "foo", bar: "bar" }
            match         = constraint.match?(message, context)
            expect(match).to be true
          end

          it "does not match when a value is different in the context" do
            message_class = Class.new(Message)
            constraint    = Constraint.new(message_class, :foo, :bar)
            message       = message_class.new(foo: "foo", bar: "bar")
            context       = { foo: "foo", bar: "qux" }
            match         = constraint.match?(message, context)
            expect(match).to be false
          end
        end

        context "dynamic key-value lookup constraint" do
          it "matches when the message value matches the context" do
            message_class = Class.new(Message)
            constraint    = Constraint.new(message_class, foo: :bar)
            message       = message_class.new(foo: "baz")
            context       = { bar: "baz" }
            match         = constraint.match?(message, context)
            expect(match).to be true
          end

          it "does not match when the message value is different in the context" do
            message_class = Class.new(Message)
            constraint    = Constraint.new(message_class, foo: :bar)
            message       = message_class.new(foo: "baz")
            context       = { bar: "qux" }
            match         = constraint.match?(message, context)
            expect(match).to be false
          end
        end
      end

    end
  end
end