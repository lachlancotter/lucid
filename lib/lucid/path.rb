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
      elsif components.is_a?(String)
        components.split("/")
      else
        components
      end
    end

    def == (other)
      to_s == other.to_s
    end

    def concat (component)
      Path.new(@components + [component])
    end

    def to_s
      "/" + @components.join("/")
    end

    private

    def verify_components (components)
      return if components.nil?
      return if components.is_a?(String)
      return if components.is_a?(Array) && components.all? do |component|
        component.is_a?(String) || component.is_a?(Symbol)
      end
      raise ArgumentError,
         "Path components must be a string or an array of strings"
    end
  end
end