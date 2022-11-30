# frozen_string_literal: true

# == Schema Information
#
# Table name: maker_suggestions
#
#  id               :integer          not null, primary key
#  approved_by_id   :integer
#  invited_by_id    :integer
#  maker_id         :integer
#  post_id          :integer
#  product_maker_id :integer
#  maker_username   :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_maker_suggestions_on_approved_by_id              (approved_by_id)
#  index_maker_suggestions_on_maker_id                    (maker_id)
#  index_maker_suggestions_on_post_id_and_maker_id        (post_id,maker_id) UNIQUE
#  index_maker_suggestions_on_post_id_and_maker_username  (post_id,maker_username) UNIQUE
#  index_maker_suggestions_on_product_maker_id            (product_maker_id)
#

class MakerSuggestion < ApplicationRecord
  belongs_to :post
  belongs_to :invited_by, class_name: 'User', foreign_key: :invited_by_id, optional: true
  belongs_to :maker, class_name: 'User', foreign_key: :maker_id, optional: true
  belongs_to :approved_by, class_name: 'User', foreign_key: :approved_by_id, optional: true
  belongs_to :product_maker, optional: true

  before_save :downcase_maker_username

  validates :maker_username, presence: true, uniqueness: { scope: :post_id }

  scope :approved, -> { where.not(approved_by_id: nil) }
  scope :pending, -> { where(approved_by_id: nil) }
  scope :not_joined, -> { where(maker_id: nil) }
  scope :joined, -> { where.not(maker_id: nil) }
  scope :with_preloads, -> { preload [:maker] }

  class << self
    def by_username(username)
      username.present? ? where(maker_username: username.downcase) : none
    end
  end

  def approved?
    approved_by_id.present?
  end

  def joined?
    maker_id.present?
  end

  def twitter_username
    maker_username
  end

  private

  def downcase_maker_username
    maker_username.downcase!
  end
end
