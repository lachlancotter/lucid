require "lucid/store"

module Lucid
  #
  # Execute code on the server.
  #
  class Action
    class << self
      #
      # Define params.
      #
      def params (&block)
        @params_class = Class.new(State, &block)
      end

      def params_class
        @params_class ||= Class.new(State)
      end

      def config (&block)
        DSL::Config.new(self, &block).install
      end

      #
      # Define a store.
      #
      def store (name, class_name)
        define_method(name) do
          @stores       ||= {}
          @stores[name] ||= class_name.new
        end
      end
    end

    def initialize (params, &config_block)
      @params = build_params(params)
      @config = DSL::Config::Store.new(&config_block)
    end

    attr_reader :params

    def call
      raise NotImplementedError
    end

    def build_params (params)
      self.class.params_class.new(params)
    end
  end
end