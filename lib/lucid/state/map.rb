require "docile"

module Lucid
  module State
    #
    # Encapsulates rules to map between view states and URLs.
    #
    class Map
      def initialize
        @rules = []
      end

      attr_reader :rules

      def path (key)
        rules << Path.new(key, path_count)
      end

      def param (key, type)
        rules << Param.new(key, type)
      end

      def path? (key)
        rules.any? { |rule| rule.is_a?(Path) && rule.key == key }
      end

      def path_count
        @rules.count { |rule| rule.is_a?(Path) }
      end

      #
      # If a Map has been defined with path mapping rules, but is used
      # in a component which is not on the route, then the path rules
      # should be treated as query parameters instead.
      #
      def off_route
        Map.new.tap do |map|
          @rules.each do |rule|
            if rule.is_a?(Path)
              map.rules << Param.new(rule.key, Types.string) if rule.key.is_a?(Symbol)
            else
              map.rules << rule
            end
          end
        end
      end

      def encode (state, buffer)
        rules.each do |rule|
          rule.encode(state, buffer)
        end
      end

      def decode (reader, state)
        rules.each do |rule|
          rule.decode(reader, state)
        end
      end

      #
      # Base class for rules.
      #
      class Rule
        def initialize (key, type)
          @key  = (Types.string | Types.symbol)[key]
          @type = type
        end

        attr_reader :key

        def inspect
          "<#{self.class.name.split('::').last} #{key}>"
        end

        def fetch_from (state)
          state.fetch(@key) { raise MissingValue.new(@key) }
        end

        def default_value? (value)
          @type.default? && @type[] == value
        end
      end

      #
      # Rule for a single path component of a URL.
      #
      class Path < Rule
        def initialize(key, index, type = Types.string)
          super(key, type)
          @index = index
        end

        def encode (state, buffer)
          value = @key.is_a?(Symbol) ? fetch_from(state) : @key
          buffer.write_path_segment(value)
        end

        def decode (reader, state)
          reader.read_path_segment(@index).tap do |segment|
            case @key
            when String then MismatchedPath.check(@key, segment)
            when Symbol then state[@key] = segment if segment.is_a?(String)
            end
          end
        end
      end

      #
      # Rule for a single query parameter of a URL.
      #
      class Param < Rule
        def encode (state, buffer)
          value = fetch_from(state)
          # If the value matches the default for the type, we skip encoding it
          # to avoid unnecessary query parameters in the URL.
          buffer.write_param(@key, value) unless default_value?(value)
        end

        def decode (reader, state)
          reader.read_param(@key).tap do |param|
            state[@key] = param unless param.nil?
          end
        end
      end

      class MissingValue < StandardError
        def initialize(key)
          super("missing value for key: #{key}")
        end
      end

      class MismatchedPath < StandardError
        def self.check(expected, actual)
          raise new(expected, actual) unless expected == actual
        end

        def initialize(expected, actual)
          super("expected path segment '#{expected}' but got '#{actual}'")
        end
      end

      def self.build (&block)
        Docile.dsl_eval(Builder.new, &block).build
      end

      #
      # DSL for building a Route::Map.
      #
      class Builder
        def initialize
          @rules      = []
          @path_index = 0
        end

        def path (key, type = Types.string)
          @rules << Path.new(key, @path_index, type)
          @path_index += 1
        end

        def param (key, type = Types.string)
          @rules << Param.new(key, type)
        end

        def query (*keys)
          param(*keys)
        end

        def build
          Map.new.tap do |map|
            map.rules.concat(@rules)
          end
        end
      end
    end
  end
end