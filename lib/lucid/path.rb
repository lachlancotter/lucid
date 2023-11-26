module Lucid
  #
  # Utilities for working with path names.
  # Used to encode paths through the component tree.
  #
  class Path
    def initialize(components = [])
      verify_components(components)
      @components = if components.nil?
        []
      elsif components.is_a?(Symbol)
        [components.to_s]
      elsif components.is_a?(String)
        components.split("/")
      else
        components
      end
    end

    def == (other)
      to_s == other.to_s
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
      Path.new(@components + [component])
    end

    def components
      @components.dup
    end

    def join (separator)
      @components.join(separator)
    end

    def to_s
      "/" + join("/")
    end

    private

    def verify_components (components)
      return if components.nil?
      return if components.is_a?(String)
      return if components.is_a?(Symbol)
      return if components.is_a?(Array) && components.all? do |component|
        component.is_a?(String) || component.is_a?(Symbol)
      end
      raise ArgumentError,
         "Path components must be a symbol, string, or an array of strings: #{components}"
    end
  end
end