module Lucid
  describe TypeHelpers do
    it "adds a type helper to components" do
      component_class = Class.new(Component::Base) do
        param :count, type(:integer, default: 1)
      end

      component = component_class.new({ count: "3" })

      expect(component.count).to eq(3)
    end

    it "returns the Types module when called without arguments" do
      component_class = Class.new(Component::Base) do
        prop :tags, type.array(String)
      end

      component = component_class.new({}, tags: ["ruby"])

      expect(component.tags).to eq(["ruby"])
    end

    it "supports class-backed prop declarations" do
      project_class = Class.new
      project = project_class.new

      component_class = Class.new(Component::Base) do
        prop :project, type(project_class)
      end

      component = component_class.new({}, project: project)

      expect(component.project).to eq(project)
    end

    it "wraps invalid class-backed props in config errors" do
      project_class = Class.new
      component_class = Class.new(Component::Base) do
        prop :project, type(project_class)
      end
      component = component_class.new({}, project: Object.new)

      expect { component.project }.to raise_error(ConfigError)
    end

    it "adds a type helper to injection consumers" do
      notifier_class = Class.new
      notifier = notifier_class.new
      consumer_base = Class.new { include Injection::Consumer }
      consumer_class = Class.new(consumer_base) do
        use :notifier, type(notifier_class)
      end
      container_class = Class.new(App::Container) do
        define_method(:initialize) { super({}, {}) }
        provide(:notifier) { notifier }
      end

      consumer = consumer_class.new(container_class.new)

      expect(consumer.notifier).to eq(notifier)
    end

    it "adds a type helper to handlers" do
      notifier_class = Class.new
      handler_class = Class.new(Handler) do
        use :notifier, type(notifier_class)
      end

      expect(handler_class.send(:deps_class).schema.key(:notifier).valid?(notifier_class.new)).to be true
    end

    it "validates injection consumer dependencies when read" do
      consumer_base = Class.new { include Injection::Consumer }
      consumer_class = Class.new(consumer_base) do
        use :name, type(:string)
      end
      container_class = Class.new(App::Container) do
        define_method(:initialize) { super({}, {}) }
        provide(:name) { 123 }
      end

      consumer = consumer_class.new(container_class.new)

      expect { consumer.name }.to raise_error(Dry::Types::ConstraintError)
    end
  end
end
