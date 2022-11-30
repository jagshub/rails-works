# frozen_string_literal: true

# == Schema Information
#
# Table name: cookie_policy_logs
#
#  id         :integer          not null, primary key
#  ip_address :string           not null
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_cookie_policy_logs_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class CookiePolicyLog < ApplicationRecord
  belongs_to :user, inverse_of: :cookie_policy, optional: true
end
