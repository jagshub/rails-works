# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_card_update_logs
#
#  id                 :bigint(8)        not null, primary key
#  stripe_token_id    :string           not null
#  stripe_customer_id :string           not null
#  project            :string           not null
#  success            :boolean          default(TRUE), not null
#  user_id            :bigint(8)        not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_payment_card_update_logs_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Payment::CardUpdateLog < ApplicationRecord
  include Namespaceable

  belongs_to :user, foreign_key: :user_id, inverse_of: :card_update_logs
end
