require "lucid/view"

#
# Counter that keeps track of state via request params.
#
class LinkCounter < Lucid::View
  state do
    attribute :count, default: 0
    validate do
      required(:count).filled(:integer)
    end
  end

  route { param :count }
  link(:inc) { |state| state.count += 1 }
  link(:dec) { |state| state.count -= 1 }

  def render
    <<~HTML
      <p>Count: #{state.count}</p>
      <p>#{inc.text("Inc")}</p>
      <p>#{dec.text("Dec")}</p>
    HTML
  end
end