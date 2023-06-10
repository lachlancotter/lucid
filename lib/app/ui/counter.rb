require "lucid/view"

#
# Counter that keeps track of state via request params.
#
class LinkCounter < Lucid::View
  # state do
  #   attribute :count, :integer, default: 0
  #
  #   validate do
  #     required(:count).filled
  #   end
  # end

  route do
    param :count
  end

  link :inc do |state|
    state.count += 1
  end

  link :dec do |state|
    state.count -= 1
  end

  def render
    <<~HTML
      <p>Count: #{state.count}</p>
      <p>#{inc.text("Inc")}</p>
      <p>#{dec.text("Dec")}</p>
    HTML
  end
end

# Lucid::App.root(LinkCounter)

# class Counted < Lucid::Event
#   params do
#     required(:old_count).value(:integer)
#     required(:new_count).value(:integer)
#   end
# end

# class Counter < Lucid::View
#   params do
#     required(:count).value(:integer)
#   end
#
#   init do |state|
#     state.count = 0
#   end
#
#   action :inc do |state|
#     state.count += 1
#   end
#
#   action :dec do |state|
#     state.count -= 1
#   end
#
#   action :inc do |old_count|
#     notify(Counted.new({
#        old_count: old_count,
#        new_count: old_count + 1
#     }))
#   end
#
#   action :dec do |state|
#     state.count -= 1
#   end
#
#   link :dec do |state|
#     state.count -= 1
#   end
#
#   on Counted do |event, state|
#     state.count = event.new_count
#   end
#
#   def render
#     <<~HTML
#       <p>Count: #{state.n}</p>
#       <p>#{inc.link("INC")}</p>
#       <p>#{dec.link("INC")}</p>
#     HTML
#   end
# end

