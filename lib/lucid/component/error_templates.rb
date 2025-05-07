module Lucid
  module Component
    module ErrorTemplates
      def self.included (base)
        base.template ParamError do
          div(class: "error param-error") {
            h1 { text "Invalid Request" }
            p { text "The request parameters are invalid." }
          }
        end

        base.template PermissionError do
          div(class: "error permission-error") {
            h1 { text "Permission Denied" }
            p { text "You do not have permission to access this resource." }
          }
        end

        base.template ResourceError do
          div(class: "error resource-error") {
            h1 { text "Resource Not Found" }
            p { text "The requested resource was not found." }
          }
        end

        base.template ConfigError do
          div(class: "error config-error") {
            h1 { text "Invalid Config" }
            p { text "The component was configured incorrectly. This is a bug." }
          }
        end

        base.template StateError do
          div(class: "error state-error") {
            h1 { text "Invalid State" }
            p { text "An invalid state was applied to this component. This is a bug." }
          }
        end
      end

    end
  end
end