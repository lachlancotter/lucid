require "console"

module Lucid
  #
  # Print pretty logs of the request cycle to the console.
  #
  class Logger
    class << self

      #
      # Wrap a request cycle.
      #
      def cycle (request, response, &block)
        block_result = nil
        Console.logger.info(request) do |buffer|
          @buffer = buffer
          request(request)
          block_result = block.call
          response(response)
        end
        block_result
      end

      def request (request)
        @buffer.puts("#{request.request_method}: #{request.fullpath}")
      end

      def response (response)
        @buffer.puts("  Response(#{response.headers.inspect})")
      end

      def command (command)
        @buffer.puts("  #{command.class.name}(#{command.params.inspect})")
      end

      def event (event)
        @buffer.puts("  #{event.class.name}(#{event.params.inspect})")
      end

    end
  end
end