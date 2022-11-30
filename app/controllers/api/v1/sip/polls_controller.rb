# frozen_string_literal: true

class API::V1::Sip::PollsController < API::V1::BaseController
  def show
    render json: { sip_poll: nil }
  end

  private

  def public_endpoint?
    true
  end
end
