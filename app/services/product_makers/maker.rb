# frozen_string_literal: true

class ProductMakers::Maker
  attr_reader :username, :user, :post

  class << self
    def from_suggestion(maker_suggestion, auth: nil)
      # NOTE(DZ): Suggestions are for twitter usernames but in PH sometimes
      # they have a different username. Use auth to find user by twitter uid
      user = maker_suggestion.maker || auth&.find_user

      post = maker_suggestion.post
      username = maker_suggestion.maker_username

      new(post: post, maker_suggestion: maker_suggestion, user: user, username: username)
    end
  end

  def initialize(username: nil, user: nil, post: nil, maker_suggestion: nil)
    @username   = username.try(:downcase) || user.username
    @user       = user || User.find_by_username(username)
    @post       = post
    @suggestion = maker_suggestion
  end

  delegate :id, to: :suggestion, prefix: true

  def suggestion
    @suggestion ||= find_suggestion
  end

  def suggested?
    suggestion.present?
  end

  def association
    association_scope.first
  end

  def association?
    association_scope.any?
  end

  def twitter_username
    user&.twitter_username
  end

  # Note(andreasklinger): For legacy makers that dont have a suggestion with them
  def approved?
    return suggestion.approved? if suggested?

    true
  end

  def joined?
    return suggestion.joined? if suggested?

    true
  end

  def invited_by
    return suggestion.invited_by if suggested?

    nil
  end

  def invited_by_id
    return suggestion.invited_by_id if suggested?

    nil
  end

  private

  def find_suggestion
    return if post.blank?

    (user.present? && post.maker_suggestions.find_by(maker_id: user.id)) ||
      post.maker_suggestions.find_by(maker_username: username)
  end

  def association_scope
    @association_scope ||=
      if user.present?
        user.product_makers.where(post_id: post.id)
      else
        ProductMaker.none
      end
  end
end
