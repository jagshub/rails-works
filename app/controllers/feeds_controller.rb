# frozen_string_literal: true

class FeedsController < ActionController::Base
  respond_to :atom

  layout false

  def show
    @application_id = OAuth::Application.find_by(twitter_app_name: 'Product Hunt Feed').try(:id)

    @posts = Post.featured.includes(:user).limit(50).by_date

    topic = Topic.find_by(slug: params[:category]) if params[:category]
    @posts = @posts.in_topic(topic) if topic.present?

    @posts = @posts.to_a

    return unless stale?(@posts)
  end

  def stories
    category = params[:category]

    scope = Anthologies::Story.published.includes(:author)
    scope = scope.where(category: category) if Anthologies::Story.categories.key?(category)

    @stories = scope.order(published_at: :desc).limit(50)
  end

  def newsletters
    @newsletters = Newsletter.sent.daily.by_sent_date.limit(50)
  end
end
