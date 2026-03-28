module Lucid
  describe Handler::PermissionCheck do
    def build_permission_check (handler_class: handler_class_with_policy, env: "test", message_class: Class.new(Command))
      container = App::Container.new({}, {
        "RACK_ENV" => env,
        "rack.session" => {}
      })

      Handler::PermissionCheck.new(handler_class, message_class, container)
    end

    let(:policy_class) do
      Class.new(Policy) do
        def permits_message? (message)
          true
        end

        def permits_view? (resource)
          true
        end
      end
    end
    let(:handler_class_with_policy) do
      adopted_policy = policy_class
      Class.new(Handler) { adopt(adopted_policy) }
    end
    let(:handler_class_without_policy) { Class.new(Handler) }
    let(:handler_class_with_public_policy) { Class.new(Handler) { adopt(Policy::PublicPolicy) } }

    describe "#track" do
      it "raises when a policy-governed handler completes without a permission check in test env" do
        permission_check = build_permission_check

        expect {
          permission_check.track {}
        }.to raise_error(Handler::PermissionCheck::Skipped, /did not call with_permission/)
      end

      it "does not raise after a permission check has been recorded" do
        permission_check = build_permission_check
        permission_check.checked!

        expect {
          permission_check.track {}
        }.not_to raise_error
      end

      it "does not raise for handlers without an adopted policy" do
        permission_check = build_permission_check(handler_class: handler_class_without_policy)

        expect {
          permission_check.track {}
        }.not_to raise_error
      end

      it "does not raise for handlers adopting PublicPolicy" do
        permission_check = build_permission_check(handler_class: handler_class_with_public_policy)

        expect {
          permission_check.track {}
        }.not_to raise_error
      end

      it "does not raise in production env" do
        permission_check = build_permission_check(env: "production")

        expect {
          permission_check.track {}
        }.not_to raise_error
      end

      it "does not replace exceptions raised by the tracked block" do
        permission_check = build_permission_check

        expect {
          permission_check.track { raise StandardError, "boom" }
        }.to raise_error(StandardError, "boom")
      end
    end
  end
end
