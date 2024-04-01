module Lucid
  describe Renderable do
    describe "render" do
      describe "default template" do
        it "renders" do
          view = Class.new(Component::Base) do
            template do
              h1 { text "Hello, World" }
            end
          end.new
          expect(view.render).to match(/<h1>Hello, World<\/h1>/)
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
          expect(view.render).to match(/<h1>Hello, World<\/h1>/)
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
          expect(view.render).to match(/<h1>Hello, World<\/h1>/)
        end
      end
    end

    describe "#changed?" do
      it "is false when created" do
        view = Class.new(Component::Base) do
          param :foo
        end.new(foo: "foo")
        expect(view.changed?).to be(false)
      end

      it "is true when template state dependencies change" do
        view = Class.new(Component::Base) do
          param :foo
          template do |foo|
            h1 { text foo }
          end
        end.new(foo: "foo")
        view.update(foo: "bar")
        expect(view.changed?).to be(true)
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
        expect(view.changed?).to be(true)
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
        expect(view.changed?).to be(false)
        expect(view.bar.changed?).to be(true)
      end

      it "is false when template dependencies are unchanged" do
        view = Class.new(Component::Base) do
          param :foo
          template do
            h1 { "Test" }
          end
        end.new(foo: "foo")
        view.update(foo: "bar")
        expect(view.changed?).to be(false)
      end
    end

  end
end