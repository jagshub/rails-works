# frozen_string_literal: true

class Graph::Resolvers::Products::AlternativeAssociationsSearchResolver < Graph::Resolvers::BaseSearch
  scope do
    object.alternative_associations
          .joins(:associated_product)
          .order('associated_product.sort_key_max_votes DESC')
  end

  option :include_no_longer_available, type: Boolean, with: :for_no_longer_available

  private

  def for_no_longer_available(scope, value)
    return scope if value

    scope.where(associated_product: { state: 'live' })
  end
end
