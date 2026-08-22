require "lucid/html/template"

module Lucid
  module HTML
    describe Template do
      context "static" do
        it "renders with Papercraft" do
          view     = Class.new(Component::Base).new({})
          template = Template.new do
            div { text "Hello, World" }
          end.bind(view)
          expect(template.render).to eq("<div>Hello, World</div>")
        end
      end

      it "renders script elements" do
        view = Class.new(Component::Base) do
          element do
            head {
              script(src: "https://example.com/script.js")
            }
          end
        end.new({})
        view.delta.replace
        expect(view.render).to match(
           '<head><script src="https://example.com/script.js"></script></head>'
        )
      end

      context "with template arguments" do
        it "renders the template" do
          view     = Class.new(Component::Base)
          template = Template.new do |name|
            div { text "Hello, #{name}" }
          end.bind(view)
          expect(template.render("World")).to eq("<div>Hello, World</div>")
        end
      end
      
      context "with nested component" do
        it "renders the nested component" do
          nested_component_class = Class.new(Component::Base) do
            element { span { text "Nested Component" } }
          end
          base_component_class   = Class.new(Component::Base) do
            nest(:nested) { nested_component_class }
            element { subcomponent(:nested) }
          end

          view = base_component_class.new({})
          expect(view.template.render).to include("Nested Component")
        end
      end

      context "with named template" do
        it "renders the named template with template" do
          base_component_class = Class.new(Component::Base) do
            template(:greeting) do |name|
              span { text "Hello, #{name}" }
            end

            element { template(:greeting, "World") }
          end

          view = base_component_class.new({})
          expect(view.template.render).to include("<span>Hello, World</span>")
        end

        it "renders form context output inside template wrappers" do
          form_message = stub_const("TemplateFormCommand", Class.new(Lucid::Command))

          base_component_class = Class.new(Component::Base) do
            form(:generation_form, form_message) do |form|
              form.merge_default(model: "gpt-image-1")
            end

            template(:field_select) do |form_context, field_name, label_text, options, selected_value|
              fields_for form_context do |form|
                div(class: "form-field") do
                  form.label(field_name, label_text)
                  form.select(field_name, value: selected_value) do |select|
                    options.each { |option_label| select.option(option_label) }
                  end
                end
              end
            end

            element do |generation_form|
              form_for generation_form do |form|
                section(class: "form-grid") do
                  template(:field_select, form.context, :model, "Model", ["gpt-image-1"], "gpt-image-1")
                end
              end
            end
          end

          view = base_component_class.new({})
          expect(view.render).to include(
             '<div class="form-field"><label for="model">Model</label>' \
             '<select name="model" id="model">' \
             '<option value="gpt-image-1" selected>gpt-image-1</option>' \
             '</select></div>'
          )
        end

        it "renders fields for a form model without rendering form metadata" do
          form_message = stub_const("TemplateFieldsForCommand", Class.new(Lucid::Command))

          base_component_class = Class.new(Component::Base) do
            form(:generation_form, form_message) do |form|
              form.merge_default(model: "gpt-5")
            end

            element do |generation_form|
              fields_for generation_form do |form|
                form.text(:model)
              end
            end
          end

          render = base_component_class.new({}).render
          expect(render).to include('<input type="text" name="model" value="gpt-5" id="model">')
          expect(render).not_to include("<form")
          expect(render).not_to include('name="component"')
          expect(render).not_to include('name="form"')
        end

        it "renders fields for a scoped form context" do
          form_message = stub_const("TemplateScopedFieldsForCommand", Class.new(Lucid::Command))

          base_component_class = Class.new(Component::Base) do
            form(:profile_form, form_message) do |form|
              form.merge_default(profile: { name: "Jane" })
            end

            element do |profile_form|
              fields_for Form::Context.new(profile_form).scoped(:profile) do |form|
                form.text(:name)
              end
            end
          end

          expect(base_component_class.new({}).render).to include(
             '<input type="text" name="profile[name]" value="Jane" id="profile_name">'
          )
        end

        it "does not leak partial nested template output when the caller rescues" do
          base_component_class = Class.new(Component::Base) do
            template(:broken) do
              span { text "partial" }
              raise "boom"
            end

            element do
              begin
                template(:broken)
              rescue RuntimeError
                div { text "fallback" }
              end
            end
          end

          render = base_component_class.new({}).render
          expect(render).to include("<div>fallback</div>")
          expect(render).not_to include("partial")
        end

        it "warns when a form builder is passed to a template" do
          form_message = stub_const("TemplateBuilderWarningCommand", Class.new(Lucid::Command))

          base_component_class = Class.new(Component::Base) do
            form(:generation_form, form_message)

            template(:field_select) do |form|
              fields_for form.context do |fields|
                fields.text(:model, value: "gpt-5")
              end
            end

            element do |generation_form|
              form_for generation_form do |form|
                template(:field_select, form)
              end
            end
          end

          expect { base_component_class.new({}).render }.
             to output(/Passing `Lucid::HTML::Form::Builder` to `template` is deprecated/).to_stderr
        end

        it "does not leak an unused template block to later templates" do
          base_component_class = Class.new(Component::Base) do
            template(:ignores_block) do
              div { text "ignored" }
            end

            template(:uses_yield) do
              div { emit_yield }
            end

            element do
              template(:ignores_block) do
                span { text "leaked" }
              end

              template(:uses_yield)
            end
          end

          view = base_component_class.new({})
          expect { view.render }.to raise_error(Papercraft::Error, "No block given")
        end

        it "restores the caller template block after rescued validation errors" do
          base_component_class = Class.new(Component::Base) do
            template(:needs_name) do |name:|
              span { text name }
            end

            template(:wrapper) do
              begin
                template(:needs_name)
              rescue Papercraft::Error
                nil
              end

              div { emit_yield }
            end

            element do
              template(:wrapper) do
                text "fallback content"
              end
            end
          end

          view = base_component_class.new({})
          expect(view.render).to include("<div>fallback content</div>")
        end

        it "warns when fragment is used" do
          base_component_class = Class.new(Component::Base) do
            template(:greeting) do |name|
              span { text "Hello, #{name}" }
            end

            element { fragment(:greeting, "World") }
          end

          view = base_component_class.new({})
          expect { view.template.render }.
             to output(/`fragment` is deprecated; use `template` instead\./).to_stderr
        end
      end

      context "with nested component collection" do
        it "renders the collection with subcomponents" do
          nested_component_class = Class.new(Component::Base) do
            prop :name
            element { |name| span { text name } }
          end
          base_component_class   = Class.new(Component::Base) do
            nest(:nested) { nested_component_class[].enum(%w[One Two], as: :name) }
            element { subcomponents(:nested) }
          end

          view = base_component_class.new({})
          expect(view.template.render).to include("One")
          expect(view.template.render).to include("Two")
        end
      end

      context "invalid nested component name" do
        it "raises an exception" do
          base_component_class = Class.new(Component::Base) { element { subcomponent(:invalid_name) } }
          view                 = base_component_class.new({})
          expect { view.template.render }.to raise_error(ApplicationError)
        end
      end

      context "command passed to link_to" do
        it "raises an exception" do
          msg_class = Class.new(Lucid::Command)
          view      = Class.new(Component::Base) do
            element { link_to msg_class.new, "Link" }
          end.new({})
          expect { view.template.render }.to raise_error(ApplicationError)
        end
      end
    end
  end
end
