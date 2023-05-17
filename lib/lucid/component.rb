require "lucid/state"

module Lucid
  class Component
    def initialize (parent = nil, params = { state: "Default" })
      @parent        = parent
      @params        = params
      puts @params
      @current_state = state_class(@params[:state]).new(self)
    end

    attr_reader :parent
    attr_reader :params
    attr_reader :current_state

    def render
      current_state.render
    end

    private

    def state_class (state_name)
      self.class.const_get(state_name)
    end

    class Default < State

    end
  end
end

# module Application
#   class Switch < HyperModel::Component
#
#     # ACTIONS
#     #
#     Toggle = Class.new(Action)
#
#     # resolve: :css, :alpine, :server
#
#     group Toggle, resolve: :server do
#       class Off < State
#         action Toggle => On
#       end
#
#       class On < State
#         action Toggle => Off
#       end
#       # state Off, initial: true do
#       #   action Toggle => Off
#       # end
#       #
#       # state On do
#       #   action Toggle => On
#       # end
#     end
#
#   end
# end