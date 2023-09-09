module Lucid
  #
  # Query a view hierarchy using a path string.
  #
  # Takes a path string, and a view object. The path string
  # is a series of method names, and optional array indexes
  # for example:
  #
  #   /foo/bar[n]/baz
  #
  # The method names are sent to the view object, and the
  # result of each method call is used as the receiver for
  # the next method call. If the result of any method call
  # is nil, then the path resolution fails, and nil is
  # returned.
  #
  class ActionPath
    def initialize(path_string, target)
      @path_string = path_string
      @target      = target
    end

    def resolve
      segments = @path_string.split("/").reject(&:empty?)

      if segments.length == 1
        segment = segments.first
        resolve_segment(segment)
      else
        first_segment   = segments.shift
        child_component = resolve_segment(first_segment)
        if child_component.nil?
          nil
        else
          resolve_rest(segments, child_component)
        end
      end
    end

    private

    def resolve_rest (segments, child_component)
      ActionPath.new(segments.join("/"), child_component).resolve
    end

    def resolve_segment (segment)
      if segment.match?(/\[.*\]/)
        key, index = segment.split(/\[|\]/).reject(&:empty?)
        @target.send(key, index.to_i)
      else
        @target.send(segment)
      end
    end
  end
end