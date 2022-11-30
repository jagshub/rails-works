# frozen_string_literal: true

module CurrentUser
  def current_user
    return unless session[:user_id]
    return @current_user if @current_user.present?

    @current_user = User.visible.find_by(id: impersonate_user_id || session[:user_id])

    # Note(andreasklinger): If the user has an outdated user_id make sure
    #   we remove that user_id to avoid edgecases (eg. can't log out)
    session.delete(:user_id) if @current_user.nil?

    @current_user
  end

  def impersonated?
    impersonate_user_id.present?
  end

  def impersonate_user_id
    session[:impersonate_user_id]
  end

  def reset_impersonate
    session.delete(:impersonate_user_id)
  end

  def user_signed_in?
    current_user.present?
  end

  def authenticate_admin_user!
    return if user_signed_in? && current_user.admin?

    redirect_to root_path
  end

  def current_admin_user
    return unless current_user.admin?

    current_user
  end
end
