Lucid.root do

  #
  # Define view state.
  #
  data do
    attr_reader :foo
    validates :foo
  end

  route do |path|
    content.route(path)
  end

  route do |path|
    state.foo = path.shift do |path|
      state.bar = path.shift do |path|
        content.route(path)
      end
    end
  end

  # path do |route|
  #   route.encode do ||
  #
  #   end
  # end
  #
  # def parse (route)
  #
  # end
  #
  # def encode (route)
  #
  # end
  #
  # def to_route (route)
  #   content.to_route(route.push(foo, bar).merge(state))
  # end

  path :foo, :bar, tail: :content

  path "/:foo/:bar", tail: :content

  path "/:foo/:bar" do |foo, bar|
    state.foo = map(foo)
    state.bar = map(bar)
  end

  route.map do |path, params|
    path.take(:foo, state)
    path.take(:bar, state)
    path.tail(content)
  end

  select :current_section do
    #
    # Define a state, with delegate class.
    #
    state :dashboard, class: Dashboard
    state :account, class: Account
  end

  #
  # Defining a sub-component inline. The body of the
  # block defines the component states.
  #
  frame :content, bind: :current_section

  #
  # Defining a sub-component with a class. The body of the
  # block generates the config to be passed to the view instance.
  #
  frame :nav, class: Nav do |config|
    current_section.states.each do |section|
      config.items << ({
         name: section.name,
         path: /^#{section.path}/
      })
    end

    select :current, store: nil do
      config.items.each do |item|
        state item.name,
           match: /^#{item.path}/,
           css: "current"
      end
    end
  end

  #
  # Update view state in response to an event.
  #
  on "test.event" do |event, state|
    state.foo = event.data.bar
  end

  #
  # Activate a state on event.
  #
  on "test.event" => :dashboard

  on EventClass do |event, state|
    activate!(dashboard)
    # dashboard.activate!
  end

  source :data_source, class: DataSourceClass do |config|
    config.term = state.foo
  end

  query :data_source, DataSourceClass do |config|

  end

  def data_source
    @cache.fetch(DataSouceClass, config)
  end

end