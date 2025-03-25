module Satori
  module Booking
    class WeekCalendarView < Lucid::Component::Base

      element do
        div(class: 'week-header') {
          span(class: 'date-range') { 'Date Range' }
          span(class: 'year') { 'Year' }
          div(class: 'week-nav') {
            link_to previous_week, "<"
            link_to next_week, ">"
          }
          div(class: 'availability') { 'Availability' }
        }
        div(class: 'week-grid') {
          div(class: 'day') { 'Sun' }
          div(class: 'day') { 'Mon' }
          div(class: 'day') { 'Tue' }
          div(class: 'day') { 'Wed' }
          div(class: 'day') { 'Thu' }
          div(class: 'day') { 'Fri' }
          div(class: 'day') { 'Sat' }
          1.upto(7) do |n|
            div(class: 'day') { n.to_s }
          end
        }
      end

      def previous_week
        ShowWeek.new(date: 'previous')
      end

      def next_week
        ShowWeek.new(date: 'next')
      end
    end
  end
end