module Lucid
  module State
    #
    # Mutable data structure for manipulating state that maps to and from URL strings.
    # 
    class Store
      def self.from_url (str)
        return new unless str && !str.empty?

        path_part, query_part = str.split('?', 2)
        path_segments         = parse_path(path_part)
        params                = parse_params(query_part)

        new(path_segments, params)
      end

      def initialize (path = [], params = {})
        @path   = Types.array[path]
        @params = Types.hash[params]
      end
      
      def scoped
        Scope.new(self)
      end

      def to_url
        url = '/' + encode_path(@path)

        unless @params.empty?
          url += '?' + encode_params(@params)
        end

        url
      end

      def get_segment (n)
        @path[n]
      end

      def set_segment (n, value)
        @path[n] = value
      end

      def get_param (key)
        @params[key]
      end

      def set_param (key, value)
        @params[key] = value
      end

      private

      def self.parse_path (path_str)
        path_str.split('/').reject(&:empty?).map do |seg|
          decoded = Rack::Utils.unescape(seg)
          decoded == '-' ? nil : decoded
        end
      end

      def self.parse_params (query_str)
        query_str ? Rack::Utils.parse_query(query_str) : {}
      end

      def encode_path (segments)
        # Find the last non-nil segment index
        last_non_nil_index = segments.rindex { |seg| !seg.nil? }
        
        # If all segments are nil, return empty string
        return '' if last_non_nil_index.nil?
        
        # Only encode up to the last non-nil segment
        segments[0..last_non_nil_index].map do |seg|
          seg.nil? ? '-' : Rack::Utils.escape(seg)
        end.join('/')
      end

      def encode_params (params)
        Rack::Utils.build_query(params)
      end

    end
  end
end