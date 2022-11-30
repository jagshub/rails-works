# frozen_string_literal: true

# == Schema Information
#
# Table name: oauth_applications
#
#  id                      :integer          not null, primary key
#  name                    :string(255)      not null
#  uid                     :string(255)      not null
#  secret                  :string(255)      not null
#  redirect_uri            :text             not null
#  created_at              :datetime
#  updated_at              :datetime
#  twitter_app_name        :string(255)
#  owner_id                :integer
#  owner_type              :string(255)
#  twitter_auth_allowed    :boolean          default(FALSE)
#  twitter_consumer_key    :string(255)
#  twitter_consumer_secret :string(255)
#  write_access_allowed    :boolean          default(FALSE)
#  max_requests_per_hour   :integer          default(3600), not null
#  confidential            :boolean          default(TRUE), not null
#  verified                :boolean          default(FALSE), not null
#  max_points_per_hour     :integer          default(25000), not null
#  legacy                  :boolean          default(FALSE), not null
#
# Indexes
#
#  index_oauth_applications_on_legacy                   (legacy)
#  index_oauth_applications_on_owner_id_and_owner_type  (owner_id,owner_type)
#  index_oauth_applications_on_twitter_app_name         (twitter_app_name)
#  index_oauth_applications_on_uid                      (uid) UNIQUE
#

class OAuth::Application < Doorkeeper::Application
  V2_GRAPHQL_IDENTIFIER = 'v2_graphql'

  has_many :requests, class_name: 'OAuth::Request', dependent: :destroy, inverse_of: :application

  scope :legacy, -> { where(legacy: true) }
  scope :not_legacy, -> { where(legacy: false) }

  def rate_limiter
    @rate_limiter ||= ::RateLimiter::API.for(self, max_requests_per_hour)
  end

  def rate_limiter_graphql
    @rate_limiter_graphql ||= ::RateLimiter::API.for(self, max_points_per_hour, V2_GRAPHQL_IDENTIFIER)
  end
end
