module Lucid
  module DSL
    #
    # Define configuration options for a view or action.
    #
    class Config
      #
      # target_class - The class on which to define config options.
      # block        - A block defining the config options.
      #
      # Config.new do
      #   option :foo, "bar"
      # end
      #
      def initialize (target_class, &block)
        @target_class = target_class
        @block        = block
      end

      def install
        Docile.dsl_eval(self, &@block)
      end

      def option (name, default)
        @target_class.define_method(name) do
          @config.fetch(name, default)
        end
      end

      #
      # A store for configuration options. Exposes keys as methods.
      #
      # Config::Store.new do |config|
      #  config.foo = "bar"
      # end
      #
      class Store < Hash
        def initialize
          yield self if block_given?
        end

        private

        #
        # Access keys as methods.
        #
        def method_missing(symbol, *args)
          if symbol.to_s =~ /=$/
            self[symbol.to_s.gsub(/=$/, "").to_sym] = args.first
          elsif has_key?(symbol.to_sym)
            self[symbol.to_sym]
          else
            super
          end
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        has_key?(method_name) || super
      end
    end
  end
end