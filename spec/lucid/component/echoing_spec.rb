module Lucid
  module Component
    describe Echoing do

      def encode_form_data (component_path, form_name, params)
        URI.encode_www_form(params.merge(component: component_path, form: form_name))
      end

      def mock_post_params (component_path, form_name, params)
        form_data = encode_form_data(component_path, form_name, params)
        {
           "REQUEST_METHOD" => "POST",
           "CONTENT_TYPE"   => "application/x-www-form-urlencoded",
           "CONTENT_LENGTH" => form_data.bytesize.to_s,
           "rack.input"     => StringIO.new(form_data),
        }
      end

      def mock_get_params (component_path, form_name, params)
        form_data = encode_form_data(component_path, form_name, params)
        {
           "REQUEST_METHOD" => "GET",
           "QUERY_STRING"   => form_data,
           "rack.input"     => "",
        }
      end

      context "always" do
        it "provides a form model" do
          message_class   = Class.new(Lucid::Command)
          component_class = Class.new(Component::Base) { echo :foo_form, message_class }
          env             = mock_post_params("/", :foo_form, { foo: "bar" })
          component       = component_class.new({}, env: env)
          expect(component.forms[:foo_form]).to be_a(HTTP::FormModel)
          expect(component.forms[:foo_form].message_type).to eq(message_class)
        end

        # Message needs to have a constant name.
        TestCommand = Class.new(Lucid::Command)

        it "echos the form state to the template" do
          component_class = Class.new(Component::Base) do
            echo :foo_form, TestCommand
            element do |foo_form|
              form_for foo_form do |f|
                emit f.text(:foo)
              end
            end
          end
          env             = mock_post_params("/", :foo_form, { foo: "bar" })
          component       = component_class.new({}, env: env)
          render          = component.render_full
          expect(render).to include("name=\"foo\"")
          expect(render).to include("value=\"bar\"")
        end

        it "echos the component path to the form" do
          component_class = Class.new(Component::Base) do
            echo :foo_form, TestCommand
            element do |foo_form|
              form_for foo_form do |f|
                emit f.text(:foo)
              end
            end
          end
          env             = mock_post_params("/", :foo_form, { foo: "bar" })
          component       = component_class.new({}, env: env)
          render          = component.render_full
          expect(render).to include("name=\"component\"")
          expect(render).to include("value=\"/\"")
          expect(render).to include("name=\"form\"")
          expect(render).to include("value=\"foo_form\"")
        end
      end

      context "with default params" do
        it "provides the default params to the form" do
          message_class   = Class.new(Lucid::Command)
          component_class = Class.new(Component::Base) do
            echo(:foo_form, message_class) do |form|
              form.or_default({ foo: "default" })
            end
          end
          env             = mock_post_params("/", nil, {})
          component       = component_class.new({}, env: env)
          expect(component.forms[:foo_form].to_h).to eq({ foo: "default" })
        end
      end

      context "with param filter" do
        it "filters out the specified keys" do
          message_class   = Class.new(Lucid::Command)
          component_class = Class.new(Component::Base) { echo :credentials, message_class, except: :password }
          env             = mock_post_params("/", :credentials, { email: "foo", password: "bar" })
          component       = component_class.new({}, env: env)
          expect(component.forms[:credentials].to_h).to eq({ email: "foo" })
        end
      end

      context "GET message" do
        it "provides the GET params" do
          message_class   = Class.new(Lucid::Link)
          component_class = Class.new(Component::Base) { echo :foo_form, message_class }
          env             = mock_get_params("/", :foo_form, { foo: "bar" })
          component       = component_class.new({}, env: env)
          expect(component.forms[:foo_form].to_h).to eq({ foo: "bar" })
        end
      end

      context "POST message" do
        it "provides the POST params" do
          message_class   = Class.new(Lucid::Command)
          component_class = Class.new(Component::Base) { echo :foo_form, message_class }
          env             = mock_post_params("/", :foo_form, { foo: "bar" })
          component       = component_class.new({}, env: env)
          expect(component.forms[:foo_form].to_h).to eq({ foo: "bar" })
        end
      end

      context "request contains this form" do
        it "provides form params from the request" do
          message_class   = Class.new(Lucid::Command)
          component_class = Class.new(Component::Base) { echo :foo_form, message_class }
          env             = mock_post_params("/", :foo_form, { foo: "bar" })
          component       = component_class.new({}, env: env)
          expect(component.forms[:foo_form].to_h).to eq({ foo: "bar" })
        end

        it "triggers form dependencies" do
          called          = false
          message_class   = Class.new(Lucid::Command)
          component_class = Class.new(Component::Base) do
            echo :foo_form, message_class
            watch(:foo_form) { called = true }
          end
          env             = mock_post_params("/", :foo_form, { foo: "bar" })
          component       = component_class.new({}, env: env)
          expect(called).to be_truthy
        end
      end

      context "request contains another form" do
        it "filters form params for the other form" do
          message_class   = Class.new(Lucid::Command)
          component_class = Class.new(Component::Base) { echo :foo_form, message_class }
          env             = mock_post_params("/", :other_form, { foo: "bar" })
          component       = component_class.new({}, env: env)
          expect(component.forms[:foo_form].to_h).to eq({})
        end

        it "does not trigger form dependencies" do
          called          = false
          message_class   = Class.new(Lucid::Command)
          component_class = Class.new(Component::Base) do
            echo :foo_form, message_class
            watch(:foo_form) { called = true }
          end
          env             = mock_post_params("/", :bar_form, { foo: "bar" })
          component       = component_class.new({}, env: env)
          expect(called).to be_falsey
        end
      end

      context "request is from another component" do
        it "filters form params for the other component" do
          message_class        = Class.new(Lucid::Command)
          component_class      = Class.new(Component::Base) { echo :foo_form, message_class }
          root_component_class = Class.new(Component::Base) do
            nest(:component1) { component_class }
            nest(:component2) { component_class }
          end
          env                  = mock_post_params("/component1", :foo_form, { foo: "bar" })
          root_component       = root_component_class.new({}, env: env)
          source_component     = root_component.component1
          other_component      = root_component.component2
          expect(source_component.forms[:foo_form].to_h).to eq({ foo: "bar" })
          expect(other_component.forms[:foo_form].to_h).to eq({})
        end

        it "does not trigger form dependencies" do
          called               = 0
          message_class        = Class.new(Lucid::Command)
          component_class      = Class.new(Component::Base) do
            echo :foo_form, message_class
            watch(:foo_form) { called += 1 }
          end
          root_component_class = Class.new(Component::Base) do
            nest(:component1) { component_class }
            nest(:component2) { component_class }
          end
          env                  = mock_post_params("/component1", :foo_form, { foo: "bar" })
          root_component       = root_component_class.new({}, env: env)
          expect(called).to eq(1)
        end
      end

    end
  end
end