module Lucid
  module TypeHelpers
    UNDEFINED = Object.new.freeze

    def type (type = UNDEFINED, **options)
      return Types if type.equal?(UNDEFINED) && options.empty?

      Types.resolve(type, **options)
    end
  end
end
