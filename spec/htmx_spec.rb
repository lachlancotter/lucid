# frozen_string_literal: true

require 'rspec'

describe HTMX do
  describe ".oob" do
    context "beforeend" do
      it "uses beforeend" do
        expect(HTMX.oob(beforeend: "parent")).to eq("hx-swap-oob" => "beforeend:#parent")
      end
    end
  end
end
