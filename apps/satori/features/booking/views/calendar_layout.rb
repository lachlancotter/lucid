module Satori
  module Booking
    class CalendarLayout < Lucid::Component::Base
      nest(:session_details) { SessionDetailsView }
      nest(:month_calendar) { MonthCalendarView }
      nest(:week_calendar) { WeekCalendarView }

      element do
        div(class: 'booking-calendar') {
          div(class: 'sidebar') {
            subview(:session_details)
            subview(:month_calendar)
          }
          subview(:week_calendar)
        }
      end
    end
  end
end