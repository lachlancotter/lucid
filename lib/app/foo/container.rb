class Container < Lucid::View
  config do
    attr :content_class, class: Lucid::State
  end

  def render
    config.content_class.new(state).render
  end
end
