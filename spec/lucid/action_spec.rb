module Lucid
  describe Action do

    # ===================================================== #
    #    Params
    # ===================================================== #

    describe ".params" do
      it "defines the action params" do
        action = Class.new(Action) do
          params do
            attribute :foo, default: "bar"
          end
        end.new({ baz: "wow" })
        expect(action.class.params_class.defaults).to eq({ foo: "bar" })
        expect(action.params.to_h).to eq({ foo: "bar" })
      end
    end
    
    # ===================================================== #
    #    Config
    # ===================================================== #

    describe ".config" do
      context "default" do
        it "sets the default" do
          view = Class.new(Action) do
            config do
              option :foo, "bar"
            end
          end.new({})
          expect(view.foo).to eq("bar")
        end
      end

      context "override" do
        it "overrides the default" do
          view = Class.new(Action) do
            config do
              option :foo, "bar"
            end
          end.new({}) do |config|
            config.foo = "baz"
          end
          expect(view.foo).to eq("baz")
        end
      end
    end

    # ===================================================== #
    #    Store
    # ===================================================== #

    describe ".store" do
      it "defines a data store" do
        data_store_class = Class.new(Store)
        action = Class.new(Action) do
          store :foo, data_store_class
        end.new({})
        expect(action.foo).to be_a(data_store_class)
      end
    end
  end
end