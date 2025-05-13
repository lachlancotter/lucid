module Lucid
  module Component
    module ErrorHandling

      #
      # When an exception is thrown by a child component, whether during
      # initialization, message application or rendering, we replace the
      # invalid child component with the ErrorPage component.
      # 
      # This stops error propagation in the parent and provides a graceful
      # error page to the user.
      # 
      def rescue_child_errors (name, *errors, &block)
        block.call
      rescue *errors => e
        replace_nest(name) { ErrorPage[error: e] }
      end
       
    end
  end
end