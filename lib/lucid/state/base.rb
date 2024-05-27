require "dry-schema"

module Lucid
  module State
    # class Invalid < StandardError
    #   def initialize(state)
    #     super(
    #        <<~MSG
    #          Invalid state:
    #           #{state.errors.to_h}
    #           ---
    #           #{state.to_h}
    #        MSG
    #     )
    #   end
    # end

    #
    # Encapsulates the application state.
    #
    class Base
      extend Forwardable
      include Component::Callbacks
      include Attributes
      # include Validated

      def initialize(data = {})
        @data = self.class.map_attributes { |attr| attr.build(data) }
        # raise Invalid, self unless valid?
      end

      def_delegators :@data, :[], :keys, :key?, :to_h

      # def validated (data)
      #   if schema
      #     schema.call(data).to_h
      #   else
      #     data
      #   end
      # end

      def == (other)
        if other.is_a?(Hash)
          to_h.eql?(other)
        else
          super(other)
        end
      end

      def inspect
        "<State #{to_h}>"
      end

      # def valid?
      #   schema ? schema.call(to_h).success? : true
      # end
      #
      # def errors
      #   schema.call(to_h).errors
      # end

      def empty?
        @data.empty?
      end

      # def schema
      #   self.class.schema
      # end

      #
      # Merges the new data into the state, modifying this object.
      #
      def update (data)
        new_data = @data.merge(data)
        @data = self.class.map_attributes { |attr| attr.build(new_data) }
      end
    end
  end
end