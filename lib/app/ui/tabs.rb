require "lucid/component"
require "lucid/state"
require "lucid/route"



class TabNav < Lucid::Component
  def initialize(parent, panes)
    super(parent, { state: "Default" })
    @panes = panes
  end

  attr_reader :panes

  class Default < Lucid::State
    def render
      <<~HTML
        <ul>
          <li><a href="#{panes.states[0].route}">Tab 1</a></li>
          <li><a href="#{panes.states[1].route}">Tab 2</a></li>
          <li><a href="#{panes.states[2].route}">Tab 3</a></li>
        </ul>-
      HTML
    end
  end
end

class TabPanes < Lucid::Component
  def states
    [
       Pane1.new(self),
       Pane2.new(self),
       Pane3.new(self)
    ]
  end

  class Pane1 < Lucid::State
    def render
      <<~HTML
        <p>Tab 1 Content</p>
      HTML
    end
  end

  class Pane2 < Lucid::State
    def render
      <<~HTML
        <p>Tab 2 Content</p>
      HTML
    end
  end

  class Pane3 < Lucid::State
    def render
      <<~HTML
        <p>Tab 3 Content</p>
      HTML
    end
  end
end

class Tabs < Lucid::Component
  def initialize(parent, params)
    super(parent, { state: "Default" })
    @pane_state = current_state
  end

  def nav
    TabNav.new(self, panes)
  end

  def panes
    TabPanes.new(self, @pane_state)
  end

  class Default < Lucid::State
    def render
      <<~HTML
        #{nav.render}
        #{panes.render}
      HTML
    end
  end

end