module Lucid
  #
  # Encapsulates the roles and permissions for a given resource.
  #
  class AccessPolicy
    #
    # Raised when constructing an access policy with an action that is undefined.
    #
    class ActionUndefined < ArgumentError
      def self.check (action, policy_class)
        raise new(action) unless policy_class.permissions.key?(action)
      end

      def initialize (action)
        super("Invalid action for access policy: #{action}")
      end
    end

    class Violation < StandardError
      def initialize (action, user)
        super("Access violation: #{user} does not have permission to #{action}")
      end
    end
    

    attr_reader :action, :user

    def initialize (action, user)
      ActionUndefined.check(action, self.class)
      @action = action
      @user   = user
    end

    def assess
      if permitted?
        Permitted.new
      else
        Forbidden.new
      end
    end

    def permitted?
      permissions.include?(@action)
    end

    def forbidden?
      !permitted?
    end

    #
    # Returns the list of permissions that are granted to the user's roles.
    #
    def permissions
      self.class.permissions.select do |action, role|
        roles.include?(role)
      end.keys
    end

    #
    # Executes the role predicate blocks for this user and returns the
    # roles for which the block returns true.
    #
    def roles
      self.class.roles.select do |role|
        role.assigned?(@user)
      end
    end

    #
    # DSL to define the roles and permissions for this policy.
    #
    class << self
      def assign (role, &block)
        roles << Role.new(role, &block)
      end

      def permit (role, to:)
        permissions[to] = role
      end

      def permissions
        @permissions ||= {}
      end

      def roles
        @roles ||= []
      end
      
      def role_names
        roles.map(&:name)
      end
    end
    
    #
    # 
    # 
    class Role
      attr_reader :name
      
      def initialize (name, &block)
        @name = name
        @block = block
      end
      
      def assigned? (user)
        @block.call(user)
      end
    end

    #
    # Encapsulates the result of an access policy assessment.
    #
    class Assessment

    end

    #
    # Permitted result.
    #
    class Permitted < Assessment
      def permitted?
        true
      end

      def forbidden?
        false
      end

      def if_permitted (&block)
        block.call
      end

      def if_forbidden (&block) end

      def enforce (&block)
        block.call
      end
    end

    #
    # Forbidden result.
    #
    class Forbidden < Assessment
      def permitted?
        false
      end

      def forbidden?
        true
      end

      def if_permitted (&block) end

      def if_forbidden (&block)
        block.call
      end

      def enforce (&block) end
    end
  end
end