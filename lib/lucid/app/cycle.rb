module Lucid
  class App
    #
    # Manages a request/response cycle.
    #
    class Cycle
      attr_reader :request, :response

      def initialize (request, response, container)
        @request   = request
        @response  = response
        @container = container
      end

      def state
        view = component(nil)
        run_with_context(view) do
          @response.send_state(view)
        end
      end

      def link
        @request.yield_link do |link|
          view = component(link)
          run_with_context(view) do
            Logger.link(link)
            @response.send_delta(view, htmx: @request.htmx?)
          end
        end
      end

      def command
        @request.yield_command do |command|
          Logger.command(command)
          message_bus.dispatch(command)
        end
        @request.yield_invalid do |params, errors|
          Logger.error("Invalid command", params)
          message_bus.publish(
             MessageInvalidated.new(
                params: params,
                errors: errors
             )
          )
        end
        message = message_bus.published.first
        view    = component(message)
        run_with_context(view) do
          @response.send_delta(view, htmx: @request.htmx?)
        end
      end

      private

      def htmx?
        @request.htmx?
      end

      def component (message)
        @container.component_class.new(
           @request.state_reader,
           message,
           app_root:     @container[:app_root],
           container:    @container,
           http_session: @container[:session]
        )
      end

      def message_bus
        @container[:message_bus]
      end

      def run_with_context (component, &block)
        Logger.cycle(self) do
          HTTP::Message.with_url_base(@container[:app_root]) do
            HTTP::Message.with_state(state_for_messages(component), &block)
          end
        end
      rescue Dry::Types::CoercionError => e
        Logger.exception(e)
        @response.send_error(e)
      end

      #
      # Returns the state of the component for inclusion in links and forms.
      # If HTMX is enabled for the request, the state is omitted as we will 
      # rely on the HX-Current-URL header to pass the state instead.
      #
      def state_for_messages (component)
        htmx? ? {} : component.deep_state
      end
    end
  end
end