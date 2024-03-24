module Lucid
  module Component
    module Linkable
      #
      # Return a local link for the given name and params. Local
      # links are applied only to the current Linkable instance.
      #
      def link (name = nil, params = {})
        Check[name].symbol
        Link::Scoped.new(self, name, params)
      end

      #
      # Apply the block for the given link type to the current
      # state, and return the transformed state. Used to resolve the
      # href for global links.
      #
      def visit (link)
        Check[link].type(Link)
        visits?(link) do |application|
          application.call(self, link)
        end
        nests.values.each { |nest| nest.visit(link) }
      end

      def visits? (link)
        Check[link].type(Link)
        link_application = self.class.link(link.key)
        yield link_application if link_application
      end

      def self.included (base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        #
        # Defines the state the component needs to be in to answer
        # the given query. The block is passed the query instance
        # and a copy of the current view state. The block should
        # mutate the state to reflect the query.
        #
        # Returns the route to the view state that answers the query.
        #
        # link_key may be a Symbol or a Link subclass.
        #
        def visit (link_key, *attrs, **map, &block)
          @links           ||= {}
          @links[link_key] = LinkApplication.new(*attrs, **map, &block)
        end

        def link (link_key)
          (@links || {})[link_key]
        end
      end

      #
      # Applies a link to a component using a list of attribute symbols,
      # a Hash of symbols or a block.
      #
      class LinkApplication
        def initialize (*attrs, **map, &block)
          @attrs = attrs
          @map   = map
          @block = block
        end

        def call (component, link)
          if @attrs.any?
            component.state.update(
               link.to_h.select { |k, _| @attrs.include?(k) }
            )
          end
          component.state.update(@map) if @map.any?
          component.instance_exec(link, &@block) if @block
        end
      end
    end
  end
end