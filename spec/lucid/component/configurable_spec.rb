require "lucid/configurable"
require "lucid/component/base"

module Lucid
  describe Configurable do

    context "default" do
      it "sets the default" do
        view = Class.new(Component::Base) do
          setting :foo, default: "bar"
        end.new
        expect(view.config.foo).to eq("bar")
      end
    end

    context "override" do
      it "overrides the default" do
        view = Class.new(Component::Base) do
          setting :foo, default: "bar"
        end.new.configure do |config|
          config.foo = "baz"
        end
        expect(view.config.foo).to eq("baz")
      end
    end

    context "standard" do
      it "has a path" do
        view = Class.new(Component::Base).new
        expect(view.config.path).to eq("/")
        expect(view.config[:path]).to eq("/")
      end

      it "has a root" do
        view = Class.new(Component::Base).new
        expect(view.config.app_root).to eq("/")
        expect(view.config[:app_root]).to eq("/")
      end
    end

    context "inheritance" do
      it "inherits defaults from parent class" do
        super_class = Class.new(Component::Base) do
          setting :foo, default: "bar"
        end
        sub_class   = Class.new(super_class)
        view        = sub_class.new
        expect(view.config[:foo]).to eq("bar")
      end

      it "declares new values in subclasses" do
        super_class = Class.new(Component::Base) do
          setting :foo, default: "bar"
        end
        sub_class = Class.new(super_class) do
          setting :baz, default: "qux"
        end
        view     = sub_class.new
        expect(view.config[:foo]).to eq("bar")
        expect(view.config[:baz]).to eq("qux")
      end
    end

  end
end