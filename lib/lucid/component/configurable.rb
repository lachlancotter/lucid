require "docile"

module Lucid
  #
  # Configurable components can be configured with options
  # and defaults. This module provides a DSL for defining
  # configuration options and a store for the options.
  #
  module Configurable
    def self.included (base)
      base.extend(ClassMethods)
    end

    #
    # Instantiates a configuration store with the default
    # values for this component class, and configures the
    # instance with the given block.
    #
    def configure (&block)
      @config = Store.for_host(self, &block)
    end

    module ClassMethods
      #
      # The class config block defines the configuration options
      # and defaults that are available to instances.
      #
      def config (&block)
        if respond_to?(:configuration)
          configuration.install(&block)
        else
          configuration = Config.new(self)
          configuration.install(&block)
          define_singleton_method(:configuration) { configuration }
        end
      end
    end

    class Config
      #
      # target_class - The class on which to define config options.
      # block        - A block defining the config options.
      #
      # Config.new(target_class).install do
      #   option :foo, "bar"
      # end
      #
      def initialize (target_class)
        @target_class = target_class
        @defaults     = {}
      end

      attr_reader :defaults

      def install (&block)
        Docile.dsl_eval(self, &block)
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
        new(host.class.configuration.defaults, &block)
      end

      def initialize (defaults)
        super()
        defaults.each { |key, value| self[key] = value }
        yield self if block_given?
      end

      # def [] (key)
      #   fetch(key) { @defaults[key] }
      # end

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