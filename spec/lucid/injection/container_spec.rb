module Lucid
  module Injection
    describe Container do

      let(:config) { double(:config) }
      let(:session) { double(:session) }

      context "valid key" do
        it "resolves the dependency" do
          container_class = Class.new(Container) { provide(:foo) { "foo" } }
          container = container_class.new(config, session)
          expect(container.key?(:foo)).to be_truthy
          expect(container[:foo]).to eq("foo")
        end

        it "momoizes the value" do
          container_class = Class.new(Container) { provide(:foo) { Object.new } }
          container = container_class.new(config, session)
          first = container[:foo]
          second = container[:foo]
          expect(first).to be(second)
        end
      end

      context "invalid key" do
        it "raises an error" do
          container_class = Class.new(Container) { provide(:foo) { "foo" } }
          container = container_class.new(config, session)
          expect(container.key?(:bar)).to be_falsey
          expect { container[:bar] }.to raise_error(Container::NoSuchProvider)
        end
      end

    end
  end
end