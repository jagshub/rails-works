# frozen_string_literal: true

class Admin::UserRestoreForm
  include MiniForm::Model

  model :user, save: true, attributes: %i(twitter_username username) + SignIn::SOCIAL_ATTRIBUTES, read: %i(id to_param persisted?)

  validates :username, exclusion: { in: ->(user) { ["deleted-#{ user.user.id }"] }, message: 'should be changed' }
  validates :twitter_username, presence: { message: 'must be given when twitter_uid is present' }, if: ->(u) { u.twitter_uid.present? }

  validate :ensure_social_uid
  before_update :nilify_blanks

  def initialize(user)
    @user = user
  end

  def perform
    user.restore
  end

  private

  def ensure_social_uid
    return unless user.connected_social_accounts_count == 0

    SignIn::SOCIAL_ATTRIBUTES.each do |attribute_name|
      errors.add attribute_name, '- at least one social UID should be given'
    end
  end

  def nilify_blanks
    [SignIn::SOCIAL_ATTRIBUTES, :twitter_username].flatten.each do |attribute_name|
      @user[attribute_name] = @user[attribute_name].presence
    end
  end
end
