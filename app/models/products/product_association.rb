# frozen_string_literal: true

# == Schema Information
#
# Table name: product_associations
#
#  id                    :bigint(8)        not null, primary key
#  product_id            :bigint(8)        not null
#  associated_product_id :bigint(8)        not null
#  relationship          :string           not null
#  source                :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  votes_count           :integer          default(0), not null
#  credible_votes_count  :integer          default(0), not null
#
# Indexes
#
#  index_product_associations_unique  (product_id,associated_product_id) UNIQUE
#
class Products::ProductAssociation < ApplicationRecord
  self.table_name = 'product_associations'

  include Votable

  belongs_to :product, inverse_of: :product_associations
  belongs_to :associated_product, class_name: 'Product'

  validate :ensure_product_not_associated_to_self

  after_commit :refresh_counters, only: %i(create destroy)
  after_update :refresh_counters_after_update

  # Note(Rahul): When adding new relationship make sure to
  #              add it to COUNTER_NAME_MAP below
  enum relationship: {
    addon: 'addon',
    alternative: 'alternative',
    related: 'related',
  }

  enum source: {
    data_migration: 'data_migration',
    data_migration_platform: 'data_migration_platform',
    data_migration_keyword: 'data_migration_keyword',
    moderation: 'moderation',
    admin: 'admin',
  }

  audited associated_with: :product

  scope :by_date, -> { order(arel_table[:created_at].desc) }
  scope :created_before, ->(date) { where(arel_table[:created_at].lteq(date)) }
  scope :created_after, ->(date) { where(arel_table[:created_at].gteq(date)) }

  class << self
    def graphql_type
      Graph::Types::ProductAssociationType
    end
  end

  private

  def ensure_product_not_associated_to_self
    return if product.nil? || associated_product.nil?

    errors.add(:associated_product, "can't be same as product") if product == associated_product
  end

  COUNTER_NAME_MAP = {
    'addon' => 'refresh_addons_count',
    'related' => 'refresh_related_products_count',
    'alternative' => 'refresh_alternatives_count',
  }.freeze

  def refresh_counters
    refresh_counter_method = COUNTER_NAME_MAP[relationship]

    # Note(Rahul): This way we only refresh specific relationship count
    #              and not all.
    product.public_send(refresh_counter_method)
  end

  # Note(Rahul): Call refresh counters on only the changed relationship
  def refresh_counters_after_update
    changed_relationships = saved_changes['relationship'] || []

    changed_relationships.each do |r|
      refresh_counter_method = COUNTER_NAME_MAP[r]

      product.public_send(refresh_counter_method)
    end
  end
end
