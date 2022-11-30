# frozen_string_literal: true

# == Schema Information
#
# Table name: spam_multiple_accounts_logs
#
#  id               :bigint(8)        not null, primary key
#  previous_user_id :bigint(8)        not null
#  current_user_id  :bigint(8)        not null
#  request_info     :jsonb
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_spam_multiple_accounts_logs_on_current_user_id   (current_user_id)
#  index_spam_multiple_accounts_logs_on_previous_user_id  (previous_user_id)
#
# Foreign Keys
#
#  fk_rails_...  (current_user_id => users.id)
#  fk_rails_...  (previous_user_id => users.id)
#

class Spam::MultipleAccountsLog < ApplicationRecord
  include Namespaceable

  belongs_to :previous_user, class_name: 'User'
  belongs_to :current_user, class_name: 'User'
end
