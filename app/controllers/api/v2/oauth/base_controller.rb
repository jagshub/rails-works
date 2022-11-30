# frozen_string_literal: true

class API::V2::OAuth::BaseController < ApplicationController
  respond_to :html

  before_action :require_user_for_cancan_auth!

  helper_method :find_developer_token_for

  private

  def set_application
    id = params[:id] || params[:application_id]
    @application = current_user.oauth_applications.not_legacy.find(id)
  end

  def find_developer_token_for(application)
    @tokens = {} if @tokens.blank?

    @tokens[application.id] ||= application.access_tokens.find_by(
      resource_owner_id: current_user.id,
      scopes: 'public private write',
      expires_in: nil,
    )
  end
end
