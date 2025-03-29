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

      def param (key)
        rules << Param.new(key)
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
              map.rules << Param.new(rule.key)
            else
              map.rules << rule
            end
          end
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
        def initialize (key)
          @key = Check[key].type(Symbol, String).value
        end

        attr_reader :key

        def inspect
          "<#{self.class.name.split('::').last} #{key}>"
        end

        def fetch_from (state)
          state.fetch(@key) { raise MissingValue.new(@key) }
        end
      end

      #
      # Rule for a single path component of a URL.
      #
      class Path < Rule
        def initialize(key, index)
          super(key)
          @index = index
        end

        def encode (state, buffer)
          value = @key.is_a?(Symbol) ? fetch_from(state) : @key
          buffer.write_path_segment(value)
        end

        def decode (reader, state)
          reader.read_path_segment(@index).tap do |segment|
            if segment.is_a?(String) && @key.is_a?(Symbol)
              state[@key] = segment
            end
          end
        end
      end

      #
      # Rule for a single query parameter of a URL.
      #
      class Param < Rule
        def encode (state, buffer)
          buffer.write_param(@key, fetch_from(state))
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

        def path (*keys)
          keys.each do |key|
            @rules << Path.new(key, @path_index)
            @path_index += 1
          end
        end

        def param (*keys)
          keys.each do |key|
            @rules << Param.new(key)
          end
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