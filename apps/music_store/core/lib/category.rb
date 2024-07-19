module MusicStore
  class Category < OpenStruct
    def self.all
      YAML.load(File.read(data_file)).map do |data|
        Category.new(data)
      end
    end

    def self.slugs
      @slugs ||= all.map(&:slug)
    end

    def self.find_by_slug (slug)
      all.find { |c| c.slug == slug }
    end

    private

    def self.data_file
      File.dirname(__FILE__).concat("/../data/categories.yml")
    end
  end
end