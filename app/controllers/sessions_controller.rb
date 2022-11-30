# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_forgery_protection only: :create

  def create
    auth_response = SignIn.auth_response_from_web_request(request)

    if SignIn.user_trying_to_merge_new_social?(auth_response, current_user)
      SignIn.merge_auth_response(auth_response, current_user)

      redirect_back
      return
    end

    app_id = session.delete(:via_application_id)
    new_social_login = SignIn.detect_duplicate_user(auth_response, app_id)

    if new_social_login.present? && !new_social_login.merged?
      SignIn.set_session_new_social_login_id(session, new_social_login.id)

      redirect_to duplicate_account_url
      return
    end

    user = SignIn.process_auth_response(auth_response, app_id)

    ::ErrorReporting.set_user(username: user.username, id: user.id) if user

    if Admin::MultiFactor.authenticate?(user, auth_response.provider)
      Admin::MultiFactor.create_and_deliver!(user)

      redirect_to my_multi_factor_token_path
      return
    end

    sign_in auth_response, user

    # Todo(Rahul): This might be temporary & remove/update it after collecting data
    if session[:previous_uid].present?
      SpamChecks.track_same_browser_multiple_logins(
        previous_user_id: session[:previous_uid].to_i,
        current_user: user,
        request_info: RequestInfo.new(request).to_hash.as_json,
      )
    end

    if user_in_middle_of_ship_signup?
      Ships::Session.call(user: user, ship_lead: ship_lead, visitor_id: cookies[:visitor_id])
      redirect_to ship_signup_billing_path
    elsif user_in_middle_of_founder_club_signup?
      redirect_to founder_club_path
    elsif user.first_time_user?
      redirect_to welcome_url
    elsif user.potential_spammer?
      redirect_to verification_url
    else
      redirect_back
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end

  def failure
    if params[:message] == 'invalid_credentials'
      redirect_to root_url
      return
    end

    ErrorReporting.report_warning_message("OmniAuth failure - #{ params[:message] }", extra: { session: session.keys })
    redirect_to '/auth_failure'
  end

  private

  def user_in_middle_of_ship_signup?
    return false if back_to.blank?

    back_to.starts_with?(ship_signup_account_path)
  end

  def user_in_middle_of_founder_club_signup?
    return false if back_to.blank?

    back_to.starts_with?(founder_club_path)
  end

  def sign_in(auth_response, user)
    session[:user_id] = user.id

    # NOTE(rstankov): Omniauth stores initial request params in `env['omniauth.params']`
    source_component = request.env.dig('omniauth.params', 'source_component')

    if user.first_time_user?
      user.registration_reasons.create!(
        source_component: source_component,
        origin_url: back_to,
        app: 'web',
        provider: auth_response.provider,
      )
    end

    Metrics.track_signin(
      user: user,
      options: {
        first_time: user.first_time_user?,
        provider: auth_response.provider,
        origin: back_to,
        link_location: params[:link_location],
        source_component: source_component,
      },
    )
  end

  def sign_out
    if impersonated?
      reset_impersonate
    else
      uid = session[:user_id]

      reset_session

      session[:previous_uid] = uid
    end
  end

  def back_to
    session[:back_to] ||= request.env['omniauth.origin']
  end

  def ship_lead
    ShipLead.find_by(id: cookies[:SHIP_LEAD_ID])
  end

  def welcome_url
    back_path = if back_to.blank? || (back_to == login_path)
                  root_path
                else
                  back_to
                end

    welcome_onboarding_url(next: back_path)
  end

  def redirect_back(options = {})
    redirect_path = UrlSanitize.call(session.delete(:back_to))
    redirect_path = root_path if redirect_path.blank? || redirect_path == '/login'

    # NOTE(vesln): in order to bypass the CDN cache, we set an extra query param
    uri = Addressable::URI.parse(redirect_path)

    # NOTE(vesln): "bc" means bypass cache, I don't feel comfortable exposing
    # what it means to the users since it may result in unnecessary attention
    query_params = Rack::Utils.parse_nested_query(uri.query)
    query_params['bc'] = 1

    uri.query = Rack::Utils.build_nested_query(query_params)

    redirect_to uri.to_s, options
  end
end
