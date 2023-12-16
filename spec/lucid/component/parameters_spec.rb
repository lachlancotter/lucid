module Lucid
  module Component
    describe Parameters do

      describe ".param" do
        it "defines parameters" do
          instance = Class.new(Component::Base) do
            param :foo
          end.new(foo: "bar")
          expect(instance.foo).to eq("bar")
        end

        it "sets defaults" do
          instance = Class.new(Component::Base) do
            param :count, default: 1
          end.new({})
          expect(instance.count).to eq(1)
        end
      end

      describe "validation" do
        context "no schema" do
          it "is always valid" do
            instance = Class.new(Component::Base) do
              param :foo
            end.new({})
            expect(instance).to be_valid
          end
        end

        context "valid input" do
          it "instantiates" do
            instance = Class.new(Component::Base) do
              param :count
              validate do
                required(:count).filled(:integer)
              end
            end.new(count: "1")
            expect(instance).to be_valid
          end
        end

        context "invalid input" do
          it "raises an error" do
            expect {
              Class.new(Component::Base) do
                param :count
                validate do
                  required(:count).filled(:integer)
                end
              end.new(count: "foo")
            }.to raise_error(State::Invalid)
          end
        end
      end
      
    end

  end
end