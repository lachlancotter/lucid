module Lucid
  module Component
    describe Echoing do

      def encode_form_data (form_name, params)
        URI.encode_www_form(
           case form_name
           when Symbol then params.merge(:form_name => form_name)
           else params
           end
        )
      end

      def mock_post_params (form_name, params)
        form_data = encode_form_data(form_name, params)
        {
           "REQUEST_METHOD" => "POST",
           "CONTENT_TYPE"   => "application/x-www-form-urlencoded",
           "CONTENT_LENGTH" => form_data.bytesize.to_s,
           "rack.input"     => StringIO.new(form_data),
        }
      end

      def mock_get_params (form_name, params)
        form_data = encode_form_data(form_name, params)
        {
           "REQUEST_METHOD" => "GET",
           "QUERY_STRING"   => form_data,
           "rack.input"     => "",
        }
      end

      context "always" do
        it "provides a form model" do
          message_class   = Class.new(Lucid::Command)
          component_class = Class.new(Base) { echo :form_name, message_class }
          env             = mock_post_params(:form_name, { foo: "bar" })
          component       = component_class.new({}, env: env)
          expect(component.forms[:form_name]).to be_a(Lucid::HTML::FormModel)
          expect(component.forms[:form_name].message_type).to eq(message_class)
        end
        
        # Message needs to have a constant name.
        TestCommand = Class.new(Lucid::Command)

        it "echos the form state to the template" do
          component_class = Class.new(Base) do
            echo :form_name, TestCommand
            element do |form_name|
              form_for form_name do |f|
                emit f.text(:foo)
              end
            end
          end
          env             = mock_post_params(:form_name, { foo: "bar" })
          component       = component_class.new({}, env: env)
          render          = component.render_full
          expect(render).to include("name=\"foo\"")
          expect(render).to include("value=\"bar\"")
        end
      end

      context "with default params" do
        it "provides the default params to the form" do
          message_class   = Class.new(Lucid::Command)
          component_class = Class.new(Base) do
            echo(:form_name, message_class) do |form|
              form.or_default({ "foo" => "default" })
            end
          end
          env             = mock_post_params(nil, {})
          component       = component_class.new({}, env: env)
          expect(component.forms[:form_name].to_h).to eq({ "foo" => "default" })
        end
      end

      context "with param filter" do
        it "filters out the specified keys" do
          message_class   = Class.new(Lucid::Command)
          component_class = Class.new(Base) { echo :credentials, message_class, except: :password }
          env             = mock_post_params(:credentials, { "email" => "foo", "password" => "bar" })
          component       = component_class.new({}, env: env)
          expect(component.forms[:credentials].to_h).to eq({ "email" => "foo" })
        end
      end

      context "GET message" do
        it "provides the GET params" do
          message_class   = Class.new(Lucid::Link)
          component_class = Class.new(Base) { echo :form_name, message_class }
          env             = mock_get_params(:form_name, { foo: "bar" })
          component       = component_class.new({}, env: env)
          expect(component.forms[:form_name].to_h).to eq({ "foo" => "bar" })
        end
      end

      context "POST message" do
        it "provides the POST params" do
          message_class   = Class.new(Lucid::Command)
          component_class = Class.new(Base) { echo :form_name, message_class }
          env             = mock_post_params(:form_name, { foo: "bar" })
          component       = component_class.new({}, env: env)
          expect(component.forms[:form_name].to_h).to eq({ "foo" => "bar" })
        end
      end

      context "request contains this form" do
        it "provides form params from the request" do
          message_class   = Class.new(Lucid::Command)
          component_class = Class.new(Base) { echo :form_name, message_class }
          env             = mock_post_params(:form_name, { foo: "bar" })
          component       = component_class.new({}, env: env)
          expect(component.forms[:form_name].to_h).to eq({ "foo" => "bar" })
        end

        it "triggers form dependencies" do
          called          = false
          message_class   = Class.new(Lucid::Command)
          component_class = Class.new(Base) do
            echo :form_name, message_class
            watch(:form_name) { called = true }
          end
          env             = mock_post_params(:form_name, { foo: "bar" })
          component       = component_class.new({}, env: env)
          expect(called).to be_truthy
        end
      end

      context "request contains another form" do
        it "filters form params for the other form" do
          message_class   = Class.new(Lucid::Command)
          component_class = Class.new(Base) { echo :form_name, message_class }
          env             = mock_post_params(:other_form, { foo: "bar" })
          component       = component_class.new({}, env: env)
          expect(component.forms[:form_name].to_h).to eq({})
        end

        it "does not trigger form dependencies" do
          called          = false
          message_class   = Class.new(Lucid::Command)
          component_class = Class.new(Base) do
            echo :form_name, message_class
            watch(:form_name) { called = true }
          end
          env             = mock_post_params(:another_form, { foo: "bar" })
          component       = component_class.new({}, env: env)
          expect(called).to be_falsey
        end
      end

    end
  end
end