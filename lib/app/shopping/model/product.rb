module Shopping
  class Product < OpenStruct
    extend Checked

    def self.all
      data_file = File.dirname(__FILE__).concat("/../data/products.yml")
      YAML.load(File.read(data_file)).map do |data|
        Product.new(data)
      end
    end

    def self.in_category (category)
      all.select { |p| p.category_id == category.id }
    end

    def self.find (id)
      check(id).integer
      all.find { |p| p.id == id.to_i }
    end
  end
end