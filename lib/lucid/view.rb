require "lucid/state"
require "lucid/route"
require "lucid/link"
require "lucid/button"
require "lucid/action"

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
          Link.new(new_state, routes)
        end
      end

      # ===================================================== #
      #    Actions
      # ===================================================== #

      #
      # Provide access to an Action.
      #
      class Endpoint
        def initialize (action_method, action_route, action_class)
          @action_method = action_method
          @action_route  = action_route
          @action_class  = action_class
        end

        attr_reader :action_class
        attr_reader :action_method
        attr_reader :action_route

        # def route
        #   @routes.encode(@state)
        # end

        def link (string)
          # Link.new().text(string)
        end

        def button (label)
          Button.new(self, label).to_s
        end
      end

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
          Endpoint.new(method, path.extend(name), action_class)
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
      def on (event_class, &block) end
    end

    config do
      option :path_root, "/"
    end

    def initialize (data = {}, &config)
      @state  = build_state(data)
      @config = Configure.new(&config).to_h
      @links  = SimpleDelegator.new(self)
    end

    def build_state (data)
      self.class.state_class.new(data)
    end

    #
    # Default routes configuration. Overridden by using the
    # routes class method to define a mapping.
    #
    def routes
      Route::Map.new
    end

    class Path
      def initialize(components = [])
        @components = components
      end

      def extend (component)
        Path.new(@components + [component])
      end

      def to_s
        "/" + @components.join("/")
      end
    end

    #
    # The from the root view component to this component.
    # Used to encoding routes to actions.
    #
    def path
      Path.new
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

    attr_reader :state
    attr_reader :links

    def to_s
      render
    end

    private

    def routes_config
      { path_root: path_root }
    end
  end
end
