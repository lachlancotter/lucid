module Lucid
  module Component
    describe Dependencies do
      class TestDependencyContainer < App::Container
        provide(:foo) { "bar" }
      end

      it "resolves declared dependencies from the container" do
        component_class = Class.new(Component::Base) { use :foo, Types.string }
        component       = component_class.new({}, container: TestDependencyContainer.new({}, {}))
        expect(component.foo).to eq("bar")
      end

      it "validates declared dependency types" do
        container_class = Class.new(App::Container) { provide(:foo) { 123 } }
        component_class = Class.new(Component::Base) { use :foo, Types.string }
        component       = component_class.new({}, container: container_class.new({}, {}))

        expect { component.foo }.to raise_error(Dry::Types::ConstraintError)
      end

      it "inherits dependency declarations" do
        component_superclass = Class.new(Component::Base) { use :foo, Types.string }
        component_class      = Class.new(component_superclass)
        component            = component_class.new({}, container: TestDependencyContainer.new({}, {}))
        expect(component.foo).to eq("bar")
      end

      it "allows optional dependencies to be absent" do
        component_class = Class.new(Component::Base) { use :foo, Types.string.optional }
        component       = component_class.new({})
        expect(component.foo).to be_nil
      end

      it "raises when a required dependency is absent" do
        component_class = Class.new(Component::Base) { use :foo, Types.string }
        expect { component_class.new({}) }.to raise_error(Dependencies::MissingDependency)
      end

      it "exposes the HTTP session dependency" do
        component = Component::Base.new({})
        expect(component.http_session).to be_a(App::Session)
      end
    end
  end
end
