module Lucid
  describe MessageBus do
    def build_bus (handler_class)
      container = App::Container.new(
         { handler_class: handler_class },
         { "rack.session" => {} }
      )
      container[:message_bus]
    end

    it "dispatches top-level commands" do
      handled       = false
      command_class = Class.new(Command)
      handler_class = Class.new(Handler) do
        perform(command_class) { handled = true }
      end

      build_bus(handler_class).dispatch(command_class.new)

      expect(handled).to eq(true)
    end

    it "defers commands dispatched by a handler until the handler returns" do
      calls                = []
      command_class        = Class.new(Command)
      nested_command_class = Class.new(Command)
      handler_class        = Class.new(Handler) do
        perform(command_class) do
          calls << "start command"
          dispatch nested_command_class.new
          calls << "end command"
        end

        perform(nested_command_class) do
          calls << "nested command"
        end
      end

      build_bus(handler_class).dispatch(command_class.new)

      expect(calls).to eq([
         "start command",
         "end command",
         "nested command"
      ])
    end

    it "defers events published by a handler until the handler returns" do
      calls         = []
      command_class = Class.new(Command)
      event_class   = Class.new(Event)
      handler_class = Class.new(Handler) do
        perform(command_class) do
          calls << "start command"
          publish event_class.new
          calls << "end command"
        end

        subscribe(event_class) do
          calls << "event"
        end
      end

      build_bus(handler_class).dispatch(command_class.new)

      expect(calls).to eq([
         "start command",
         "end command",
         "event"
      ])
    end

    it "processes queued messages in FIFO order" do
      calls                 = []
      command_class          = Class.new(Command)
      first_command_class    = Class.new(Command)
      second_command_class   = Class.new(Command)
      appended_command_class = Class.new(Command)
      event_class            = Class.new(Event)
      handler_class          = Class.new(Handler) do
        perform(command_class) do
          calls << "start command"
          dispatch first_command_class.new
          publish event_class.new
          dispatch second_command_class.new
          calls << "end command"
        end

        perform(first_command_class) do
          calls << "first command"
          dispatch appended_command_class.new
        end

        subscribe(event_class) do
          calls << "event"
        end

        perform(second_command_class) do
          calls << "second command"
        end

        perform(appended_command_class) do
          calls << "appended command"
        end
      end

      build_bus(handler_class).dispatch(command_class.new)

      expect(calls).to eq([
         "start command",
         "end command",
         "first command",
         "event",
         "second command",
         "appended command"
      ])
    end

    it "records published events as soon as they are accepted by the bus" do
      published_during_subscriber = nil
      command_class               = Class.new(Command)
      event_class                 = Class.new(Event)
      handler_class               = Class.new(Handler) do
        perform(command_class) do
          publish event_class.new
        end

        subscribe(event_class) do
          published_during_subscriber = message_bus.published.dup
          raise StandardError, "subscriber failed"
        end
      end

      bus = build_bus(handler_class)
      bus.dispatch(command_class.new)

      expect(published_during_subscriber.map(&:class)).to eq([event_class])
      expect(bus.published.map(&:class)).to eq([event_class, HandlerRaised])
    end

    it "does not record invalid published messages" do
      bus = build_bus(Class.new(Handler))

      expect {
        bus.publish(Object.new)
      }.to raise_error(MessageBus::InvalidMessage)
      expect(bus.published).to eq([])
    end

    it "raises before enqueueing commands with no handler" do
      command_class = Class.new(Command)
      bus           = build_bus(Class.new(Handler))

      expect {
        bus.dispatch(command_class.new)
      }.to raise_error(MessageBus::UndispatchableMessage)

      event_class = Class.new(Event)
      bus.publish(event_class.new)

      expect(bus.published.map(&:class)).to eq([event_class])
    end

    it "reports commands with no handler dispatched from handlers" do
      command_class           = Class.new(Command)
      unhandled_command_class = Class.new(Command)
      handler_class           = Class.new(Handler) do
        perform(command_class) do
          dispatch unhandled_command_class.new
        end
      end

      bus = build_bus(handler_class)

      expect {
        bus.dispatch(command_class.new)
      }.not_to raise_error
      expect(bus.published.map(&:class)).to eq([HandlerRaised])
      expect(bus.published.first.error).to be_a(MessageBus::UndispatchableMessage)
    end

    it "raises when draining exceeds the maximum message count" do
      stub_const("Lucid::MessageBus::MAX_MESSAGES_PER_DRAIN", 3)

      command_class = Class.new(Command)
      handler_class = Class.new(Handler) do
        perform(command_class) do
          dispatch command_class.new
        end
      end

      expect {
        build_bus(handler_class).dispatch(command_class.new)
      }.to raise_error(MessageBus::QueueOverflow, /exceeded 3 messages/)
    end
  end
end
