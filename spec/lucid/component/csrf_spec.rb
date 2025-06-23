module Lucid
  module Component
    describe "CSRF" do
      context "#form_for" do
        it "includes the CSRF token" do
          component_class = Class.new(Component::Base) do
            echo :foo, Link
            element do |foo|
              form_for(foo) {}
            end
          end
          container       = App::Container.new({ csrf_token: "foo_token" }, {})
          component       = component_class.new({}, container: container)
          expect(component.render_full).to include('<input type="hidden" name="authenticity_token" value="foo_token"')
        end
      end

      context "#button_to" do
        it "includes the CSRF token" do
          component_class = Class.new(Component::Base) do
            element do
              button_to Link.new, "Click Me"
            end
          end
          container       = App::Container.new({ csrf_token: "foo_token" }, {})
          component       = component_class.new({}, container: container)
          expect(component.render_full).to include('<input type="hidden" name="authenticity_token" value="foo_token"')
        end
      end

    end
  end
end