# frozen_string_literal: true

class API::Widgets::Cards::MainController < ActionController::Base
  include CurrentUser

  before_action :set_robot_noindex
  before_action :find_resource
  before_action :extract_forwarded_params

  def redirect
    redirect_to url, status: :moved_permanently
  end

  private

  def set_robot_noindex
    response.headers['X-Robots-Tag'] = 'noindex'
  end

  def find_resource
    @resource = ::Cards.object_for(params[:id])
  end

  def extract_forwarded_params
    # NOTE(DZ): Everything in params except for these keys are forwarded as
    # redirected URL params.
    @forwarded_params = params.except(:id, :controller, :action).permit!
  end

  def url
    Routes.subject_url(@resource, @forwarded_params)
  end
end
