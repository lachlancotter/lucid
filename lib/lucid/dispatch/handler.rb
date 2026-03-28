module Lucid
  #
  # Base class for message handlers. Provides a class level DSL for defining
  # message handler blocks, and handler dependencies. Messages are dispatched
  # to the class object. If a matching handler is found, the Handler class is
  # instantiated with that handler block and the message is passed to it.
  # 
  # noinspection RubyResolve
  class Handler
    include Component::Callbacks
    include Injection::Consumer
    extend CommandDispatch
    extend EventBroadcast

    #
    # The message bus is shared among all handlers. This provides a means for
    # handlers to dispatch commands and publish events for other handlers.
    # 
    use :message_bus, Types.instance(MessageBus)

    #
    # Handlers have access to the session object, which is a wrapper around
    # the Rack session. This allows handlers to store and retrieve data
    # from the session.
    # 
    use :session, Types.instance(App::Session)

    #
    # Instantiate a Handler with a container object and code block.
    # The block will be called with the message as an argument.
    # The container provides the dependencies required by the handler.
    #
    def initialize (message, container, &handler)
      super(container)
      @message          = message
      @handler          = handler
      @memoized         = {}
      @permission_check = PermissionCheck.new(self.class, message.class, container)
    end

    #
    # Entry point for handlers.
    # 
    def call
      @permission_check.track do
        instance_exec(@message, &@handler)
      end
    rescue MissingPermissionCheck
      raise
    rescue StandardError => e
      App::Logger.exception(self, e)
      publish(HandlerRaised.new(error: e))
    end

    #
    # Explicit policy check.
    # 
    def with_permission (context = {}, &block)
      @permission_check.checked!
      policy = self.class.policy_class.new(default_policy_context.merge(context))
      if policy.permits_message?(@message)
        yield
      else
        publish(PermissionDenied.new(message: @message))
      end
    end

    #
    # Publish new events for other handlers and components to consume.
    # 
    def publish (event)
      message_bus.publish(event)
    end

    #
    # Dispatch new commands to other handlers.
    # 
    def dispatch (command)
      message_bus.dispatch(command)
    end

    def default_policy_context
      self.class.policy_context_keys.each_with_object({}) do |key, result|
        result[key] = @container[key]
      end
    end

    #
    # DSL methods.
    #
    class << self
      def recruit (message_class)
        recruit_dispatcher message_class
        recruit_broadcaster message_class
      end

      def let (key, &block)
        define_method(key) do
          @memoized.fetch(key) do
            @memoized[key] = instance_exec(@message, &block)
          end
        end
      end

      def adopt (policy_class, *context_keys)
        @policy_class        = policy_class
        @policy_context_keys = context_keys
      end

      def policy_class
        if instance_variable_defined?(:@policy_class)
          @policy_class
        elsif superclass.respond_to?(:policy_class)
          superclass.policy_class
        else
          Policy::PublicPolicy
        end
      end

      def policy_context_keys
        if instance_variable_defined?(:@policy_context_keys)
          @policy_context_keys
        elsif superclass.respond_to?(:policy_context_keys)
          superclass.policy_context_keys
        else
          []
        end
      end

      def policy_adopted?
        if instance_variable_defined?(:@policy_class)
          true
        elsif superclass.respond_to?(:policy_adopted?)
          superclass.policy_adopted?
        else
          false
        end
      end
    end

    class MissingPermissionCheck < StandardError
      def initialize (handler_class, policy_class, message_class)
        super("#{handler_class} adopts #{policy_class} but did not call with_permission for #{message_class}")
      end
    end

    class PermissionCheck
      def initialize (handler_class, message_class, container)
        @handler_class = handler_class
        @message_class = message_class
        @container     = container
        @checked       = false
      end

      def track (&block)
        return yield unless enforced?

        yield
        verify!
      end

      def checked!
        @checked = true
      end

      def verify!
        return unless @handler_class.policy_adopted?
        return if @checked

        raise MissingPermissionCheck.new(@handler_class, @handler_class.policy_class, @message_class)
      end

      def enforced?
        %w[test development].include?(rack_env)
      end

      private

      def rack_env
        if @container.respond_to?(:env)
          @container.env["RACK_ENV"] || @container.env[:RACK_ENV]
        elsif @container.respond_to?(:key?) && @container.key?(:env)
          env = @container[:env]
          env["RACK_ENV"] || env[:RACK_ENV]
        end
      end
    end
  end
end
