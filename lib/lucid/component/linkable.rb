module Lucid
  module Component
    module Linkable
      #
      # Return a local link for the given name and params. Local
      # links are applied only to the current Linkable instance.
      #
      def link (name = nil, params = {})
        check(name).symbol
        Link::Scoped.new(self, name, params)
      end

      #
      # Apply the block for the given link type to the current
      # state, and return the transformed state. Used to resolve the
      # href for global links.
      #
      def visit (link)
        instance_exec(link, &self.class.link(link.key)) if visits?(link)
        nests.values.each { |nest| nest.visit(link) }
      end

      def visits? (link)
        self.class.link(link.key) ? true : false
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
        def visit (link_key, &block)
          @links           ||= {}
          @links[link_key] = block
        end

        def link (link_key)
          (@links || {})[link_key]
        end
      end
    end
  end
end