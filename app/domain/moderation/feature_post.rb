# frozen_string_literal: true

class Moderation::FeaturePost
  include MiniForm::Model
  include ActiveModel::Validations::Callbacks

  STANDARD_REASONS = ['Product is pre-launch', 'Product has been around for some time', 'Duplicate', 'Not a product', 'Website is down'].freeze
  OTHER_REASON = 'other'

  attributes :action, :featured_at, :bump_post, :custom_reason
  model :moderation_reason, attributes: %i(reason share_public message)
  model :post

  alias node post
  alias graphql_result post

  before_validation :update_values

  def initialize(post:, moderator:)
    @post = post
    @moderation_reason = Moderation::Reason.find_or_initialize_by reference: post, moderator: moderator
  end

  def featured_at_or_fallback
    featured_at.presence || post.scheduled_at || post.created_at
  end

  def custom_reason
    return @custom_reason if @custom_reason.present?

    reason unless STANDARD_REASONS.include? reason
  end

  def perform
    post.save!
    moderation_reason.reason = @custom_reason if @custom_reason.present?
    moderation_reason.save!
    Moderation::Notifier.for_post(notifier_options).notify
  end

  private

  def update_values
    case action
    when 'unfeature'
      Posts::Feature.call(post, featured_at: nil)
    when 'feature'
      Posts::Feature.call(post, featured_at: Time.current) if bump_post.present? || !post.featured?
    when 'schedule'
      Posts::Feature.call(post, featured_at: featured_at)
    else
      raise MiniForm::InvalidForm
    end

    self.message = notifier_options[:message]
  end

  def notifier_options
    case action
    when 'unfeature'
      base_options.merge(message: ModerationLog::UNFEATURE_MESSAGE, color: :red, reason: reason)
    when 'feature'
      base_options.merge(message: ModerationLog::FEATURE_MESSAGE, color: :green)
    when 'schedule'
      base_options.merge(message: ModerationLog::SCHEDULE_MESSAGE, color: :green)
    end
  end

  def base_options
    { author: moderation_reason.moderator, post: post }
  end
end
