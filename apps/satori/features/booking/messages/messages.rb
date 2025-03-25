module Satori
  module Booking

    # ===================================================== #
    #    Links
    # ===================================================== #

    class ShowWeek < Lucid::Link
      validate do
        required(:date).filled
      end
    end

    class ShowMonth < Lucid::Link
      validate do
        required(:month).filled
      end
    end

    class ShowDay < Lucid::Link
      validate do
        required(:date).filled
      end
    end

    class ChangeTimezone < Lucid::Link
      validate do
        required(:timezone).filled
      end
    end

    class ShowAvailabilitySchedule < Lucid::Link
      validate do
        required(:availability_schedule_id).filled
      end
    end

    class SelectSessionTime < Lucid::Link
      validate do
        required(:session_time).filled
      end
    end
  end
end