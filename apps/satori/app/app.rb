module Satori
  class App < Lucid::App

    def self.build (session)
      new(config(session))
    end

    def self.config (session)
      {
         base_view_class: Booking::CalendarLayout,
         handler:         Handler,
         context:         {
            session: Lucid::Session.new(session)
         },
         session:         Lucid::Session.new(session),
         app_root:        "/"
      }
    end
    
  end
end