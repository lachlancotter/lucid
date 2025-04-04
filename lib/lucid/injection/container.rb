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
        def initialize (key)
          super("No such provider registered: #{key}")
        end

        def self.check (key, container)
          raise new(key) unless container.key?(key)
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
          @memoized[key] = self.class.resolve(key, self)
        end
      end

      def key? (key)
        self.class.key?(key)
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
        end

        #
        # Run a provider block in the context of the given container instance.
        # 
        def resolve (key, instance)
          NoSuchProvider.check(key, self)
          block = providers[key]
          instance.instance_exec(&block)
        end

        def key? (key)
          providers.key?(key)
        end

        private

        def providers
          @providers ||= {}
        end
      end
    end
  end
end