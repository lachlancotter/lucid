module Lucid
  class App
    #
    # A dependency injection container, configured to provide context about
    # the application configuration and environment.
    # 
    class Container < Injection::Container
      def initialize (config, rack_session)
        super()
        @config       = config
        @rack_session = rack_session
      end

      provide(:session) { @config.session_class.new(@rack_session) }
      provide(:message_bus) { @config.handler_class }
    end
  end
end