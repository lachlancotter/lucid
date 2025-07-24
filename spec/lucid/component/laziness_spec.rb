module Lucid
  describe Component::Base do
    it "evaluates signals lazily" do
      called          = false
      component_class = Class.new(Component::Base) do
        let(:foo) { called = true; "bar" }
        element { |foo| text foo }
      end
      component       = component_class.new({})
      expect(called).to be false
      expect(component.render_full).to match /bar/
    end

    it "passes signals by reference" do
      called             = false
      subcomponent_class = Class.new(Component::Base) do
        prop :foo, String
        element { |foo| text foo }
      end
      component_class    = Class.new(Component::Base) do
        let(:bar) { called = true; "bar" }
        nest(:sub) { subcomponent_class[foo: :bar] }
        element { subview :sub }
      end
      component          = component_class.new({})
      expect(called).to be false
      expect(component.render_full).to match /bar/
    end

    it "invalidates signals via state" do
      called          = false
      component_class = Class.new(Component::Base) do
        param :foo, Types.string
        let(:bar) { |foo| called = true; foo.upcase }
        element { |bar| text bar }
      end
      component       = component_class.new({ foo: "foo" })
      component.update(foo: "bar")
      expect(called).to be false
      expect(component.render_full).to match /BAR/
    end
  end
end