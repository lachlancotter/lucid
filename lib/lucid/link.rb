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

    # def to_params
    #   (Link.context ? Link.context.params : {}).
    #      merge(message_name.to_sym => to_h).
    #      merge(msg: message_name)
    # end
    #
    # def to_query
    #   "?" + Rack::Utils.build_query(to_params)
    # end

    #
    # A link to a state of the current component.
    #
    class Local < OpenStruct
      def initialize (target, name, params)
        super(params)
        @name      = name
        @target = target
      end

      def href
        Location.new(apply, @target.routes).to_s
      end

      def to_params
        (Link.context ? Link.context.params : {}).
           merge(message_name.to_sym => to_h).
           merge(msg: message_name.to_s).
           merge(path: @target.path.to_s)
      end

      def message_name
        @name
      end

      def apply
        @target.visit(self)
      end

      def key
        @name
      end
    end

  end
end