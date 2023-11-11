module Lucid
  #
  #
  #
  module Configurable
    def self.included (base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      #
      # The class config block defines the configuration options
      # and defaults that are available to instances.
      #
      def config (&block)
        DSL.new(self, &block).install
      end
    end

    class DSL
      #
      # target_class - The class on which to define config options.
      # block        - A block defining the config options.
      #
      # Config.new(target_class) do
      #   option :foo, "bar"
      # end
      #
      def initialize (target_class, &block)
        @target_class = target_class
        @block        = block
        @defaults     = {}
      end

      def install
        defaults = @defaults
        @target_class.define_singleton_method(:config_defaults) { defaults }
        Docile.dsl_eval(self, &@block)
      end

      def option (name, default)
        @defaults[name] = default
        @target_class.define_method(name) { @config[name] }
      end

      def validate (&block) end

      def respond_to_missing?(method_name, include_private = false)
        has_key?(method_name) || super
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
      def self.for_host (host, &block)
        new(host.class.config_defaults, &block)
      end

      def initialize (defaults)
        @defaults = defaults
        yield self if block_given?
      end

      def [] (key)
        fetch(key) { @defaults[key] }
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
  end
end