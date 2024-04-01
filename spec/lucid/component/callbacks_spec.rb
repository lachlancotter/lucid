module Lucid
  module Component
    describe Callbacks do

      describe ".after_initialize" do
        it "registers a callback hook" do
          component_class = Class.new do
            include Callbacks
            after_initialize { @foo = "bar" }
          end
          expect(component_class.callbacks(:after_initialize).size).to eq(1)
        end

        it "is inherited in subclasses" do
          base_class = Class.new do
            include Callbacks
            after_initialize { @foo = "bar" }
          end
          sub_class = Class.new(base_class)
          expect(sub_class.callbacks(:after_initialize).size).to eq(1)
        end
      end

    end
  end
end