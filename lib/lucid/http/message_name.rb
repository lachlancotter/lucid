module Lucid
  module HTTP
    #
    # Maps between Messages classes and names encoded for URLs.
    #
    module MessageName
      #
      # Converts a CamelCased class name to a slash and dash delimited
      # identifier suitable for use in URLs.
      # For example:
      #   "Lucid::TestLink" => "lucid/test-link"
      #   "Lucid::HTTP::MessageName" => "lucid/http/message-name"
      #
      def self.encode (klass)
        klass.name.split('::').map do |part|
          part.split(/(?=[A-Z])/).map do |word|
            word.downcase
          end.join('-')
        end.join('/')
      end

      #
      # Converts a slash and dash delimited identifier to a CamelCased
      # class name.
      #
      def self.decode (name)
        name.split('/').map do |part|
          part.split('-').map do |word|
            word.capitalize
          end.join
        end.join('::')
      end

      def self.to_class (class_name)
        const_get(class_name).tap do |klass|
          raise "Message class #{class_name} not found" unless klass
          raise "Message class #{class_name} is not a link" unless
             klass.ancestors.include?(HTTP::Message)
        end
      end
    end
  end
end