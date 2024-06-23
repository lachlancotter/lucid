require "awesome_print"
require "lucid/logger"
# require "lucid/state/tree"
require "lucid/event_bus"
require "lucid/command"
require "lucid/link"
require "lucid/event"
require "lucid/component/base"
require "lucid/http/request_adaptor"
require "lucid/http/response_adaptor"

module Lucid
  #
  # Top-level interface for dispatching HTTP requests.
  #
  class App
    def initialize (config)
      @config = config
    end

    def query (request, response)
      Logger.cycle(request, response, @config[:session]) do
        cycle(request, response).query
      end
    end

    def command (request, response)
      Logger.cycle(request, response, @config[:session]) do
        cycle(request, response).command
      end
    end

    def validate (request)
      log(request, "Starting validation") do

      end
    end

    private

    def cycle (request, response)
      @cycle ||= Cycle.new(
         HTTP::RequestAdaptor.new(request),
         HTTP::ResponseAdaptor.new(response),
         @config
      )
    end

    #
    # Manages a request-response cycle.
    #
    class Cycle
      def initialize (request, response, config)
        @request  = request
        @response = response
        @config   = config
      end

      def query
        run_with_context do
          @request.yield_link do |link|
            validate_message!(link) do |valid_link|
              Logger.link(valid_link)
              base_view.visit(valid_link)
              base_view.check_guards do
                @response.send_delta(base_view, htmx: @request.htmx?)
              end
            end
          end.yield_no_message do
            base_view.check_guards do
              @response.send_state(base_view)
            end
          end
        end
      end

      def command
        run_with_context do
          @request.yield_command do |command|
            base_view # Build the tree before dispatching the command.
            validate_message!(command) do |valid_command|
              Logger.command(valid_command)
              command_bus.dispatch(valid_command)
            end
            base_view.check_guards do
              @response.send_delta(base_view, htmx: @request.htmx?)
            end
          end
        end
      end

      def htmx?
        @request.htmx?
      end

      def base_view
        @base_view ||= build(
           @request.state_reader(
              app_root: app_root
           )
        )
      end

      def app_root
        @config[:app_root]
      end

      def base_view_class
        @config[:base_view_class]
      end

      def command_bus_class
        @config[:command_bus_class]
      end

      def href
        base_view.href
      end

      def notify (event)
        base_view.notify(event)
      end

      def state
        base_view.deep_state
      end

      #
      # Merge the current state to the message params unless HTMX is enabled.
      # For HTMX requests, the current state is passed in the HX-Current-URL header.
      #
      def merge_state (message_params)
        if htmx?
          message_params
        else
          base_view.merge_state(message_params)
        end
      end

      private

      def build (state)
        base_view_class.new(state) do
          {}.tap do |config|
            config[:app_root] = @config[:app_root]
            config[:session]  = @config[:session]
            config[:path]     = Path.new
          end
        end
      end

      def command_bus
        @command_bus ||= command_bus_class.new(@config[:session])
      end

      def run_with_context
        with_context { yield }
      rescue Dry::Types::CoercionError => e
        Logger.exception(e)
        @response.send_error(e)
      end

      def validate_message! (message_params)
        if message_params.valid?
          yield message_params.to_message
        else
          Logger.error(
             message_params.message_type,
             message_params.errors
          )
          Validation::Failed.notify(
             message_type:   message_params.message_type,
             message_params: message_params.message_params
          )
        end
      end

      def with_context (&block)
        Event.with_bus(event_bus) do
          HttpMessage.with_app_state(self) do
            block.call
          end
        end
      end

      def event_bus
        EventBus.new(self)
      end
    end

  end
end