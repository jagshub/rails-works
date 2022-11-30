# frozen_string_literal: true

module ApplicationPolicy
  extend KittyPolicy
  extend self

  # NOTE(rstankov): Used in GraphQL type, can a user see a given subject
  READ = :read

  # NOTE(rstankov): Maintain means that a user can create, read, update, destroy a given resource
  # Use case - ship account member can, manage this account surveys
  MAINTAIN = :maintain
  MODERATE = :moderate

  extend Ships::Policy
  extend Maker::Policy
  extend Anthologies::Policy
  extend MakersFestival::Policy
  extend Discussion::Policy
  extend UpcomingEvents::Policy
  extend FounderClub.policy
  extend GoldenKitty.policy
  extend Moderation.policy
  extend Teams.policy

  can :change_username, User do |user|
    (user.twitter_username.blank? || user.twitter_username.try(:downcase) != user.username) && user.created_at > 24.hours.ago
  end

  can :change_email, User do |user|
    user.admin? || user.subscriber.can_change_email?
  end

  can :create, Shoutout do |user|
    !spammer?(user)
  end

  can :moderate, Flag do |user|
    admin?(user)
  end

  can :moderate, Post do |user|
    admin?(user)
  end

  can :moderate, Product do |user|
    admin?(user) || external_moderator?(user)
  end

  can :moderate, User do |user|
    admin?(user)
  end

  can %i(new create), ProductRequest do |user|
    !spammer?(user) && !user.company?
  end

  can %i(edit update destroy), ProductRequest do |user, product_request|
    user.admin? || product_request.user_id == user.id
  end

  can :moderate, ProductRequest do |user|
    admin?(user)
  end

  can :manage, :beta_features do |user|
    user.admin? || user.beta_tester?
  end

  can %i(index new create edit update destroy), :application do |user|
    !spammer?(user)
  end

  can %i(create destroy), :developer_token do |user|
    !spammer?(user)
  end

  can %i(edit update followings), User do
    true
  end

  can :create, Review do |user, review|
    subject = review.product || review.post
    !user.blocked? && !subject.reviews.where(user_id: user.id).exists? && (!subject.respond_to?(:maker_ids) || !subject.maker_ids.include?(user.id))
  end

  can %i(update destroy), Review do |user, review|
    user.admin? || review.user_id == user.id
  end

  can %i(new create), Recommendation do |user, recommendation|
    !spammer?(user) && !user.company? && !recommendation.product_request&.duplicate?
  end

  can %i(edit update destroy), Recommendation do |user, recommendation|
    user.admin? || recommendation.user_id == user.id
  end

  can :moderate, Recommendation do |user|
    admin?(user)
  end

  can :moderate, RecommendedProduct do |user|
    admin?(user)
  end

  can :create, Vote do |user, vote|
    subject = vote.subject

    case subject.class.name
    when 'Post'
      !subject.scheduled? || subject.user_id == user.id || !subject.disabled_when_scheduled?
    when 'MakersFestival::Participant'
      ::MakersFestival::Utils.period(subject.makers_festival_category.makers_festival_edition) == :voting
    else
      true
    end
  end

  can :destroy, Vote do |user, vote|
    vote.user_id == user.id
  end

  can :create, Collection do
    true
  end

  can :update, Collection do |user, collection|
    collection.curator? user
  end

  can %i(destroy edit_curators), Collection do |user, collection|
    collection.owner? user
  end

  can :destroy, Subscription do |user, subscription|
    user.subscriber.id == subscription.subscriber_id
  end

  can %i(create update destroy feature), CollectionPostAssociation do |user, collection_post|
    user.admin? || collection_post.collection.curator?(user)
  end

  can :show, :moderation_tools do |user|
    admin?(user)
  end

  can :create, Post do |user|
    Posts::CanPostCheck.call(user)
  end

  can :become_maker, Post do |user, post|
    !spammer?(user) && !user.company? && !user_is_maker?(user: user, post: post)
  end

  can :feature, Post do |user|
    admin?(user) || user.can_post?
  end

  can :manage, Post do |user, _post|
    admin?(user)
  end

  can :edit, Post do |user, post|
    admin?(user) || user_is_hunter_or_maker?(user: user, post: post)
  end

  can %i(update maintain), Post do |user, post|
    admin?(user) || (!post.locked? && user_is_hunter_or_maker?(user: user, post: post))
  end

  can :create, PostTopicAssociation do
    true
  end

  can %i(update destroy), PostTopicAssociation do |user, assoc|
    admin?(user) || ProductMakers.maker_of?(user: user, post_id: assoc.post_id)
  end

  can :show, ModerationLog do |user, moderation_log|
    admin?(user) || moderation_log&.share_public?
  end

  can :destroy, User do |user, user_to_destroy|
    user_to_destroy.id == user.id
  end

  can %i(create destroy manage), UserFriendAssociation do
    true
  end

  can :manage, Subscription do
    true
  end

  can %i(new create), Comment do |user, comment|
    if comment.subject.is_a?(Post) && post_archived?(comment.subject)
      false
    else
      user.admin? || (!user.company? && user.verified_legit_user?)
    end
  end

  can :reply, Comment do |user, comment|
    case comment.subject
    when UpcomingPageMessage
      !spammer?(user) && !comment.sticky
    when Review
      false
    when Post
      post_archived?(comment.subject) ? false : (!user.company? && !spammer?(user) && !comment.sticky)
    else
      !user.company? && !spammer?(user) && !comment.sticky
    end && user.verified_legit_user?
  end

  can %i(edit update manage), Comment do |user, comment|
    admin?(user) || comment.user_id == user.id
  end

  can :destroy, Comment do |user, comment|
    admin?(user) || comment.user_id == user.id
  end

  can :moderate, Comment do |user|
    admin?(user)
  end

  can :moderate, Review do |user|
    admin?(user)
  end

  can %i(create update destroy manage), Media do |user, media|
    subject = media.subject
    admin?(user) ||
      (subject.is_a?(Post) &&
        user_is_hunter_or_maker?(user: user, post: subject))
  end

  can %i(create update destroy manage), ProductMaker do |user|
    admin?(user)
  end

  can :moderate, Job do |user|
    admin?(user)
  end

  can :maintain, Job do |user, job|
    job.user_id.present? && job.user_id == user.id
  end

  can :read, Payment::Subscription do |user, subscription|
    subscription.user_id == user.id
  end

  can :destroy, PollAnswer do |user, poll_answer|
    poll_answer.user_id == user.id
  end

  can :update, Stream::FeedItem do |user, feed_item|
    feed_item.receiver_id == user.id
  end

  can :showcase, Badges::UserAwardBadge do |user, badge|
    badge.subject_id.to_i == user.id
  end

  private

  def hunter_or_maker_of?(user, product)
    product.posts.each do |post|
      return true if user_is_hunter?(user: user, post: post)
      return true if user_is_maker?(user: user, post: post)
    end

    false
  end

  def spammer?(user)
    user.potential_spammer? || user.spammer?
  end

  def admin?(user)
    user&.admin?
  end

  def external_moderator?(user)
    user&.external_moderator?
  end

  def user_is_hunter_or_maker?(user:, post:)
    user_is_hunter?(user: user, post: post) || user_is_maker?(user: user, post: post)
  end

  def user_is_maker?(user:, post:)
    ProductMakers.maker_of?(user: user, post_id: post.id)
  end

  def user_is_hunter?(user:, post:)
    post.user_id == user.id
  end

  def post_archived?(post)
    return false unless post.persisted?

    post.archived?
  end
end
