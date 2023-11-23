require "lucid/message"

module Lucid
  module HTTP
    #
    # Maps between Messages classes and names encoded for URLs.
    #
    module MessageName
      def self.encode (klass)
        klass.name.gsub(/::/, '-')
      end

      def self.decode (name)
        name.gsub(/-/, '::')
      end

      def self.to_class (name)
        class_name = decode(name)
        puts "class_name: #{class_name}"
        const_get(class_name).tap do |klass|
          raise "Message class #{class_name} not found" unless klass
          raise "Message class #{class_name} is not a link" unless
             klass.ancestors.include?(Lucid::Message)
        end
      end
    end
  end
end