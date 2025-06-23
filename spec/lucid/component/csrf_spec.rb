module Lucid
  module Component
    describe "CSRF" do
      it "includes the CSRF token in forms" do
        component_class = Class.new(Component::Base) do
          echo :foo, Link
          element do |foo|
            form_for(foo) {}
          end
        end
        container       = App::Container.new({ csrf_token: "foo_token" }, {})
        component       = component_class.new({}, container: container)
        expect(component.render_full).to include('<input type="hidden" name="_csrf_token" value="foo_token"')
      end
    end
  end
end