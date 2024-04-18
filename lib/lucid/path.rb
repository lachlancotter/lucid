module Lucid
  #
  # Utilities for working with path names.
  # Used to encode paths through the component tree.
  #
  class Path
    class InvalidComponents < ArgumentError
      def initialize (components)
        super("Path components must be a symbol, string, or an array of strings: #{components}")
      end
    end

    def initialize(components = [])
      @components = Match.on(components) do
        type(Array) do
          Check[components].every { |e| e.type(Symbol, String) }.value
        end
        type(Symbol) { [components.to_s] }
        type(String) { components.split("/") }
        type(NilClass) { [] }
        default { InvalidComponents.new(components) }
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
      Path.new(@components + [component])
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