# frozen_string_literal: true

class Newsletter::Content::TopPostItem
  attr_reader :name, :tagline, :post, :makers

  delegate :id, :thumbnail_url, :to_param, :votes_count, to: :post

  VOTERS_SHOWN_COUNT = 5

  class << self
    def from_array(posts_array, loader = nil)
      posts_array.map do |attributes|
        attributes = attributes.stringify_keys
        post = loader.present? ? loader.get(attributes.fetch('id')).first : Post.find(attributes.fetch('id'))

        new(post, attributes)
      end
    end
  end

  def initialize(post, attributes = {})
    @post = post
    @name = attributes.fetch('name') { @post.name }
    @tagline = attributes.fetch('tagline') { @post.tagline }
    @makers = @post.makers.pluck(:id)
  end

  def voter_ids_for(user)
    scope = post.votes
    scope = scope.order_by_friends(user) if user.present? && user.persisted?
    scope.limit(VOTERS_SHOWN_COUNT).pluck(:user_id)
  end
end
