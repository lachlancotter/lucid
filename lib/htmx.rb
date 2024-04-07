module HTMX

  #
  # Convert options to HTMX attribute names.
  #
  def self.[] (**options)
    {}.tap do |result|
      options.each do |key, value|
        result["hx-#{key}"] = value
      end
    end
  end

end