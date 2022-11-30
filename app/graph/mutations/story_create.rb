# frozen_string_literal: true

class Graph::Mutations::StoryCreate < Graph::Mutations::BaseMutation
  argument :title, String, required: true
  argument :body_html, Graph::Types::HTMLType, required: false
  argument :description, String, required: false
  argument :header_image_uuid, String, required: false
  argument :social_image_uuid, String, required: false
  argument :mins_to_read, Integer, required: false
  argument :category, String, required: true
  argument :author_name, String, required: false
  argument :author_url, String, required: false
  argument_records :post_mentions, Post, required: false
  argument_records :user_mentions, User, required: false
  argument_records :product_mentions, Product, required: false

  returns Graph::Types::Anthologies::StoryType

  authorize :create, Anthologies::Story

  def perform(inputs)
    story = Anthologies::Story.create(
      author: current_user,
      title: inputs[:title],
      body_html: inputs[:body_html],
      description: inputs[:description],
      header_image_uuid: inputs[:header_image_uuid],
      social_image_uuid: inputs[:social_image_uuid],
      mins_to_read: inputs[:mins_to_read],
      category: inputs[:category],
      author_name: inputs[:author_name],
      author_url: inputs[:author_url],
      post_mention_ids: (inputs[:post_mentions] || []).pluck(:id),
      user_mention_ids: (inputs[:user_mentions] || []).pluck(:id),
      product_mention_ids: (inputs[:product_mentions] || []).pluck(:id),
    )

    Anthologies.update_story_events(story)

    story
  end
end
