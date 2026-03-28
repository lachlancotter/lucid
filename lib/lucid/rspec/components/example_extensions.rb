module Lucid
  module RSpec
    module Components
      module ExampleExtensions
        #
        # Expects the environment to have a container method.
        # 
        def verify_component (*messages, state: {}, **props)
          path_to_spec = caller_locations.first.path
          formatter    = ComponentFormatter
          component    = described_component.new(state, *messages, **props)
          verify("", path_to_spec: path_to_spec, format: :yaml) do
            formatter.new(component).to_s
          end
        end

        def described_component
          meta = self.class.metadata

          while meta[:parent_example_group]
            meta = meta[:parent_example_group]
          end

          meta[:described_class]
        end
      end
    end
  end
end