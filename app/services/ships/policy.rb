# frozen_string_literal: true

module Ships::Policy
  extend KittyPolicy
  extend self

  can :manage, :ship do |user|
    Ships::Subscription.new(user).valid?
  end

  can :trial, ShipSubscription, allow_guest: true do |user, _subscription|
    Ships::Subscription.new(user).trial_available?
  end

  can :claim_aws_credits, ShipSubscription do |user, _subscription|
    Ships::Subscription.new(user).can_claim_aws_credits?
  end

  can %i(new create), UpcomingPage do |user, _upcoming_page|
    user.admin? || Ships::Subscription.new(user).can_create_upcoming_page?
  end

  can %i(edit update maintain), UpcomingPage do |user, upcoming_page|
    upcoming_page_maintainter?(user, upcoming_page)
  end

  can :destroy, UpcomingPage do |user, upcoming_page|
    upcoming_page.account.user_id == user.id
  end

  can :claim_aws_credits, UpcomingPage do |user, upcoming_page|
    upcoming_page_maintainter?(user, upcoming_page) && Ships::Subscription.new(upcoming_page.user).can_claim_aws_credits?
  end

  can :ship_schedule_posts, UpcomingPage do |user, upcoming_page|
    upcoming_page_maintainter?(user, upcoming_page) && Ships::Subscription.new(upcoming_page.user).can_schedule_posts?
  end

  can :send_message, UpcomingPage do |user, upcoming_page|
    upcoming_page_maintainter?(user, upcoming_page) && Ships::Subscription.new(upcoming_page.user).can_send_message?
  end

  can :ship_segments, UpcomingPage do |user, upcoming_page|
    upcoming_page_maintainter?(user, upcoming_page) && Ships::Subscription.new(upcoming_page.user).can_segments?
  end

  can :ship_metrics, UpcomingPage do |user, upcoming_page|
    upcoming_page_maintainter?(user, upcoming_page) && Ships::Subscription.new(upcoming_page.user).can_use_metrics?
  end

  can :ship_ab, UpcomingPage do |user, upcoming_page|
    upcoming_page_maintainter?(user, upcoming_page) && Ships::Subscription.new(upcoming_page.user).can_use_ab?
  end

  can :ship_webhooks, UpcomingPage do |user, upcoming_page|
    upcoming_page_maintainter?(user, upcoming_page) && Ships::Subscription.new(upcoming_page.user).can_use_webhooks?
  end

  can :ship_premium_support, UpcomingPage do |user, upcoming_page|
    upcoming_page_maintainter?(user, upcoming_page) && Ships::Subscription.new(upcoming_page.user).can_access_premium_support?
  end

  can :send_continuous_messages, UpcomingPage do |user, upcoming_page|
    upcoming_page_maintainter?(user, upcoming_page) && Ships::Subscription.new(upcoming_page.user).can_send_continuous_messages?
  end

  can :promote, UpcomingPage do |user, upcoming_page|
    upcoming_page_maintainter?(user, upcoming_page) && Ships::Subscription.new(upcoming_page.user).can_promote_upcoming_page?
  end

  can :ship_email_form, UpcomingPage do |user, upcoming_page|
    upcoming_page_maintainter?(user, upcoming_page) && Ships::Subscription.new(upcoming_page.user).can_use_email_form?
  end

  can :ship_surveys, UpcomingPage do |user, upcoming_page|
    upcoming_page_maintainter?(user, upcoming_page) && Ships::Subscription.new(upcoming_page.user).can_use_surveys?
  end

  can :read, UpcomingPageMessage, allow_guest: true do |user, message|
    !message.draft? || upcoming_page_maintainter?(user, message.upcoming_page)
  end

  can %i(new create), UpcomingPageMessage do |user, message|
    upcoming_page_maintainter?(user, message.upcoming_page) && Ships::Subscription.new(message.upcoming_page.user).can_send_message?
  end

  can :destroy, UpcomingPageMessage do |user, message|
    message.draft? && upcoming_page_maintainter?(user, message.upcoming_page)
  end

  can :maintain, UpcomingPageMessage do |user, message|
    upcoming_page_maintainter?(user, message.upcoming_page)
  end

  can %i(new edit read), UpcomingPageSegment do |user, segment|
    upcoming_page_maintainter?(user, segment.upcoming_page) && Ships::Subscription.new(segment.upcoming_page.user).can_segments?
  end

  can :destroy, UpcomingPageSegment do |user, segment|
    upcoming_page_maintainter?(user, segment.upcoming_page)
  end

  can :maintain, UpcomingPageVariant do |user, variant|
    upcoming_page_maintainter?(user, variant.upcoming_page)
  end

  can %i(destroy maintain), UpcomingPageSubscriber do |user, subscriber|
    upcoming_page_maintainter?(user, subscriber.upcoming_page)
  end

  can %i(read destroy maintain), UpcomingPageConversation do |user, conversation|
    upcoming_page_maintainter?(user, conversation.upcoming_page)
  end

  can %i(read maintain), UpcomingPageSubscriberSearch do |user, search|
    upcoming_page_maintainter?(user, search.upcoming_page)
  end

  can %i(destroy maintain), UpcomingPageSurvey do |user, survey|
    upcoming_page_maintainter?(user, survey.upcoming_page)
  end

  can :read, UpcomingPageSurvey, allow_guest: true do |user, survey|
    !survey.draft? || upcoming_page_maintainter?(user, survey.upcoming_page)
  end

  can :read, UpcomingPageQuestion, allow_guest: true do |user, question|
    !question.survey.draft? || upcoming_page_maintainter?(user, question.survey.upcoming_page)
  end

  can :maintain, UpcomingPageQuestion do |user, question|
    upcoming_page_maintainter?(user, question.survey.upcoming_page)
  end

  can :maintain, UpcomingPageQuestionOption do |user, option|
    upcoming_page_maintainter?(user, option.question.survey.upcoming_page)
  end

  can :read, UpcomingPageMessageDelivery do |user, delivery|
    subject = delivery.message || delivery.subject
    upcoming_page_maintainter?(user, subject.upcoming_page)
  end

  can :read, UpcomingPageConversationMessage do |user, message|
    upcoming_page_maintainter?(user, message.upcoming_page)
  end

  can :read, UpcomingPageSegmentSubscriberAssociation do |user, segment_subscriber|
    upcoming_page_maintainter?(user, segment_subscriber.upcoming_page_segment.upcoming_page)
  end

  can :read, UpcomingPageEmailImport do |user, import|
    upcoming_page_maintainter?(user, import.upcoming_page)
  end

  can :read, UpcomingPageMakerTask do |user, task|
    upcoming_page_maintainter?(user, task.upcoming_page)
  end

  can :maintain, ShipAccount do |user, account|
    account_maintainer?(user, account)
  end

  can :ship_surveys, ShipAccount do |user, account|
    account_maintainer?(user, account) && Ships::Subscription.new(account.user).can_use_surveys?
  end

  can :maintain, ShipContact do |user, contact|
    account_maintainer?(user, contact.account)
  end

  private

  def account_maintainer?(user, account)
    return false if user.nil?
    return false if account.nil?
    return true if user.admin?
    return false if Ships::Subscription.new(account.user).trial_ended?

    account.user_id == user.id || account.member_ids.include?(user.id)
  end

  def upcoming_page_maintainter?(user, upcoming_page)
    account_maintainer?(user, upcoming_page.account)
  end
end
