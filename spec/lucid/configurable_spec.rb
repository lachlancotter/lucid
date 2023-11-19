require "lucid/configurable"

module Lucid
  describe Configurable do

    context "default" do
      it "sets the default" do
        view = Class.new(Component) do
          config do
            option :foo, "bar"
          end
        end.new
        expect(view.foo).to eq("bar")
      end
    end

    context "override" do
      it "overrides the default" do
        view = Class.new(Component) do
          config do
            option :foo, "bar"
          end
        end.new do |config|
          config.foo = "baz"
        end
        expect(view.foo).to eq("baz")
      end
    end

    context "standard" do
      it "has a path" do
        view = Class.new(Component).new
        expect(view.path).to eq("/")
        expect(view.config[:path]).to eq("/")
      end

      it "has a root" do
        view = Class.new(Component).new
        expect(view.app_root).to eq("/")
        expect(view.config[:app_root]).to eq("/")
      end
    end

    context "multiple config blocks" do
      it "combines the config options" do
        view = Class.new(Component) do
          config do
            option :foo, "bar"
          end
          config do
            option :baz, "qux"
          end
        end.new
        expect(view.foo).to eq("bar")
        expect(view.baz).to eq("qux")
      end
    end

    context "inheritance" do
      it "inherits defaults from parent class" do
        view = Class.new(Component) do
          config do
            option :foo, "bar"
          end
        end.new
        expect(view.config[:path]).to eq("/")
        expect(view.config[:app_root]).to eq("/")
      end
    end

  end
end