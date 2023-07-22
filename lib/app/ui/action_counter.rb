require "lucid/event"
require "lucid/view"

class CountChanged < Lucid::Event
  params do
    attribute :old_count
    attribute :new_count
    validate do
      required(:old_count).filled(:integer)
      required(:new_count).filled(:integer)
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

  post :inc do
    source :counter_store

    def call
      puts "INC"
      old_count = counter_store.count
      counter_store.inc!
      CountChanged.notify(
         old_count: old_count,
         new_count: counter_store.count
      )
    end
  end

  post :dec do
    source :counter_store

    def call
      old_count = counter_store.count
      counter_store.dec!
      CountChanged.notify(
         old_count: old_count,
         new_count: counter_store.count
      )
    end
  end

  on(CountChanged) { |event, state| refresh }

  def render
    <<~HTML
      <p>Count: #{state.count}</p>
      <p>#{inc.button("Inc")}</p>
      <p>#{dec.button("Dec")}</p>
    HTML
  end
end