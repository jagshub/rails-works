# frozen_string_literal: true

class API::V2::OAuth::ApplicationsController < API::V2::OAuth::BaseController
  before_action :set_application, only: %i(edit update destroy)

  def index
    authorize! :index, :application

    page_title('Product Hunt - Applications')

    @applications = current_user.oauth_applications
  end

  def new
    authorize! :new, :application

    @application = current_user.oauth_applications.build
  end

  def create
    authorize! :create, :application

    @application = current_user.oauth_applications.build(application_params)

    if @application.save
      redirect_to api_v2_oauth_applications_path, notice: 'Saved!'
    else
      render :new
    end
  end

  def update
    authorize! :update, :application

    if @application.update(application_params)
      redirect_to api_v2_oauth_applications_path, notice: 'Updated!'
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, :application

    @application.destroy!
    redirect_to api_v2_oauth_applications_path, notice: 'Destroyed!'
  end

  private

  def application_params
    # NOTE(Dhruv): Reduce max_requests_per_hour limit for v2 apps since
    # they would be hitting graphql endpoint most of the time
    params.require(:oauth_application).permit(:name, :redirect_uri).merge(max_requests_per_hour: 1000, legacy: false)
  end
end
