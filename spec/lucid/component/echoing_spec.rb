module Lucid
  module Component
    describe Echoing do

      def mock_post_params (form_name, params)
        form_data = URI.encode_www_form(params.merge(:form_name => form_name))
        {
           "REQUEST_METHOD" => "POST",
           "CONTENT_TYPE"   => "application/x-www-form-urlencoded",
           "CONTENT_LENGTH" => form_data.bytesize.to_s,
           "rack.input"     => StringIO.new(form_data),
        }
      end

      def mock_get_params (form_name, params)
        form_data = URI.encode_www_form(params.merge(:form_name => form_name))
        {
           "REQUEST_METHOD" => "GET",
           "QUERY_STRING"   => form_data,
           "rack.input"     => "",
        }
      end

      it "provides a form model" do
        message_class   = Class.new(Lucid::Command)
        component_class = Class.new(Base) { echo :form_name, message_class }
        env             = mock_post_params(:form_name, { foo: "bar" })
        component       = component_class.new({}, env: env)
        expect(component.forms[:form_name]).to be_a(Lucid::HTML::FormModel)
        expect(component.forms[:form_name].message_type).to eq(message_class)
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
      end

      context "request contains another form" do
        it "filters form params for the other form" do
          message_class   = Class.new(Lucid::Command)
          component_class = Class.new(Base) { echo :form_name, message_class }
          env             = mock_post_params(:other_form, { foo: "bar" })
          component       = component_class.new({}, env: env)
          expect(component.forms[:form_name].to_h).to eq({})
        end
      end

    end
  end
end