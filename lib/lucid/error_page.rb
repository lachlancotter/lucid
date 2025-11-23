module Lucid
  #
  # If a component cannot be initialized, or rendered due to an error
  # the ErrorPage component is returned instead. 
  # 
  class ErrorPage < Component::Base
    static :error, StandardError

    def template (name = :ignored)
      self.class.template(props.error.class).bind(self)
    end

    template ParamError do
      div(class: "error param-error") {
        h1 { text "Invalid Request" }
        p { text "The request parameters are invalid." }
      }
    end

    template PermissionError do |error|
      div(class: "error permission-error") {
        h1 { text "Permission Denied" }
        p { text "You do not have permission to access this resource." }
      }
    end

    template ResourceError do |error|
      div(class: "error resource-error") {
        h1 { text "Resource Not Found" }
        p { text "The requested resource was not found." }
      }
    end

    template ConfigError do |error|
      div(class: "error config-error") {
        h1 { text "Invalid Config" }
        p { text "The component was configured incorrectly. This is a bug." }
        # h2 { text props.error.message }
        # props.error.backtrace.each do |line|
        #   p { text line }
        # end
      }
    end

    template StateError do |error|
      div(class: "error state-error") {
        h1 { text "Invalid State" }
        p { text "An invalid state was applied to this component. This is a bug." }
      }
    end

    template StandardError do |error|
      div(class: "error unknown-error") {
        h1 { text "Unknown Error" }
        p { text "Could not fulfil the request due to an unknown error." }
        h2 { text props.error.message }
        props.error.backtrace.each do |line|
          p { text line }
        end
      }
    end
  end
end