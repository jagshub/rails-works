# frozen_string_literal: true

class PublicImageController < ApplicationController
  def post_launch
    @post = Post.find(params[:id])
    url = External::Url2pngApi.share_url(@post, 'post_launch')
    image_data = HandleNetworkErrors.call(fallback: nil) { URI.open(url).read }
    send_data(image_data, type: 'image/png', disposition: 'inline')
  end
end
