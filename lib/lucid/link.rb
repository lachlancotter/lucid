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
      SCOPE_PARAM = "_scope".freeze

      def initialize (target, name, params)
        super(params)
        @name   = name
        @target = target
      end

      def query_params
        {
            NAME_PARAM => message_name,
            ARGS_PARAM => params.merge({
               SCOPE_PARAM => @target.path.to_s
            })
        }
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