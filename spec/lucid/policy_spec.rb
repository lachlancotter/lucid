module Lucid
  describe Policy do

    describe ".use" do
      it "defines an accessor method for the context" do
        policy_class  = Class.new(Policy) { use :resource }
        context_class = Struct.new(:resource)
        context       = context_class.new("foo")
        policy        = policy_class.new(context)
        expect(policy.resource).to eq("foo")
      end
    end

  end
end