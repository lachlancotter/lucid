module Lucid
  class QueryHandler
    def initialize (query_class, &block)
      @query_class = query_class
      @block       = block
    end

    def handles? (query)
      query.is_a?(@query_class)
    end

    def call (query, state)
      @block.call(query, state)
    end
  end

  class QueryBus
    def initialize (app)
      @app      = app
      @handlers = []
    end

    def register (handler)
      @handlers << handler
    end

    def ask (query)
      log(query)
      state = @app.state.dup
      apply_handlers(query, state)
      Location.new(state, @app.routes)
    end

    def apply_handlers (query, state)
      @handlers.each do |handler|
        if handler.handles?(query)
          handler.call(query, state)
        end
      end
    end

    def log (query)
      puts "QueryBus#dispatch: #{query.to_h}"
    end
  end
end