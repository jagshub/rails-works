# frozen_string_literal: true

# NOTE(RO): Makes a model tracked for user activity, requires a user
#
# Will need to add your class name to Users::ActivityEvent::SUBJECTS

module UserActivityTrackable
  extend ActiveSupport::Concern

  included do
    has_one :user_activity_event, class_name: 'Users::ActivityEvent', as: :subject, dependent: :destroy, inverse_of: :subject
    after_create :create_user_activity
  end

  private

  def create_user_activity
    Users::ActivityEvent.create!(user: user, subject: self, occurred_at: created_at)
  end
end
