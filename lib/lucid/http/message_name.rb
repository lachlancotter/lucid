module Lucid
  module HTTP
    #
    # Maps between Messages classes and names encoded for URLs.
    #
    module MessageName
      #
      # URL pattern for matching messages.
      # 
      PATTERN = /^(?:.*?\/@\/)(.+?)(\?.*)?$/

      #
      # Checks whether the request contains a message.
      #
      def self.message? (request)
        request.fullpath.match?(PATTERN)
      end

      #
      # Maps a request representing a message to the class of that message.
      # 
      def self.to_class (request)
        PathInvalid.check(request.fullpath)
        path       = request.fullpath.match(PATTERN)[1]
        class_name = MessageName.decode(path)
        const_get(class_name).tap do |klass|
          ClassInvalid.check(klass)
        end
      end
      
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

      #
      # Indicates that the given request path does not match the expected format.
      #
      class PathInvalid < StandardError
        def self.check (fullpath)
          raise new(fullpath) unless fullpath.match?(PATTERN)
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