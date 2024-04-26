module Lucid
  module Component
    describe Guarded do

      context "no guard" do
        it "allows the component to render" do
          component = Class.new(Base).new
          expect(component.denied?).to be_falsey
          expect(component.permitted?).to be_truthy
          expect { component.render }.not_to raise_error
        end
      end

      context "invalid result" do
        it "raises an exception on render" do
          component = Class.new(Base) { guard { "foo" } }.new
          expect { component.render }.to raise_error(Guard::Invalid)
        end
      end

      context "guard exception" do
        it "raises an exception on render" do
          component = Class.new(Base) { guard { raise "foo" } }.new
          expect { component.render }.to raise_error(RuntimeError)
        end
      end

      context "permit" do
        it "allows the component to render" do
          component = Class.new(Base) { guard { Permit } }.new
          expect(component.denied?).to be_falsey
          expect(component.permitted?).to be_truthy
          expect(component.render).to be_a(Rendering::Render)
        end
      end

      context "deny" do
        it "raises an exception on render" do
          component = Class.new(Base) { guard { Deny } }.new
          expect(component.denied?).to be_truthy
          expect(component.permitted?).to be_falsey
          expect { component.render }.to raise_error(Guard::Violation)
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

      describe "#if_denied" do
        context "no guards" do
          it "does not call the block" do
            component = Class.new(Base).new
            expect { |b| component.if_denied(&b) }.not_to yield_control
          end
        end

        context "when permitted" do
          it "does not call the block" do
            component = Class.new(Base) { guard { Permit } }.new
            expect { |b| component.if_denied(&b) }.not_to yield_control
          end
        end
        
        context "when denied" do
          it "yields the result to the block" do
            component = Class.new(Base) { guard { Deny } }.new
            expect { |b| component.if_denied(&b) }.to yield_with_args(Guard::Deny)
          end
        end

        context "when denied in subcomponent" do
          it "yields the denied result to the block" do
            component = Class.new(Base) do
              nest(:foo) { Class.new(Base) { guard { Deny } } }
            end.new
            expect { |b| component.foo.if_denied(&b) }.to yield_with_args(Guard::Deny)
            expect { |b| component.if_denied(&b) }.to yield_with_args(Guard::Deny)
          end
        end
      end

      describe "#patrol" do
        context "no guards" do
          it "returns Permit" do
            component = Class.new(Base).new
            expect(component.patrol).to eq(Permit)
          end
        end

        context "unresolved guard" do
          it "raises max patrols exception" do
            component = Class.new(Base) { guard { Deny } }.new
            expect { component.patrol }.to raise_error(Guarded::MaxPatrolsExceeded)
          end
        end

        context "resolved guard" do
          it "returns Permit" do
            component = Class.new(Base) do
              param :foo, default: false
              guard { |foo| foo ? Permit : Deny }
              on(Guard::Denied) { update(foo: true) }
            end.new
            expect do
              expect(component.patrol).to eq(Permit)
            end.not_to raise_error
          end
        end

        context "unresolved nested guard" do
          it "raises åx patrols exception" do
            component = Class.new(Base) do
              param :foo, default: false
              on(Guard::Denied) { update(foo: true) }
              nest :bar do
                Class.new(Base) { guard { Deny } }
              end
            end.new
            expect { component.patrol }.to raise_error(Guarded::MaxPatrolsExceeded)
          end
        end
      end

    end
  end
end