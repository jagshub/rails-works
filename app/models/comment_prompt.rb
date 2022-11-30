# frozen_string_literal: true

# == Schema Information
#
# Table name: comment_prompts
#
#  id         :bigint(8)        not null, primary key
#  prompt     :string           not null
#  post_id    :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_comment_prompts_on_post_id  (post_id)
#
# Foreign Keys
#
#  fk_rails_...  (post_id => posts.id)
#
class CommentPrompt < ApplicationRecord
  POST_COMMENT_PROMPT_LIMIT = 3

  belongs_to :post, inverse_of: :comment_prompts

  enum prompt: {
    design_and_ux: 'design_and_ux',
    business_model: 'business_model',
    initial_impressions: 'initial_impressions',
    pricing: 'pricing',
    value_proposition: 'value_proposition',
    feature_set: 'feature_set',
  }

  validate :post_prompts_do_not_exceed_limit
  validates_absence_of :existing_prompt_for_post

  private

  def existing_prompt_for_post
    return if post.blank?

    post.comment_prompts.find_by(prompt: prompt)
  end

  def post_prompts_do_not_exceed_limit
    return if post.blank?

    if post.comment_prompts.count >= POST_COMMENT_PROMPT_LIMIT
      errors.add(:prompt, "post comment prompt count cannot exceed #{ POST_COMMENT_PROMPT_LIMIT }")
    end
  end
end
