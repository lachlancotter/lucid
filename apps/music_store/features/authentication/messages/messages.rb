module MusicStore
  module Authentication

    # ===================================================== #
    #    Links
    # ===================================================== #

    class ShowLogin < Lucid::Link

    end

    # ===================================================== #
    #    Commands
    # ===================================================== #

    class Authenticate < Lucid::Command
      validate do
        required(:email).filled(:string)
      end
    end

    # ===================================================== #
    #    Events
    # ===================================================== #

    class Authenticated < Lucid::Event
      validate do
        required(:email).filled(:string)
      end
    end

  end
end