# frozen_string_literal: true

module Lucid
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
              def collection_key
                "foo"
              end
            end.enum([])
          end
        end.new
      end

      let(:changes) { view.changes }

      it "sets a replace action" do
        changes.replace
        expect(changes.count).to eq(1)
        expect(changes.first).to be_a(ChangeSet::Replace)
        expect(changes.to_s).to eq("<h1>Hello, World</h1>")
      end

      it "replaces any other changes" do
        view.subviews.append({})
        changes.replace
        expect(changes.count).to eq(1)
        expect(changes.first).to be_a(ChangeSet::Replace)
        expect(changes.to_s).to eq("<h1>Hello, World</h1>")
      end

      it "is idempotent" do
        changes.replace
        changes.replace
        expect(changes.count).to eq(1)
        expect(changes.first).to be_a(ChangeSet::Replace)
        expect(changes.to_s).to eq("<h1>Hello, World</h1>")
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
            props.subview_class.enum([]) do |e, i|
              { foo: i }
            end
          end
        end.new { { subview_class: subview_class } }
      end
      let(:subview_class) do
        Class.new(Component::Base) do
          prop :foo
          template { |foo| p { text "Item #{foo}" } }
          def collection_key
            props.foo
          end
        end
      end

      let(:changes) { view.changes }

      it "adds an append action" do
        view.item_views.append(foo: 0)
        expect(changes.count).to eq(1)
        expect(changes.first).to be_a(ChangeSet::Append)
        expect(changes.to_s).to match(/<div hx-swap-oob="beforeend:#root" id="item_views\[0\]"><p>Item 0<\/p><\/div>/)
      end

      it "is cumulative" do
        view.item_views.append(foo: 0)
        view.item_views.append(foo: 1)
        expect(changes.count).to eq(2)
        expect(changes.to_s).to match(/<div hx-swap-oob="beforeend:#root" id="item_views\[0\]"><p>Item 0<\/p><\/div>/)
        expect(changes.to_s).to match(/<div hx-swap-oob="beforeend:#root" id="item_views\[1\]"><p>Item 1<\/p><\/div>/)
      end

      it "defers to a replace action" do
        changes.replace
        view.item_views.append(foo: 0)
        expect(changes.count).to eq(1)
        expect(changes.first).to be_a(ChangeSet::Replace)
        expect(changes.to_s).to eq("<h1>Hello, World</h1>")
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
          nest(:item_views) { props.subview_class.enum([]) {} }
        end.new { { subview_class: subview_class } }
      end
      let(:subview_class) do
        Class.new(Component::Base) do
          prop :foo
          def collection_key
            props.foo
          end
          template { |foo| p { text "Item #{foo}" } }
        end
      end

      let(:changes) { view.changes }

      it "adds an prepend action" do
        view.item_views.prepend(foo: 0)
        expect(changes.count).to eq(1)
        expect(changes.first).to be_a(ChangeSet::Prepend)
        expect(changes.to_s).to match(/<div hx-swap-oob="afterbegin:#root" id="item_views\[0\]"><p>Item 0<\/p><\/div>/)
      end

      it "is cumulative" do
        view.item_views.prepend(foo: 0)
        view.item_views.prepend(foo: 1)
        expect(changes.count).to eq(2)
        expect(changes.to_s).to match(/<div hx-swap-oob="afterbegin:#root" id="item_views\[0\]"><p>Item 0<\/p><\/div>/)
        expect(changes.to_s).to match(/<div hx-swap-oob="afterbegin:#root" id="item_views\[1\]"><p>Item 1<\/p><\/div>/)
      end

      it "defers to a replace action" do
        changes.replace
        view.item_views.prepend(foo: 0)
        expect(changes.count).to eq(1)
        expect(changes.first).to be_a(ChangeSet::Replace)
        expect(changes.to_s).to eq("<h1>Hello, World</h1>")
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
          nest :bar, Class.new(Component::Base) {
            use :foo
            template do |foo|
              h1 { text foo }
            end
          }
        end.new(foo: "foo")
        view.update(foo: "bar")
        expect(view.changes.any?).to be(false)
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
        expect(view.changes.any?).to be(false)
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
          expect(view.changes.branches).to be_empty
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
          expect(view.changes.branches).to eq([view.changes])
        end
      end

      context "when child changed" do
        it "contains the child component render" do
          view = Class.new(Component::Base) do
            nest :bar, Class.new(Component::Base) {
              param :baz
              template do |baz|
                h1 { text baz }
              end
            }
          end.new
          view.bar.update(baz: "qux")
          expect(view.changes.branches).to eq([view.bar.changes])
        end
      end

      context "when multiple children changed" do
        it "contains multiple child branches" do
          view = Class.new(Component::Base) do
            nest :a, Class.new(Component::Base) {
              param :foo
              template do |foo|
                h1 { text foo }
              end
            }

            nest :b, Class.new(Component::Base) {
              param :bar
              template do |bar|
                h1 { text bar }
              end
            }

            template do
              h1 { text "Parent" }
              subview :a
              subview :b
            end
          end.new
          view.a.update(foo: "baz")
          view.b.update(bar: "qux")
          branches = view.changes.branches
          expect(branches).not_to include(view.changes)
          expect(branches).to include(view.a.changes)
          expect(branches).to include(view.b.changes)
        end
      end
    end

  end
end