require "papercraft"
require "nokogiri"

require "lucid/state/base"
require "lucid/location"
require "lucid/html/anchor"
require "lucid/html/button"
require "lucid/event_handler"
require "lucid/template"


require "lucid/stateful"
require "lucid/configurable"
require "lucid/linkable"
require "lucid/commandable"
require "lucid/eventable"
require "lucid/nestable"
require "lucid/renderable"
require "lucid/routable"

module Lucid
  #
  # Base class for Lucid views. Defines a DSL for constructing a
  # view with links, actions, data sources and routes.
  #
  class Component
    include Stateful
    include Configurable
    include Linkable
    include Commandable
    include Eventable
    include Nestable
    include Renderable
    include Routable

    class << self
      def store (name, store_class = nil, &block)
        define_method(name) do
          @stores       ||= {}
          @stores[name] ||= store_class.new
        end
      end
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

    def initialize (data = {}, &config_block)
      @state  = build_state(data)
      @config = Configurable::Store.for_host(self, &config_block)
      @links  = SimpleDelegator.new(self)
    end

    def inspect
      "<#{self.class.name} #{state.to_h}>"
    end

    attr_reader :links
    attr_reader :config

    #
    # The from the root view component to this component.
    # Used to encoding routes to actions.
    #
    def path
      Path.new(@config[:path] || "/")
    end

    def full_path
      Path.new(@config[:app_root]).extend(path).to_s
    end

  end
end
