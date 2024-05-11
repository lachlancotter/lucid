#
# DSL for generating HTMX attributes.
#
class HTMX < Hash
  LIB = {
     src:         "https://unpkg.com/htmx.org@1.9.11",
     integrity:   "sha384-0gxUXCCR8yv9FM2b+U3FDbsKthCI66oH5IA9fHppQq9DDMHuMauqq1ZHBpJxQ0J0",
     crossorigin: "anonymous"
  }

  def self.boost
    self[boost: true]
  end

  def self.oob (innerHTML: nil, beforeend: nil, afterbegin: nil)
    return self["swap-oob": "innerHTML:##{innerHTML}"] unless innerHTML.nil?
    return self["swap-oob": "beforeend:##{beforeend}"] unless beforeend.nil?
    return self["swap-oob": "afterbegin:##{afterbegin}"] unless afterbegin.nil?
    self["swap-oob": true]
  end

  #
  # Convert options to HTMX attribute names.
  #
  def self.[] (**options)
    HTMX.new.tap do |result|
      options.each do |k, v|
        result[map_key(k)] = map_value(v)
      end
    end
  end

  def self.map_key (key)
    "hx-#{key}"
  end

  def self.map_value (value)
    case value
    when true
      "true"
    when false
      "false"
    else
      value.to_s
    end
  end

end