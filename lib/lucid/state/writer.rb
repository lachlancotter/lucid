module Lucid
  module State
    #
    # Accumulate the components of a URL from a state.
    # Path components and query params may be added to
    # the buffer to build up a URL.
    #
    class Writer

      #
      # Add context to errors raised during encoding.
      # 
      class Error < StandardError
        def initialize (component, reason)
          super("Error encoding component: #{component}: #{reason}")
        end
      end

      def initialize
        @store  = Store.new
        @scopes = [@store.scoped]
      end

      def to_s
        @store.to_url
      end

      def with_scope (scope)
        @scopes << scope
        yield @scopes.last
      ensure
        @scopes.pop
      end

      def scope
        @scopes.last
      end

      def scope_for_nest (nest)
        scope.descend(
           nest.parent.class.state_map.path_count,
           nest.ordinal
        )
      end

      def write_component (component, on_route:)
        Types.component[component]
        tap do
          state_map = component.class.state_map
          state_map = state_map.off_route unless on_route
          write_state(state_map, component.state.to_h)
          write_nests(component.nests, on_route: on_route)
        end
      rescue State::Map::MissingValue => e
        raise Error.new(component, e.message)
      end

      def write_state (map, hash)
        map.encode(hash, scope)
      end

      def write_nests (nests, on_route:)
        nests.each do |(name, nest)|
          # TODO handle state for collections
          unless nest.collection?
            with_scope scope_for_nest(nest) do
              write_component(nest.component, on_route: nest.on_route? && on_route)
            end
          end
        end
      end

    end
  end
end