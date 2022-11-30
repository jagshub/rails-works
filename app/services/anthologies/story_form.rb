# frozen_string_literal: true

class Anthologies::StoryForm
  include MiniForm::Model

  ATTRIBUTES = %i(
    title
    body_html
    description
    header_image_uuid
    social_image_uuid
    mins_to_read
    post_mentions
    user_mentions
    product_mentions
    author_name
    author_url
    category
  ).freeze

  model :anthologies_stories, attributes: ATTRIBUTES, read: %i(id)

  alias node anthologies_stories
  alias graphql_result anthologies_stories

  def initialize(inputs:, user:)
    @user = user
    @anthologies_stories = inputs[:story]
    @post_mentions = inputs[:post_mentions] || []
    @user_mentions = inputs[:user_mentions] || []
    @product_mentions = inputs[:product_mentions] || []
  end

  def perform
    @anthologies_stories.post_mentions = @post_mentions
    @anthologies_stories.user_mentions = @user_mentions
    @anthologies_stories.product_mentions = @product_mentions

    @anthologies_stories.save!
  end
end
