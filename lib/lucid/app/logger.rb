require "console"

module Lucid
  module App
    #
    # Print pretty logs of the request cycle to the console.
    #
    class Logger
      class << self

        #
        # Wrap a request cycle.
        #
        def cycle (request, response, session_data, &block)
          block_result = nil
          Console.logger.info(request) do |buffer|
            @buffer = buffer
            begin
              request(request)
              # session(session_data)
              block_result = block.call
              response(response)
            end
          end
          block_result
        end

        def session (hash)
          puts("  📦 Session:")
          hash.each do |key, value|
            puts("        #{key}: #{value.inspect}")
          end
        end

        def request (request)
          puts("#{request.request_method}: #{request.fullpath}")
          # request.params.each do |key, value|
          #   puts("        #{key}: #{value.inspect}")
          # end
          request.env.each do |key, value|
            if key.start_with?("HTTP_HX") #|| key.start_with?("HTTP_COOKIE")
              puts("        #{key}: #{value.inspect}")
            end
          end
        end

        def response (response)
          puts("  📤 Response:")
          puts("        Status: #{response.status}")
          response.headers.each do |key, value|
            puts("        #{key}: #{value.inspect}")
          end
        end

        def link (link)
          puts("  🔗 #{link.class.name}")
          log_data(link.to_h)
        end

        def command (command)
          puts("  🛠️ #{command.class.name}")
          log_data(command.to_h)
        end

        def event (event)
          puts("  🔔 #{event.class.name}")
          log_data(event.to_h)
        end

        def debug (message, data = {})
          puts("  🐞 #{message}")
          log_data(data)
        end

        def warning (message, data = {})
          puts("  ⚠️ #{message}")
          log_data(data)
        end

        def error (message, data = {})
          puts("  ❌ #{message}")
          log_data(data)
        end

        def exception (exception)
          puts("  ❌ #{exception.class.name}: #{exception.message}")
          exception.backtrace.
             reject { |line| line.include?("gems/") }.
             each { |line| puts("    #{line}") }
        end

        private

        def log_data (data)
          data.each do |key, value|
            puts("        #{key}: #{value.inspect}")
          end
        end

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
end