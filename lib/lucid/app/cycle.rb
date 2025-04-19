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
        run_with_context do
          @response.send_state(component)
        end
      end

      def link
        run_with_context do
          @request.yield_link do |link|
            Logger.link(link)
            component.visit(link)
            @response.send_delta(component, htmx: @request.htmx?)
          end
        end
      end

      def command
        run_with_context do
          @request.yield_command do |command|
            component # Build the tree before dispatching the command.
            Logger.command(command)
            message_bus.dispatch(command)
            @response.send_delta(component, htmx: @request.htmx?)
          end
        end
      end

      def htmx?
        @request.htmx?
      end

      def component
        Types.component[@container[:component]]
      end

      def message_bus
        @container[:message_bus]
      end

      def href
        component.href
      end

      def notify (event)
        component.notify(event)
      end

      #
      # Returns the state of the component for inclusion in links and forms.
      # If HTMX is enabled for the request, the state is omitted as we will 
      # rely on the HX-Current-URL header to pass the state instead.
      #
      def state_for_messages
        htmx? ? {} : component.deep_state
      end

      private

      def run_with_context
        Logger.cycle(self) do
          with_context { yield }
        end
      rescue Dry::Types::CoercionError => e
        Logger.exception(e)
        @response.send_error(e)
      end
      
      def with_context (&block)
        HTTP::Message.with_state(state_for_messages) do
          block.call
        end
      end
    end
  end
end