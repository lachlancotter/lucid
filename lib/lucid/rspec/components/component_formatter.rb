require "nokogiri"

module Lucid
  module RSpec
    module Components
      class ComponentFormatter
        BLOCK_ELEMENTS = %w[div p h1 h2 h3 h4 h5 h6 form section article header footer nav main blockquote pre table ul ol li hr].to_set.freeze
        INPUT_ELEMENTS = %w[input textarea select].to_set.freeze

        def initialize (component)
          @component = component
        end

        def to_s
          doc = Nokogiri::HTML.fragment(@component.render_full)
          format_node(doc).gsub(/\n{3,}/, "\n\n").strip
        end

        private

        def format_node(node)
          node.children.map { |child|
            content = format_child(child)
            if BLOCK_ELEMENTS.include?(child.name)
              "\n\n#{content}\n\n"
            elsif INPUT_ELEMENTS.include?(child.name)
              "\n#{content}"
            else
              content
            end
          }.join
        end

        def format_child(node)
          if component_element?(node)
            format_component(node)
          else
            case node.name
            when "a"
              href = node["href"]
              "#{format_node(node)} (#{format_href(href)})"
            when "form"
              action = node["action"]
              method = node["method"]
              if HTTP::MessageName.valid?(action)
                "#{format_node(node)} (#{format_href(action)})"
              else
                "#{format_node(node)} (#{method} #{action})"
              end
            when "input"
              name  = node["name"]
              value = node["value"]
              "[#{name}: '#{value}']"
            when "textarea"
              name  = node["name"]
              value = node.text
              "[#{name}: '#{value}']"
            when "select"
              name     = node["name"]
              selected = node.at_css("option[selected]")
              value    = selected ? selected["value"] : nil
              "[#{name}: '#{value}']"
            when "text"
              node.text
            else
              format_node(node)
            end
          end
        end

        def component_element?(node)
          node.element? && node["class"]&.match?(/\A[A-Z]/)
        end

        def format_component(node)
          class_name = node["class"].gsub("-", "::")
          content    = format_node(node).gsub(/\n{3,}/, "\n\n").strip
          indented   = content.gsub(/^(?!$)/, "  ")
          "---\n#{class_name}\n#{indented}"
        end

        def format_href(href)
          if HTTP::MessageName.valid?(href)
            klass = HTTP::MessageName.to_class(href)
            query = URI.parse(href).query
            if query
              "#{klass.name}(#{format_message_params(query)})"
            else
              klass.name
            end
          else
            href
          end
        end

        def format_message_params(query)
          URI.decode_www_form(query)
             .reject { |k, _| k == "_s" }
             .map { |k, v| "#{k}: '#{v}'" }
             .join(", ")
        end
      end
    end
  end
end
