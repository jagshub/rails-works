# frozen_string_literal: true

module RandomOrder
  extend ActiveSupport::Concern

  included do
    scope :by_random, -> { order(Arel.sql('RANDOM()')) }
  end
end
