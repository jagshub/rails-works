# frozen_string_literal: true

class Graph::Resolvers::Collections::AlternativeProductsResolver < Graph::Resolvers::Base
  argument :take, Integer, required: false

  # NOTE(TE): type is passed as a string to avoid cyclical loading issues
  # https://graphql-ruby.org/fields/resolvers.html#nesting-resolvers-of-the-same-type
  type '[Graph::Types::ProductType]', null: false

  # Note(TE): For every product in the collection, we want to return:
  # * The top alternative (has highest votes) of each product, and is already not in the collection's products
  # * If a product doesn't have any, pick up the next until we reach the 'take' amount
  # * If we don't reach that amount, pick from the second top alternatives and so on
  def resolve(take: 8)
    products = object.products
    return [] if products.blank?

    array = products
            .joins(:alternatives)
            .includes(:alternatives)
            .map { |p| p.alternatives.by_credible_votes }

    flatten_by_order_of_index(array)
      .uniq
      .take(take)
  end

  private

  # This method flattens items in an array of arrays in order of its index within sub-array. Eg:
  #
  # a = [ [{id: 1, ...}, {id: 2, ...}], [{id: 3, ...}], [{id: 4, ...}, {id: 5, ...}, {id: 6, ...}] }
  # flatten_by_order_of_index(a)
  # => [{id: 1, ...}, {id: 3, ...}, {id: 4, ...}, {id: 2, ...}, {id: 5, ...}, {id: 6, ...}}]
  def flatten_by_order_of_index(array)
    return [] if array.blank?

    Array.new(array.map(&:length).max).zip(*array).flatten.compact
  end
end
