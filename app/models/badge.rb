# frozen_string_literal: true

# == Schema Information
#
# Table name: badges
#
#  id           :integer          not null, primary key
#  subject_id   :integer          not null
#  subject_type :string           not null
#  type         :string           not null
#  data         :jsonb            not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_badges_on_subject_type_and_subject_id  (subject_type,subject_id)
#

class Badge < ApplicationRecord
  include Storext.model

  # Note(andreasklinger): see monkey_patches/jsonb_monkey_patch.rb
  include JsonbTypeMonkeyPatch[:data]

  belongs_to :subject, polymorphic: true

  validates :type, presence: true

  scope :with_data, ->(data) { where('data @> ? ', data.to_json) }
  scope :by_created_at, -> { order(arel_table[:created_at].desc) }
  scope :between_dates, ->(start_date, end_date) { where("data->>'date' >= ? AND data->>'date' <= ?", start_date.to_date, end_date.to_date) }
  scope :with_period, ->(period) { where("data->>'period' = ?", period) }

  def self.graphql_type
    "Graph::Types::Badges::#{ name.demodulize }Type".safe_constantize
  end

  def self.mobile_graphql_type
    "Mobile::Graph::Types::Badges::#{ name.demodulize }Type".safe_constantize
  end

  def self.graph_v2_internal_type
    "API::V2Internal::Types::Badges::#{ name.demodulize }Type".safe_constantize
  end
end
