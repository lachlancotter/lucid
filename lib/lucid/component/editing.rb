module Lucid
  module Component
    #
    # API for queuing instructions for the ChangeSet. Methods are designed to
    # be called from message handler blocks which are invoked before child
    # components have been instantiated.
    # 
    module Editing
      
      def replace
        delta.replace
      end
      
      def delete
        delta.delete
      end
      
      def append (model, to:)
        nests[to].append(model)
      end
      
      def prepend (model, to:)
        nests[to].prepend(model)
      end
      
      def remove (collection_key, from:)
        nests[from].remove(collection_key)
      end
      
    end
  end
end