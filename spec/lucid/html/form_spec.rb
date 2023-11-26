module Lucid
  module HTML
    describe Form::Builder do
      describe "field_name" do
        context "top level" do
          it "is the name of the field" do
            builder = Form::Builder.new({ foo: "bar" }, nil)
            expect(builder.field_name(:foo)).to eq("foo")
          end
        end

        context "nested field" do
          it "includes the nested key" do
            builder = Form::Builder.new({ foo: { bar: "baz" } }, nil, Path.new(:foo))
            expect(builder.field_name(:bar)).to eq("foo[bar]")
          end
        end

        context "deeply nested field" do
          
        end
      end
    end
  end
end