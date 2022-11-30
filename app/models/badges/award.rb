# frozen_string_literal: true

# == Schema Information
#
# Table name: badges_awards
#
#  id          :bigint(8)        not null, primary key
#  identifier  :string           not null
#  name        :string           not null
#  description :string           not null
#  image_uuid  :string           not null
#  active      :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_badges_awards_on_identifier  (identifier) UNIQUE
#
class Badges::Award < ApplicationRecord
  include Namespaceable
  include Uploadable

  uploadable :image
  validates :identifier, presence: true
  validates :identifier, uniqueness: true
  validates :name, presence: true
  validates :description, presence: true
  validates :image_uuid, presence: true
  validate :ensure_valid_identifier

  # NOTE(DZ): ORDER MATTERS HERE! ADD ALL ENUMS TO THE END
  enum identifiers: [
    'thought_leader',
    'contributor',
    'buddy_system',
    'in_real_life',
    'maker_grant_recipient',
    'veteran',
    'top_product',
    'gemologist',
    'beta_tester',
  ].freeze
  scope :visible, -> { where(active: true) }

  attr_readonly :identifier

  private

  def ensure_valid_identifier
    errors.add :identifier, :invalid unless Badges::Award.identifiers.key?(identifier)
  end
end
