# frozen_string_literal: true

module Voting::Create
  extend self

  def call(subject:, user:, source:, request_info: nil, source_component: nil)
    HandleRaceCondition.call do
      vote = Vote.find_or_initialize_by subject: subject, user: user, source_component: source_component
      return if vote.persisted?

      attach_source_to_vote(vote: vote, info: request_info)
      create_vote!(vote: vote, info: request_info)
      auto_follow_product(subject, user)

      SpamChecks.check_vote vote
      ApplicationEvents.trigger(:upvote, vote)
      Stream::Events::VoteCreated.trigger(
        user: user,
        subject: vote,
        source: source,
        source_component: source_component,
        request_info: request_info || {},
        payload: {
          vote_subject_type: vote.subject_type,
          vote_subject_id: vote.subject_id,
        },
        delay: 5.minutes,
      )

      vote
    end
  end

  private

  VALID_VOTE_INFO_ATTRIBUTES = VoteInfo.attribute_names.map(&:to_sym)

  def create_vote!(vote:, info:)
    if info.present?
      info_with_valid_attrs = info.slice(*VALID_VOTE_INFO_ATTRIBUTES)
      vote.vote_info = VoteInfo.new(info_with_valid_attrs) if info_with_valid_attrs.any?
    end

    vote.sandboxed = Spam::User.sandboxed_user?(vote.user)
    vote.credible = !vote.sandboxed
    vote.save!
    vote.subject.refresh_all_vote_counts
  end

  def attach_source_to_vote(vote:, info:)
    return if info.blank?

    oauth_app = OAuth::Application.find(info[:oauth_application_id])
    vote.source = ::HasApiActions.source_to_identifier(oauth_app)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def auto_follow_product(subject, user)
    return unless subject.class.name == 'Post'

    product = subject.new_product

    return if product.nil?
    return if user.subscriber.nil?
    return if Subscribe.auto_subscribe?(product, user)

    Subscribe.subscribe(product, user, nil, source: 'auto_follow')
  end
end
