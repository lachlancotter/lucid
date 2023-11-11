module Lucid
  module Linkable
    #
    # Return a local link for the given name and params. Local
    # links are applied only to the current Linkable instance.
    #
    def link (name = nil, params = {})
      Link::Local.new(name, params, self)
    end

    #
    # Apply the block for the given link class to the current
    # state, and return the mutated state. Used to resolve the
    # href for global links.
    #
    def visit (link)
      ap nested
      nested.inject(apply_link(link)) do |state, (key, value)|
        puts "state: #{state}"
        puts "key: #{key}, val: #{value}"
        # We might need to prefix the key with the current path.
        # And rather than using merge, we should use mutate.
        state.merge(key => value.visit(link))
      end
    end

    def apply_link (link)
      state.dup.tap do |new_state|
        # TODO Refactor by calling state.mutate and passing the block.
        #   Mutate should take block arguments.
        block = self.class.destination(link.key)
        block.call(link, new_state)
      end
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
        @destinations           ||= {}
        @destinations[link_key] = block
      end

      def destination (link_key)
        (@destinations || {}).fetch(link_key) do
          raise "No destination state defined for #{link_key}"
        end
      end
    end
  end
end