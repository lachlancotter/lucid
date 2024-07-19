module MusicStore
  class App < Lucid::App

    def self.build (session)
      new(config(session))
    end

    def self.config (session)
      {
         base_view_class: Layout,
         handler:         Handler,
         context:         {
            session: Session.new(session)
         },
         session:         Session.new(session),
         app_root:        "/"
      }
    end
    
  end
end