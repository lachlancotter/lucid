module Lucid
  module RSpec
    module Components
      class ComponentVerification
        def initialize (component_class, state, *messages, **props)
          @component_class = component_class
          @state           = state
          @messages        = messages
          @props           = props
        end
        
        def configure (&block)
          yield self
        end
        
        def call
          ComponentFormatter.new(build).to_s
        end

        def build
          @component_class.new(@state, *@messages, **@props)
        end
      end
    end
  end
end