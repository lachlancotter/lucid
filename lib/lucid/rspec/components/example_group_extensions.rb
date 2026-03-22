module Lucid
  module RSpec
    module Components
      #
      # Extend the RSpec DSL for handlers.
      # 
      module ExampleGroupExtensions
        #
        # Handler specs have access to a test container by default. The container comes
        # with a FakeMessageBus that can be used to verify that messages are published
        # by the handler. The container, or its contents can be overridden with
        # let() and provide().
        # 
        def self.extended(base)
          base.let(:container_class) { Class.new(Lucid::App::Container) {} }
          base.let(:container) { container_class.new({}, container_env) }
          base.let(:container_env) { {} }
        end

        #
        # In a handler spec, provide() works like let() but provides the block
        # value through the test container. It is also available as a standard
        # let block.
        # 
        def provide(name, &block)
          let(name, &block)
          before do
            container_env[name] = send(name)
            container_class.provide(name) { @env[name] }
          end
        end
      end
    end
  end
end