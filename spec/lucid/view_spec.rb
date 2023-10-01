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
            expect(view.foo.action_route.to_s).to eq("/bar/")
            expect(view.foo.action_name.to_s).to eq("/foo")
            expect(view.foo.action_class).to eq(action_class)
          end
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

        context "with view configuration" do
          it 'inherits the configuration' do
            view = Class.new(View) do
              config do
                option :bar, "baz"
              end
              post :foo do
                def call
                  "bar"
                end
              end
            end.new
            expect(view.foo.build({}).bar).to eq("baz")
          end
        end
      end
    end

    describe ".get_action" do
      context "top level action" do
        it "returns the action" do
          action_class = Class.new(Action)
          view         = Class.new(View) do
            post :foo, action_class
          end.new
          endpoint     = view.get_action("/foo")
          expect(endpoint).to be_a(Endpoint)
          expect(endpoint.action_class).to eq(action_class)
        end
      end

      context "nested action" do
        it "returns the action" do
          action_class = Class.new(Action)
          view         = Class.new(View) do
            nest :bar do
              post :foo, action_class
            end
          end.new
          endpoint     = view.get_action("/bar/foo")
          expect(endpoint).to be_a(Endpoint)
          expect(endpoint.action_class).to eq(action_class)
        end
      end

      context "nested in collection" do
        it "returns the action" do
          action_class = Class.new(Action)
          view         = Class.new(View) do
            nest :bar, in: [1, 2] do
              post :foo, action_class
            end
          end
          endpoint     = view.new.get_action("/bar[1]/foo")
          expect(endpoint).to be_a(Endpoint)
          expect(endpoint.action_class).to eq(action_class)
        end
      end
    end

    describe ".perform_action" do
      context "top level action" do
        it "performs the action" do
          action_class = Class.new(Action)
          view         = Class.new(View) do
            post :foo, action_class
          end.new
          expect_any_instance_of(action_class).to receive(:call)
          view.perform_action("/foo", {})
        end
      end

      context "nested action" do
        it "performs the action" do
          action_class = Class.new(Action)
          view         = Class.new(View) do
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
      context "main template" do
        it "renders the main template" do
          view = Class.new(View) do
            state { attribute :name }
            template { div { text "Hello, #{state.name}" } }
          end.new(name: "World")
          expect(view.template.render).to eq("<div>Hello, World</div>")
        end
      end
    end

    # ===================================================== #
    #    Nesting
    # ===================================================== #

    describe ".nest" do
      context "inline" do
        it "nests a child component" do
          view = Class.new(View) do
            nest :foo do
              def render
                "Nested"
              end
            end
          end.new
          expect(view.foo).to be_a(View)
          ap view.foo.method(:render)
          expect(view.foo.render).to eq("Nested")
        end

        it "nests a child component over an array" do
          view = Class.new(View) do
            nest :foo, in: %w[english spanish], as: :bar do
              def render
                "Nested #{@config[:bar]}"
              end
            end
          end.new do |config|
            config.app_root = "/app/root"
          end

          expect(view.foo(0)).to be_a(View)
          expect(view.foo(0).render).to eq("Nested english")
          expect(view.foo(0).config.app_root).to eq("/app/root")
          expect(view.foo(0).config.path).to eq("/foo[0]")
          expect(view.foo(0).config.bar).to eq("english")

          expect(view.foo(1)).to be_a(View)
          expect(view.foo(1).render).to eq("Nested spanish")
          expect(view.foo(1).config.app_root).to eq("/app/root")
          expect(view.foo(1).config.path).to eq("/foo[1]")
          expect(view.foo(1).config.bar).to eq("spanish")
        end

        it "nests a child component over a collection reference" do
          view = Class.new(View) do
            def languages
              %w[english spanish]
            end

            nest :foo, in: :languages, as: :bar do
              def render
                "Nested #{@config[:bar]}"
              end
            end
          end.new do |config|
            config.app_root = "/app/root"
          end
          expect(view.foo(0)).to be_a(View)
          expect(view.foo(0).render).to eq("Nested english")
          expect(view.foo(0).config.app_root).to eq("/app/root")
          expect(view.foo(0).config.path).to eq("/foo[0]")
          expect(view.foo(0).config.bar).to eq("english")

          expect(view.foo(1)).to be_a(View)
          expect(view.foo(1).render).to eq("Nested spanish")
          expect(view.foo(1).config.app_root).to eq("/app/root")
          expect(view.foo(1).config.path).to eq("/foo[1]")
          expect(view.foo(1).config.bar).to eq("spanish")
        end
      end

      context "named constant" do
        class NamedNestedView < View
          def render
            "Nested #{@config[:bar]}"
          end
        end

        it "nests a child component" do
          view = Class.new(View) do
            nest :foo, NamedNestedView
          end.new
          expect(view.foo).to be_a(View)
        end

        it "nests a child component over an array" do
          view = Class.new(View) do
            nest :foo, NamedNestedView, in: %w[english spanish], as: :bar
          end.new do |config|
            config.app_root = "/app/root"
          end

          expect(view.foo(0)).to be_a(View)
          expect(view.foo(0).render).to eq("Nested english")
          expect(view.foo(0).config.app_root).to eq("/app/root")
          expect(view.foo(0).config.path).to eq("/foo[0]")
          expect(view.foo(0).config.bar).to eq("english")

          expect(view.foo(1)).to be_a(View)
          expect(view.foo(1).render).to eq("Nested spanish")
          expect(view.foo(1).config.app_root).to eq("/app/root")
          expect(view.foo(1).config.path).to eq("/foo[1]")
          expect(view.foo(1).config.bar).to eq("spanish")
        end

      end
    end

    # ===================================================== #
    #    Rendering
    # ===================================================== #

    describe "#render" do
      it "renders the view" do
        view = Class.new(View) do
          def render
            "Hello, World"
          end
        end.new
        expect(view.render).to eq("Hello, World")
      end
    end

  end
end



