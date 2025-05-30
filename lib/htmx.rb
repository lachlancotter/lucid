#
# DSL for generating HTMX attributes.
#
class HTMX < Hash
  LIB           = {
     src:         "https://unpkg.com/htmx.org@2.0.4",
     integrity:   "sha384-HGfztofotfshcF7+8n44JQL2oJmowVChPTg48S+jvZoztPfvwD79OC/LTtG6dMp+",
     crossorigin: "anonymous"
  }
  IDIOMORPH     = {
     src:         "https://unpkg.com/idiomorph@0.7.3",
     integrity:   "sha384-JcorokHTL/m+D6ZHe2+yFVQopVwZ+91GxAPDyEZ6/A/OEPGEx1+MeNSe2OGvoRS9",
     crossorigin: "anonymous"
  }
  IDIOMORPH_EXT = {
     src:         "https://unpkg.com/idiomorph@0.7.3/dist/idiomorph-ext.min.js",
     integrity:   "sha384-szktAZju9fwY15dZ6D2FKFN4eZoltuXiHStNDJWK9+FARrxJtquql828JzikODob",
     crossorigin: "anonymous"
  }

  def self.boost
    self[boost: true, ext: "morph"]
  end

  def self.oob (morphOuterHTML: nil, outerHTML: nil, beforeend: nil, afterbegin: nil, delete: nil)
    return self["swap-oob": "outerHTML:##{outerHTML}"] unless outerHTML.nil?
    return self["swap-oob": "morph:outerHTML:##{morphOuterHTML}"] unless morphOuterHTML.nil?
    return self["swap-oob": "beforeend:##{beforeend}"] unless beforeend.nil?
    return self["swap-oob": "afterbegin:##{afterbegin}"] unless afterbegin.nil?
    return self["swap-oob": "delete:##{delete}"] unless delete.nil?
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