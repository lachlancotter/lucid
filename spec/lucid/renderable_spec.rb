module Lucid
  describe Renderable do
    describe "render" do
      describe "default template" do
        it "renders" do
          renderable = Class.new do
            include Renderable
            template do
              h1 { text "Hello, World" }
            end
          end.new
          expect(renderable.render).to match(/<h1>Hello, World<\/h1>/)
        end
      end

      describe "named template" do
        it "renders" do
          renderable = Class.new do
            include Renderable
            template :foo do
              h1 { text "Hello, World" }
            end
          end.new
          expect(renderable.template(:foo).render).to match(/<h1>Hello, World<\/h1>/)
        end
      end

      describe "template with args" do
        it "renders" do
          renderable = Class.new do
            include Renderable
            template do |name|
              h1 { text "Hello, #{name}" }
            end
          end.new
          expect(renderable.template.render("World")).to match(/<h1>Hello, World<\/h1>/)
        end
      end

      describe "template with context" do
        it "renders" do
          renderable = Class.new do
            include Renderable
            template do
              h1 { text "Hello, #{name}" }
            end
            def name
              "World"
            end
          end.new
          expect(renderable.render).to match(/<h1>Hello, World<\/h1>/)
        end
      end

      describe "context with name collision" do
        it "renders" do
          renderable = Class.new do
            include Renderable
            template do
              h1 { text "Hello, #{label}" }
            end
            def label
              "World"
            end
          end.new
          expect(renderable.render).to match(/<h1>Hello, World<\/h1>/)
        end
      end
    end
  end
end