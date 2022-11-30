# frozen_string_literal: true

class API::V1::SipsController < API::V1::BaseController
  def index
    render json: { sips: [] }
  end

  def show
    render json: { sip: nil }
  end

  private

  def public_endpoint?
    true
  end
end
