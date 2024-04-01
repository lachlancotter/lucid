module Lucid
  module Component
    module Linking
      #
      # Return a local link for the given name and params. Local
      # links are applied only to the current Linkable instance.
      #
      def link_to (name = nil, params = {})
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
        visitations[link.key].call(self, link) if visitations.key?(link.key)
        nests.values.each { |nest| nest.visit(link) }
      end

      def visitations
        @visits ||= {}
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
          after_initialize do
            visitations[link_key] = Visit.new(*attrs, **map, &block)
          end
        end
      end

      #
      # Applies a link to a component using a list of attribute symbols,
      # a Hash of symbols or a block.
      #
      class Visit
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