# frozen_string_literal: true

class Graph::Mutations::StoryUpdate < Graph::Mutations::BaseMutation
  argument_record :story, Anthologies::Story, required: true, authorize: :update

  argument :title, String, required: false
  argument :body_html, Graph::Types::HTMLType, required: false
  argument :description, String, required: false
  argument :header_image_uuid, String, required: false
  argument :social_image_uuid, String, required: false
  argument :mins_to_read, Integer, required: false
  argument :category, String, required: false
  argument :authorName, String, required: false
  argument :authorUrl, String, required: false
  argument_records :post_mentions, Post, required: false
  argument_records :user_mentions, User, required: false
  argument_records :product_mentions, Product, required: false

  returns Graph::Types::Anthologies::StoryType

  def perform(inputs)
    form = Anthologies::StoryForm.new(inputs: inputs, user: current_user)
    form.update(inputs)

    Anthologies.update_story_events(form.node)

    form.node
  end
end
