# frozen_string_literal: true

class Graph::Resolvers::Ads::Preview < Graph::Resolvers::Base
  type [Graph::Types::PostType], null: false

  TESLA_ROADSTER_ID = 113_763
  OAK_ID = 112_301
  INTERCOM_ID = 232
  YOURSTACK_ID = 182_437

  def resolve
    preview_post_id = user_top_post(current_user || INTERCOM_ID)

    Post.where(id: [TESLA_ROADSTER_ID, preview_post_id, OAK_ID, YOURSTACK_ID])
  end

  private

  def user_top_post(current_user)
    return if current_user.nil?

    Post
      .featured
      .joins(:product_makers).where('product_makers.user_id': current_user[:id])
      .order('featured_at desc')
      .limit(1)
      .pluck(:id).first
  end
end
