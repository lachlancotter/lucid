require "lucid/event"
require "lucid/view"

class CountChanged < Lucid::Event
  params do
    attribute :count
    validate do
      required(:count).filled(:integer)
    end
  end
end

class ActionCounter < Lucid::View
  state do
    attribute :count, default: 0
    validate do
      required(:count).filled(:integer)
    end
  end

  route { param :count }
  # link(:inc) { |state| state.count += 1 }
  # link(:dec) { |state| state.count -= 1 }

  post :inc do
    source :counter_store
    def call
      counter_store.inc!
      CountChanged.notify(new_count: counter_store.count)
    end
  end

  post :dec do
    source :counter_store
    def call
      counter_store.dec!
      CountChanged.notify(new_count: counter_store.count)
    end
  end

  on CountChanged do |event, state|
    refresh
  end

  def render
    <<~HTML
      <p>Count: #{state.count}</p>
      <p>#{inc.button("Inc")}</p>
      <p>#{dec.button("Dec")}</p>
    HTML
  end
end