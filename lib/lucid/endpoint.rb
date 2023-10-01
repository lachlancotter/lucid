require "base64"

module Lucid
  #
  # Provide access to instantiate and run an action via HTTP.
  # The Endpoint class is used to encode action state in the
  # view with form and link elements. And also to instantiate
  # and run the actions that are called via those elements.
  #
  class Endpoint
    #
    # action_method - HTTP method for the request (get, post, etc.)
    # action_route  - Full URL encoding the application state.
    # action_name   - App path identifying the action to run.
    # action_class  - Class that implements the action.
    #
    def initialize (context, action_method, action_route, action_name, action_class)
      @context       = context
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
      Button.new(self, label).template
    end

    def form (data = {}, &block)
      Form.new(self, data).template(&block)
    end

    def build (params)
      @action_class.new(params) do |config|
        # config.delegate(@context.config)
      end
    end
  end
end