module Satori
  module Booking
    class SessionDetailsView < Lucid::Component::Base
      element do
        div(class: 'coach-avatar')
        div(class: 'coach-name') { 'Coach Name' }
        div(class: 'coach-name') { 'Session Type' }
        div(class: 'session-time') { 'Session Time' }
        div(class: 'session-duration') { 'Session Duration' }
        div(class: 'session-duration') { 'Timezone' }
      end
    end
  end
end