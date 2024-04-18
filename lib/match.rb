#
# Pattern matching.
#
class Match
  class NoMatch < StandardError
    def initialize (value)
      super("No match for #{value}")
    end
  end

  def self.on (value, &block)
    new(value).match(&block)
  end

  def initialize (value)
    @value = value
  end

  def match (&block)
    block_binding = block.binding
    match_block   = catch(:match) { instance_eval(&block) }
    raise NoMatch.new(@value) unless match_block
    block_binding.receiver.instance_exec(@value, &match_block)
  end

  # def is (pattern, &block)
  #   throw :match, block if @value == pattern
  # end

  def value (val, &block)
    throw :match, block if @value == val
  end

  def type (klass, &block)
    throw :match, block if @value.is_a?(klass)
  end

  def responds_to (*methods, &block)
    throw :match, block if methods.all? { |method| @value.respond_to?(method) }
  end

  # def instance_of (klass, &block)
  #   throw :match, block if @value.is_a?(klass)
  # end

  def extends (klass, &block)
    throw :match, block if @value.ancestors.include?(klass)
  end

  def default (&block)
    throw :match, block
  end
end