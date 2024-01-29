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
        puts("#{request.request_method}: #{request.fullpath}")
      end

      def response (response)
        puts("  Response(#{response.headers.inspect})")
      end

      def command (command)
        puts("  #{command.class.name}(#{command.params.inspect})")
      end

      def event (event)
        puts("  #{event.class.name}(#{event.params.inspect})")
      end

      private

      def puts(*args)
        if @buffer
          @buffer.puts(*args)
        else
          super
        end
      end

    end
  end
end