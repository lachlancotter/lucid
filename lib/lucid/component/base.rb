require "lucid/component/stateful"
require "lucid/component/configurable"
require "lucid/component/linkable"
require "lucid/component/eventable"
require "lucid/component/nestable"
require "lucid/component/renderable"
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

      def initialize (params = {}, &config)
        @params = params
        @state  = self.class.normalize_state(params)
        configure(&config)
      end

      def state_for_nested (name)
        @params[name] || {}
      end

      config do
        # The path from the web root to the application root.
        # Used to encode URLs for the webserver. Useful
        # if you want to nest your application under a subdirectory.
        option :app_root, "/"

        # The path from the root view component to this component.
        # Used to identify components and actions.
        option :path, "/"
      end

      def path
        Path.new(@config[:path] || "/")
      end

      # def full_path
      #   Path.new(@config[:app_root]).concat(path).to_s
      # end

      def inspect
        "<#{self.class.name} #{state.to_h}>"
      end

      # attr_reader :links
      attr_reader :config

    end
  end
end