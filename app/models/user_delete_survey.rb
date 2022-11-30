# frozen_string_literal: true

# == Schema Information
#
# Table name: user_delete_surveys
#
#  id         :integer          not null, primary key
#  reason     :string           not null
#  feedback   :text
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_user_delete_surveys_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class UserDeleteSurvey < ApplicationRecord
  belongs_to :user
end
