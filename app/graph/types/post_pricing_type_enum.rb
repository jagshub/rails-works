# frozen_string_literal: true

module Graph::Types
  class PostPricingTypeEnum < BaseEnum
    Post.pricing_types.each do |k, _v|
      value k, k
    end
  end
end
