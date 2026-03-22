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
          component    = described_class.new(state, *messages, **props)
          verify("", path_to_spec: path_to_spec, format: :yaml) do
            formatter.new(component).to_s
          end
        end
      end
    end
  end
end