module Lucid
  #
  # Probably going to remove this.
  # 
  # describe AccessPolicy, skip: true do
  #   describe ".roles" do
  #     context "no roles" do
  #       it "is empty" do
  #         policy_class = Class.new(AccessPolicy) {}
  #         expect(policy_class.roles).to be_empty
  #       end
  #     end
  #
  #     context "one role" do
  #       it "returns the role" do
  #         policy_class = Class.new(AccessPolicy) do
  #           assign(:anyone) { true }
  #         end
  #         expect(policy_class.roles).to eq([:anyone])
  #       end
  #     end
  #
  #     context "multiple roles" do
  #
  #     end
  #   end
  #
  #   describe ".permissions" do
  #
  #   end
  #
  #   context "permitted action" do
  #     it "is permitted" do
  #       policy_class = Class.new(AccessPolicy) do
  #         assign(:anyone) { true }
  #         permit :anyone, to: :view
  #       end
  #       user         = double("User")
  #       policy       = policy_class.new(:view, user)
  #       expect(policy.permitted?).to be(true)
  #       expect(policy.forbidden?).to be(false)
  #       expect(policy.assess).to be_instance_of(AccessPolicy::Permitted)
  #     end
  #   end
  #
  #   context "forbidden action" do
  #     it "is forbidden" do
  #       policy_class = Class.new(AccessPolicy) do
  #         assign(:anyone) { false }
  #         permit :anyone, to: :view
  #       end
  #       user         = double("User")
  #       policy       = policy_class.new(:view, user)
  #       expect(policy.permitted?).to be(false)
  #       expect(policy.forbidden?).to be(true)
  #     end
  #   end
  #
  #   context "invalid action" do
  #     it "raises an exception" do
  #       policy_class = Class.new(AccessPolicy) {}
  #       user         = double("User")
  #       expect {
  #         policy_class.new(:view, user)
  #       }.to raise_error(AccessPolicy::ActionUndefined)
  #     end
  #   end
  #
  # end
end