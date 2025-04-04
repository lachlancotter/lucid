module Lucid
  module Injection

    #
    # Convenience class for testing.
    # 
    class ConsumerBase
      include Consumer
    end

    describe Consumer do

      context "valid dependency provided" do
        it "instantiates the consumer" do
          consumer_class  = Class.new(ConsumerBase) { use :foo, Types.string }
          container_class = Class.new(Container) { provide(:foo) { "foo" } }
          container       = container_class.new
          expect { consumer_class.new(container) }.not_to raise_error
        end
      end

      context "inherited dependency provided" do
        it "instantiates the consumer" do
          consumer_superclass = Class.new(ConsumerBase) { use :foo, Types.string }
          consumer_class      = Class.new(consumer_superclass) { }
          container_class     = Class.new(Container) { provide(:foo) { "foo" } }
          container           = container_class.new
          expect { 
            consumer = consumer_class.new(container)
            expect(consumer.foo).to eq("foo")
          }.not_to raise_error
        end
      end

      context "optional dependency not provided" do
        it "instantiates the consumer" do
          consumer_superclass = Class.new(ConsumerBase) { use :foo, Types.string.optional }
          consumer_class      = Class.new(consumer_superclass) { }
          container_class     = Class.new(Container) {  }
          container           = container_class.new
          expect { consumer_class.new(container) }.not_to raise_error
        end
      end

      context "no such provider" do
        it "raises an error" do
          consumer_class  = Class.new(ConsumerBase) { use :foo, Types.string }
          container_class = Class.new(Container) {  }
          container       = container_class.new
          expect { consumer_class.new(container) }.to raise_error(Consumer::MissingDependency)
        end
      end

    end
  end
end