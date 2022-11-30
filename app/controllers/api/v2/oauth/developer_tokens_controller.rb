# frozen_string_literal: true

class API::V2::OAuth::DeveloperTokensController < API::V2::OAuth::BaseController
  before_action :set_application, only: %i(create destroy)

  def create
    authorize! :create, :developer_token

    @application.access_tokens.find_or_create_by!(
      resource_owner_id: current_user.id,
      scopes: 'public private write',
      expires_in: nil,
    )

    redirect_to api_v2_oauth_applications_path, notice: 'Developer Token created!'
  end

  def destroy
    authorize! :destroy, :developer_token

    @developer_token = find_developer_token_for(@application)

    @developer_token.destroy! if @developer_token.present?
    redirect_to api_v2_oauth_applications_path, notice: 'Developer Token destroyed!'
  end
end
