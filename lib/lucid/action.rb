require "lucid/store"

module Lucid
  #
  # Execute code on the server.
  #
  class Action
    class << self
      #
      #
      #
      def store (name, class_name)
        define_method(name) do
          @stores       ||= {}
          @stores[name] ||= class_name.new
        end
      end
    end

    def initialize (params)
      @params = params
    end
  end
end