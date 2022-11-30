# frozen_string_literal: true

class Products::Scrapers::JSON::Base
  include Products::Scrapers::Utils::FieldSerializer

  attr_reader :response, :product

  class << self
    def invoke(&block)
      define_method(:invoke_api, &block)
    end
  end

  def initialize(product)
    @product = product
    @response = invoke_api(product)
  end
end
