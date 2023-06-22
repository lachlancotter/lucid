require "lucid/state"
require "lucid/route"
require "lucid/link"

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
