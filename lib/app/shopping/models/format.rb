module Shopping
  class Format
    def self.currency (value)
      formatted_value     = '%.2f' % value.to_f
      integer, decimal    = formatted_value.split('.')
      integer_with_commas = integer.chars.to_a.reverse.each_slice(3).map(&:join).join(',').reverse
      "$#{integer_with_commas}.#{decimal}"
    end
  end
end