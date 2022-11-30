# frozen_string_literal: true

# == Schema Information
#
# Table name: promoted_email_ab_test_variants
#
#  id                        :bigint(8)        not null, primary key
#  title                     :string
#  tagline                   :string
#  thumbnail_uuid            :string
#  promoted_email_ab_test_id :bigint(8)        not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  cta_text                  :string
#
# Indexes
#
#  index_promoted_email_ab_variants_on_ab_test_id  (promoted_email_ab_test_id)
#
# Foreign Keys
#
#  fk_rails_...  (promoted_email_ab_test_id => promoted_email_ab_tests.id)
#

class PromotedEmail::AbTestVariant < ApplicationRecord
  # NOTE(DZ): PromotedEmail is deprecated
  def readonly?
    true
  end

  include Namespaceable
  include Uploadable

  uploadable :thumbnail

  belongs_to :promoted_email_ab_test, class_name: '::PromotedEmail::AbTest', inverse_of: :variants
end
