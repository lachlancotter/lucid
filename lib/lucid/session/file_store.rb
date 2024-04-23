require "lucid"

module Lucid
  module Session
    #
    # Simple file storage for session data using JSON encoding.
    #
    module FileStore
      STORAGE_DIR = Lucid.root + "/tmp/sessions"

      def self.load (id)
        Check[id].string.not_blank
        return {} unless File.exist?(filename(id))
        data = File.read(filename(id))
        parse(data).tap { |h| Check[h].hash }
      end

      def self.save (id, data)
        Check[id].string.not_blank
        Check[data].hash
        FileUtils.mkdir_p(STORAGE_DIR)
        File.write(filename(id), JSON.generate(data))
      end

      def self.delete (id)
        Check[id].string.not_blank
        File.delete(filename(id)) if File.exist?(filename(id))
      end

      def self.use (id)
        if block_given?
          load(id).tap do |data|
            yield data
            save(id, data)
          end
        end
      end

      def self.filename (id)
        "#{STORAGE_DIR}/#{id}.json"
      end

      private

      def self.parse(data)
        JSON.parse(data).map do |key, value|
          [key.to_sym, value]
        end.to_h
      end
    end
  end
end