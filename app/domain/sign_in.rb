# frozen_string_literal: true

module SignIn
  extend self

  SOCIAL_ATTRIBUTES = SignIn::AuthResponse::SOCIAL_ATTRIBUTES

  # NOTE(rstankov): List of removed social logins
  # - Angellist login removed on 2022/01/26
  REMOVED_SOCIAL_ATTRIBUTES = %i(angellist_uid).freeze

  VALIDATION_ATTRIBUTES = SOCIAL_ATTRIBUTES + REMOVED_SOCIAL_ATTRIBUTES

  class TokenExpirationError < StandardError; end

  def auth_response_from_web_request(request)
    SignIn::AuthResponse.from_web_request(request)
  end

  def auth_response_from_new_social_login(new_social_login)
    SignIn::AuthResponse.from_json(new_social_login.auth_response)
  end

  def auth_response_from_api(auth_data, oauth_app)
    SignIn::AuthResponse.from_api(auth_data, oauth_app)
  end

  def process_auth_response(auth_response, via_app_id)
    SignIn::ProcessAuthResponse.call(auth_response, via_app_id)
  end

  def merge_auth_response(auth_response, user)
    SignIn::MergeSocials.from_auth_response(auth_response, user)
  end

  def merge_new_social_login(new_social_login)
    SignIn::MergeSocials.from_new_social_login(new_social_login)
  end

  def user_trying_to_merge_new_social?(auth_response, user)
    SignIn::MergeSocials.user_trying_to_merge_new_social?(
      auth_response, user
    )
  end

  def valid_username(username, existing_user:)
    SignIn::ValidUsername.call(username, existing_user: existing_user)
  end

  def create_user(auth_response)
    SignIn::CreateUser.call(auth_response)
  end

  def user_has_new_social_login_request?(session)
    return false if session[:new_social_login_id].blank?

    new_social_login = Users::NewSocialLogin.find_by(
      id: session[:new_social_login_id],
    )
    !!new_social_login&.processable?
  end

  def detect_duplicate_user(auth_response, via_app_id, skip_email_link_tracking: false)
    user = auth_response.find_user
    email = auth_response.email
    return if user.present? || email.blank?

    subscriber = Subscriber.with_user.find_by(email: email)
    return if subscriber.blank?

    login = Users::NewSocialLogin.create!(
      user: subscriber.user,
      auth_response: auth_response.to_json,
      via_application_id: via_app_id,
      social: auth_response.provider,
      email: auth_response.email,
      state: :requested,
    )

    if auth_response.trusted
      merge_new_social_login(login)
    else
      UserMailer.new_social_login_requested(
        login,
        skip_tracking: skip_email_link_tracking,
      ).deliver_later
    end

    login
  end

  # NOTE(rstankov): This is temporary feature, until we implement this fully on mobile
  def duplicated_user_provider(auth_response, via_app_id)
    user = auth_response.find_user
    email = auth_response.email

    return if user.present? || email.blank?

    subscriber = Subscriber.with_user.find_by(email: email)
    return if subscriber.blank?

    unless auth_response.trusted
      user = subscriber.user
      return find_provider_for_user(user)
    end

    login = Users::NewSocialLogin.create!(
      user: subscriber.user,
      auth_response: auth_response.to_json,
      via_application_id: via_app_id,
      social: auth_response.provider,
      email: auth_response.email,
      state: :requested,
    )
    merge_new_social_login(login)

    nil
  end

  def find_provider_for_user(user)
    VALIDATION_ATTRIBUTES
      .detect { |attribute_name| user[attribute_name].present? }
      .to_s.gsub('_uid', '').titlecase
  end

  def session_new_social_login_id(session)
    session[:new_social_login_id]
  end

  def reset_session_new_social_login_id(session)
    session[:new_social_login_id] = nil
  end

  def set_session_new_social_login_id(session, value)
    session[:new_social_login_id] = value
  end
end
