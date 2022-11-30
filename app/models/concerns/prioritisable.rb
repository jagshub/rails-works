# frozen_string_literal: true

module Prioritisable
  def self.included(base)
    base.scope :by_priority, -> { order(arel_table[:priority].desc, arel_table[:id].desc) }
  end
end
