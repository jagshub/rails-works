# frozen_string_literal: true

# == Schema Information
#
# Table name: post_drafts
#
#  id                   :bigint(8)        not null, primary key
#  user_id              :bigint(8)        not null
#  post_id              :bigint(8)
#  uuid                 :string           not null
#  url                  :string           not null
#  data                 :jsonb            not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  suggested_product_id :bigint(8)
#  connect_product      :boolean          default(FALSE), not null
#
# Indexes
#
#  index_post_drafts_on_post_id               (post_id)
#  index_post_drafts_on_suggested_product_id  (suggested_product_id)
#  index_post_drafts_on_user_id               (user_id)
#  index_post_drafts_on_uuid                  (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (suggested_product_id => products.id)
#

class PostDraft < ApplicationRecord
  extension HasUniqueCode, field_name: :uuid, length: 34

  belongs_to :user
  belongs_to :post, optional: true
  belongs_to :suggested_product, class_name: '::Product', optional: true, foreign_key: 'suggested_product_id', inverse_of: :suggested_post_drafts

  scope :incomplete, -> { where(post_id: nil) }
end
