# frozen_string_literal: true

class Discussion::Form::Thread
  include MiniForm::Model

  PARAMS = %i(
    title
    description
    user_id
    anonymous
    subject
    poll_options
    category
    status
  ).freeze

  model :thread, attributes: PARAMS, read: %i(id), save: true

  attr_reader :request_info, :thread_is_new, :source

  alias node thread
  alias graphql_result thread

  validate :ensure_can_create_poll
  validate :ensure_user_can_create_beta_thread
  before_update :auto_approve_for_beta_threads
  after_update :save_poll
  after_update :trigger_create_event

  def poll_options=(options)
    return if options.blank?

    @poll_options_count = options.length
    @poll ||= node.build_poll
    options.each { |option| @poll.options.build(text: option[:text], image_uuid: option[:image_uuid]) }
  end

  def initialize(thread: ::Discussion::Thread.new, request_info: {}, source: :web)
    @thread = thread
    @thread_is_new = thread.new_record?
    @request_info = request_info
    @source = source
  end

  private

  def auto_approve_for_beta_threads
    return unless thread_is_new && beta_thread?

    thread.status = 'approved'
  end

  def ensure_user_can_create_beta_thread
    return unless beta_thread?

    permission = thread.subject_id == MakerGroup::IOS_BETA ? :ios_beta : :android_beta
    return if ApplicationPolicy.can?(thread.user, :participate, permission)

    errors.add :base, 'Only beta users can create beta threads'
  end

  def save_poll
    node.poll&.save!
  end

  def trigger_create_event
    return unless thread_is_new
    return if beta_thread?

    Stream::Events::DiscussionThreadCreated.trigger(
      user: User.find(user_id),
      subject: thread,
      source: source,
      request_info: request_info,
      payload: { thread_subject_type: thread.subject_type, thread_subject_id: thread.subject_id },
    )
  end

  def ensure_can_create_poll
    return if @poll.blank?

    errors.add :poll, 'Can not create a poll with less than 2 options' if @poll_options_count < 2
    errors.add :poll, 'Can not create a poll with more than 10 options' if @poll_options_count > 10
    errors.add :poll, 'Can not create a poll with duplicate options' if duplicate_options?

    @poll.options.each_with_index do |option, i|
      errors.add "option-#{ i }", option.errors.full_messages.first if option.invalid?
    end
  end

  def duplicate_options?
    unique_count != @poll_options_count
  end

  def unique_count
    @poll.options
         .map(&:text)
         .map(&:strip)
         .uniq
         .count
  end

  def beta_thread?
    [MakerGroup::IOS_BETA, MakerGroup::ANDROID_BETA].include?(thread.subject_id)
  end
end
