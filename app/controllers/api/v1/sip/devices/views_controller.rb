# frozen_string_literal: true

class API::V1::Sip::Devices::ViewsController < API::V1::BaseController
  def create
    render json: { analytic: {} }, status: :created
  end

  private

  def public_endpoint?
    true
  end
end
