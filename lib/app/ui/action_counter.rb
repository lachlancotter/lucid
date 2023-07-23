require "lucid/event"
require "lucid/view"

#
# Event
#
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

#
# Store
#
class CounterStore
  attr_reader :count

  def initialize
    @file_path = File.join(Dir.pwd, 'counter.txt')
    @count = if File.exists?(@file_path)
      File.read(@file_path).to_i
    else
      0
    end
  end

  def inc!
    @count += 1
    write_to_file
  end

  def dec!
    @count -= 1
    write_to_file
  end

  private

  def write_to_file
    File.open(@file_path, 'w') { |file| file.write(@count) }
  end
end

#
# App
#
class ActionCounter < Lucid::View
  store :counter_store, CounterStore

  post :inc do
    store :counter_store, CounterStore

    def call
      old_count = counter_store.count
      counter_store.inc!
      CountChanged.notify(
         old_count: old_count,
         new_count: counter_store.count
      )
    end
  end

  post :dec do
    store :counter_store, CounterStore

    def call
      old_count = counter_store.count
      counter_store.dec!
      CountChanged.notify(
         old_count: old_count,
         new_count: counter_store.count
      )
    end
  end

  on(CountChanged) { |event, state| nil }

  def render
    <<~HTML
      <html>
        <head>
          <title>Counter</title>
        </head>
        <body>
          <p>Count: #{counter_store.count}</p>
          <p>#{inc.button("Inc")}</p>
          <p>#{dec.button("Dec")}</p>
        </body>
      </html>
    HTML
  end
end