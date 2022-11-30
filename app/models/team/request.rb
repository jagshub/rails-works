# frozen_string_literal: true

# == Schema Information
#
# Table name: team_requests
#
#  id                              :bigint(8)        not null, primary key
#  user_id                         :bigint(8)        not null
#  product_id                      :bigint(8)        not null
#  status_changed_by_id            :bigint(8)
#  team_email                      :string
#  approval_type                   :string
#  status                          :string           default("pending"), not null
#  status_changed_at               :datetime         not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  team_email_confirmed            :boolean          default(FALSE), not null
#  verification_token              :string
#  verification_token_generated_at :datetime
#  additional_info                 :text
#  user_flags_count                :integer          default(0)
#  moderation_notes                :text
#
# Indexes
#
#  index_team_requests_on_product_id            (product_id)
#  index_team_requests_on_status_changed_by_id  (status_changed_by_id)
#  index_team_requests_on_team_email_confirmed  (team_email_confirmed)
#  index_team_requests_on_user_id               (user_id)
#  index_team_requests_on_verification_token    (verification_token)
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#  fk_rails_...  (status_changed_by_id => users.id)
#  fk_rails_...  (user_id => users.id)
#
class Team::Request < ApplicationRecord
  include Namespaceable
  include UserFlaggable

  audited associated_with: :product, except: %i(created_at updated_at)

  belongs_to :product, inverse_of: :team_requests
  belongs_to :user, inverse_of: :team_requests
  belongs_to :status_changed_by, class_name: 'User', optional: true, inverse_of: :moderated_team_requests
  has_one :team_member, class_name: 'Team::Member', as: :referrer, dependent: :nullify, inverse_of: :referrer
  has_many :flags, as: :subject, dependent: :destroy

  enum status: {
    pending: 'pending',
    approved: 'approved',
    rejected: 'rejected',
  }

  enum approval_type: {
    auto: 'auto',
    manual: 'manual',
  }

  HasEmailField.define self, field_name: :team_email, uniqueness: false, allow_nil: false

  # TODO(DT): Add a smarter uniqueness validator, considering the status and the cooldown period.
  validates :user, uniqueness: { scope: %i(product_id status) }, on: :create
  validates :status, presence: true
end
