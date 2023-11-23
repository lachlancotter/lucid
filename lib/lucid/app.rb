require "awesome_print"
# require "lucid/state/tree"
require "lucid/event_bus"
require "lucid/command"
require "lucid/link"
require "lucid/http/request_adaptor"
require "lucid/http/response_adaptor"

module Lucid
  #
  # Runs an event cycle for an application.
  #
  class App
    def initialize (config)
      @config = config
    end

    #
    # Instantiates state for a request cycle.
    #
    class Cycle
      def initialize (request, response, config)
        @request  = request
        @response = response
        @config   = config
      end

      def base_view
        @config[:base_view]
      end

      def command_bus
        @config[:command_bus]
      end

      def base
        @base ||= build(@request.state(base_view, @config))
      end

      def build (state)
        base_view.new(state) do |config|
          config.app_root = @config[:app_root]
        end
      end

      def query
        base.visit(@request.message) if @request.has_query?
        @response.tap do
          @response.location = base.href
          @response.body     = base.render
        end
      end

      def command
        command_bus.dispatch(@request.message) if @request.has_command?
        @response.tap do
          @response.location = base.href
          @response.body     = base.render
        end
      end

      def href (message)
        base.href(message)
      end

      def notify (event)
        base.notify(event)
      end

      def state
        base.deep_state
      end
    end

    def cycle (request, response)
      @cycle ||= Cycle.new(
         HTTP::RequestAdaptor.new(request),
         HTTP::ResponseAdaptor.new(response),
         @config
      )
    end

    # ===================================================== #
    #    Requests
    # ===================================================== #

    def query (request, response)
      log(request, "Starting query") do
        cycle = cycle(request, response)
        with_context { cycle.query }
      end
    end

    def command (request, response)
      log(request, "Starting command") do
        cycle = cycle(request, response)
        with_context { cycle.command }
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
      puts "------------------------------------------"
      response = block.call
      puts "------------------------------------------"
      puts "Response: #{response.headers.inspect}"
      puts "=========================================="
      response
    end

    def with_context (&block)
      Event.with_bus(event_bus) do
        Command.with_context(@cycle) do
          Link.with_context(@cycle) do
            block.call
          end
        end
      end
    end

    def event_bus
      EventBus.new(@cycle)
    end
  end
end