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
      Logger.cycle(request, response) do
        cycle(request, response).query
      end
    # rescue => e
    #   Console.logger.error(self, e)
    end

    def command (request, response)
      Logger.cycle(request, response) do
        cycle(request, response).command
      end
    # rescue => e
    #   Console.logger.error(self, e)
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
        with_context do
          if @request.has_link?
            validated!(@request.message) do |link|
              Logger.link(@request.message)
              base_view.visit(link)
            end
            respond_with_delta
          else
            respond_with_refresh
          end
        end
      rescue State::Invalid => e
        Logger.error(e.message)
        respond_with_error(e)
      end

      def command
        with_context do
          if @request.has_command?
            validated!(@request.message) do |command|
              command_bus.dispatch(command)
            end
          end
          respond_with_delta
        end
      rescue State::Invalid => e
        Logger.error(e.message)
        respond_with_error(e)
      end

      def validated! (message)
        if message.valid?
          yield message
        else
          Validation::Failed.notify(message: message)
          Logger.error(message, message.errors)
        end
      end

      def respond_with_delta
        @response.tap do
          @response.status = 303
          @response.location = base_view.href
        end
      end

      def respond_with_refresh
        @response.tap do
          @response.location = base_view.href
          @response.body     = base_view.render
        end
      end

      def respond_with_error (error)
        @response.tap do
          @response.status = 422
          @response.body   = "Invalid state"
        end
      end

      def base_view
        @base_view ||= build(@request.state_reader(@config))
      end

      def build (state)
        base_view_class.new(state) do |config|
          config.app_root = @config[:app_root]
          config.path     = Path.new
        end
      end

      def base_view_class
        @config[:base_view_class]
      end

      def command_bus
        @config[:command_bus]
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

      private

      def with_context (&block)
        Event.with_bus(event_bus) do
          Message.with_context(self) do
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