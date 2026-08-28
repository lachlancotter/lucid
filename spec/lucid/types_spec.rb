module Lucid
  describe Types do
    describe ".resolve" do
      it "returns dry types unchanged" do
        expect(Types.resolve(Types.string)).to eq(Types.string)
      end

      it "resolves named primitive types" do
        expect(Types.resolve(:integer)["12"]).to eq(12)
      end

      it "resolves primitive classes to Lucid primitive types" do
        expect(Types.resolve(Integer)["12"]).to eq(12)
      end

      it "resolves application classes to instance types" do
        klass = Class.new
        object = klass.new

        expect(Types.resolve(klass)[object]).to eq(object)
      end

      it "applies optional types" do
        expect(Types.resolve(:integer, optional: true)[nil]).to be_nil
      end

      it "applies default values" do
        expect(Types.resolve(:string, default: "foo".freeze)[]).to eq("foo")
      end

      it "rejects unknown named types" do
        expect { Types.resolve(:missing) }.to raise_error(ArgumentError, /Unknown type/)
      end
    end

    describe ".array" do
      it "normalizes member type expressions" do
        expect(Types.array(String)[["foo"]]).to eq(["foo"])
      end
    end

    describe ".union" do
      it "normalizes member type expressions" do
        type = Types.union(String, Symbol)

        expect(type["foo"]).to eq("foo")
        expect(type[:foo]).to eq(:foo)
      end
    end

    describe ".enum" do
      it "defines an enum over literal values" do
        type = Types.enum("open", "closed")

        expect(type["open"]).to eq("open")
        expect { type["archived"] }.to raise_error(Dry::Types::ConstraintError)
      end
    end
  end
end

