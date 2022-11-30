# frozen_string_literal: true

module Stacks
  extend self

  def add(product:, user:, source:)
    ActiveRecord::Base.transaction do
      Products::Stack.create!(product: product, user: user, source: source)
    end
  end

  def remove(product:, user:)
    ActiveRecord::Base.transaction do
      stack = Products::Stack.find_by(product: product, user: user)
      stack&.destroy!
    end
  end

  # TODO(vlad): Handle auto approve if there are 3 suggestions
  def suggest_alternative(product:, alternative_product:, user:, source:)
    ActiveRecord::Base.transaction do
      Products::AlternativeSuggestion.create!(product: product, alternative_product: alternative_product, user: user, source: source)
    end
  end
end
