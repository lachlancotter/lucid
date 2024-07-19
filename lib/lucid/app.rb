module Lucid
  #
  # Top-level interface for dispatching HTTP requests.
  #
  class App
    def initialize (config)
      @config = config
    end

    def query (request, response)
      Logger.cycle(request, response, @config[:session]) do
        cycle(request, response).query
      end
    end

    def command (request, response)
      Logger.cycle(request, response, @config[:session]) do
        cycle(request, response).command
      end
    end

    def validate (request)
      log(request, "Starting validation") do

      end
    end

    private

    def cycle (request, response)
      @cycle ||= Cycle.new(
         HTTP::RequestAdaptor.new(request),
         HTTP::ResponseAdaptor.new(response),
         @config
      )
    end
  end
end