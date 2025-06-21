module Lucid
  module HTTP
    class Endpoint
      def self.relative (url, base: "/")
        uri     = URI.parse(Types.string[url])
        pattern = base.sub(/\/$/, "")
        uri.path.sub(pattern, "").tap do |path|
          query = uri.query || ""
          path << "/" if path.empty?
          path << "?" + query if query != ""
        end
      end
    end
  end
end