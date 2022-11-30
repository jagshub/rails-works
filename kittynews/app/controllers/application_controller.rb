class ApplicationController < ActionController::Base
  # NOTE(rstankov): Removed for demo purposes
  # protect_from_forgery with: :exception
  #
  include Devise::Controllers::Helpers
  before_action :set_user

  private

  def set_user
    cookies[:username] = current_user.nil? ? "" : current_user.name
  end
end
