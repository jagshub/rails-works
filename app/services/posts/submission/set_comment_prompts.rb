# frozen_string_literal: true

module Posts::Submission::SetCommentPrompts
  extend self

  def call(post:, comment_prompts:)
    return if comment_prompts.blank?

    comment_prompts.each do |prompt|
      post.comment_prompts.create!(prompt: prompt)
    end
  end
end
