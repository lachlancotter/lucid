require "papercraft"
require "nokogiri"

require "lucid/config"
require "lucid/state"
require "lucid/route"
require "lucid/link"
require "lucid/button"
require "lucid/action"
require "lucid/action_path"
require "lucid/endpoint"
require "lucid/event_handler"
require "lucid/template"

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

      def nest (name, view_class = nil, in: nil, as: nil, &view_def)
        values     = binding.local_variable_get(:in)
        config_key = binding.local_variable_get(:as) || :model

        if values.nil?
          define_method(name) do
            @nest       ||= {}
            @nest[name] ||= build_nested_view(view_class, view_def)
          end
        else
          define_method(name) do |collection_key|
            @nest                       ||= {}
            @nest[name]                 ||= []
            value                       = values.is_a?(Symbol) ? send(values)[collection_key] : values[collection_key]
            path_component              = "#{name}[#{collection_key}]"
            @nest[name][collection_key] ||= build_nested_view(view_class, view_def) do |config|
              config[config_key] = value
              config.app_root    = app_root
              config.path        = path.extend(path_component).to_s
            end
          end
        end
      end

      # class Nest
      #   def initialize (target_class, *args, **options, &block)
      #     @target_class = target_class
      #     @args         = args
      #     @options      = options
      #     @block        = block
      #   end
      #
      #   def install
      #     values     = binding.local_variable_get(:in)
      #     config_key = binding.local_variable_get(:as) || :model
      #
      #     if values.nil?
      #       @target_class.define_method(name) do
      #         @nest       ||= {}
      #         @nest[name] ||= build_nested_view(view_class, view_def)
      #       end
      #     else
      #       @target_class.define_method(name) do |collection_key|
      #         @nest                       ||= {}
      #         @nest[name]                 ||= []
      #         value                       = values.is_a?(Symbol) ? send(values)[collection_key] : values[collection_key]
      #         path_component              = "#{name}[#{collection_key}]"
      #         @nest[name][collection_key] ||= build_nested_view(view_class, view_def) do |config|
      #           config[config_key] = value
      #           config.app_root    = app_root
      #           config.path        = path.extend(path_component).to_s
      #         end
      #       end
      #     end
      #   end
      # end

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
        raise "Attempt to define template without a block" if block.nil?
        @templates       ||= {}
        @templates[name] = block
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

    def build_nested_view (view_class, view_def)
      view_class = Class.new(View, &view_def) if view_class.nil?
      view_class.new { |config| yield config if block_given? }
    end

    #
    # Access the templates hash. Provides a default if none
    # has been defined.
    #
    def templates
      self.class.templates
    end

    #
    # Access a template/partial to be rendered. Defaults
    # to the main template if no name is provided.
    #
    def template (name = :main)
      template_def = templates.fetch(name.to_sym) do
        raise "Could not find template `#{name}` in #{self.class} at #{config.path}. Available templates: #{templates.keys}"
      end
      Template.new(self, &template_def)
    end

    def initialize (data = {}, &config)
      @state  = build_state(data)
      @config = Configure.new(&config).build
      @links  = SimpleDelegator.new(self)
    end

    attr_reader :state
    attr_reader :links
    attr_reader :config

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
      Path.new(@config[:path] || "/")
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

      def build
        Config.new(@store)
      end

      def []= (key, value)
        @store[key] = value
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

    def render
      html = template.render
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
      ActionPath.new(action_path, self).resolve
    end

    private

    def routes_config
      { app_root: app_root }
    end
  end
end
