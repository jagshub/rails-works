# frozen_string_literal: true

class CommentsController < ApplicationController
  # NOTE (k1): This URL is specifically used for oembed permalinks into comments and should not be used by users directly.
  # This is temporary until we have proper comment permalinks.

  include ActionView::Helpers::TagHelper

  def show
    comment = Comment.find(params[:id])

    oembed_url = "https://www.producthunt.com/comments/#{ comment.id }"
    oembed_discovery_tag = tag(:link, rel: 'alternate', type: 'application/json+oembed', href: "https://api.producthunt.com/widgets/oembed?url=#{ Addressable::URI.encode(oembed_url) }")

    render html: "<html><head>#{ oembed_discovery_tag }</head><body></body></html>".html_safe
  end
end
