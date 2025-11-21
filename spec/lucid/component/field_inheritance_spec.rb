module Lucid
  describe Component::FieldInheritance do
    describe ".use" do
      it "inherits let value from parent" do
        view = Class.new(Component::Base) do
          let(:foo) { "bar" }
          nest :child do
            Class.new(Component::Base) {
              use :foo
            }
          end
        end.new({})
        expect(view.child.foo).to eq("bar")
      end

      it "inherits let values from ancestors" do
        view = Class.new(Component::Base) do
          let(:foo) { "bar" }
          nest :child do
            Class.new(Component::Base) {
              nest :grandchild do
                Class.new(Component::Base) {
                  use :foo
                }
              end
            }
          end
        end.new({})
        expect(view.child.grandchild.foo).to eq("bar")
      end

      it "inherits values from the session" do
        session_class = Class.new(App::Session) { key :foo }
        session       = session_class.new("foo" => "bar")
        view_class    = Class.new(Component::Base) { use :foo, from: :http_session }
        view          = view_class.new({}, http_session: session)
        expect(view.foo).to eq("bar")
      end

      it "inherits state values" do
        view = Class.new(Component::Base) do
          param :foo
          nest :child do
            Class.new(Component::Base) {
              use :foo
            }
          end
        end.new({ foo: "bar" })
        expect(view.child.foo).to eq("bar")
      end

      it "inherits prop values" do
        view = Class.new(Component::Base) do
          prop :foo
          nest :child do
            Class.new(Component::Base) { use :foo }
          end
        end.new({}, foo: "bar")
        expect(view.child.foo).to eq("bar")
      end

      it "uses value overrides" do
        view = Class.new(Component::Base) do
          let(:foo) { "bar" }
          nest :child do
            Class.new(Component::Base) {
              let(:foo) { "baz" }
              nest :grandchild do
                Class.new(Component::Base) {
                  use :foo
                }
              end
            }
          end
        end.new({})
        expect(view.child.grandchild.foo).to eq("baz")
      end

      it "raises when undefined" do
        view = Class.new(Component::Base) do
          use :foo
        end
        expect { view.new({}) }.to raise_error(Fields::NoSuchField)
      end
    end

  end
end