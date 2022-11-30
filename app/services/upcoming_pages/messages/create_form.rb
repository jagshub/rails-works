# frozen_string_literal: true

class UpcomingPages::Messages::CreateForm
  include MiniForm::Model

  DAILY_SPAM_RATE_LIMIT = 10

  ATTRIBUTES = %i(
    body
    kind
    layout
    post_id
    state
    subject
    subscriber_filters
    upcoming_page_id
    upcoming_page_survey_id
    user_id
    visibility
  ).freeze

  model :upcoming_page_message, attributes: ATTRIBUTES, read: %i(sent?), save: true

  attributes :send_test

  validate :rate_limit_check, if: :sent?
  before_update :authorize_continuous_kind

  alias node upcoming_page_message
  alias graphql_result upcoming_page_message

  def initialize(user:, inputs:)
    @user = user
    @upcoming_page = UpcomingPage.not_trashed.find(inputs[:upcoming_page_id])
    @upcoming_page_message = find_or_initialize(inputs)
  end

  def visibility=(value)
    @upcoming_page_message.visibility = value || :public
  end

  def kind=(value)
    @upcoming_page_message.kind = value || :one_off
  end

  def subscriber_filters=(value)
    @upcoming_page_message.subscriber_filters = value || []
  end

  private

  def find_or_initialize(inputs)
    if inputs[:id].present?
      messages = @upcoming_page.messages
      messages.where(state: :draft).or(messages.where(kind: :continuous)).find(inputs[:id])
    else
      @upcoming_page.messages.new(
        kind: :one_off,
        state: inputs[:state] == 'draft' ? :draft : :sent,
        user: @user,
        visibility: :public,
        subscriber_filters: [],
      )
    end
  end

  def authorize_continuous_kind
    return unless @upcoming_page_message.continuous?

    ApplicationPolicy.authorize! @user, :send_continuous_messages, @upcoming_page
  end

  def after_assignment
    ApplicationPolicy.authorize! @user, :send_message, @upcoming_page
  end

  def rate_limit_check
    errors.add :base, 'rate_limit_warning' if UpcomingPages::Messages::RateLimiter.limit_reached?(upcoming_page_message)
  end

  def after_update
    if send_test == true
      UpcomingPages::TestMessageWorker.perform_later(@upcoming_page_message)
    elsif sent?
      UpcomingPages::EnqueueMessageWorker.perform_later(@upcoming_page_message)
    end
  end
end
