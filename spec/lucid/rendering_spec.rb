module Lucid
  describe Rendering do
    describe "render" do
      describe "default template" do
        it "renders" do
          view = Class.new(Component::Base) do
            template do
              h1 { text "Hello, World" }
            end
          end.new
          expect(view.render.replace.call).to match(/<h1>Hello, World<\/h1>/)
        end
      end

      describe "named template" do
        it "renders" do
          view = Class.new(Component::Base) do
            template :foo do
              h1 { text "Hello, World" }
            end
          end.new
          expect(view.template(:foo).render).to match(/<h1>Hello, World<\/h1>/)
        end
      end

      describe "element ID" do
        context "root component" do
          it "is omitted" do
            view = Class.new(Component::Base) do
              template do
                h1 { text "Hello, World" }
              end
            end.new
            expect(view.render.replace.call).to eq("<h1>Hello, World</h1>")
          end
        end

        context "nested component" do
          it "is the component path" do
            view = Class.new(Component::Base) do
              nest :foo, Class.new(Component::Base) {
                template { h1 { text "Nested" } }
              }
              template { subview(:foo) }
            end.new
            expect(view.render.replace.call).to match(/<div id="foo"><h1>Nested<\/h1><\/div>/)
          end
        end
      end

      describe "template with args" do
        it "renders" do
          view = Class.new(Component::Base) do
            param :name
            template do |name|
              h1 { text "Hello, #{name}" }
            end
          end.new
          expect(view.template.render("World")).to match(/<h1>Hello, World<\/h1>/)
        end
      end

      describe "template with context" do
        it "renders" do
          view = Class.new(Component::Base) do
            template do
              h1 { text "Hello, #{name}" }
            end

            def name
              "World"
            end
          end.new
          expect(view.render.replace.call).to match(/<h1>Hello, World<\/h1>/)
        end
      end

      describe "context with name collision" do
        it "renders" do
          view = Class.new(Component::Base) do
            template do
              h1 { text "Hello, #{context.label}" }
            end

            def label
              "World"
            end
          end.new
          expect(view.render.replace.call).to match(/<h1>Hello, World<\/h1>/)
        end
      end
    end

    describe "#any?" do
      it "is false when created" do
        view = Class.new(Component::Base) do
          param :foo
        end.new(foo: "foo")
        expect(view.render.any?).to be(false)
      end

      it "is true when template state dependencies change" do
        view = Class.new(Component::Base) do
          param :foo
          template do |foo|
            h1 { text foo }
          end
        end.new(foo: "foo")
        view.update(foo: "bar")
        expect(view.render.any?).to be(true)
      end

      it "is true when template let dependencies change" do
        view = Class.new(Component::Base) do
          param :foo
          let(:bar) { |foo| foo.upcase }
          template do |bar|
            h1 { text bar }
          end
        end.new(foo: "foo")
        view.update(foo: "bar")
        expect(view.render.any?).to be(true)
      end

      it "is true when template use dependencies change" do
        view = Class.new(Component::Base) do
          param :foo
          nest :bar, Class.new(Component::Base) {
            use :foo
            template do |foo|
              h1 { text foo }
            end
          }
        end.new(foo: "foo")
        view.update(foo: "bar")
        expect(view.render.any?).to be(false)
        expect(view.bar.render.any?).to be(true)
      end

      it "is false when template dependencies are unchanged" do
        view = Class.new(Component::Base) do
          param :foo
          template do
            h1 { "Test" }
          end
        end.new(foo: "foo")
        view.update(foo: "bar")
        expect(view.render.any?).to be(false)
      end
    end

    describe "#branches" do
      context "when unchanged" do
        it "is empty" do
          view = Class.new(Component::Base) do
            template do
              h1 { text "Hello, World" }
            end
          end.new
          expect(view.render.branches).to be_empty
        end
      end

      context "when changed" do
        it "contains the root component render" do
          view = Class.new(Component::Base) do
            param :foo
            template do |foo|
              h1 { text foo }
            end
          end.new
          view.update(foo: "bar")
          expect(view.render.branches).to eq([view.render])
        end
      end

      context "when child changed" do
        it "contains the child component render" do
          view = Class.new(Component::Base) do
            nest :bar, Class.new(Component::Base) {
              param :baz
              template do |baz|
                h1 { text baz }
              end
            }
          end.new
          view.bar.update(baz: "qux")
          expect(view.render.branches).to eq([view.bar.render])
        end
      end

      context "when multiple children changed" do
        it "contains multiple child branches" do
          view = Class.new(Component::Base) do
            nest :a, Class.new(Component::Base) {
              param :foo
              template do |foo|
                h1 { text foo }
              end
            }

            nest :b, Class.new(Component::Base) {
              param :bar
              template do |bar|
                h1 { text bar }
              end
            }

            template do
              h1 { text "Parent" }
              subview :a
              subview :b
            end
          end.new
          view.a.update(foo: "baz")
          view.b.update(bar: "qux")
          branches = view.render.branches
          expect(branches).not_to include(view.render)
          expect(branches).to include(view.a.render)
          expect(branches).to include(view.b.render)
        end
      end
    end

  end
end