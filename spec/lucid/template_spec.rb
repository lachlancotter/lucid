require "lucid/template"

module Lucid
  describe Template do
    it "initializes with a block" do
      block = Proc.new { "Hello, World" }
      template = Template.new(&block)
      expect(template).to be_a(Template)
    end

    it "calls the block when call method is invoked" do
      block = Proc.new { "Hello, World" }
      template = Template.new(&block)
      expect(template.call).to eq("Hello, World")
    end
  end
end
