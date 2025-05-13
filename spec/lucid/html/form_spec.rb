module Lucid
  module HTML
    describe Form::Builder do

      describe "#text" do
        context "implicit value" do
          it "renders a text field with the value from the model" do
            message_type = Class.new(HTTP::Message)
            params       = HTTP::FormModel.new(message_type, { foo: "model_value" })
            builder      = Form::Builder.new(nil, params)
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
            builder      = Form::Builder.new(nil, params)
            result       = builder.text(:foo, value: "explicit_value")
            expect(result).to match('type="text"')
            expect(result).to match('name="foo"')
            expect(result).to match('value="explicit_value"')
          end
        end
      end

      describe "#textarea" do
        context "implicit value" do
          it "renders a textarea field with the value from the model" do
            message_type = Class.new(HTTP::Message)
            params       = HTTP::FormModel.new(message_type, { foo: "model_value" })
            builder      = Form::Builder.new(nil, params)
            result       = builder.textarea(:foo)
            expect(result).to match('<textarea')
            expect(result).to match('name="foo"')
            expect(result).to match('value="model_value"')
          end
        end

        context "explicit value" do
          it "renders a textarea field with the given value" do
            message_type = Class.new(HTTP::Message)
            params       = HTTP::FormModel.new(message_type, { foo: "model_value" })
            builder      = Form::Builder.new(nil, params)
            result       = builder.textarea(:foo, value: "explicit_value")
            expect(result).to match('<textarea')
            expect(result).to match('name="foo"')
            expect(result).to match('value="explicit_value"')
          end
        end
      end

      describe "#hidden" do
        context "implicit value" do
          it "renders a hidden field with the value from the model" do
            message_type = Class.new(HTTP::Message)
            params       = HTTP::FormModel.new(message_type, { foo: "model_value" })
            builder      = Form::Builder.new(nil, params)
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
            builder      = Form::Builder.new(nil, params)
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
            builder      = Form::Builder.new(nil, params)
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