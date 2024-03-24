require "lucid/renderable"
require "lucid/configurable"
require "lucid/state/reader"
require "lucid/component/state_param"
require "lucid/component/parameters"
require "lucid/component/stateful"
require "lucid/component/mappable"
require "lucid/component/linkable"
require "lucid/component/eventable"
require "lucid/component/nestable"
require "lucid/component/echoable"
require "lucid/component/dataflow"

module Lucid
  module Component
    #
    # Base class for Lucid components.
    #
    class Base
      include Checked
      include Callbacks
      include Parameters
      include Stateful
      include Mappable
      include Configurable
      include Linkable
      include Eventable
      include Nestable
      include Renderable
      include Echoable
      include Dataflow

      # The path from the web root to the application root.
      # Used to encode URLs for the webserver. Useful
      # if you want to nest your application under a subdirectory.
      setting :app_root, default: "/"

      # The path from the root view component to this component.
      # Used to identify components and actions.
      setting :path, default: "/", constructor: -> (path) do
        path.is_a?(Path) ? path : Path.new(path)
      end

      setting :parent, default: nil

      def self.build (buffer, &config)
        new(buffer, &config)
      end

      def initialize (params = {}, &config)
        check(params).type(Hash, StateParam::FromHash, State::Reader)
        @params = StateParam.from(params)
        @state  = self.class.build_state(@params.read(state_map))
        # nests.each do |name, nest|
        #   nest.build(self, @params.seek(state_map.path_count, name))
        # end
        # @buffer = buffer_or_params if buffer_or_params.is_a?(ReadBuffer)
        # @params = buffer_or_params if buffer_or_params.is_a?(Hash)
        # @state = self.class.normalize_state(params)
        configure(&config)
        run_callbacks(:after_initialize)
      end

      def nested_state (key)
        @params.seek(state_map.path_count, key).tap do |result|
          check(result).type(StateParam::FromHash, State::Reader)
        end
      end

      # def params
      #   @params ||= @buffer.read(href_map)
      # end
      #
      # def state_for_nested (name)
      #   @params[name] || {}
      # end

      # def path
      #   if config[:path].is_a?(Path)
      #     config[:path]
      #   else
      #     Path.new(config[:path])
      #   end
      # end

      def inspect
        "<#{self.class.name || "Component"}(#{path}) #{state.to_h}>"
      end

    end
  end
end