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
      def cycle (request, response, session_data, &block)
        block_result = nil
        Console.logger.info(request) do |buffer|
          @buffer = buffer
          request(request)
          # session(session_data)
          block_result = block.call
          response(response)
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
        puts("  ❌ #{error.message}")
        # error.backtrace.each do |line|
        #   puts("        #{line}")
        # end
        data.merge(error_data(error)).each do |key, value|
          puts("        #{key}: #{value.inspect}")
        end
      end

      private

      def error_data (error)
        {
           class: error.class,
           at: error.backtrace.find do |line|
             !line.include?("gems/")
           end
        }
      end

      # def trace (error)
      #   Tempfile.new(["trace", ".txt"], "/tmp").tap do |tf|
      #     tf.open
      #     tf.write(error.message)
      #     tf.write("\n")
      #     error.backtrace.each do |line|
      #       tf.write(line)
      #       tf.write("\n")
      #     end
      #     tf.close
      #   end
      # end

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