# frozen_string_literal: true

class API::V1::Sip::PollVotesController < API::V1::BaseController
  def index
    render json: { vote_counts: 0 }, status: :created
  end

  def create
    render json: { vote: nil }, status: :created
  end

  private

  def public_endpoint?
    true
  end
end
