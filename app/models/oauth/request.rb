# frozen_string_literal: true

# == Schema Information
#
# Table name: oauth_requests
#
#  id              :bigint(8)        not null, primary key
#  last_request_at :datetime         not null
#  user_id         :bigint(8)
#  application_id  :bigint(8)        not null
#
# Indexes
#
#  index_oauth_requests_application_id_user_id  (application_id,user_id) UNIQUE
#  index_oauth_requests_on_application_id       (application_id) UNIQUE WHERE (user_id IS NULL)
#
# Foreign Keys
#
#  fk_rails_...  (application_id => oauth_applications.id)
#  fk_rails_...  (user_id => users.id)
#

class OAuth::Request < ApplicationRecord
  include Namespaceable

  belongs_to :application, class_name: 'OAuth::Application', inverse_of: :requests
  belongs_to :user, inverse_of: :oauth_requests, optional: true

  validates :last_request_at, presence: true

  scope :for_user, ->(user) { where(user: user) }
  scope :without_user, -> { where(user_id: nil) }

  attr_readonly :application_id, :user_id
end
