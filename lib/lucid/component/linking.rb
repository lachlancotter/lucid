module Lucid
  module Component
    module Linking
      #
      # Return a local link for the given name and params. Local
      # links are applied only to the current Linkable instance.
      #
      def link_to (name = nil, params = {})
        Link::Scoped.new(self, Types.symbol[name], params)
      end

      #
      # Apply the block for the given link type to the current
      # state, and return the transformed state. Used to resolve the
      # href for global links.
      #
      def visit (link)
        Types.instance(Link)[link]
        visitors[link.key].call(self, link) if visitors.key?(link.key)
        each_subcomponent do |sub|
          rescue_child_errors(sub.name.value, StateError) do
            sub.visit(link)
          end
        end
      end

      def visitors
        @visitors ||= {}
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
        def to (link_key, *attrs, **map, &block)
          after_initialize do
            visitors[link_key] = Visit.new(*attrs, **map, &block)
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
          data = delta(link)
          component.update(data) if data.any?
          component.instance_exec(link, &@block) if @block
        end

        private

        #
        # Merge attributes from the link with constants from the visit.
        #
        def delta (link)
          whitelist(link).merge(@map)
        end

        #
        # Select specified attributes from the link.
        #
        def whitelist (link)
          link.to_h.select { |k, _| @attrs.include?(k) }
        end
      end
    end
  end
end