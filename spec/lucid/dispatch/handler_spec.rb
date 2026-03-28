module Lucid
  describe Handler do

    describe "#call" do
      it "handles errors" do
        message_class = Class.new(Command)
        handler_class = Class.new(Handler) { perform(message_class) { raise StandardError } }
        block         = handler_class.handlers[message_class]

        message_bus = MessageBus.new(nil, nil)
        container   = { message_bus: message_bus, session: nil }
        handler     = handler_class.new(message_class.new, container, &block)
        expect(message_bus).to receive(:publish) do |event|
          expect(event).to be_a(HandlerRaised)
          expect(event.error).to be_a(StandardError)
        end
        expect { handler.call }.not_to raise_error
      end
    end

    describe ".adopt" do
      context "default policy" do
        it "always calls" do
          called        = false
          message_class = Class.new(Command)
          container     = { message_bus: nil, session: nil }
          handler       = Handler.new(message_class.new, container) { called = true }
          handler.call
          expect(called).to eq(true)
        end
      end

      context "policy permits message" do
        it "calls the handler" do
          called        = false
          message_class = Class.new(Command)
          policy_class  = Class.new(Policy) do
            def permits_message? (message)
              true
            end
          end
          handler_class = Class.new(Handler) do
            adopt(policy_class)
            perform message_class do |msg|
              with_permission do
                called = true
              end
            end
          end
          message_bus   = MessageBus.new(nil, nil)
          container     = { message_bus: message_bus, session: nil }
          handler_class.dispatch(message_class.new, container)
          expect(called).to eq(true)
        end
      end

      context "policy denies message" do
        it "does not call the handler" do
          called        = false
          message_class = Class.new(Command)
          policy_class  = Class.new(Policy) do
            def permits_message? (message)
              false
            end
          end
          handler_class = Class.new(Handler) do
            adopt(policy_class)
            perform message_class do |msg|
              with_permission do
                called = true
              end
            end
          end
          message_bus   = MessageBus.new(nil, nil)
          container     = { message_bus: message_bus, session: nil }
          handler_class.dispatch(message_class.new, container)
          expect(called).to eq(false)
        end
      end

      context "missing permission check" do
        it "raises in test env when an adopted policy is present but with_permission is not called" do
          message_class = Class.new(Command)
          policy_class  = Class.new(Policy) do
            def permits_message? (message)
              true
            end
          end
          handler_class = Class.new(Handler) do
            adopt(policy_class)
            perform message_class do |msg|
              nil
            end
          end

          container = App::Container.new({}, {
            "RACK_ENV" => "test",
            "rack.session" => {}
          })

          expect {
            handler_class.dispatch(message_class.new, container)
          }.to raise_error(Handler::MissingPermissionCheck, /did not call with_permission/)
        end

        it "does not raise in production env when with_permission is not called" do
          message_class = Class.new(Command)
          policy_class  = Class.new(Policy) do
            def permits_message? (message)
              true
            end
          end
          handler_class = Class.new(Handler) do
            adopt(policy_class)
            perform message_class do |msg|
              nil
            end
          end

          container = App::Container.new({}, {
            "RACK_ENV" => "production",
            "rack.session" => {}
          })

          expect {
            handler_class.dispatch(message_class.new, container)
          }.not_to raise_error
        end
      end

      context "policy inheritance" do
        it "inherits the adopted policy class from the superclass" do
          policy_class  = Class.new(Policy)
          parent_class  = Class.new(Handler) { adopt(policy_class) }
          child_class   = Class.new(parent_class)

          expect(child_class.policy_class).to eq(policy_class)
        end

        it "allows the subclass to override the inherited policy class" do
          parent_policy = Class.new(Policy)
          child_policy  = Class.new(Policy)
          parent_class  = Class.new(Handler) { adopt(parent_policy) }
          child_class   = Class.new(parent_class) { adopt(child_policy) }

          expect(child_class.policy_class).to eq(child_policy)
        end
      end

      context "default policy context" do
        it "merges default context with explicit context" do
          called        = false
          message_class = Class.new(Command)
          policy_class  = Class.new(Policy) do
            use :current_user
            use :resource

            def permits_message? (message)
              current_user == "alice" && resource == "post-1"
            end
          end
          handler_class = Class.new(Handler) do
            adopt(policy_class, :current_user)

            def default_policy_context
              { current_user: "alice" }
            end

            perform message_class do |msg|
              with_permission(resource: "post-1") do
                called = true
              end
            end
          end

          message_bus = MessageBus.new(nil, nil)
          container   = { message_bus: message_bus, session: nil }
          handler_class.dispatch(message_class.new, container)
          expect(called).to eq(true)
        end

        it "loads declared default context keys from the container" do
          called        = false
          message_class = Class.new(Command)
          policy_class  = Class.new(Policy) do
            use :current_user
            use :resource

            def permits_message? (message)
              current_user == "alice" && resource == "post-1"
            end
          end
          handler_class = Class.new(Handler) do
            adopt(policy_class, :current_user)

            perform message_class do |msg|
              with_permission(resource: "post-1") do
                called = true
              end
            end
          end

          message_bus = MessageBus.new(nil, nil)
          container   = { message_bus: message_bus, session: nil, current_user: "alice" }
          handler_class.dispatch(message_class.new, container)
          expect(called).to eq(true)
        end
      end
    end

    describe ".let" do
      it "defines values" do
        handler_class = Class.new(Handler) { let(:foo) { "bar" } }
        message_class = Class.new(Command)
        container     = { message_bus: nil, session: nil }
        message       = message_class.new
        handler       = handler_class.new(message, container) {}
        expect(handler.foo).to eq("bar")
      end

      it "accepts a message argument" do
        handler_class = Class.new(Handler) { let(:foo) { |msg| msg[:count] } }
        message_class = Class.new(Command) { validate { optional(:count) } }
        container     = { message_bus: nil, session: nil }
        message       = message_class.new(count: 42)
        handler       = handler_class.new(message, container) {}
        expect(handler.foo).to eq(42)
      end

      it "memos the result" do
        count         = 0
        handler_class = Class.new(Handler) { let(:foo) { count += 1 } }
        message_class = Class.new(Command) {}
        container     = { message_bus: nil, session: nil }
        message       = message_class.new
        handler       = handler_class.new(message, container) {}
        expect(handler.foo).to eq(1)
        expect(handler.foo).to eq(1)
        expect(count).to eq(1)
      end
    end

  end
end
