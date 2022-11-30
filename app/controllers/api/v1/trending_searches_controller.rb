# frozen_string_literal: true

class API::V1::TrendingSearchesController < API::V1::BaseController
  def index
    render json: {
      data: Rails.configuration.settings.array(:trending_searches),
    }
  end
end
