module Shopping
  class Category < OpenStruct
    def self.all
      data_file = File.dirname(__FILE__).concat("/../data/categories.yml")
      YAML.load(File.read(data_file)).map do |data|
        Category.new(data)
      end
    end

    def self.find_by_slug (slug)
      all.find { |c| c.slug == slug }
    end
  end
end