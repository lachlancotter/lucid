require "lucid/message"

module Lucid
  #
  # Represents a state in the information space that a user
  # can visit.
  #
  class Link < Message

    def http_method
      Message::GET
    end

    def key
      self.class
    end

    #
    # A link scoped to a specific component path.
    #
    class Scoped < Link
      SCOPE_PARAM = "scope".freeze

      def initialize (target, name, params)
        @target = check(target).type(Component::Base).value
        @name   = check(name).symbol.value
        super(params)
      end

      def query_params
        super.tap do |params|
          params[MESSAGE_PARAM][SCOPE_PARAM] = @target.path.to_s
        end
      end

      def message_name
        @name
      end

      def key
        @name
      end
    end

  end
end