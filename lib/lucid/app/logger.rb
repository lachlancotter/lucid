require "console"

module Lucid
  class App
    #
    # Print pretty logs of the request cycle to the console.
    #
    class Logger
      class << self

        #
        # Wrap a request cycle.
        #
        def cycle (cycle, &block)
          block_result = nil
          Console.logger.info(cycle.request) do |buffer|
            @buffer = buffer
            begin
              request(cycle.request)
              # session(session_data)
              block_result = block.call
              response(cycle.response)
            end
          end
          block_result
        end

        def session (hash)
          puts("  📦 Session:")
          log_data(hash)
        end

        def request (request)
          puts("#{request.request_method}: #{request.fullpath}")
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
          puts("  🔈 #{event.class.name}")
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

        SENSITIVE_KEYS = [
          /password/i,
          /(^|_)pw($|_)/i,
          /(^|_)pwd($|_)/i,
          /token/i,
          /secret/i,
          /\bkey\b/i,
          /api[_-]?key/i,
          /private[_-]?key/i,
          /access[_-]?key/i,
          /auth/i
        ].freeze

        def sensitive_key? (key)
          key_string = key.to_s
          SENSITIVE_KEYS.any? { |pattern| key_string.match?(pattern) }
        end

        def filter_value (key, value)
          if sensitive_key?(key)
            "[FILTERED]"
          elsif value.is_a?(Hash)
            filter_hash(value)
          elsif value.is_a?(Array)
            value.map { |item| item.is_a?(Hash) ? filter_hash(item) : item }
          else
            value
          end
        end

        def filter_hash (hash)
          hash.each_with_object({}) do |(key, value), acc|
            acc[key] = filter_value(key, value)
          end
        end

        def log_data (data)
          data.each do |key, value|
            filtered_value = filter_value(key, value)
            puts("        #{key}: #{filtered_value.inspect}")
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