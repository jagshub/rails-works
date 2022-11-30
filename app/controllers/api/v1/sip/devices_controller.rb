# frozen_string_literal: true

class API::V1::Sip::DevicesController < API::V1::BaseController
  def create
    render json: {}
  end

  private

  def public_endpoint?
    true
  end
end
