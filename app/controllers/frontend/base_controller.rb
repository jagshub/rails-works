# frozen_string_literal: true

class Frontend::BaseController < ApplicationController
  # NOTE(vesln): CloudFlare does not support content negotiation and Rails needs an explicit hint
  before_action :ensure_proper_format

  protect_from_forgery_stateless

  rescue_from ActiveRecord::RecordNotFound do
    head :not_found
  end

  private

  def ensure_proper_format
    request.format = :json
  end
end
