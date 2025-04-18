module Lucid
  module HTTP
    #
    # Parses and filters message parameters from an HTTP request.
    # 
    class MessageParams
      #
      # Special fields added to forms by default to identify the 
      # component and form that originated the request. 
      # 
      FORM_NAME_PARAM_KEY      = "form"
      COMPONENT_PATH_PARAM_KEY = "component"
      STATE_HASH_PARAM_KEY     = "state"

      def initialize (raw, filter: [])
        @raw    = Types.hash[raw]
        @filter = parse_filter(filter)
      end

      def to_h
        filtered_keys = @filter.concat [FORM_NAME_PARAM_KEY, COMPONENT_PATH_PARAM_KEY, STATE_HASH_PARAM_KEY]
        @raw.reject { |key, _| filtered_keys.include?(key) }
      end

      def state
        Types.hash[@raw[STATE_HASH_PARAM_KEY] || {}]
      end

      def active_form_name
        Types.symbol.optional[@raw[FORM_NAME_PARAM_KEY]]
      end

      def active_component_path
        Types.string.optional[@raw[COMPONENT_PATH_PARAM_KEY]]
      end

      private

      def parse_filter (filter)
        case filter
        when String then [filter]
        when Symbol then [filter.to_s]
        when Array then filter.map { |f| f.to_s }
        else raise ArgumentError, "Invalid filter: #{filter.inspect}"
        end
      end
    end
  end
end