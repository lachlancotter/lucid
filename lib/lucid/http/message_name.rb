module Lucid
  module HTTP
    #
    # Maps between Messages classes and names encoded for URLs.
    #
    module MessageName
      PUBLIC_NAMESPACE = "Caju".freeze
      LEGACY_NAMESPACE = "Lucid".freeze

      #
      # URL pattern for matching messages.
      # 
      PATTERN = /^(?:.*?\/@\/)(.+?)(\?.*)?$/

      #
      # Checks whether the request contains a message.
      #
      def self.valid? (fullpath)
        fullpath.match?(PATTERN)
      end

      #
      # Maps a request path to a message to the class of that message.
      # 
      def self.to_class (fullpath)
        PathInvalid.check(fullpath)
        path       = fullpath.match(PATTERN)[1]
        class_name = MessageName.decode(path)
        resolve_class(class_name)
      end
 
      #
      # Maps a message class to a URL path.
      # 
      def self.from_class (message_class)
        encode(message_class.name)
      end

      #
      # Converts a CamelCased class name to a slash and dash delimited
      # identifier suitable for use in URLs.
      # For example:
      #   "Lucid::TestLink" => "lucid/test-link"
      #   "Lucid::HTTP::MessageName" => "lucid/http/message-name"
      #
      def self.encode (class_name)
        Types.string[class_name].split('::').map do |part|
          part.split(/(?=[A-Z])/).map do |word|
            word.downcase
          end.join('-')
        end.join('/')
      end

      #
      # Converts a slash and dash delimited identifier to a CamelCased
      # class name.
      #
      def self.decode (path_name)
        path_name.split('/').map do |part|
          part.split('-').map do |word|
            word.capitalize
          end.join
        end.join('::')
      end

      def self.resolve_class (class_name)
        candidate_class_names(class_name).each do |candidate|
          if const_defined_by_name?(candidate)
            return Object.const_get(candidate).tap do |klass|
               ClassInvalid.check(klass)
            end
          end
        end

        Object.const_get(class_name)
      end

      def self.const_defined_by_name? (class_name)
        Object.const_defined?(class_name)
      rescue NameError
        false
      end

      def self.candidate_class_names (class_name)
        [class_name, compatible_class_name(class_name)].compact.uniq
      end

      def self.compatible_class_name (class_name)
        case class_name
        when /\A#{PUBLIC_NAMESPACE}::/
          class_name.sub(/\A#{PUBLIC_NAMESPACE}::/, "#{LEGACY_NAMESPACE}::")
        when /\A#{LEGACY_NAMESPACE}::/
          class_name.sub(/\A#{LEGACY_NAMESPACE}::/, "#{PUBLIC_NAMESPACE}::")
        end
      end

      #
      # Indicates that the given request path does not match the expected format.
      #
      class PathInvalid < StandardError
        def self.check (fullpath)
          raise new(Types.string[fullpath]) unless fullpath.match?(PATTERN)
        end

        def initialize (fullpath)
          super("Cannot parse message URL: #{fullpath}")
        end
      end

      #
      # Indicates that the given class is not a subclass of HTTP::Message.
      # 
      class ClassInvalid < StandardError
        def initialize (klass)
          super("Class #{klass.name} is not a an HTTP message")
        end

        def self.check (klass)
          raise new(klass) unless klass.ancestors.include?(HTTP::Message)
        end
      end
    end
  end
end
