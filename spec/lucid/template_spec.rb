require "lucid/template"

module Lucid
  describe Template do
    it "initializes with a view and a block" do
      view = double("View")
      block = Proc.new { "Hello, World" }
      template = Template.new(view, &block)
      expect(template).to be_a(Template)
    end

    it "calls the block when call method is invoked" do
      view = double("View")
      block = Proc.new { "Hello, World" }
      template = Template.new(view, &block)
      expect(template.call).to eq("Hello, World")
    end
  end
end
