require 'zlib'

module Lucid
  module State
    #
    # Generates qualified parameter names for a component using a
    # path digest strategy. Might make more sense to replace with 
    # a co-ordinate strategy.
    # 
    class Namespace
      def self.from_path (path)
        normalized_path = case path
        when Path then path
        when String, Symbol, Array then Path.new(path)
        else path
        end
        new(digest(normalized_path.to_s))
      end

      def initialize (component)
        @scope = (Types.component | Types.string)[component]
      end

      def qualify (key)
        if empty?
          key
        else
          "#{key}.#{to_s}"
        end
      end

      def to_s
        @result ||= case @scope
        when Component::Base then self.class.digest(@scope.path.to_s)
        when String then @scope
        else fail
        end
      end

      def empty?
        case @scope
        when Component::Base then @scope.root?
        when String then @scope.empty?
        else fail
        end
      end

      private

      def self.digest (path_string)
        Zlib.crc32(path_string).to_s(16)[0...3]
      end
    end
  end
end
