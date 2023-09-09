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
          emit_yield Builder.new(data, self)
        end
      end.apply(@endpoint, @data, &block)
    end

    class Builder
      def initialize (data, renderer)
        @data = data
        @renderer = renderer
      end

      def label (field_name, options = {})
        proc = Papercraft.html do |name|
          label(field_name.capitalize, { for: name }.merge(options))
        end.apply(field_name)
        @renderer.emit proc
      end

      def text (field_name, options = {})
        proc = Papercraft.html do |name, value|
          input({ type: :text, name: name, value: value, id: name }.merge(options))
        end.apply(field_name, @data.fetch(field_name, ""))
        @renderer.emit proc
      end

      def submit (label)
        proc = Papercraft.html do |l|
          input type: :submit, value: l
        end.apply(label)
        @renderer.emit proc
      end
    end
  end
end