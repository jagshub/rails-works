# frozen_string_literal: true

class API::V1::SettingsSerializer < API::V1::UserSerializer
  attributes :permissions, :notifications, :first_time_user

  delegated_attributes(
    :name,
    :email,
    :role,
    to: :resource,
  )

  delegated_attributes(
    :send_mention_email,
    :send_friend_post_email,
    :send_new_follower_email,
    :send_product_recommendation_email,
    :subscribed_to_push,
    :send_email_digest_email,
    :send_onboarding_email,
    :send_onboarding_post_launch_email,
    :send_maker_instructions_email,
    :send_dead_link_report_email,
    :send_featured_maker_email,
    :send_stripe_discount_email,
    :send_upcoming_page_promotion_scheduled_email,
    to: :resource,
  )

  def permissions
    {
      can_vote_posts: ApplicationPolicy.can?(resource, :create, ::Vote.new(subject: ::Post.new)),
      can_comment: ApplicationPolicy.can?(resource, :create, ::Comment.new(subject: ::Post.new)),
      can_post: ApplicationPolicy.can?(resource, :create, ::Post),
      can_change_username: ApplicationPolicy.can?(resource, :change_username, resource),
    }
  end

  def notifications
    {
      total: 0,
      unseen: 0,
    }
  end

  def first_time_user
    resource.first_time_user?
  end

  def interactions
    API::V1::UserInteractions.new(resource).all
  end

  def serialize_attributes
    if include? 'interactions'
      { interactions: {} }.merge(super)
    else
      super
    end
  end
end
