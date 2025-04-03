module Lucid
  module Injection

    #
    # Convenience class for testing.
    # 
    class ConsumerBase
      include Consumer
    end

    describe Consumer do

      let(:config) { double(:config) }
      let(:session) { double(:session) }

      context "valid dependency provided" do
        it "instantiates the consumer" do
          consumer_class  = Class.new(ConsumerBase) { use :foo, Types.string }
          container_class = Class.new(Container) { provide(:foo) { "foo" } }
          container       = container_class.new(config, session)
          expect { consumer_class.new(container) }.not_to raise_error
        end
      end

      context "no such provider" do
        it "raises an error" do
          consumer_class  = Class.new(ConsumerBase) { use :foo, Types.string }
          container_class = Class.new(Container) {  }
          container       = container_class.new(config, session)
          expect { consumer_class.new(container) }.to raise_error(Consumer::MissingDependency)
        end
      end

    end
  end
end