class NavBar < Lucid::View
  props do
    required(:link_states).array_of(Lucid::State)
  end

  state do
    attr :expanded, Types::Bool, default: false
  end

  def links
    props.link_states.map do |state|
      state.link(state.page.capitalize, class: { active: state.current? })
    end
  end

  def render
    links.map(&:render)
  end
end
