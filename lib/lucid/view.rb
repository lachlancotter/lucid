require "papercraft"
require "nokogiri"

require "lucid/state"
require "lucid/route"
require "lucid/link"
require "lucid/button"
require "lucid/action"
require "lucid/endpoint"
require "lucid/event_handler"

module Lucid
  #
  # Base class for Lucid views. Defines a DSL for constructing a
  # view with links, actions, data sources and routes.
  #
  class View
    class << self
      # ===================================================== #
      #    State Definition
      # ===================================================== #

      #
      # Defines the state attributes and validation rules
      # for this view component. View state encapsulates the
      # parameters that are exposed to the client.
      #
      def state (&block)
        @state_class = Class.new(State, &block)
      end

      #
      # Access the state class. Provides a default if none
      # has been defined.
      #
      def state_class
        @state_class ||= Class.new(State)
      end

      # ===================================================== #
      #    Dependency Injection
      # ===================================================== #

      #
      # The class config block defines the configuration options
      # and defaults that are available to instances.
      #
      def config (&block)
        Docile.dsl_eval(ConfigDef.new(self), &block).build
      end

      #
      # Configuration options DSL.
      #
      class ConfigDef
        def initialize (klass)
          @klass = klass
        end

        def option (name, default)
          @klass.define_method(name) do
            @config.fetch(name, default)
          end
        end

        def build
          @klass
        end
      end

      # ===================================================== #
      #    Nested Views
      # ===================================================== #

      def nest (name, &block)
        define_method(name) do
          @nested_views       ||= {}
          @nested_views[name] ||= Class.new(View, &block).new
        end
      end

      # ===================================================== #
      #    Routes
      # ===================================================== #

      #
      # The route block defines the path components and params
      # to project from the view state.
      #
      def route (&block)
        define_method(:routes) do
          @routes ||= Route::Map.build(routes_config, &block)
        end
      end

      # ===================================================== #
      #    Links
      # ===================================================== #

      #
      # Defines a link with a name and a block that mutates
      # the view state, producing the state to link to.
      #
      def link (name, &block)
        define_method(name) do
          new_state = state.mutate(&block)
          Link.new(Route.new(new_state, routes))
        end
      end

      # ===================================================== #
      #    Stores
      # ===================================================== #

      def store (name, store_class = nil, &block)
        define_method(name) do
          @stores       ||= {}
          @stores[name] ||= store_class.new
        end
      end

      # ===================================================== #
      #    Actions
      # ===================================================== #

      def post (name, action_class = nil, &block)
        action(:post, name, action_class, &block)
      end

      #
      # Defines a named action that will run on the server.
      # The action can be defined by a provided class, or
      # inline with the block.
      #
      def action (method, name, action_class = nil, &block)
        action_class = Class.new(Action, &block) if action_class.nil?
        define_method(name) do
          action_name = path.extend(name)
          route       = Route.new(state, routes)
          Endpoint.new(method.to_sym, route, action_name, action_class)
        end
      end

      # ===================================================== #
      #    Events
      # ===================================================== #

      #
      # Defines a handler function that will respond to
      # notifications with the given class. Block is passed
      # the event instance, and the current view state.
      #
      def on (event_class, &block)
        @event_handlers ||= []
        @event_handlers << EventHandler.new(event_class, &block)
      end

      attr_reader :event_handlers

      # ===================================================== #
      #    Templates
      # ===================================================== #

      #
      # Defines a template with a name and a block that gives
      # the template definition.
      #
      def template (name = :main, &block)
        @templates       ||= {}
        @templates[name] = Template.new(self, &block)
      end

      #
      # Access the templates hash. Provides a default if none
      # has been defined.
      #
      def templates
        @templates ||= {}
      end
    end

    config do
      # The path from the web root to the application root.
      # Used to encode URLs for the webserver. Useful
      # if you want to nest your application under a subdirectory.
      option :app_root, "/"

      # The path from the root view component to this component.
      # Used to identify components and actions.
      option :path, "/"
    end

    #
    # Access the templates hash. Provides a default if none
    # has been defined.
    #
    def templates
      self.class.templates
    end

    #
    # Access the main template. Provides a default if none
    # has been defined.
    #
    def template
      templates[:main]
    end

    def initialize (data = {}, &config)
      @state  = build_state(data)
      @config = Configure.new(&config).to_h
      @links  = SimpleDelegator.new(self)
    end

    attr_reader :state
    attr_reader :links

    def event_handlers
      self.class.event_handlers || []
    end

    def build_state (data)
      self.class.state_class.new(data)
    end

    def encode_state
      JSON.encode(@state.to_h)
    end

    #
    # Default routes configuration. Overridden by using the
    # routes class method to define a mapping.
    #
    def routes
      Route::Map.new(routes_config)
    end

    #
    # The from the root view component to this component.
    # Used to encoding routes to actions.
    #
    def path
      Path.new(@config[:path])
    end

    def full_path
      Path.new(@config[:app_root]).extend(path).to_s
    end

    #
    # Provides a scope to set configuration options during
    # initialization, which can then be encapsulated in the
    # view instance.
    #
    class Configure
      def initialize
        @store = {}
        yield self if block_given?
      end

      def to_h
        @store
      end

      private

      def method_missing(symbol, *args)
        if symbol.to_s =~ /=$/
          @store[symbol.to_s.gsub(/=$/, "").to_sym] = args.first
        else
          super
        end
      end
    end

    def to_s
      render
    end

    def render
      html = template.call(self)
      doc  = Nokogiri::HTML(html)
      doc.to_xhtml(indent: 2, indent_text: ' ')
    end

    def perform_action (action_path, params)
      action = get_action(action_path)
      if action.nil?
        raise "Action not found: #{action_path}"
      else
        action.build(params).call
      end
    end

    def get_action (action_path)
      segments = action_path.split("/").reject(&:empty?)
      if segments.length == 1
        send(segments.first)
      else
        first_segment   = segments.shift
        child_component = send(first_segment)
        child_component.get_action(segments.join("/"))
      end
    end

    private

    def routes_config
      { app_root: app_root }
    end
  end
end
