# frozen_string_literal: true

class Comments::CreateForm
  include MiniForm::Model

  ATTRIBUTES = %i(
    body
    parent_comment_id
    subject
    poll_options
    media_uploads
    review_id
  ).freeze

  model :comment, attributes: ATTRIBUTES, save: true

  attr_reader :request_info, :source

  alias graphql_result comment
  alias node comment

  validate :ensure_can_create_poll
  validate :ensure_not_spam
  validate :ensure_media_count

  after_update :save_poll
  after_update :save_media

  def initialize(user:, source:, request_info: {}, skip_spam_check: false)
    @comment = Comment.new user: user
    @source = source
    @request_info = request_info
    @skip_spam_check = skip_spam_check
    @media = []
  end

  def poll_options=(options)
    return if options.blank?

    @poll_options_count = options.length
    @poll ||= comment.build_poll
    options.each { |option| @poll.options.build(text: option[:text], image_uuid: option[:image_uuid]) }
  end

  def media_uploads=(options)
    return if options.blank?

    options.reverse.each_with_index do |media, idx|
      image_data = media[:image_data]
      @media.push(
        Media.new(
          uuid: image_data[:image_uuid],
          kind: image_data[:media_type],
          original_width: image_data[:original_width],
          original_height: image_data[:original_height],
          priority: idx,
        ),
      )
    end
  end

  def review_id=(id)
    review = Review.find_by(id: id)
    return if review.blank?

    comment.review = review
  end

  def body=(body)
    comment.body = BetterFormatter.call(body, mode: :simple)
  end

  private

  def before_update
    action = comment.parent_comment_id.present? ? :reply : :create
    ApplicationPolicy.authorize! comment.user, action, comment
  end

  def after_update
    sliced_request_info = request_info.slice(:referer, :first_referer, :request_ip, :user_agent, :visit_duration)

    ApplicationEvents.trigger(:comment_created, comment: comment, request_info: sliced_request_info)
    Stream::Events::CommentCreated.trigger(
      user: comment.user,
      subject: comment,
      source: source,
      request_info: request_info,
      payload: { comment_subject_type: comment.subject_type, comment_subject_id: comment.subject_id },
    )

    Metrics.track_create_comment(comment) if post_comment?
  end

  def post_comment?
    comment.subject.is_a? Post
  end

  def save_poll
    comment.poll&.save!
  end

  def save_media
    return if @media.empty?

    @media.each do |media|
      media.update!(subject: comment, user: comment.user)
    end
  end

  def ensure_can_create_poll
    return if @poll.blank?

    ensure_can_create_poll_options

    errors.add :poll, 'Not authorized to create a poll' unless (comment.subject && comment.subject.user.id == comment.user.id) || ProductMakers.maker_of?(user: comment.user, post_id: comment.subject.id) || comment.user.admin?
  end

  def ensure_can_create_poll_options
    errors.add :poll, 'Can not create a poll with less than 2 options' if @poll_options_count < 2
    errors.add :poll, 'Can not create a poll with more than 10 options' if @poll_options_count > 10

    options_text_tally = @poll.options.to_a.pluck(:text).tally

    @poll.options.each_with_index do |option, i|
      errors.add "option-#{ i }", 'Text should be unique' if options_text_tally[option[:text]] > 1
      errors.add "option-#{ i }", option.errors.full_messages.first if option.invalid?
    end
  end

  def ensure_media_count
    errors.add :body, "you may only attach #{ Comment::MEDIA_LIMIT } images" if @media.count > Comment::MEDIA_LIMIT
  end

  def ensure_not_spam
    return if skip_spam_check?

    errors.add :body, 'invalid content detected' if Comments::SpamDetection.new(comment).spam?
  end

  def skip_spam_check?
    return true if @skip_spam_check

    case comment.subject_type
    when 'Discussion::Thread'
      comment.user_id == comment.subject.user_id
    else
      false
    end
  end
end
