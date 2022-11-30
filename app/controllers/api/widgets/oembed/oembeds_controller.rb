# frozen_string_literal: true

class API::Widgets::Oembed::OembedsController < ActionController::Base
  respond_to :json

  def show
    oembed = ::Oembed.fetch(url: params[:url], maxwidth: params[:maxwidth], maxheight: params[:maxheight])

    if oembed
      render json: oembed
    else
      head :not_found
    end
  end
end
