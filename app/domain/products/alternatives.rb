# frozen_string_literal: true

class Products::Alternatives
  attr_reader :product

  def initialize(product)
    @product = product
  end

  delegate :id, to: :product
end
