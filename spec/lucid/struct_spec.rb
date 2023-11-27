module Lucid
  describe Struct do
    describe ".attribute" do
      it "declares an attribute" do
        struct_class = Class.new(Struct) do
          attribute :foo
        end
        struct       = struct_class.new(foo: "bar")
        expect(struct.foo).to eq("bar")
      end

      it "sets defaults" do
        struct_class = Class.new(Struct) do
          attribute :foo, default: "bar"
        end
        struct       = struct_class.new
        expect(struct.foo).to eq("bar")
      end
    end

    describe ".validate" do
      it "defines a schema" do
        struct_class = Class.new(Struct) do
          attribute :foo
          validate do
            required(:foo).filled
          end
        end
        struct       = struct_class.new
        expect(struct.valid?).to eq(false)
        expect(struct.errors).to eq({ foo: ["must be filled"] })
      end
    end
  end
end