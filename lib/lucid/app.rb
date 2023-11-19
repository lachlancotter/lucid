require "awesome_print"
require "lucid/state/tree"
require "lucid/event_bus"
require "lucid/command"
require "lucid/link"

module Lucid
  #
  # Runs an event cycle for an application.
  #
  class App
    def initialize (base_class, app_root)
      @base_class = base_class
      @app_root   = app_root
    end

    #
    # Instantiates state for a request cycle.
    #
    class Cycle
      def initialize (base_class, config, fullpath)
        @base_class = base_class
        @config     = config
        @params     = decode_params(fullpath)
        @base       = build_component(@params)
      end

      attr_reader :base

      def decode_params (fullpath)
        @base_class.routes(@config).decode(fullpath)
        # State::Tree.new(raw_state, @base_class)
      end

      def build_component (state)
        @base_class.new(state) do |config|
          config.app_root = @config[:app_root]
        end
      end

      def state
        @base.deep_state
      end

      def routes
        @base.routes
      end

      def visit (link)
        @base.visit(link)
        # For each path in the tree that matches the link,
        # transform the state at that path using the link.
        # Return the transformed state tree.
      end
    end

    def cycle (request)
      @cycle ||= Cycle.new(
         @base_class, { app_root: @app_root }, request.fullpath
      )
    end

    # ===================================================== #
    #    Requests
    # ===================================================== #

    def query (request)
      log(request, "Starting query") do
        base = cycle(request).base
        render(base)
      end
    end

    def command (request)
      log(request, "Starting command") do
        base = cycle(request).base
        dispatch_command(request)
        render(base)
      end
    end

    def validate (request)
      log(request, "Starting validation") do

      end
    end

    private

    def log (request, message, &block)
      puts "=========================================="
      puts message
      puts "Fullpath: #{request.fullpath}"
      puts "Params: #{request.params.inspect}"
      puts "=========================================="
      block.call
      puts "=========================================="
    end

    def dispatch_command (params)
      if params["command"]
        Event.with_bus(event_bus) do
          command_class = Object.const_get(params["command"])
          command       = command_class.new(params)
          @base.dispatch_command(command)
        end
      end
    end

    def render (component)
      Command.with_context(self) do
        Link.with_context(@cycle) do
          component.render
        end
      end
    end

    # def query_bus
    #   QueryBus.new(@base)
    # end

    def event_bus
      EventBus.new(@base)
    end
  end
end