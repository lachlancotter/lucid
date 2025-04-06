# frozen_string_literal: true

module Lucid
  module Component
    describe ChangeSet::Branches do
      describe "#to_s" do
        let(:item_class) do
          Class.new(Component::Base) do
            prop :foo, Types.string
            key { props.foo }
            element { |foo| p { text "Item #{foo}" } }
          end
        end
        let(:base_class) do
          Class.new(Component::Base) do
            prop :item_class, Types.Instance(Class)
            nest(:a) { Class.new(Component::Base) { element { h1 "Component A" } } }
            nest(:b) { Class.new(Component::Base) { element { h1 "Component B" } } }
            nest(:item_views) { props.item_class.enum([]) { |i| { foo: i } } }
          end
        end
        let(:view) { base_class.new({}, item_class: item_class) }

        context "one change" do
          it "omits the OOB attribute" do
            view.a.delta.replace
            expect(view.a.changes.to_s).to match(/<h1>Component A<\/h1>/)
            expect(view.a.changes.to_s).to match(/id="a"/)
            expect(view.a.changes.to_s).not_to match(/hx-swap-oob/)
          end
        end

        context "multiple changes" do
          before do
            view.delta.append(view.item_views.build("One"))
            view.delta.append(view.item_views.build("Two"))
          end

          describe "first change" do
            subject { view.changes[0] }
            it "omits the OOB attribute" do
              expect(subject).to match(/<p>Item One<\/p>/)
              expect(subject).not_to match(/hx-swap-oob="beforeend:#root"/)
              expect(subject).to match(/id="item_views-One"/)
            end
          end

          describe "other changes" do
            subject { view.changes[1] }
            it "includes the OOB attribute" do
              expect(subject).to match(/<p>Item Two<\/p>/)
              expect(subject).to match(/hx-swap-oob="beforeend:#root"/)
              expect(subject).to match(/id="item_views-Two"/)
            end
          end
        end

        context "nested changes" do
          before do
            view.a.delta.replace
            view.b.delta.replace
          end

          describe "first change" do
            subject { view.changes[0] }
            it "omits the OOB attribute" do
              expect(subject).to match(/<h1>Component A<\/h1>/)
              expect(subject).not_to match(/hx-swap-oob/)
              expect(subject).to match(/id="a"/)
            end
          end

          describe "other changes" do
            subject { view.changes[1] }
            it "includes the OOB attribute" do
              expect(subject).to match(/<h1>Component B<\/h1>/)
              expect(subject).to match(/hx-swap-oob="outerHTML:#b/)
              expect(subject).to match(/id="b"/)
            end
          end
        end
      end
    end

    describe ChangeSet do
      # ===================================================== #
      #    #replace
      # ===================================================== #

      describe "#replace" do
        let(:view) do
          Class.new(Component::Base) do
            element { h1 { text "Hello, World" } }
            nest(:subviews) do
              Class.new(Component::Base) do
                element { p { text "Item" } }
                key { "foo" }
              end.enum([])
            end
          end.new({})
        end

        it "sets a replace action" do
          view.delta.replace
          expect(view.changes.count).to eq(1)
          expect(view.changes.first).to be_a(ChangeSet::Replace)
          expect(view.changes.to_s).to eq("<h1>Hello, World</h1>")
        end

        it "replaces any other changes" do
          view.subviews.append({})
          view.delta.replace
          expect(view.changes.count).to eq(1)
          expect(view.changes.first).to be_a(ChangeSet::Replace)
          expect(view.changes.to_s).to eq("<h1>Hello, World</h1>")
        end

        it "is idempotent" do
          view.delta.replace
          view.delta.replace
          expect(view.changes.count).to eq(1)
          expect(view.changes.first).to be_a(ChangeSet::Replace)
          expect(view.changes.to_s).to eq("<h1>Hello, World</h1>")
        end
      end

      # ===================================================== #
      #    #append
      # ===================================================== #

      describe "#append" do
        let(:view) do
          Class.new(Component::Base) do
            prop :subview_class, Types.Instance(Class)
            element { h1 { text "Hello, World" } }
            nest :item_views do |subview_class|
              subview_class.enum([]) { |i| { foo: i } }
            end
          end.new({}, subview_class: subview_class)
        end
        let(:subview_class) do
          Class.new(Component::Base) do
            prop :foo, Types.integer
            element { |foo| p { text "Item #{foo}" } }
            key { props.foo }
          end
        end

        it "adds an append action" do
          view.delta.append(view.item_views.build(0))
          expect(view.changes.count).to eq(1)
          expect(view.changes.first).to be_a(ChangeSet::Append)
          expect(view.changes.to_s).to match(/id="item_views-0"/)
          expect(view.changes.to_s).to match(/<p>Item 0<\/p>/)
        end

        it "is cumulative" do
          view.delta.append(view.item_views.build(0))
          view.delta.append(view.item_views.build(1))
          expect(view.changes.count).to eq(2)
          expect(view.changes.to_s).to match(/id="item_views-0"/)
          expect(view.changes.to_s).to match(/<p>Item 0<\/p>/)
          expect(view.changes.to_s).to match(/id="item_views-1"/)
          expect(view.changes.to_s).to match(/<p>Item 1<\/p>/)
        end

        it "defers to a replace action" do
          view.delta.replace
          view.delta.append(view.item_views.build(0))
          expect(view.changes.count).to eq(1)
          expect(view.changes.first).to be_a(ChangeSet::Replace)
          expect(view.changes.to_s).to eq("<h1>Hello, World</h1>")
        end
      end
      
      # ===================================================== #
      #    #prepend
      # ===================================================== #

      describe "#prepend" do
        let(:view) do
          Class.new(Component::Base) do
            prop :subview_class, Types.Instance(Class)
            element { h1 { text "Hello, World" } }
            nest(:item_views) { props.subview_class.enum([]) { |i| { foo: i } } }
          end.new({}, subview_class: subview_class)
        end
        let(:subview_class) do
          Class.new(Component::Base) do
            prop :foo, Types.integer
            key { props.foo }
            element { |foo| p { text "Item #{foo}" } }
          end
        end

        it "adds an prepend action" do
          view.delta.prepend(view.item_views.build(0))
          expect(view.changes.count).to eq(1)
          expect(view.changes.first).to be_a(ChangeSet::Prepend)
          expect(view.changes.to_s).to match(/id="item_views-0"/)
          expect(view.changes.to_s).to match(/<p>Item 0<\/p>/)
        end

        it "is cumulative" do
          view.delta.prepend(view.item_views.build(0))
          view.delta.prepend(view.item_views.build(1))
          expect(view.changes.count).to eq(2)
          expect(view.changes.to_s).to match(/id="item_views-0"/)
          expect(view.changes.to_s).to match(/<p>Item 0<\/p>/)
          expect(view.changes.to_s).to match(/id="item_views-1"/)
          expect(view.changes.to_s).to match(/<p>Item 1<\/p>/)
        end

        it "defers to a replace action" do
          view.delta.replace
          view.delta.prepend(view.item_views.build(0))
          expect(view.changes.count).to eq(1)
          expect(view.changes.first).to be_a(ChangeSet::Replace)
          expect(view.changes.to_s).to eq("<h1>Hello, World</h1>")
        end
      end

      # ===================================================== #
      #    #remove
      # ===================================================== #

      describe "#remove" do
        let(:view) do
          Class.new(Component::Base) do
            prop :subview_class, Types.subclass(Component::Base)
            element { h1 { text "Hello, World" } }
            nest :item_views do |subview_class|
              subview_class.enum([1,2,3]) { |i| { index: i } }
            end
          end.new({}, subview_class: subview_class)
        end
        let(:subview_class) do
          Class.new(Component::Base) do
            prop :index, Types.integer
            element { |index| p { text "Item #{index}" } }
            key { props.index }
          end
        end
        
        it "adds a delete action for the subcomponent" do
          view.delta.remove(view.item_views.first)
          expect(view.changes.count).to eq(1)
          expect(view.changes.first).to be_a(ChangeSet::Delete)
          expect(view.changes.to_s).to match(/id="item_views-1"/)
          expect(view.changes.to_s).not_to match(/<p>Item 1<\/p>/)
        end

        it "is cumulative" do
          view.delta.remove(view.item_views.first)
          view.delta.remove(view.item_views.last)
          expect(view.changes.count).to eq(2)
          expect(view.changes.to_s).to match(/id="item_views-1"/)
          expect(view.changes.to_s).not_to match(/<p>Item 1<\/p>/)
          expect(view.changes.to_s).to match(/id="item_views-3"/)
          expect(view.changes.to_s).not_to match(/<p>Item 3<\/p>/)
        end

        it "defers to a replace action" do
          view.delta.replace
          view.delta.append(view.item_views.build(0))
          expect(view.changes.count).to eq(1)
          expect(view.changes.first).to be_a(ChangeSet::Replace)
          expect(view.changes.to_s).to eq("<h1>Hello, World</h1>")
        end

        it "overrides changes on the removed component" do
          subcomponent = view.item_views.first
          subcomponent.delta.replace
          view.delta.remove(subcomponent)
          expect(view.changes.count).to eq(1)
          expect(view.changes.first).to be_a(ChangeSet::Delete)
          expect(view.changes.to_s).to match(/id="item_views-1"/)
          expect(view.changes.to_s).not_to match(/<p>Item 1<\/p>/)
        end

        it "override subsequent replace action" do
          subcomponent = view.item_views.first
          view.delta.remove(subcomponent)
          subcomponent.delta.replace
          expect(view.changes.count).to eq(1)
          expect(view.changes.first).to be_a(ChangeSet::Delete)
          expect(view.changes.to_s).to match(/id="item_views-1"/)
          expect(view.changes.to_s).not_to match(/<p>Item 1<\/p>/)
        end
      end
      
      # ===================================================== #
      #    #any?
      # ===================================================== #

      describe "#any?" do
        it "is false when created" do
          view = Class.new(Component::Base) do
            param :foo
          end.new({ foo: "foo" })
          expect(view.changes.any?).to be(false)
        end

        it "is true when template state dependencies change" do
          view = Class.new(Component::Base) do
            param :foo
            element { |foo| h1 { text foo } }
          end.new({ foo: "foo" })
          view.update(foo: "bar")
          expect(view.changes.any?).to be(true)
        end

        it "is true when template let dependencies change" do
          view = Class.new(Component::Base) do
            param :foo
            let(:bar) { |foo| foo.upcase }
            element { |bar| h1 { text bar } }
          end.new({ foo: "foo" })
          view.update(foo: "bar")
          expect(view.changes.any?).to be(true)
        end

        it "is true when template use dependencies change" do
          view = Class.new(Component::Base) do
            param :foo
            nest :bar do
              Class.new(Component::Base) {
                use :foo
                element { |foo| h1 { text foo } }
              }
            end
          end.new({ foo: "foo" })
          view.update(foo: "bar")
          expect(view.bar.changes.any?).to be(true)
        end

        it "is false when template dependencies are unchanged" do
          view = Class.new(Component::Base) do
            param :foo
            element { h1 { "Test" } }
          end.new({ foo: "foo" })
          view.update(foo: "bar")
          expect(view.delta.any?).to be(false)
        end
      end

      # ===================================================== #
      #    #branches
      # ===================================================== #

      describe "#branches" do
        context "when unchanged" do
          it "is empty" do
            view = Class.new(Component::Base) do
              element do
                h1 { text "Hello, World" }
              end
            end.new({})
            expect(view.changes).to be_empty
          end
        end

        context "when changed" do
          it "contains the root component render" do
            view = Class.new(Component::Base) do
              param :foo
              element { |foo| h1 { text foo } }
            end.new({})
            view.update(foo: "bar")
            expect(view.changes.map(&:component)).to eq([view])
          end
        end

        context "when child changed" do
          it "contains the child component render" do
            view = Class.new(Component::Base) do
              nest :bar do
                Class.new(Component::Base) {
                  param :baz
                  element { |baz| h1 { text baz } }
                }
              end
            end.new({})
            view.bar.update(baz: "qux")
            expect(view.changes.map(&:component)).to eq([view.bar])
          end
        end

        context "when multiple children changed" do
          it "contains multiple child branches" do
            view = Class.new(Component::Base) do
              nest :a do
                Class.new(Component::Base) {
                  param :foo
                  element { |foo| h1 { text foo } }
                }
              end

              nest :b do
                Class.new(Component::Base) {
                  param :bar
                  element { |bar| h1 { text bar } }
                }
              end

              element do
                h1 { text "Parent" }
                subview :a
                subview :b
              end
            end.new({})
            view.a.update(foo: "baz")
            view.b.update(bar: "qux")
            expect(view.changes.map(&:component)).not_to include(view)
            expect(view.changes.map(&:component)).to include(view.a)
            expect(view.changes.map(&:component)).to include(view.b)
          end
        end
      end

    end
  end
end