require "binding_of_caller"

#
# Enables concise checking of values for type and other properties.
#
# Example:
#   Check[value].symbol
#   Check[value].string.not_empty
#
class Check
  STACK_DEPTH = 2

  def self.[] (value)
    new(value)
  end

  def initialize (value)
    @value   = value
    @context = binding.of_caller(STACK_DEPTH)
    @caller  = binding.of_caller(STACK_DEPTH + 1)
  end

  attr_reader :value, :context, :caller

  def location
    @context.source_location.join(':')
  end

  def caller_location
    @caller.source_location.join(':')
  end

  def has_type (*types)
    unless (defined?(RSpec::Mocks::Double) &&
       @value.is_a?(RSpec::Mocks::Double)) ||
       types.any? { |type| @value.is_a?(type) }
      raise Failure.new(self, "should have type #{types.join(' or ')}")
    end; self
  end

  def extends (*modules)
    unless modules.all? { |mod| @value.ancestors.include?(mod) }
      raise Failure.new(self, "should extend #{modules.join(' and ')}")
    end; self
  end

  alias type has_type

  def responds_to (*methods)
    methods.each do |method|
      unless @value.respond_to?(method)
        raise Failure.new(self, "should respond to #{method}")
      end
    end; self
  end

  def not_nil
    if @value.nil?
      raise Failure.new(self, "should not be nil")
    end; self
  end

  def not_blank
    if @value.nil? || @value.empty?
      raise Failure.new(self, "should not be blank")
    end; self
  end

  def has_key (key)
    unless @value.key?(key)
      raise Failure.new(self, "should have key #{key}")
    end; self
  end

  def every (&block)
    @value.each do |value|
      yield Check.new(value)
    end; self
  end

  def every_value (&block)
    @value.values.each do |value|
      yield Check.new(value)
    end; self
  end

  def gt (other, message = "should be greater than #{other}")
    raise Failure.new(self, message) unless @value > other; self
  end

  def includes (hash)
    hash.each do |key, value|
      unless @value.key?(key) && @value[key] == value
        raise Failure.new(self, "should include #{key} => #{value}")
      end
    end
  end

  def string
    type(String); self
  end

  def integer
    type(Integer); self
  end

  def symbol
    type(Symbol); self
  end

  def hash
    type(Hash); self
  end

  #
  # Raised on error conditions.
  #
  class Failure < StandardError
    def initialize (check, message)
      @check   = check
      @message = message
    end

    def message
      <<~MESSAGE
         Check failed in ##{listing.method_name}: 
          value: #{@check.value}
          class: #{@check.value.class}
          message: #{@message}
          at: #{@check.location}
          caller: #{@check.caller_location}
        ----------------------------------------
        #{listing.snippet}
      MESSAGE
    end

    private

    def listing
      Listing.new(*@check.context.source_location)
    end
  end

  #
  # Include source listing in error message.
  #
  class Listing
    def initialize (file, line)
      @file = file
      @line = line
    end

    def filename
      @file
    end

    def line_number
      @line
    end

    def location
      "#{@file}:#{@line}"
    end

    def snippet (context = 3)
      return '' unless File.exist?(@file)
      lines = File.readlines(@file)

      start_line = [@line - context - 1, 0].max
      end_line   = [@line + context - 1, lines.size - 1].min

      source_code = ''
      (start_line..end_line).each do |i|
        # source_code += "#{i + 1}: #{lines[i]}"
        source_code += lines[i]
      end

      source_code
    end

    def method_name
      return nil unless File.exist?(@file)
      lines = File.readlines(@file)

      method_name           = nil
      class_or_module_stack = []

      lines.each_with_index do |line, index|
        break if index >= @line

        case line.strip
        when /^class\s+([^\s;]+)/, /^module\s+([^\s;]+)/
          class_or_module_stack.push($1)
        when /^end$/
          class_or_module_stack.pop
        when /^def\s+([^\s;]+)/
          method_name = class_or_module_stack.empty? ? $1 : "#{class_or_module_stack.join('::')}::#{$1}"
        end
      end

      method_name
    end

  end
end