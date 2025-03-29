module Lucid
  class App
    #
    # Manages a request/response cycle.
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
              message_bus.dispatch(valid_command, handler_context)
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
        base_view_class.new(state, {
           app_root: app_root,
           session:  @config[:session],
           path:     Path.new
        })
      end

      def message_bus
        @config[:handler]
      end

      def handler_context
        @config[:context].merge(bus: @config[:handler])
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