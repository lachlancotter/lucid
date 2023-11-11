require "lucid/state/tree"

module Lucid
  describe State::Tree do

    # ===================================================== #
    #    Empty
    # ===================================================== #

    context "empty" do
      it "is empty" do
        component = Class.new(Component)
        node      = State::Tree.new({}, component)
        expect(node.state).to be_empty
      end
    end

    # ===================================================== #
    #    Root Node
    # ===================================================== #

    context "root node" do
      it "applies data" do
        component = Class.new(Component)
        node      = State::Tree.new({ foo: "bar" }, component)
        expect(node.state).to eq({ foo: "bar" })
      end

      it "applies defaults" do
        component = Class.new(Component) do
          state do
            attribute :foo, default: "bar"
          end
        end
        node      = State::Tree.new({}, component)
        expect(node.state).to eq({ foo: "bar" })
      end

      it "applies validation" do
        component = Class.new(Component) do
          state do
            validate do
              required(:foo).filled(:string)
            end
          end
        end
        node      = State::Tree.new({}, component)
        expect(node.state).not_to be_valid
      end
    end

    # ===================================================== #
    #    Nested Node
    # ===================================================== #

    context "nested node" do
      it "applies data" do
        component = Class.new(Component) do
          nest :foo, Class.new(Component)
        end
        node      = State::Tree.new({ foo: { bar: "baz" } }, component)
        nested    = node.nested(:foo)
        expect(nested.state).to eq({ bar: "baz" })
      end

      it "applies defaults" do
        component = Class.new(Component) do
          nest :foo, Class.new(Component) do
            state do
              attribute :bar, default: "baz"
            end
          end
        end
        node      = State::Tree.new({}, component)
        nested    = node.nested(:foo)
        expect(nested.state).to eq({ bar: "baz" })
      end

      it "applies validation" do
        component = Class.new(Component) do
          nest :foo, Class.new(Component) do
            state do
              validate do
                required(:bar).filled(:string)
              end
            end
          end
        end
        node      = State::Tree.new({}, component)
        nested    = node.nested(:foo)
        expect(nested.state).not_to be_valid
      end
    end

    # ===================================================== #
    #    Deeply Nested Node
    # ===================================================== #

    context "deeply nested node" do
      it "applies data" do
        component = Class.new(Component) do
          nest :foo, Class.new(Component) do
            nest :bar, Class.new(Component)
          end
        end
        node      = State::Tree.new({ foo: { bar: { baz: "qux" } } }, component)
        nested    = node.nested(:foo, :bar)
        expect(nested.state).to eq({ baz: "qux" })
      end

      it "applies defaults" do
        component = Class.new(Component) do
          nest :foo, Class.new(Component) do
            nest :bar, Class.new(Component) do
              state do
                attribute :baz, default: "qux"
              end
            end
          end
        end
        node      = State::Tree.new({}, component)
        nested    = node.nested(:foo, :bar)
        expect(nested.state).to eq({ baz: "qux" })
      end

      it "applies validation" do
        component = Class.new(Component) do
          nest :foo, Class.new(Component) do
            nest :bar, Class.new(Component) do
              state do
                validate do
                  required(:baz).filled(:string)
                end
              end
            end
          end
        end
        node      = State::Tree.new({}, component)
        nested    = node.nested(:foo, :bar)
        expect(nested.state).not_to be_valid
      end
    end

    # ===================================================== #
    #    Sibling Nodes
    # ===================================================== #

    context "sibling nodes" do
      it "applies data" do
        component = Class.new(Component) do
          nest :foo, Class.new(Component)
          nest :bar, Class.new(Component)
        end
        node      = State::Tree.new({ foo: { baz: "qux" }, bar: { quux: "corge" } }, component)
        expect(node.nested(:foo).state).to eq({ baz: "qux" })
        expect(node.nested(:bar).state).to eq({ quux: "corge" })
      end

      it "applies defaults" do
        component = Class.new(Component) do
          nest :foo, Class.new(Component) do
            state do
              attribute :baz, default: "qux"
            end
          end

          nest :bar, Class.new(Component) do
            state do
              attribute :quux, default: "corge"
            end
          end
        end
        node      = State::Tree.new({}, component)
        expect(node.nested(:foo).state).to eq({ baz: "qux" })
        expect(node.nested(:bar).state).to eq({ quux: "corge" })
      end

      it "applies validation" do
        component = Class.new(Component) do
          nest :foo, Class.new(Component) do
            state do
              validate do
                required(:baz).filled(:string)
              end
            end
          end
          nest :bar, Class.new(Component) do
            state do
              validate do
                required(:quux).filled(:string)
              end
            end
          end
        end
        node      = State::Tree.new({}, component)
        expect(node.nested(:foo).state).not_to be_valid
        expect(node.nested(:bar).state).not_to be_valid
      end
    end
  end
end