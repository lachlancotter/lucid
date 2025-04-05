module Lucid
  class App
    #
    # Manages a request/response cycle.
    #
    class Cycle
      def initialize (request, response, container)
        @request         = request
        @response        = response
        @container       = container
      end

      def query
        run_with_context do
          @request.yield_link do |link|
            validate_message!(link) do |valid_link|
              Logger.link(valid_link)
              component.visit(valid_link)
              # component.check_guards do
              @response.send_delta(component, htmx: @request.htmx?)
              # end
            end
          end.yield_no_message do
            # component.check_guards do
            @response.send_state(component)
            # end
          end
        end
      end

      def command
        run_with_context do
          @request.yield_command do |command|
            component # Build the tree before dispatching the command.
            validate_message!(command) do |valid_command|
              Logger.command(valid_command)
              message_bus.dispatch(valid_command)
            end
            # component.check_guards do
            @response.send_delta(component, htmx: @request.htmx?)
            # end
          end
        end
      end

      def htmx?
        @request.htmx?
      end

      def component
        @container[:component]
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

      def state
        component.deep_state
      end

      #
      # Merge the current state to the message params unless HTMX is enabled.
      # For HTMX requests, the current state is passed in the HX-Current-URL header.
      #
      def merge_state (message_params)
        if htmx?
          message_params
        else
          component.merge_state(message_params)
        end
      end

      private

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
        HTTP::Message.with_app_state(self) do
          block.call
        end
      end
    end
  end
end