# frozen_string_literal: true

class API::V1::OAuth::ApplicationsController < API::V1::OAuth::BaseController
  before_action :set_application, only: %i(edit update destroy)

  def index
    authorize! :index, :application

    page_title('Product Hunt - Applications')

    @applications = current_user.oauth_applications.legacy
  end

  def update
    authorize! :update, :application

    if @application.update(application_params)
      redirect_to api_v1_oauth_applications_path, notice: 'Updated!'
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, :application

    @application.destroy!
    redirect_to api_v1_oauth_applications_path, notice: 'Destroyed!'
  end

  private

  def application_params
    if @application.present? && @application.twitter_auth_allowed?
      params.require(:oauth_application).permit(:name, :redirect_uri, :twitter_app_name,
                                                :twitter_consumer_key, :twitter_consumer_secret)
    else
      params.require(:oauth_application).permit(:name, :redirect_uri)
    end
  end
end
