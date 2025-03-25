module Satori
  module Booking
    class MonthCalendarView < Lucid::Component::Base
      prop :month, Types.Instance(String).default('nov-24')
      prop :active_days, Types.Array(String).default([])
      visit ShowMonth, :month

      element do
        div(class: 'month-header') {
          span(class: 'month') { text 'Month Name' }
          span(class: 'year') { text 'Year' }
          div(class: 'month-nav') {
            link_to previous_month, "<"
            link_to next_month, ">"
          }
        }
        div(class: 'month-grid') {
          div(class: 'day') { text 'Sun' }
          div(class: 'day') { text 'Mon' }
          div(class: 'day') { text 'Tue' }
          div(class: 'day') { text 'Wed' }
          div(class: 'day') { text 'Thu' }
          div(class: 'day') { text 'Fri' }
          div(class: 'day') { text 'Sat' }
          1.upto(28) do |n|
            div(class: 'day') { text n.to_s }
          end
        }
      end

      def previous_month
        ShowMonth.new(month: 'oct-24')
      end

      def next_month
        ShowMonth.new(month: 'dec-24')
      end
    end
  end
end