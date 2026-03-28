module Lucid
  module Component
    module Mutation
      protected

      def set (data)
        state_data, temp_data, unknown = partition_mutations(data)

        update(state_data) if state_data.any?
        touch(temp_data) if temp_data.any?

        return if unknown.empty?

        raise ArgumentError, "Unknown writable signals: #{unknown.join(", ")}"
      end

      private

      def partition_mutations (data)
        state_keys = self.class.state_class.schema.keys.map(&:name)
        temp_keys  = temps.keys

        data.each_with_object([{}, {}, []]) do |(key, value), memo|
          state_data, temp_data, unknown = memo

          if state_keys.include?(key)
            state_data[key] = value
          elsif temp_keys.include?(key)
            temp_data[key] = value
          else
            unknown << key
          end
        end
      end
    end
  end
end
