# frozen_string_literal: true

# == Schema Information
#
# Table name: funding_surveys
#
#  id                            :bigint(8)        not null, primary key
#  post_id                       :bigint(8)
#  have_raised_vc_funding        :boolean
#  funding_round                 :string
#  funding_amount                :string
#  interested_in_vc_funding      :boolean
#  interested_in_being_contacted :boolean
#  share_with_investors          :boolean
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
# Indexes
#
#  index_funding_surveys_on_post_id  (post_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (post_id => posts.id)
#
class FundingSurvey < ApplicationRecord
  belongs_to :post, inverse_of: :funding_survey
end
