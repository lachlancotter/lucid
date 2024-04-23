require "pathname"

module Lucid
  #
  # Path to the project root directory.
  #
  def self.root
    Pathname.new(__dir__).ascend do |path|
      return path.to_s if path.join("Gemfile").exist?
    end
  end
end