module Lucid
  module HTML
    describe Form::Builder do

      describe "#text" do
        context "implicit value" do
          it "renders a text field with the value from the model" do
            message_type = Class.new(HTTP::Message)
            params       = HTTP::FormModel.new(message_type, { foo: "model_value" })
            renderer     = Template::RenderContext.new(nil) {}
            builder      = Form::Builder.new(renderer, params)
            result       = builder.text(:foo)
            expect(result).to match('type="text"')
            expect(result).to match('name="foo"')
            expect(result).to match('value="model_value"')
          end
        end

        context "explicit value" do
          it "renders a text field with the given value" do
            message_type = Class.new(HTTP::Message)
            params       = HTTP::FormModel.new(message_type, { foo: "model_value" })
            renderer     = Template::RenderContext.new(nil) {}
            builder      = Form::Builder.new(renderer, params)
            result       = builder.text(:foo, value: "explicit_value")
            expect(result).to match('type="text"')
            expect(result).to match('name="foo"')
            expect(result).to match('value="explicit_value"')
          end
        end
      end

      describe "#email" do
        context "implicit value" do
          it "renders an email field with the value from the model" do
            message_type = Class.new(HTTP::Message)
            params       = HTTP::FormModel.new(message_type, { foo: "person@example.com" })
            renderer     = Template::RenderContext.new(nil) {}
            builder      = Form::Builder.new(renderer, params)
            result       = builder.email(:foo)
            expect(result).to match('type="email"')
            expect(result).to match('name="foo"')
            expect(result).to match('value="person@example.com"')
          end
        end

        context "explicit value" do
          it "renders an email field with the given value" do
            message_type = Class.new(HTTP::Message)
            params       = HTTP::FormModel.new(message_type, { foo: "person@example.com" })
            renderer     = Template::RenderContext.new(nil) {}
            builder      = Form::Builder.new(renderer, params)
            result       = builder.email(:foo, value: "admin@example.com")
            expect(result).to match('type="email"')
            expect(result).to match('name="foo"')
            expect(result).to match('value="admin@example.com"')
          end
        end
      end

      describe "#date" do
        context "implicit value" do
          it "renders a date field with the value from the model" do
            message_type = Class.new(HTTP::Message)
            params       = HTTP::FormModel.new(message_type, { foo: "2026-05-04" })
            renderer     = Template::RenderContext.new(nil) {}
            builder      = Form::Builder.new(renderer, params)
            result       = builder.date(:foo)
            expect(result).to match('type="date"')
            expect(result).to match('name="foo"')
            expect(result).to match('value="2026-05-04"')
          end
        end

        context "explicit value" do
          it "renders a date field with the given value" do
            message_type = Class.new(HTTP::Message)
            params       = HTTP::FormModel.new(message_type, { foo: "2026-05-04" })
            renderer     = Template::RenderContext.new(nil) {}
            builder      = Form::Builder.new(renderer, params)
            result       = builder.date(:foo, value: "2026-06-01")
            expect(result).to match('type="date"')
            expect(result).to match('name="foo"')
            expect(result).to match('value="2026-06-01"')
          end
        end
      end

      describe "#number" do
        context "implicit value" do
          it "renders a number field with the value from the model" do
            message_type = Class.new(HTTP::Message)
            params       = HTTP::FormModel.new(message_type, { foo: 42 })
            renderer     = Template::RenderContext.new(nil) {}
            builder      = Form::Builder.new(renderer, params)
            result       = builder.number(:foo)
            expect(result).to match('type="number"')
            expect(result).to match('name="foo"')
            expect(result).to match('value="42"')
          end
        end

        context "explicit value" do
          it "renders a number field with the given value" do
            message_type = Class.new(HTTP::Message)
            params       = HTTP::FormModel.new(message_type, { foo: 42 })
            renderer     = Template::RenderContext.new(nil) {}
            builder      = Form::Builder.new(renderer, params)
            result       = builder.number(:foo, value: 7)
            expect(result).to match('type="number"')
            expect(result).to match('name="foo"')
            expect(result).to match('value="7"')
          end
        end
      end

      describe "#checkbox" do
        context "implicit boolean value" do
          it "renders a checked checkbox when the model value is true" do
            message_type = Class.new(HTTP::Message)
            params       = HTTP::FormModel.new(message_type, { foo: true })
            renderer     = Template::RenderContext.new(nil) {}
            builder      = Form::Builder.new(renderer, params)
            result       = builder.checkbox(:foo)
            expect(result).to match('type="checkbox"')
            expect(result).to match('name="foo"')
            expect(result).to match('value="1"')
            expect(result).to match('checked')
          end
        end

        context "implicit matching value" do
          it "renders a checked checkbox when the model value matches the checkbox value" do
            message_type = Class.new(HTTP::Message)
            params       = HTTP::FormModel.new(message_type, { foo: "yes" })
            renderer     = Template::RenderContext.new(nil) {}
            builder      = Form::Builder.new(renderer, params)
            result       = builder.checkbox(:foo, value: "yes")
            expect(result).to match('type="checkbox"')
            expect(result).to match('name="foo"')
            expect(result).to match('value="yes"')
            expect(result).to match('checked')
          end
        end

        context "explicit checked override" do
          it "renders a checked checkbox when checked is true" do
            message_type = Class.new(HTTP::Message)
            params       = HTTP::FormModel.new(message_type, { foo: false })
            renderer     = Template::RenderContext.new(nil) {}
            builder      = Form::Builder.new(renderer, params)
            result       = builder.checkbox(:foo, checked: true)
            expect(result).to match('type="checkbox"')
            expect(result).to match('name="foo"')
            expect(result).to match('value="1"')
            expect(result).to match('checked')
          end
        end
      end

      describe "#select" do
        context "implicit value" do
          it "renders a select field with the value from the model" do
            message_type = Class.new(HTTP::Message)
            params       = HTTP::FormModel.new(message_type, { foo: "model_value" })
            renderer     = Template::RenderContext.new(nil) {}
            builder      = Form::Builder.new(renderer, params)
            result       = builder.select(:foo) do |s|
              s.option("model_value", "Model Value")
              s.option("other_value", "Other Value")
            end
            expect(result).to match('<select')
            expect(result).to match('name="foo"')
            expect(result).to match('<option value="model_value" selected>Model Value</option>')
            expect(result).to match('<option value="other_value">Other Value</option>')
          end
        end

        context "explicit value" do
          it "renders a text field with the given value" do
            message_type = Class.new(HTTP::Message)
            params       = HTTP::FormModel.new(message_type, { foo: "model_value" })
            renderer     = Template::RenderContext.new(nil) {}
            builder      = Form::Builder.new(renderer, params)
            result       = builder.select(:foo, value: "other_value") do |s|
              s.option("model_value", "Model Value")
              s.option("other_value", "Other Value")
            end
            expect(result).to match('<select')
            expect(result).to match('name="foo"')
            expect(result).to match('<option value="model_value">Model Value</option>')
            expect(result).to match('<option value="other_value" selected>Other Value</option>')
          end
        end
      end

      describe "#textarea" do
        context "implicit value" do
          it "renders a textarea field with the value from the model" do
            message_type = Class.new(HTTP::Message)
            params       = HTTP::FormModel.new(message_type, { foo: "model_value" })
            renderer     = Template::RenderContext.new(nil) {}
            builder      = Form::Builder.new(renderer, params)
            result       = builder.textarea(:foo)
            expect(result).to match('<textarea')
            expect(result).to match('name="foo"')
            expect(result).to match('>model_value</textarea>')
          end
        end

        context "explicit value" do
          it "renders a textarea field with the given value" do
            message_type = Class.new(HTTP::Message)
            params       = HTTP::FormModel.new(message_type, { foo: "model_value" })
            renderer     = Template::RenderContext.new(nil) {}
            builder      = Form::Builder.new(renderer, params)
            result       = builder.textarea(:foo, value: "explicit_value")
            expect(result).to match('<textarea')
            expect(result).to match('name="foo"')
            expect(result).to match('explicit_value</textarea>')
          end
        end
      end

      describe "#submit" do
        context "with options" do
          it "renders the options as attributes" do
            message_type = Class.new(HTTP::Message)
            params       = HTTP::FormModel.new(message_type, {})
            renderer     = Template::RenderContext.new(nil) {}
            builder      = Form::Builder.new(renderer, params)
            result       = builder.submit("Label", class: "foo-class")
            expect(result).to match('<button')
            expect(result).to match('type="submit"')
            expect(result).to match('value="Label"')
            expect(result).to match('class="foo-class"')
          end
        end
      end

      describe "#hidden" do
        context "implicit value" do
          it "renders a hidden field with the value from the model" do
            message_type = Class.new(HTTP::Message)
            params       = HTTP::FormModel.new(message_type, { foo: "model_value" })
            renderer     = Template::RenderContext.new(nil) {}
            builder      = Form::Builder.new(renderer, params)
            result       = builder.hidden(:foo)
            expect(result).to match('type="hidden"')
            expect(result).to match('name="foo"')
            expect(result).to match('value="model_value"')
          end
        end

        context "explicit value" do
          it "renders a hidden field with the given value" do
            message_type = Class.new(HTTP::Message)
            params       = HTTP::FormModel.new(message_type, { foo: "model_value" })
            renderer     = Template::RenderContext.new(nil) {}
            builder      = Form::Builder.new(renderer, params)
            result       = builder.hidden(:foo, value: "explicit_value")
            expect(result).to match('type="hidden"')
            expect(result).to match('name="foo"')
            expect(result).to match('value="explicit_value"')
          end
        end
      end

      describe "#field_name" do
        context "top level" do
          it "is the name of the field" do
            message_type = Class.new(HTTP::Message)
            params       = HTTP::FormModel.new(message_type, { foo: "bar" })
            renderer     = Template::RenderContext.new(nil) {}
            builder      = Form::Builder.new(renderer, params)
            expect(builder.field_name(:foo)).to eq("foo")
          end
        end

        context "nested field" do
          it "includes the nested key" do
            message_type = Class.new(HTTP::Message)
            params       = HTTP::FormModel.new(message_type, { foo: { bar: "baz" } })
            builder      = Form::Builder.new(nil, params, Path.new(:foo))
            expect(builder.field_name(:bar)).to eq("foo[bar]")
          end
        end

        context "deeply nested field" do
          it "includes the nested keys" do
            message_type = Class.new(HTTP::Message)
            params       = HTTP::FormModel.new(message_type, { foo: { bar: { baz: "quox" } } })
            builder      = Form::Builder.new(nil, params, Path.new("foo/bar"))
            expect(builder.field_name(:baz)).to eq("foo[bar][baz]")
          end
        end
      end

      describe "#errors" do
        let(:message_class) do
          Class.new(HTTP::Message) do
            validate do
              required(:foo).filled(:integer)
              required(:bar).hash do
                required(:baz).filled(:integer)
              end
            end
          end
        end
        context "top level" do
          it "returns the errors list" do
            params      = HTTP::FormModel.new(message_class, { foo: "bar", bar: {} })
            no_renderer = nil
            builder     = Form::Builder.new(no_renderer, params)
            expect(builder.errors(:foo)).to eq(["must be an integer"])
          end
        end

        context "missing hash error" do
          it "returns the errors list" do
            data        = { foo: "bar" }
            params      = HTTP::FormModel.new(message_class, data)
            no_renderer = nil
            builder     = Form::Builder.new(no_renderer, params)
            expect(builder.errors(:bar)).to eq(["is missing"])
          end
        end

        context "nested hash schema errors" do
          it "returns the errors list" do
            data   = { foo: "bar", bar: { baz: "string" } }
            params = HTTP::FormModel.new(message_class, data)
            Form::Builder.new(nil, params).scoped(:bar) do |builder|
              expect(builder.errors(:baz)).to eq(["must be an integer"])
            end
          end
        end
      end
    end
  end
end
