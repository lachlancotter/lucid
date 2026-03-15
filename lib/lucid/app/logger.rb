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
          request(cycle.request)
          # session(session_data)
          block_result = block.call
          response(cycle.response)
          # Console.info(cycle.request) do |buffer|
          #   @buffer = buffer
          #   begin
          #     request(cycle.request)
          #     # session(session_data)
          #     block_result = block.call
          #     response(cycle.response)
          #   end
          # end
          block_result
        end

        def session (hash)
          Console.info("📦 Session:", **filter_hash(hash))
          # log_data(hash)
        end

        def request (request)
          Console.info("#{request.request_method}: #{request.fullpath}",
             **(request.env.select do |key, value|
               key.match(/HTTP_HX/)
             end)
          )
          # puts("#{request.request_method}: #{request.fullpath}")
          # request.env.each do |key, value|
          #   if key.start_with?("HTTP_HX") #|| key.start_with?("HTTP_COOKIE")
          #     puts("        #{key}: #{value.inspect}")
          #   end
          # end
        end

        def response (response)
          Console.info("📤 Response: #{response.status}",
             **filter_hash(response.headers)
          )
          # puts("  📤 Response:")
          # puts("        Status: #{response.status}")
          # response.headers.each do |key, value|
          #   puts("        #{key}: #{value.inspect}")
          # end
        end

        def link (link)
          Console.info("🔗 #{link.class.name}", **filter_hash(link.to_h))
          # puts("  🔗 #{link.class.name}")
          # log_data(link.to_h)
        end

        def command (command)
          Console.info("🛠️ #{command.class.name}", **filter_hash(command.to_h))
          # puts("  🛠️ #{command.class.name}")
          # log_data(command.to_h)
        end

        def event (event)
          Console.info("🔈 #{event.class.name}", **filter_hash(event.to_h))
          # puts("  🔈 #{event.class.name}")
          # log_data(event.to_h)
        end

        def debug (message, data = {})
          Console.debug("🐞#{message}", **filter_hash(data))
          # puts("  🐞 #{message}")
          # log_data(data)
        end
        
        def info (message, data = {})
          Console.info("ℹ #{message}", **filter_hash(data))
        end

        def warning (message, data = {})
          Console.warn("⚠️ #{message}", **filter_hash(data))
        end

        def error (message, data = {})
          Console.error("❌ #{message}", **filter_hash(data))
        end

        def exception (context, exception)
          Console.fatal(context, exception)
          # exception.backtrace.
          #    reject { |line| line.include?("gems/") }.
          #    each { |line| puts("    #{line}") }
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

        # def log_data (data)
        #   data.each do |key, value|
        #     filtered_value = filter_value(key, value)
        #     puts("        #{key}: #{filtered_value.inspect}")
        #   end
        # end

        # def puts(*args)
        #   if @buffer
        #     @buffer.puts(*args)
        #   else
        #     super
        #   end
        # end

      end
    end
  end
end