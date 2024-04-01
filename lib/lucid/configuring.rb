require "docile"
require "dry-configurable"

module Lucid
  #
  # Configurable components can be configured with options
  # and defaults. This module provides a DSL for defining
  # configuration options and a store for the options.
  #
  module Configuring
    def self.included (klass)
      klass.include(Dry::Configurable)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      def setting (name, **options, &block)
        super(name, **options, &block)
        define_method(name) { config[name] }
      end
    end
  end
end