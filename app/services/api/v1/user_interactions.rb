# frozen_string_literal: true

class API::V1::UserInteractions
  attr_reader :user

  INTERACTIONS = {
    'following_user_ids' => ->(user) { user.user_friend_associations.pluck :following_user_id },
    'voted_post_ids' => ->(user) { user.post_votes.pluck :subject_id },
    'voted_comment_ids' => ->(user) { user.comment_votes.pluck :subject_id },
    'collected_post_ids' => ->(user) { CollectionPostAssociation.where(collection_id: user.collections.pluck(:id)).pluck(:post_id).uniq },
    'subscribed_collection_ids' => ->(user) { CollectionSubscription.where(user_id: user.id).pluck(:collection_id) },
    'followed_topics_ids' => ->(user) { user.subscriptions.for_topics.pluck :subject_id },
  }.freeze

  def self.interaction_names
    INTERACTIONS.keys
  end

  def initialize(user)
    @user = user
  end

  def all
    interactions INTERACTIONS.keys
  end

  def interactions(inclusions)
    Hash[Array(inclusions).map { |name| [name, interaction(name)] }]
  end

  private

  def interaction(name)
    interaction = INTERACTIONS.fetch(name) { raise "Invalid interaction - #{ name }" }
    interaction.call user
  end
end
