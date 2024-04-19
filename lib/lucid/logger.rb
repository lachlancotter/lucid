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
        request.env.each do |key, value|
          if key.start_with?("HTTP_HX")
            puts("        #{key}: #{value.inspect}")
          end
        end
      end

      def response (response)
        puts("  📤 Response:")
        response.headers.each do |key, value|
          puts("        #{key}: #{value.inspect}")
        end
      end

      def link (link)
        puts("  🔗 #{link.class.name}:")
        link.params.each do |key, value|
          puts("        #{key}: #{value.inspect}")
        end
      end

      def command (command)
        puts("  🛠️ #{command.class.name}:")
        command.params.each do |key, value|
          puts("        #{key}: #{value.inspect}")
        end
      end

      def event (event)
        puts("  🔔 #{event.class.name}:")
        event.params.each do |key, value|
          puts("        #{key}: #{value.inspect}")
        end
      end

      def error (error, data = {})
        puts("  ❌ #{error}")
        data.each do |key, value|
          puts("        #{key}: #{value.inspect}")
        end
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