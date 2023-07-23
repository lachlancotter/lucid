module Lucid
  describe Action do
    describe ".store" do
      it "defines a data store" do
        data_store_class = Class.new(Store)
        action = Class.new(Action) do
          store :foo, data_store_class
        end.new({})
        expect(action.foo).to be_a(data_store_class)
      end
    end
  end
end