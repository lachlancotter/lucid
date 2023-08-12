require "lucid/view"
require "lucid/route"

module Lucid
  describe View do

    # ===================================================== #
    #    State
    # ===================================================== #

    describe ".state" do
      it "defines attributes" do
        view = Class.new(View) do
          state do
            attribute :foo
          end
        end.new
        expect(view.state).to have_attributes(foo: nil)
      end

      it "sets defaults" do
        view = Class.new(View) do
          state do
            attribute :foo, default: "bar"
          end
        end.new
        expect(view.state).to have_attributes(foo: "bar")
      end
    end

    describe "validation" do
      context "valid state" do
        it "coerces the input" do
          view = Class.new(View) do
            state do
              attribute :count
              validate do
                required(:count).filled(:integer)
              end
            end
          end.new(count: "1")
          expect(view.state.count).to eq(1)
        end
      end

      context "invalid state" do

      end
    end

    # ===================================================== #
    #    Store
    # ===================================================== #

    describe ".store" do

    end

    # ===================================================== #
    #    Config
    # ===================================================== #

    describe ".config" do
      context "default" do
        it "sets the default" do
          view = Class.new(View) do
            config do
              option :foo, "bar"
            end
          end.new
          expect(view.foo).to eq("bar")
        end
      end

      context "override" do
        it "overrides the default" do
          view = Class.new(View) do
            config do
              option :foo, "bar"
            end
          end.new do |config|
            config.foo = "baz"
          end
          expect(view.foo).to eq("baz")
        end
      end
    end

    # ===================================================== #
    #    Routes
    # ===================================================== #

    describe "#routes" do
      it "returns the route map" do
        view = Class.new(View) do
          route { path :foo }
        end.new
        expect(view.routes).to be_a(Route::Map)
        expect(view.routes.rules.first).to be_a(Route::Map::Path)
        expect(view.routes.rules.first.key).to eq(:foo)
      end
    end

    # ===================================================== #
    #    Links
    # ===================================================== #

    describe ".link" do
      it 'defines a link' do
        view = Class.new(View) do
          link :foo
        end.new
        expect(view.foo).to be_a(Link)
      end
    end

    # ===================================================== #
    #    Actions
    # ===================================================== #

    describe ".post" do
      context "class reference" do
        it 'defines a post action' do
          action_class = Class.new(Action)
          view         = Class.new(View) do
            post :foo, action_class
          end.new
          # expect(view.foo).to be_a(View::Endpoint)
          expect(view.foo.action_method).to eq(:post)
          expect(view.foo.action_route.to_s).to eq("/")
          expect(view.foo.action_name.to_s).to eq("/foo")
          expect(view.foo.action_class).to eq(action_class)
        end
      end

      context "with a root path" do
        it 'includes the root path' do
          action_class = Class.new(Action)
          view_class   = Class.new(View) do
            post :foo, action_class
          end
          view         = view_class.new do |config|
            config.app_root = "/bar"
          end
          expect(view.app_root).to eq("/bar")
          expect(view.foo.action_route.to_s).to eq("/")
          expect(view.foo.action_name.to_s).to eq("/foo")
          expect(view.foo.action_class).to eq(action_class)
        end
      end

      context "inline definition" do
        it 'defines a post action' do
          view = Class.new(View) do
            post :foo do
              def call
                "bar"
              end
            end
          end.new
          # expect(view.foo).to be_a(View::Endpoint)
          expect(view.foo.action_method).to eq(:post)
          expect(view.foo.action_route.to_s).to eq("/")
          expect(view.foo.action_name.to_s).to eq("/foo")
          expect(view.foo.action_class.new({}).call).to eq("bar")
        end
      end
    end

    describe ".perform_action" do
      context "top level action" do
        it "performs the action" do
          action_class = Class.new(Action)
          view = Class.new(View) do
            post :foo, action_class
          end.new
          expect_any_instance_of(action_class).to receive(:call)
          view.perform_action("/foo", {})
        end
      end

      context "nested action" do
        it "performs the action" do
          action_class = Class.new(Action)
          view = Class.new(View) do
            nest :bar do
              post :foo, action_class
            end
          end.new
          expect_any_instance_of(action_class).to receive(:call)
          view.perform_action("/bar/foo", {})
        end
      end
    end

    # ===================================================== #
    #    Templates
    # ===================================================== #

    describe ".template" do
      it "defines a template" do
        view = Class.new(View) do
          template :foo do
            "Hello, World"
          end
        end.new
        expect(view.templates[:foo]).to be_a(Proc)
      end

      it "renders the template" do
        view = Class.new(View) do
          template :foo do
            "Hello, World"
          end
        end.new
        expect(view.templates[:foo].call).to eq("Hello, World")
      end
    end

    describe "#render" do
      it "renders the main template" do
        view = Class.new(View) do
          template do
            "Main template content"
          end
        end.new
        expect(view.render).to eq("Main template content")
      end
    end
    
    # ===================================================== #
    #    Nesting
    # ===================================================== #

    describe ".nest" do
      it "nests a child component" do
        view = Class.new(View) do
          nest :foo do
            def render
              "Nested"
            end
          end
        end.new
        expect(view.foo).to be_a(View)
      end
    end

    # ===================================================== #
    #    Rendering
    # ===================================================== #

    describe "#to_s" do
      it "renders the view" do
        view = Class.new(View) do
          def render
            "Hello, World"
          end
        end.new
        expect(view.to_s).to eq("Hello, World")
      end
    end

  end
end



