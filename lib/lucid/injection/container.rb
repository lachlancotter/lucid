module Lucid
  module Injection
    #
    # A place to register and resolve dependencies for the application.
    # 
    class Container

      # ===================================================== #
      #    Errors
      # ===================================================== #

      #
      # Raised on attempt to access a provider that does not exist in the container.
      # 
      class NoSuchProvider < ArgumentError
        def initialize (key, container)
          super("No provider named `#{key}` is registered for container class #{container}.")
        end

        def self.check (key, container)
          raise new(key, container) unless container.key?(key)
        end
      end

      # ===================================================== #
      #    Constructor
      # ===================================================== #

      #
      # A new Container is created for each request.
      # 
      def initialize
        @memoized = {}
      end

      #
      # Get a provider from the container. 
      # Raises NoSuchProvider if the provider does not exist.
      # 
      def [](key)
        @memoized.fetch(key) do
          @memoized[key] = instance_exec &(self.class.resolve(key))
        end
      end

      def key? (key)
        self.class.key?(key)
      end
      
      # ===================================================== #
      #    Inspection
      # ===================================================== #

      def to_s
        "<#{self.class.name} {#{self.class.keys}}>"
      end

      def inspect
        to_s
      end

      # ===================================================== #
      #    Class DSL
      # ===================================================== #

      class << self
        #
        # Register a block to run for the given provider key.
        # 
        def provide (key, &block)
          providers[key] = block
          define_method(key) { self[key] }
        end

        #
        # Run a provider block in the context of the given container instance.
        # 
        def resolve (key)
          providers.fetch(key) do
            if superclass.respond_to?(:resolve)
              superclass&.resolve(key)
            else
              raise NoSuchProvider.new(key, self)
            end
          end
        end

        def key? (key)
          return true if providers.key?(key)
          return superclass&.key?(key) if superclass.respond_to?(:key?)
          false
        end

        def keys
          providers.keys.concat(
             case superclass.respond_to?(:keys)
             when true then superclass.keys
             else []
             end
          )
        end

        private

        def providers
          @providers ||= {}
        end
      end
    end
  end
end