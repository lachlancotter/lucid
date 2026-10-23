module Lucid
  module Component
    describe Title do

      it "defaults to an 'Untitled'" do
        component_class = Class.new(Component::Base) {}
        component       = component_class.new({})
        expect(component.title).to eq("Untitled")
      end

      it "returns the block value" do
        component_class = Class.new(Component::Base) do
          title { "Title" }
        end
        component       = component_class.new({})
        expect(component.title).to eq("Title")
      end

      it "accepts signal arguments" do
        component_class = Class.new(Component::Base) do
          param :name, Types.string
          title { |name| "Hello, #{name}" }
        end
        component       = component_class.new({ name: "World" })
        expect(component.title).to eq("Hello, World")
      end

      it "includes a nested title" do
        nested_component_class = Class.new(Component::Base) do
          title { "Nested" }
        end
        base_component_class   = Class.new(Component::Base) do
          route "/base", nest: :nested_component
          nest(:nested_component) { nested_component_class }
          title { |nested_title| "Base: #{nested_title}" }
        end
        component = base_component_class.new({})
        expect(component.title).to eq("Base: Nested")
      end

      context "with a query-backed title" do
        let(:calls) { [] }
        let(:component) do
          invocations = calls
          Class.new(Component::Base) do
            param :name, Types.string.default("World".freeze)
            param :other, Types.integer.default(0)
            let(:record) do |name|
              invocations << :query
              name.upcase
            end
            title do |record|
              invocations << :title
              "Hello, #{record}"
            end
          end.new({})
        end

        it "does not evaluate title dependencies during construction" do
          component

          expect(calls).to be_empty
        end

        it "checks title dirtiness without evaluating dependencies" do
          changed = component.title_changed?

          expect(changed).to be(false)
          expect(calls).to be_empty
          expect(component.changes).to be_empty
        end

        it "memoizes title dependencies across reads" do
          component.title

          title = component.title

          expect(title).to eq("Hello, WORLD")
          expect(calls).to eq([:query, :title])
        end

        it "keeps the title clean after unrelated state changes" do
          component.send(:update, other: 1)

          expect(component.title_changed?).to be(false)
          expect(calls).to be_empty
        end

        it "keeps the title clean after equal-value state updates" do
          component.send(:update, name: "World")

          expect(component.title_changed?).to be(false)
          expect(calls).to be_empty
        end

        it "dirties the title transitively without evaluating dependencies" do
          component.send(:update, name: "Lucid")

          expect(component.title_changed?).to be(true)
          expect(calls).to be_empty
          expect(component.changes).to be_empty
        end

        it "refreshes memoized title data after a dependency changes" do
          component.title
          component.send(:update, name: "Lucid")

          title = component.title

          expect(title).to eq("Hello, LUCID")
          expect(calls).to eq([:query, :title, :query, :title])
        end

        it "dirties the title after explicit dependency invalidation" do
          component.invalidate(:record)

          expect(component.title_changed?).to be(true)
          expect(calls).to be_empty
          expect(component.changes).to be_empty
        end

        it "refreshes memoized title data after explicit invalidation" do
          component.title
          component.invalidate(:record)

          title = component.title

          expect(title).to eq("Hello, WORLD")
          expect(calls).to eq([:query, :title, :query, :title])
        end
      end

      [false, true].each do |during_build|
        it "propagates through multiple routed levels #{during_build ? 'during' : 'after'} construction without evaluation" do
          refresh = Class.new(Event)
          child_class = Class.new(Component::Base) do
            let(:record) { raise "Title data was evaluated" }
            title { |record| record }
            on(refresh) { invalidate(:record) }
          end
          middle_class = Class.new(Component::Base) do
            route "/", nest: :child
            nest(:child) { child_class }
            title { |nested_title| "Middle: #{nested_title}" }
          end
          root_class = Class.new(Component::Base) do
            route "/", nest: :middle
            nest(:middle) { middle_class }
            title { |nested_title| "Root: #{nested_title}" }
          end
          component = root_class.new({}, *(during_build ? [refresh.new] : []))
          unless during_build
            component.middle.child.invalidate(:record)
          end

          expect(component.middle.child.title_changed?).to be(true)
          expect(component.middle.title_changed?).to be(true)
          expect(component.title_changed?).to be(true)
          expect(component.changes).to be_empty
        end
      end

      it "propagates inherited prop invalidation before parent subscriptions exist" do
        change = Class.new(Link)
        child_class = Class.new(Component::Base) do
          prop :name, Types.string
          title { |name| name }
        end
        component = Class.new(Component::Base) do
          route "/", nest: :child
          param :name, Types.string.default("Before".freeze)
          to change, name: "After"
          nest(:child) { child_class[:name] }
          title { |nested_title| nested_title }
        end.new({}, change.new)

        expect(component.title_changed?).to be(true)
        expect(component.title).to eq("After")
        expect(component.changes).to be_empty
      end

      context "with routed and unrelated nests" do
        let(:change_selection) { Class.new(Link) }
        let(:change_other_selection) { Class.new(Link) }
        let(:component_class) do
          child_class = Class.new(Component::Base) { title { "Child" } }
          other_class = Class.new(Component::Base) { title { "Other" } }
          routed_change = change_selection
          unrelated_change = change_other_selection
          Class.new(Component::Base) do
            route "/", nest: :child
            param :selection, Types.bool.default(false)
            param :other_selection, Types.bool.default(false)
            to routed_change, selection: true
            to unrelated_change, other_selection: true
            nest(:child) { |selection| selection ? other_class : child_class }
            nest(:other) { |other_selection| other_selection ? other_class : child_class }
            title { |nested_title| "Root: #{nested_title}" }
          end
        end

        it "keeps the title clean during nest initialization" do
          component = component_class.new({})

          expect(component.title_changed?).to be(false)
          expect(component.title).to eq("Root: Child")
        end

        it "ignores title invalidation in an unrelated child" do
          component = component_class.new({})

          component.other.invalidate(:title)

          expect(component.title_changed?).to be(false)
        end

        it "ignores selection changes in an unrelated nest" do
          component = component_class.new({}, change_other_selection.new)

          expect(component.title_changed?).to be(false)
          expect(component.other.title).to eq("Other")
        end

        it "dirties the composed title after routed selection changes" do
          component = component_class.new({}, change_selection.new)

          expect(component.title_changed?).to be(true)
          expect(component.title).to eq("Root: Other")
        end
      end

      it "conservatively invalidates a changed selection even when it selects the same class" do
        change = Class.new(Link)
        child_class = Class.new(Component::Base) { title { "Child" } }
        component = Class.new(Component::Base) do
          route "/", nest: :child
          param :selection, Types.bool.default(false)
          to change, selection: true
          nest(:child) { |selection| child_class }
          title { |nested_title| nested_title }
        end.new({}, change.new)

        expect(component.title_changed?).to be(true)
        expect(component.title).to eq("Child")
        expect(component.changes).to be_empty
      end

      context "with memoized composed titles" do
        let(:calls) { [] }
        let(:root_class) do
          invocations = calls
          child_class = Class.new(Component::Base) do
            title do
              invocations << :title
              "Child #{invocations.length}"
            end
          end
          Class.new(Component::Base) do
            route "/", nest: :child
            nest(:child) { child_class }
            title { |nested_title| "Root: #{nested_title}" }
          end
        end

        it "does not evaluate composed titles during construction" do
          root_class.new({})

          expect(calls).to be_empty
        end

        it "memoizes composed titles within an instance" do
          component = root_class.new({})
          component.title

          title = component.title

          expect(title).to eq("Root: Child 1")
          expect(calls).to eq([:title])
        end

        it "evaluates composed titles separately for each instance" do
          first = root_class.new({})
          second = root_class.new({})
          first.title

          title = second.title

          expect(title).to eq("Root: Child 2")
          expect(calls).to eq([:title, :title])
        end

        it "invalidates a memoized composed title without evaluating it" do
          component = root_class.new({})
          component.title

          component.child.invalidate(:title)

          expect(component.title_changed?).to be(true)
          expect(calls).to eq([:title])
        end

        it "refreshes a composed title after child invalidation" do
          component = root_class.new({})
          component.title
          component.child.invalidate(:title)

          title = component.title

          expect(title).to eq("Root: Child 2")
          expect(calls).to eq([:title, :title])
        end

        it "preserves another instance's memoized title after invalidation" do
          first = root_class.new({})
          second = root_class.new({})
          first.title
          second.title
          first.child.invalidate(:title)
          first.title

          title = second.title

          expect(title).to eq("Root: Child 2")
          expect(calls).to eq([:title, :title, :title])
        end
      end

      {
        nil => "Untitled",
        proc { "Parent" } => "Parent",
        proc { "Parent: #{nested_title}" } => "Parent: Child",
      }.each do |declaration, expected_title|
        it "keeps #{expected_title.inspect} independent without a nested_title parameter" do
          child_class = Class.new(Component::Base) { title { "Child" } }
          component = Class.new(Component::Base) do
            route "/", nest: :child
            nest(:child) { child_class }
            title(&declaration) if declaration
          end.new({})

          component.child.invalidate(:title)

          expect(component.title_changed?).to be(false)
          expect(component.title).to eq(expected_title)
        end
      end

    end
  end
end