module Lucid
  module HTTP
    #
    # Parse and filter message parameters from an HTTP request.
    # 
    class MessageParams
      #
      # Special fields added to forms by default to identify the 
      # component and form that originated the request. 
      # 
      FORM_NAME_PARAM_KEY      = :form
      COMPONENT_PATH_PARAM_KEY = :component
      STATE_HASH_PARAM_KEY     = :state
      CSRF_TOKEN_PARAM_KEY     = :authenticity_token
      SPECIAL_PARAMS           = [FORM_NAME_PARAM_KEY, COMPONENT_PATH_PARAM_KEY, CSRF_TOKEN_PARAM_KEY].freeze

      def initialize (raw, filter: [])
        @raw    = deep_symbolize_keys(Types.hash[raw])
        @filter = parse_filter(filter)
      end

      def empty?
        to_h.empty?
      end

      def to_h
        @raw.reject do |key, _|
          @filter.include?(key) || SPECIAL_PARAMS.include?(key)
        end
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

      def merge_params (params)
        MessageParams.new(
           @raw.merge(params),
           filter: @filter,
        )
      end

      def merge_state (state)
        MessageParams.new(
           (state.empty? ?
              @raw.reject { |k, _| k == STATE_HASH_PARAM_KEY } :
              @raw.merge(STATE_HASH_PARAM_KEY => state)),
           filter: @filter
        )
      end

      private

      def parse_filter (filter)
        case filter
        when String then [filter.to_sym]
        when Symbol then [filter]
        when Array then filter.map { |f| f.to_sym }
        else raise ArgumentError, "Invalid filter: #{filter.inspect}"
        end
      end

      def deep_symbolize_keys (obj)
        case obj
        when Hash
          obj.each_with_object({}) do |(k, v), result|
            result[k.to_sym] = deep_symbolize_keys(v)
          end
        when Array
          obj.map { |e| deep_symbolize_keys(e) }
        else
          obj
        end
      end

    end
  end
end