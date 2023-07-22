require "base64"

module Lucid
  #
  # Provide access to an Action.
  #
  class Endpoint
    def initialize (action_method, action_route, action_name, action_class)
      @action_method = action_method
      @action_route  = action_route
      @action_name   = action_name
      @action_class  = action_class
    end

    attr_reader :action_method
    attr_reader :action_route
    attr_reader :action_name
    attr_reader :action_class

    def encode_state
      Base64.strict_encode64(
         JSON.dump(@action_route.state.to_h)
      )
    end

    def link (string)
      Link.new(@action_route).text(string)
    end

    def button (label)
      Button.new(self, label).to_s
    end

    def build (params)
      @action_class.new(params)
    end
  end
end