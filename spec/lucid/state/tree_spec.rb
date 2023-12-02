require "lucid/state/tree"

module Lucid
  describe State::Tree do

    # ===================================================== #
    #    Empty
    # ===================================================== #

    context "empty" do
      it "is empty" do
        component = Class.new(Component::Base)
        tree      = State::Tree.new({}, component)
        expect(tree.path.get).to be_empty
      end
    end

    # ===================================================== #
    #    Root Node
    # ===================================================== #

    context "root node" do
      it "converts to a Hash" do
        component = Class.new(Component::Base)
        tree      = State::Tree.new({ foo: "bar" }, component)
        expect(tree.to_h).to eq({ foo: "bar" })
      end

      it "applies data" do
        component = Class.new(Component::Base)
        tree      = State::Tree.new({ foo: "bar" }, component)
        expect(tree.path.get).to eq({ foo: "bar" })
      end

      it "applies defaults" do
        component = Class.new(Component::Base) do
          state do
            attribute :foo, default: "bar"
          end
        end
        tree      = State::Tree.new({}, component)
        expect(tree.path.get).to eq({ foo: "bar" })
      end

      it "applies validation" do
        component = Class.new(Component::Base) do
          state do
            validate do
              required(:foo).filled(:string)
            end
          end
        end
        tree      = State::Tree.new({}, component)
        expect(tree.path.get).not_to be_valid
      end

      it "applies mutations" do
        component = Class.new(Component::Base)
        tree      = State::Tree.new({ foo: "foo" }, component)
        changed   = tree.root.transform("bar") do |state, value|
          state.update(foo: value)
        end
        expect(changed.to_h).to eq({ foo: "bar" })
      end
    end

    # ===================================================== #
    #    Nested Node
    # ===================================================== #

    context "nested node" do
      it "converts to a Hash" do
        component = Class.new(Component::Base) do
          nest :foo, Class.new(Component::Base)
        end
        tree      = State::Tree.new({ foo: { bar: "baz" } }, component)
        expect(tree.to_h).to eq({ foo: { bar: "baz" } })
      end

      it "applies data" do
        component = Class.new(Component::Base) do
          nest :foo, Class.new(Component::Base)
        end
        tree      = State::Tree.new({ foo: { bar: "baz" } }, component)
        nested    = tree.path(:foo).get
        expect(nested).to eq({ bar: "baz" })
      end

      it "applies defaults" do
        component = Class.new(Component::Base) do
          nest :foo, Class.new(Component::Base) do
            state do
              attribute :bar, default: "baz"
            end
          end
        end
        tree      = State::Tree.new({}, component)
        nested    = tree.path(:foo).get
        expect(nested).to eq({ bar: "baz" })
      end

      it "applies validation" do
        component = Class.new(Component::Base) do
          nest :foo, Class.new(Component::Base) do
            state do
              validate do
                required(:bar).filled(:string)
              end
            end
          end
        end
        tree      = State::Tree.new({}, component)
        nested    = tree.path(:foo).get
        expect(nested).not_to be_valid
      end

      it "applies mutations" do
        component = Class.new(Component::Base) do
          nest :foo, Class.new(Component::Base)
        end
        root      = State::Tree.new({ foo: { bar: "bar" } }, component)
        changed = root.path(:foo).transform("qux") do |state, value|
          state.update(bar: value)
        end
        expect(changed).not_to eq(root)
        expect(changed.to_h).to eq({ foo: { bar: "qux" } })
      end

    end

    # ===================================================== #
    #    Deeply Nested Node
    # ===================================================== #

    context "deeply nested node" do
      it "applies data" do
        component = Class.new(Component::Base) do
          nest :foo, Class.new(Component::Base) do
            nest :bar, Class.new(Component::Base)
          end
        end
        tree      = State::Tree.new({ foo: { bar: { baz: "qux" } } }, component)
        nested    = tree.path(:foo, :bar).get
        expect(nested).to eq({ baz: "qux" })
      end

      it "applies defaults" do
        component = Class.new(Component::Base) do
          nest :foo, Class.new(Component::Base) do
            nest :bar, Class.new(Component::Base) do
              state do
                attribute :baz, default: "qux"
              end
            end
          end
        end
        tree      = State::Tree.new({}, component)
        nested    = tree.path(:foo, :bar).get
        expect(nested).to eq({ baz: "qux" })
      end

      it "applies validation" do
        component = Class.new(Component::Base) do
          nest :foo, Class.new(Component::Base) do
            nest :bar, Class.new(Component::Base) do
              state do
                validate do
                  required(:baz).filled(:string)
                end
              end
            end
          end
        end
        tree      = State::Tree.new({}, component)
        nested    = tree.path(:foo, :bar).get
        expect(nested).not_to be_valid
      end
    end

    # ===================================================== #
    #    Sibling Nodes
    # ===================================================== #

    context "sibling nodes" do
      it "applies data" do
        component = Class.new(Component::Base) do
          nest :foo, Class.new(Component::Base)
          nest :bar, Class.new(Component::Base)
        end
        tree      = State::Tree.new({ foo: { baz: "qux" }, bar: { quux: "corge" } }, component)
        expect(tree.path(:foo).get).to eq({ baz: "qux" })
        expect(tree.path(:bar).get).to eq({ quux: "corge" })
      end

      it "applies defaults" do
        component = Class.new(Component::Base) do
          nest :foo, Class.new(Component::Base) do
            state do
              attribute :baz, default: "qux"
            end
          end

          nest :bar, Class.new(Component::Base) do
            state do
              attribute :quux, default: "corge"
            end
          end
        end
        tree      = State::Tree.new({}, component)
        expect(tree.path(:foo).get).to eq({ baz: "qux" })
        expect(tree.path(:bar).get).to eq({ quux: "corge" })
      end

      it "applies validation" do
        component = Class.new(Component::Base) do
          nest :foo, Class.new(Component::Base) do
            state do
              validate do
                required(:baz).filled(:string)
              end
            end
          end
          nest :bar, Class.new(Component::Base) do
            state do
              validate do
                required(:quux).filled(:string)
              end
            end
          end
        end
        tree      = State::Tree.new({}, component)
        expect(tree.path(:foo).get).not_to be_valid
        expect(tree.path(:bar).get).not_to be_valid
      end
    end
  end
end