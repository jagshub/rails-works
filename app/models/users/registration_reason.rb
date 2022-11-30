# frozen_string_literal: true

# == Schema Information
#
# Table name: users_registration_reasons
#
#  id               :bigint(8)        not null, primary key
#  source_component :string
#  origin_url       :string
#  app              :string
#  user_id          :bigint(8)        not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  provider         :string
#
# Indexes
#
#  index_users_registration_reasons_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Users::RegistrationReason < ApplicationRecord
  include Namespaceable

  belongs_to :user, class_name: '::User', inverse_of: :registration_reasons
end
