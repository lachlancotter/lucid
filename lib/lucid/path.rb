module Lucid
  #
  # Utilities for working with path names.
  # Used to encode paths through the component tree.
  #
  class Path
    class InvalidComponents < ArgumentError
      def initialize (components = [])
        super("Path components must be a symbol, string, or an array of strings: #{components} (#{components.class})")
      end
    end

    def initialize(components = [])
      @components = case components
      when Path then components.components.dup
      when Array then components
      when Symbol then [components.to_s]
      when String then components.sub(/^\//, "").split("/")
      when NilClass then []
      else raise InvalidComponents.new(components)
      end
    end

    def == (other)
      to_s == other.to_s
    end

    def root?
      @components.empty?
    end

    def head
      @components.first
    end

    def tail
      Path.new(@components[1..-1])
    end

    def depth
      @components.length
    end

    def concat (component)
      Path.new(@components + [component.to_s])
    end

    def components
      @components.dup
    end

    def join (separator)
      @components.join(separator)
    end

    def inject (data, &block)
      @components.inject(data, &block)
    end

    def to_s
      "/" + join("/")
    end

  end
end