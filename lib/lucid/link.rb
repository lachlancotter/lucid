require "lucid/html/anchor"

module Lucid
  #
  # Represents a state in the information space that a user
  # can visit.
  #
  class Link < OpenStruct

    class << self
      def validate(&block)
        # Define schema.
      end

      def link (text, params = {})
        new(params).link(text)
      end

      def with_context (app)
        old_context = @context
        @context    = Context.new(app)
        yield
      ensure
        @context = old_context
      end

      attr_reader :context
    end

    #
    # Build a Link to the view state that answers this query.
    #
    def link (text)
      Anchor.new(href, text: text)
    end

    def href
      Link.context.href(self)
    end

    def key
      self.class
    end

    def to_params
      (Link.context ? Link.context.params : {}).
         merge(message_name.to_sym => to_h).
         merge(msg: message_name)
    end

    def to_query
      "?" + Rack::Utils.build_query(to_params)
    end

    def message_name
      self.class.name
    end

    #
    # A link to a state of the current component.
    #
    class Local < OpenStruct
      def initialize (name, params, component)
        super(params)
        @name      = name
        @component = component
      end

      def href
        Location.new(apply, @component.routes).to_s
      end

      def to_params
        (Link.context ? Link.context.params : {}).
           merge(message_name.to_sym => to_h).
           merge(msg: message_name.to_s).
           merge(path: @component.path.to_s)
      end

      def message_name
        @name
      end

      def apply
        @component.visit(self)
      end

      def key
        @name
      end
    end

    #
    # Evaluates a Link in the context of the current application
    # state and URL mapping rules.
    #
    class Context
      def initialize (app)
        @app = app
      end

      def params
        @app.params
      end

      def href (message)
        Location.new(@app.state, @app.routes) + message
      end

      # def apply (link)
      #   @app.visit(link).to_h
      # end
    end

  end
end