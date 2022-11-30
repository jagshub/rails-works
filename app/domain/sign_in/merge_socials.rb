# frozen_string_literal: true

module SignIn::MergeSocials
  extend self

  def from_new_social_login(new_social_login)
    user = new_social_login.user
    auth_response = SignIn.auth_response_from_new_social_login(new_social_login)

    result = from_auth_response(auth_response, user)

    return new_social_login.merged! if result

    capture_new_social_error(new_social_login)
    false
  end

  def from_auth_response(auth_response, user)
    existing_users = fetch_existing_users(auth_response)

    if existing_users.present?
      return :error unless ensure_no_conflicts(existing_users, user)

      existing_users.each do |trashed_user|
        Users.merge(result_user: user, trashed_user: trashed_user)
      end
    else
      twitter_username = auth_response.user_params[:twitter_username]
      user.twitter_username = twitter_username if twitter_username.present?
      user[auth_response.social_uid_key] = auth_response.social_uid

      user.save!
    end

    true
  end

  def user_trying_to_merge_new_social?(auth_response, user)
    return false if user.blank?
    return false if auth_response.social_uid.blank?
    return false if user[auth_response.social_uid_key].present?

    true
  end

  private

  def fetch_existing_users(auth_response)
    User.not_trashed.where(
      auth_response.social_uid_key => auth_response.social_uid,
    ).to_a
  end

  # NOTE(DZ): This probably will never happen since we have unique indices on
  # our social id columns. But we don't have on all columns yet. Fix this later
  def ensure_no_conflicts(existing_users, user)
    return true if existing_users.empty?

    user_uids_with_value = user.slice(*SignIn::SOCIAL_ATTRIBUTES).compact.keys

    existing_users.all? do |u|
      u.slice(*user_uids_with_value).compact.none?
    end
  end

  def capture_new_social_error(new_social_login)
    ErrorReporting.report_error_message(
      'Unexpected error while connecting accounts using new social login',
      extra: { new_social_login_id: new_social_login.id },
    )
  end
end
