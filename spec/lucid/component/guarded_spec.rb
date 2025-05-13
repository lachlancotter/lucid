module Lucid
  module Component
    describe Guarded do

      context "no guard" do
        it "allows the component to render" do
          component = Class.new(Base).new({})
          expect(component.denied?).to be_falsey
          expect(component.permitted?).to be_truthy
          expect(component.template.render).to eq("Base")
        end
      end

      context "permit" do
        it "allows access to the template" do
          component = Class.new(Base) { guard { Permit } }.new({})
          expect(component.denied?).to be_falsey
          expect(component.permitted?).to be_truthy
          expect(component.template.render).to eq("Base")
        end
      end

      context "deny" do
        it "denies access to the template" do
          component_class = Class.new(Base) do
            guard { Deny }
            element { h1 { text "Exposed!" } }
          end
          expect { component_class.new({}) }.to raise_error(PermissionError)
          # expect(component.denied?).to be_truthy
          # expect(component.permitted?).to be_falsey
          # expect(component.template.render).to eq("Denied")
        end
      end

      context "invalid result" do
        it "raises an exception on render" do
          component_class = Class.new(Base) { guard { "foo" } }
          expect { component_class.new({}) }.to raise_error(Guard::Invalid)
          # expect { component.template }.to raise_error(Guard::Invalid)
        end
      end

      context "guard exception" do
        it "raises an exception on render" do
          component_class = Class.new(Base) { guard { raise "foo" } }
          expect { component_class.new({}) }.to raise_error(RuntimeError)
          # expect { component.template }.to raise_error(RuntimeError)
        end
      end

      context "with arguments" do
        it "passes arguments to the block" do
          component = Class.new(Base) do
            param :foo
            guard { |foo| foo == "bar" ? Permit : Deny }
          end.new(foo: "bar")
          expect(component.permitted?).to be_truthy
        end
      end

      # describe "#check_guards" do
      #   context "no guards" do
      #     it "returns Permit" do
      #       component = Class.new(Base).new({})
      #       expect(component.check_guards).to eq(Permit)
      #     end
      #   end
      #
      #   context "unresolved guard" do
      #     it "raises max patrols exception" do
      #       component = Class.new(Base) { guard { Deny } }.new({})
      #       expect { component.check_guards }.to raise_error(Guarded::MaxPatrolsExceeded)
      #     end
      #   end
      #
      #   context "resolved guard" do
      #     it "returns Permit" do
      #       component = Class.new(Base) do
      #         param :foo, Types.bool.default(false)
      #         guard { |foo| foo ? Permit : Deny }
      #         on(Guard::Denied) { update(foo: true) }
      #       end.new
      #       expect do
      #         expect(component.check_guards).to eq(Permit)
      #       end.not_to raise_error
      #     end
      #   end
      #
      #   context "unresolved nested guard" do
      #     it "raises åx check_guardss exception" do
      #       component = Class.new(Base) do
      #         param :foo, Types.bool.default(false)
      #         on(Guard::Denied) { update(foo: true) }
      #         nest :bar do
      #           Class.new(Base) { guard { Deny } }
      #         end
      #       end.new
      #       expect { component.check_guards }.to raise_error(Guarded::MaxPatrolsExceeded)
      #     end
      #   end
      # end

    end
  end
end