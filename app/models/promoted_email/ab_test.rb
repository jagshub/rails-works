# frozen_string_literal: true

# == Schema Information
#
# Table name: promoted_email_ab_tests
#
#  id           :bigint(8)        not null, primary key
#  test_running :boolean          default(FALSE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class PromotedEmail::AbTest < ApplicationRecord
  # NOTE(DZ): PromotedEmail is deprecated
  def readonly?
    true
  end

  include Namespaceable

  has_many :variants, class_name: '::PromotedEmail::AbTestVariant', foreign_key: 'promoted_email_ab_test_id', inverse_of: :promoted_email_ab_test, dependent: :destroy
  has_many :campaigns, class_name: '::PromotedEmail::Campaign', foreign_key: 'promoted_email_ab_test_id', inverse_of: :promoted_email_ab_test, dependent: :nullify
end
