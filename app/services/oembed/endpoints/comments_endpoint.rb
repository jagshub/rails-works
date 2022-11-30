# frozen_string_literal: true

module Oembed::Endpoints::CommentsEndpoint
  extend self
  include Oembed::Endpoint

  MATCHERS = {
    %r{\A(?<protocol>https{0,1}:\/\/){0,1}(?<domain>(www\.){0,1}(producthunt\.com|producthunt\.org))\/comments\/(?<id>.+)\Z}i => :comments,
  }.freeze

  COMMENTS_SIZE_RATIO = (500.0 / 405.0)
  MINIMUM_SIZE = 280
  MAXIMUM_SIZE = 500

  def comments(match, maxheight: nil, maxwidth: nil)
    comment = Comment.find(match[:id])

    maxwidth = MAXIMUM_SIZE if maxwidth.nil? || maxwidth > MAXIMUM_SIZE
    maxheight = MAXIMUM_SIZE if maxheight.nil? || maxheight > MAXIMUM_SIZE

    width, height = compute_max_size(MINIMUM_SIZE, MINIMUM_SIZE, maxwidth.to_i, maxheight.to_i, COMMENTS_SIZE_RATIO)

    iframe_url = "https://cards.producthunt.com/cards/comments/#{ comment.id }?v=1"

    {
      version: '1.0',
      title: "#{ comment.user.name }'s Comment on #{ comment.subject_name }",
      type: 'rich',
      width: width,
      height: height,
      html: %(<iframe style="border: none;" src="#{ iframe_url }" width="#{ width }" height="#{ height }" frameborder="0" scrolling="no" allowfullscreen></iframe>),
      provider_name: 'Product Hunt',
      provider_url: 'https://www.producthunt.com',
    }
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
