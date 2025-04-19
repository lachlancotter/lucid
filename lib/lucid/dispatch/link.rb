module Lucid
  #
  # Represents a state in the information space that a user
  # can visit.
  #
  class Link < HTTP::Message

    def self.http_method
      HTTP::Message::GET
    end

    def key
      self.class
    end

    #
    # A link scoped to a specific component path.
    #
    class Scoped < Link
      SCOPE_PARAM = "scope".freeze
      NAME_PARAM  = "name".freeze

      def initialize (target, name, params)
        @target = Types.component[target]
        @name   = Types.symbol[name]
        super(params)
      end

      def query_params
        HTTP::MessageParams.new(super).merge_params(
           SCOPE_PARAM => @target.path.to_s,
           NAME_PARAM  => @name.to_s
        ).to_h
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