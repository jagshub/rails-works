# frozen_string_literal: true

# NOTE(jag):  Application controller is referenced from the initializer `config/initializers/00_monkey_patches.rb`
# The require's are needed to fix deprecation warnings when we moved to 6.1
# DEPRECATION WARNING: Initialization autoloaded the constants ApplicationHelper, ActiveAdmin::NotificationsHelper,
# CurrentUser .... etc.,
require 'current_user'
require 'meta_tags'
require 'routes/custom_paths'
require 'routes/frontend_paths'
require 'routes'
require 'routes/custom_controller_paths'
require 'csrf_protection'
require 'authorization'
require 'kitty_policy'

require 'application_helper'
require 'active_admin/ads_helper'
require 'active_admin/best_in_place_helper'
require 'active_admin/image_upload_helper'
require 'active_admin/notifications_helper'
require 'active_admin/payment_helper'
require 'active_admin/posts_helper'
require 'active_admin/status_helper'
require 'active_admin/user_helper'
require 'mail_helper'
require 'meta_tags_helper'
require 'newsletter_helper'
require 'team_helper'
require 's3_helper'
require 'users_helper'
require 'doorkeeper/dashboard_helper'

class ApplicationController < ActionController::Base
  include CurrentUser
  include MetaTags
  include Routes::CustomControllerPaths
  include CsrfProtection
  include Authorization

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # NOTE(vesln): the guests have no session, therefore CSRF is useless. Also,
  # they will have no CSRF token because of the CDN caching
  skip_before_action :verify_authenticity_token, unless: :user_signed_in?

  before_action :verify_origin

  # NOTE(andreasklinger): Needs to be set serverside b/c we already use it in the controllers for the initial request
  before_action :save_visitor_id_info

  before_action :save_track_code

  before_action :set_error_reporting_user

  after_action :save_csrf_token

  helper_method :current_user, :user_signed_in?

  rescue_from KittyPolicy::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  rescue_from ActiveRecord::RecordNotFound do
    handle_not_found
  end

  private

  def handle_not_found
    if request.xhr?
      head :not_found
    else
      redirect_to not_found_path
    end
  end

  def save_visitor_id_info
    cookies.permanent[:visitor_id] = SecureRandom.uuid if ::Utf8Sanitize.call(cookies[:visitor_id]).blank?
  end

  def save_track_code
    cookies.permanent[:track_code] ||= SecureRandom.hex(5)
  end

  def save_csrf_token
    cookies.permanent[:csrf_token] = form_authenticity_token
  end

  def set_error_reporting_user
    # Note(AR): Prefixed with `::` to work around autoloading bug in dev
    ::ErrorReporting.set_user(username: current_user.username, id: current_user.id) if current_user
  end

  def require_user_for_cancan_auth!
    return if user_signed_in?

    raise KittyPolicy::AccessDenied.with_message('You need to sign in to access this page')
  end

  def redirect_for_ajax_action
    redirect_back alert: 'This action only works on the page directly', fallback_location: root_path
  end

  def verify_origin
    return unless Rails.env.production?

    origin = request.headers['origin']
    return if origin.blank? || origin == 'null' || RequestOrigin.allowed_host?(origin)

    # Note(AR): Prefixed with `::` to work around autoloading bug in dev
    ::ErrorReporting.report_warning_message('Unauthorized origin', extra: { origin: origin })

    head :forbidden
  end
end
