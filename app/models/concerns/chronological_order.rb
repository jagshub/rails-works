# frozen_string_literal: true

module ChronologicalOrder
  def self.included(base)
    base.scope :reverse_chronological, -> { order(arel_table[:id].desc) }
    base.scope :chronological, -> { order(arel_table[:id].asc) }
  end
end
