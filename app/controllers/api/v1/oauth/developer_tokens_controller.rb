# frozen_string_literal: true

class API::V1::OAuth::DeveloperTokensController < API::V1::OAuth::BaseController
  before_action :set_application, only: %i(create destroy)

  def create
    authorize! :create, :application

    @application.access_tokens.find_or_create_by!(
      resource_owner_id: current_user.id,
      scopes: 'public private',
      expires_in: nil,
    )

    redirect_to api_v1_oauth_applications_path, notice: 'Developer Token created!'
  end

  def destroy
    @developer_token = find_developer_token_for(@application)

    @developer_token.destroy! if @developer_token.present?
    redirect_to api_v1_oauth_applications_path, notice: 'Developer Token destroyed!'
  end
end
