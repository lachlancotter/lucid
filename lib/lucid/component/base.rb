require "lucid/renderable"
require "lucid/configurable"
require "lucid/component/stateful"
require "lucid/component/linkable"
require "lucid/component/eventable"
require "lucid/component/nestable"
require "lucid/component/referable"

module Lucid
  module Component
    #
    # Base class for Lucid components.
    #
    class Base
      include Stateful
      include Configurable
      include Linkable
      include Eventable
      include Nestable
      include Renderable
      include Referable

      # The path from the web root to the application root.
      # Used to encode URLs for the webserver. Useful
      # if you want to nest your application under a subdirectory.
      setting :app_root, default: "/"

      # The path from the root view component to this component.
      # Used to identify components and actions.
      setting :path, default: "/", constructor: -> (path) do
        path.is_a?(Path) ? path : Path.new(path)
      end

      def initialize (params = {}, &config)
        @params = params
        @state  = self.class.normalize_state(params)
        configure(&config)
      end

      def state_for_nested (name)
        @params[name] || {}
      end

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