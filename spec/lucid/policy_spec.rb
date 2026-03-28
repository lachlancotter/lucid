module Lucid
  describe Policy do

    describe ".use" do
      it "defines an accessor method for the context" do
        policy_class  = Class.new(Policy) { use :resource }
        context       = { resource: "foo" }
        policy        = policy_class.new(context)
        expect(policy.resource).to eq("foo")
      end
    end

  end
end
