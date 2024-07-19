module MusicStore
  class Product < OpenStruct
    def self.all
      YAML.load(File.read(data_file)).map { |data| Product.new(data) }
    end

    def self.in_category (category)
      Check[category].type(Category)
      all.select { |p| p.category_id == category.id }
    end

    def self.find (id)
      Check[id].integer
      all.find { |p| p.id == id.to_i }
    end

    private

    def self.data_file
      File.dirname(__FILE__).concat("/../data/products.yml")
    end
  end
end