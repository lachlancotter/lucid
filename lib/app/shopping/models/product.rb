module Shopping
  class Product < OpenStruct
    def self.all
      data_file = File.dirname(__FILE__).concat("/../data/products.yml")
      YAML.load(File.read(data_file)).map do |data|
        Product.new(data)
      end
    end

    def self.in_category (category)
      Check[category].type(Category)
      all.select { |p| p.category_id == category.id }
    end

    def self.find (id)
      Check[id].integer
      all.find { |p| p.id == id.to_i }
    end
  end
end