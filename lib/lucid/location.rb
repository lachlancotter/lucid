require "rack"
require "docile"
require "lucid/path"

module Lucid
  #
  # In Lucid, a Route is a representation of the application
  # state (or partial state) as a URL.
  #
  class Location
    def initialize (state, map)
      @state = state
      @map   = map
    end

    attr_reader :state

    def to_s
      @map.encode(@state)
    end

    #
    # Encapsulates rules to map between view states and URLs.
    #
    class Map
      def initialize (opts = {})
        @opts  = opts
        @rules = []
      end

      attr_reader :rules

      def encode (state, buffer = StateBuffer.new)
        @rules.each { |rule| rule.encode(state, buffer) }
        app_root + buffer.to_s
      end

      def decode (buffer_or_query, state = {})
        raise "state must be a hash" unless state.is_a?(Hash)
        buffer = normalize(buffer_or_query)
        state.tap do
          @rules.each { |rule| rule.decode(buffer, state) }
        end
      end

      def normalize (buffer_or_query)
        buffer_or_query.is_a?(QueryBuffer) ?
           buffer_or_query : QueryBuffer.new(buffer_or_query, app_root)
      end

      def app_root
        @opts.fetch(:app_root, "").sub(/^\/$/, "")
      end

      #
      # Base class for rules.
      #
      class Rule
        def initialize (key)
          @key = key
        end

        attr_reader :key
      end

      #
      # Rule for a single path component of a URL.
      #
      class Path < Rule
        def encode (state, buffer)
          value = @key.is_a?(Symbol) ? state[@key] : @key.to_s
          buffer.add_component(value)
        end

        def decode (buffer, state)
          buffer.shift_path_component.tap do |component|
            if component.is_a?(String) && @key.is_a?(Symbol)
              state[@key] = component
            end
          end
        end
      end

      #
      # Rule for a single query parameter of a URL.
      #
      class Param < Rule
        def encode (state, buffer)
          buffer.add_param(@key, state[@key])
        end

        def decode (buffer, state)
          buffer.shift_param(@key).tap do |param|
            state[@key] = param unless param.nil?
          end
        end
      end

      #
      # Pass control to a nested map.
      #
      class Nest < Rule
        def initialize (key, &block)
          super(key)
          @block = block
        end

        def encode (state, buffer)
          buffer.push_scope(@key)
          nested_map.encode(state[@key], buffer)
          buffer.pop_scope
        end

        def decode (buffer, state)
          buffer.push_scope(@key)
          state[@key] = {} unless state.key?(@key)
          nested_map.decode(buffer, state[@key])
          buffer.pop_scope
        end

        private

        def nested_map
          @block.call
        end
      end

      #
      # Shared base class for buffers. Maintain a stack of
      # parameter scopes.
      #
      class ParamStack
        def initialize (top = {})
          @scope = [top]
        end

        def push_scope (key)
          @scope.last[key] = {} unless @scope.last.key?(key)
          @scope << @scope.last[key]
        end

        def pop_scope
          raise "scope underflow" if @scope.length == 1
          @scope.pop
          # If no params were added to the scope, remove it.
          @scope.last.delete_if { |k, v| v.empty? }
        end
      end

      #
      # Extract components from a URL. Path components and query
      # params may be consumed from the buffer to build up a state.
      #
      class QueryBuffer < ParamStack
        def initialize (query_string, app_root)
          query_string = query_string.sub(/^#{app_root}/, "")
          path, params = query_string.split("?")
          @components  = parse_components(path)
          @params      = parse_params(params)
          super(@params)
        end

        def shift_path_component
          @components.shift
        end

        def shift_param (key)
          @scope.last.delete(key)
        end

        private

        def parse_components (path)
          path.sub(/^\//, "").split("/")
        end

        def parse_params (param_string)
          symbolize_keys(
             Rack::Utils.parse_nested_query(param_string)
          )
        end

        def symbolize_keys(hash)
          hash.each_with_object({}) do |(key, value), result|
            result[key.to_sym] = value.is_a?(Hash) ?
               symbolize_keys(value) : value
          end
        end
      end

      #
      # Accumulate the components of a URL from a state.
      # Path components and query params may be added to
      # the buffer to build up a URL.
      #
      class StateBuffer < ParamStack
        def initialize
          @components = []
          @params     = {}
          super(@params)
        end

        def add_component (component)
          @components << component
        end

        def add_param (key, value)
          @scope.last[key] = value
        end

        def to_s
          "/" + @components.join("/") + (
             if @params.any?
               "?" + Rack::Utils.build_nested_query(@params)
             else
               ""
             end
          )
        end
      end

      def self.build (opts = {}, &block)
        Docile.dsl_eval(Builder.new(opts), &block).build
      end

      #
      # DSL for building a Route::Map.
      #
      class Builder
        def initialize(opts)
          @opts  = opts
          @rules = []
        end

        def path (*keys)
          keys.each do |key|
            @rules << Path.new(key)
          end
        end

        def param (*keys)
          keys.each do |key|
            @rules << Param.new(key)
          end
        end

        def nest (key, &block)
          @rules << Nest.new(key, &block)
        end

        def build
          Map.new(@opts).tap do |map|
            map.rules.concat(@rules)
          end
        end
      end
    end
  end
end