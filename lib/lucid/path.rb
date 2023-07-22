module Lucid
  #
  # Utilities for working with path names.
  # Used to encode paths through the component tree.
  #
  class Path
    def initialize(components = [])
      @components = if components.nil?
        []
      elsif components.is_a?(String)
        components.split("/")
      else
        components
      end
    end

    def extend (component)
      Path.new(@components + [component])
    end

    def to_s
      "/" + @components.join("/")
    end
  end
end