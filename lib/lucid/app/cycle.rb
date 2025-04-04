module Lucid
  class App
    #
    # Manages a request/response cycle.
    #
    class Cycle
      def initialize (request, response, component_class:, handler_class:, container:, app_root:)
        @request         = request
        @response        = response
        @component_class = component_class
        @handler_class   = handler_class
        @container       = container
        @app_root        = app_root
      end

      def query
        run_with_context do
          @request.yield_link do |link|
            validate_message!(link) do |valid_link|
              Logger.link(valid_link)
              base_view.visit(valid_link)
              # base_view.check_guards do
              @response.send_delta(base_view, htmx: @request.htmx?)
              # end
            end
          end.yield_no_message do
            # base_view.check_guards do
            @response.send_state(base_view)
            # end
          end
        end
      end

      def command
        run_with_context do
          @request.yield_command do |command|
            base_view # Build the tree before dispatching the command.
            validate_message!(command) do |valid_command|
              Logger.command(valid_command)
              puts valid_command.class
              @handler_class.dispatch(valid_command, @container)
            end
            # base_view.check_guards do
            @response.send_delta(base_view, htmx: @request.htmx?)
            # end
          end
        end
      end

      def htmx?
        @request.htmx?
      end

      def base_view
        @base_view ||= build(
           @request.state_reader(app_root: @app_root)
        )
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
        @component_class.new(state,
           app_root: @app_root,
           session:  @container[:session],
           path:     Path.new
        )
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
        HTTP::Message.with_app_state(self) do
          block.call
        end
      end
    end
  end
end