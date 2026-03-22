module Lucid
  module RSpec
    module Handlers
      module ExampleExtensions
        #
        # Expects the environment to have a container method.
        # 
        def verify_handler (handler, message,
           description: "",
           path_to_spec: caller_locations.first.path,
           classes: [],
           report_class: HandlerReport,
           &block)
          db_observer = DB::Observer.new(classes)
          db_observer.observe do
            case message
            when Lucid::Command then handler.dispatch(message, container)
            when Lucid::Event then handler.publish(message, container)
            else raise "Invalid message"
            end
          end
          message_bus = container[:message_bus]
          verify(description, path_to_spec: path_to_spec, format: :yaml) do
            YAMLUtil.normalize_yaml report_class.new(message, message_bus, db_observer).to_s
          end
        end
      end

    end
  end
end