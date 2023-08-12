module Lucid
  #
  # Build form elements.
  #
  class Form
    def initialize (endpoint, data)
      @endpoint = endpoint
      @data     = data
    end

    def template (&block)
      Papercraft.html do |endpoint, data|
        form action: endpoint.action_route, method: endpoint.action_method do
          input type: :hidden, name: :state, value: endpoint.encode_state
          input type: :hidden, name: :action, value: endpoint.action_name
          emit_yield Builder.new(data)
        end
      end.apply(@endpoint, @data, &block)
    end

    class Builder
      def initialize (data)
        @data = data
      end

      def label (field_name, options = {})
        Papercraft.html do |name|
          label(field_name.capitalize, { for: name }.merge(options))
        end.apply(field_name)
      end

      def text (field_name, options = {})
        Papercraft.html do |name, value|
          input({ type: :text, name: name, value: value, id: name }.merge(options))
        end.apply(field_name, @data.fetch(field_name, ""))
      end

      def submit (label)
        Papercraft.html do |label|
          input type: :submit, value: label
        end.apply(label)
      end
    end
  end
end