# frozen_string_literal: true

class FunFact
  class << self
    def to_html(user, tracking_params: nil)
      new(user, tracking_params: tracking_params).to_html
    end
  end

  attr_reader :user, :tracking_params

  def initialize(user, tracking_params: nil)
    @user = user
    @tracking_params = tracking_params
  end

  def to_html
    maker_fact ||
      submission_fact ||
      collection_fact ||
      vote_fact ||
      topics_fact ||
      ''
  end

  private

  def maker_fact
    post = user.products.visible.featured.by_credible_votes.first

    return if post.blank?

    "#{ user.first_name } made #{ link_to_post(post) }."
  end

  def submission_fact
    post = user.posts.featured.by_date.first

    return if post.blank?

    "#{ user.first_name } recently posted #{ link_to_post(post) }."
  end

  def collection_fact
    collection = user.collections.with_recently_added_posts.by_update_date.first

    return if collection.blank?

    "#{ user.first_name } created #{ link_to_collection(collection) } collection."
  end

  def vote_fact
    vote = user.post_votes.by_date.first

    return if vote.blank?

    "#{ user.first_name } recently upvoted #{ link_to_post(vote.subject) }."
  end

  def topics_fact
    topics = user.followed_topics.limit(3)

    return if topics.empty?

    "#{ user.first_name } follows #{ smart_and(topics.map { |topic| link_to_topic(topic) }) }."
  end

  def smart_and(list)
    case list.count
    when 0..2 then list.join(' and ')
    else "#{ list[0..-2].join(', ') } and #{ list.last }"
    end
  end

  def link_to_post(post)
    %(<a href="#{ Routes.post_url(post, tracking_params) }">#{ post.name }</a>)
  end

  def link_to_topic(topic)
    %(<a href="#{ Routes.topic_url(topic, tracking_params) }">#{ topic.name }</a>)
  end

  def link_to_collection(collection)
    %(<a href="#{ Routes.collection_url(collection, tracking_params) }">#{ collection.name }</a>)
  end
end
