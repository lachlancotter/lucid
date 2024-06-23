#
# Pattern matching.
#
class Match
  class NoMatch < StandardError
    def initialize (*values)
      super("No match for #{values.map(&:inspect).join(', ')}")
    end
  end

  def self.on (*values, &block)
    new(*values).match(&block)
  end

  def initialize (*values)
    @values = values
  end

  def match (&block)
    block_binding = block.binding
    match_block   = catch(:match) { instance_eval(&block) }
    raise NoMatch.new(*@values) unless match_block
    block_binding.receiver.instance_exec(*@values, &match_block)
  end

  # def is (pattern, &block)
  #   throw :match, block if @value == pattern
  # end

  def value (*vals, &block)
    throw :match, block if @values.count == vals.count &&
       @values.each_with_index.all? do |value, index|
         @values[index] == vals[index]
       end
  end

  def type (klass, &block)
    throw :match, block if @values.first.is_a?(klass)
  end

  def responds_to (*methods, &block)
    throw :match, block if methods.all? { |method| @values.first.respond_to?(method) }
  end

  def extends (klass, &block)
    throw :match, block if @values.first.is_a?(Class) && @values.first.ancestors.include?(klass)
  end

  def default (&block)
    throw :match, block
  end
end