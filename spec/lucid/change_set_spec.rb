# frozen_string_literal: true

module Lucid
  describe ChangeSet::Branches do
    describe "#to_s" do
      let(:item_class) do
        Class.new(Component::Base) do
          prop :foo
          key { props.foo }
          template { |foo| p { text "Item #{foo}" } }
        end
      end
      let(:base_class) do
        Class.new(Component::Base) do
          prop :item_class
          nest(:a) { Class.new(Component::Base) { template { h1 "Component A" } } }
          nest(:b) { Class.new(Component::Base) { template { h1 "Component B" } } }
          nest(:item_views) { props.item_class.enum([]) { |i| { foo: i } } }
        end
      end
      let(:view) { base_class.new { { item_class: item_class } } }

      context "one change" do
        it "omits the OOB attribute" do
          view.a.element.replace
          expect(view.a.changes.to_s).to match(/<h1>Component A<\/h1>/)
          expect(view.a.changes.to_s).to match(/id="a"/)
          expect(view.a.changes.to_s).not_to match(/hx-swap-oob/)
        end
      end

      context "multiple changes" do
        before do
          view.element.append(view.item_views.build("One"))
          view.element.append(view.item_views.build("Two"))
        end

        describe "first change" do
          subject { view.changes[0] }
          it "omits the OOB attribute" do
            expect(subject).to match(/<p>Item One<\/p>/)
            expect(subject).not_to match(/hx-swap-oob="beforeend:#root"/)
            expect(subject).to match(/id="item_views\[One\]"/)
          end
        end

        describe "other changes" do
          subject { view.changes[1] }
          it "includes the OOB attribute" do
            expect(subject).to match(/<p>Item Two<\/p>/)
            expect(subject).to match(/hx-swap-oob="beforeend:#root"/)
            expect(subject).to match(/id="item_views\[Two\]"/)
          end
        end
      end

      context "nested changes" do
        before do
          view.a.element.replace
          view.b.element.replace
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
            expect(subject).to match(/hx-swap-oob="innerHTML:#b/)
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
          template { h1 { text "Hello, World" } }
          nest(:subviews) do
            Class.new(Component::Base) do
              template { p { text "Item" } }
              key { "foo" }
            end.enum([])
          end
        end.new
      end

      it "sets a replace action" do
        view.element.replace
        expect(view.changes.count).to eq(1)
        expect(view.changes.first).to be_a(ChangeSet::Replace)
        expect(view.changes.to_s).to eq("<h1>Hello, World</h1>")
      end

      it "replaces any other changes" do
        view.subviews.append({})
        view.element.replace
        expect(view.changes.count).to eq(1)
        expect(view.changes.first).to be_a(ChangeSet::Replace)
        expect(view.changes.to_s).to eq("<h1>Hello, World</h1>")
      end

      it "is idempotent" do
        view.element.replace
        view.element.replace
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
          prop :subview_class
          template { h1 { text "Hello, World" } }
          nest :item_views do
            props.subview_class.enum([]) { |i| { foo: i } }
          end
        end.new { { subview_class: subview_class } }
      end
      let(:subview_class) do
        Class.new(Component::Base) do
          prop :foo
          template { |foo| p { text "Item #{foo}" } }
          key { props.foo }
        end
      end

      it "adds an append action" do
        view.element.append(view.item_views.build(0))
        expect(view.changes.count).to eq(1)
        expect(view.changes.first).to be_a(ChangeSet::Append)
        expect(view.changes.to_s).to match(/id="item_views\[0\]"/)
        expect(view.changes.to_s).to match(/<p>Item 0<\/p>/)
      end

      it "is cumulative" do
        view.element.append(view.item_views.build(0))
        view.element.append(view.item_views.build(1))
        expect(view.changes.count).to eq(2)
        expect(view.changes.to_s).to match(/id="item_views\[0\]"/)
        expect(view.changes.to_s).to match(/<p>Item 0<\/p>/)
        expect(view.changes.to_s).to match(/id="item_views\[1\]"/)
        expect(view.changes.to_s).to match(/<p>Item 1<\/p>/)
      end

      it "defers to a replace action" do
        view.element.replace
        view.element.append(view.item_views.build(0))
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
          prop :subview_class
          template { h1 { text "Hello, World" } }
          nest(:item_views) { props.subview_class.enum([]) { |i| { foo: i } } }
        end.new { { subview_class: subview_class } }
      end
      let(:subview_class) do
        Class.new(Component::Base) do
          prop :foo
          key { props.foo }
          template { |foo| p { text "Item #{foo}" } }
        end
      end

      it "adds an prepend action" do
        view.element.prepend(view.item_views.build(0))
        expect(view.changes.count).to eq(1)
        expect(view.changes.first).to be_a(ChangeSet::Prepend)
        expect(view.changes.to_s).to match(/id="item_views\[0\]"/)
        expect(view.changes.to_s).to match(/<p>Item 0<\/p>/)
      end

      it "is cumulative" do
        view.element.prepend(view.item_views.build(0))
        view.element.prepend(view.item_views.build(1))
        expect(view.changes.count).to eq(2)
        expect(view.changes.to_s).to match(/id="item_views\[0\]"/)
        expect(view.changes.to_s).to match(/<p>Item 0<\/p>/)
        expect(view.changes.to_s).to match(/id="item_views\[1\]"/)
        expect(view.changes.to_s).to match(/<p>Item 1<\/p>/)
      end

      it "defers to a replace action" do
        view.element.replace
        view.element.prepend(view.item_views.build(0))
        expect(view.changes.count).to eq(1)
        expect(view.changes.first).to be_a(ChangeSet::Replace)
        expect(view.changes.to_s).to eq("<h1>Hello, World</h1>")
      end
    end

    # ===================================================== #
    #    #any?
    # ===================================================== #

    describe "#any?" do
      it "is false when created" do
        view = Class.new(Component::Base) do
          param :foo
        end.new(foo: "foo")
        expect(view.changes.any?).to be(false)
      end

      it "is true when template state dependencies change" do
        view = Class.new(Component::Base) do
          param :foo
          template do |foo|
            h1 { text foo }
          end
        end.new(foo: "foo")
        view.update(foo: "bar")
        expect(view.changes.any?).to be(true)
      end

      it "is true when template let dependencies change" do
        view = Class.new(Component::Base) do
          param :foo
          let(:bar) { |foo| foo.upcase }
          template do |bar|
            h1 { text bar }
          end
        end.new(foo: "foo")
        view.update(foo: "bar")
        expect(view.changes.any?).to be(true)
      end

      it "is true when template use dependencies change" do
        view = Class.new(Component::Base) do
          param :foo
          nest :bar do
            Class.new(Component::Base) {
              use :foo
              template do |foo|
                h1 { text foo }
              end
            }
          end
        end.new(foo: "foo")
        view.update(foo: "bar")
        expect(view.bar.changes.any?).to be(true)
      end

      it "is false when template dependencies are unchanged" do
        view = Class.new(Component::Base) do
          param :foo
          template do
            h1 { "Test" }
          end
        end.new(foo: "foo")
        view.update(foo: "bar")
        expect(view.element.any?).to be(false)
      end
    end

    # ===================================================== #
    #    #branches
    # ===================================================== #

    describe "#branches" do
      context "when unchanged" do
        it "is empty" do
          view = Class.new(Component::Base) do
            template do
              h1 { text "Hello, World" }
            end
          end.new
          expect(view.changes).to be_empty
        end
      end

      context "when changed" do
        it "contains the root component render" do
          view = Class.new(Component::Base) do
            param :foo
            template do |foo|
              h1 { text foo }
            end
          end.new
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
                template do |baz|
                  h1 { text baz }
                end
              }
            end
          end.new
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
                template do |foo|
                  h1 { text foo }
                end
              }
            end

            nest :b do
              Class.new(Component::Base) {
                param :bar
                template do |bar|
                  h1 { text bar }
                end
              }
            end

            template do
              h1 { text "Parent" }
              subview :a
              subview :b
            end
          end.new
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