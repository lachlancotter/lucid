require "rack"
require "docile"
require "lucid/path"

module Lucid
  #
  # In Lucid, a Route is a representation of the application
  # state (or partial state) as a URL.
  #
  class Route
    def initialize (state, map)
      @state  = state
      @map    = map
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

      def encode (state, buffer = Buffer.new)
        @rules.each { |rule| rule.apply(state, buffer) }
        app_root + buffer.to_s
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
        def apply (state, buffer)
          value = @key.is_a?(Symbol) ? state[@key] : @key.to_s
          buffer.add_component(value)
        end
      end

      #
      # Rule for a single query parameter of a URL.
      #
      class Param < Rule
        def apply (state, buffer)
          buffer.add_param(@key, state[@key])
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

        def apply (state, buffer)
          buffer.push_scope(@key)
          @block.call.encode(state[@key], buffer)
          buffer.pop_scope
        end
      end

      #
      # Structure to accumulate the components of a URL.
      #
      class Buffer
        def initialize
          @components = []
          @params     = {}
          @scope      = [@params]
        end

        def add_component (component)
          @components << component
        end

        def add_param (key, value)
          @scope.last[key] = value
        end

        def push_scope (key)
          @scope.last[key] = {}
          @scope << @scope.last[key]
        end

        def pop_scope
          raise "scope underflow" if @scope.length == 1
          @scope.pop
          # If no params were added to the scope, remove it.
          @scope.last.delete_if { |k, v| v.empty? }
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