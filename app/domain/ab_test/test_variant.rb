# frozen_string_literal: true

class AbTest::TestVariant
  attr_reader :name, :variant

  def initialize(name, variant)
    @name = name
    @variant = variant
  end
end
