# frozen_string_literal: true

# == Schema Information
#
# Table name: multi_factor_tokens
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)        not null
#  token      :string           not null
#  expires_at :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_multi_factor_tokens_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class MultiFactorToken < ApplicationRecord
  extension HasUniqueCode, field_name: :token, length: 32
  extension HasExpirationDate, limit: 1.hour

  belongs_to :user, inverse_of: :multi_factor_tokens
end
