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



