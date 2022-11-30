# frozen_string_literal: true

class Comments::UpdateForm
  include MiniForm::Model

  ATTRIBUTES = %i(
    body
    media_uploads
  ).freeze

  model :comment, attributes: ATTRIBUTES, save: true

  attr_reader :request_info

  alias graphql_result comment
  alias node comment

  validate :ensure_media_count
  validate :ensure_not_spam

  after_update :save_media

  def initialize(comment:, user:, request_info: {})
    @comment = comment
    @user = user
    @request_info = request_info
    @existing_media = comment.media
    @new_media = []
    @update_media = false
  end

  def media_uploads=(options)
    @update_media = true unless options.nil?
    return if options.blank?

    options.reverse.each_with_index do |media, idx|
      image_data = media[:image_data]
      existing_media = comment.media.find_by_uuid(image_data[:image_uuid])

      if existing_media.nil?
        @new_media.push(
          Media.new(
            uuid: image_data[:image_uuid],
            kind: image_data[:media_type],
            original_width: image_data[:original_width],
            original_height: image_data[:original_height],
            priority: idx,
          ),
        )
      else
        existing_media.assign_attributes(priority: idx)
        @new_media.push(existing_media)
      end
    end
  end

  def body=(body)
    comment.body = BetterFormatter.call(body, mode: :simple)
  end

  private

  def ensure_media_count
    errors.add :body, "you may only attach #{ Comment::MEDIA_LIMIT } images" if @new_media.count > Comment::MEDIA_LIMIT
  end

  def ensure_not_spam
    return if skip_spam_check?

    errors.add :body, 'invalid content detected' if Comments::SpamDetection.new(comment).spam?
  end

  def skip_spam_check?
    case comment.subject_type
    when 'Discussion::Thread'
      comment.user_id == comment.subject.user_id
    else
      false
    end
  end

  def before_update
    ApplicationPolicy.authorize! @user, :update, comment
  end

  def after_update
    sliced_request_info = request_info.slice(:referer, :first_referer, :request_ip, :user_agent, :visit_duration)
    ApplicationEvents.trigger(:comment_updated, comment: comment, request_info: sliced_request_info)
  end

  def save_media
    # Note (Jag): Do not remove media when media_uploads argument is nil
    return unless @update_media

    # Note (Jag): when media_uploads is empty array, we wipe all associated media
    # Note (TC): This will remove any existing media that is not present in the update request
    # as this would mean that the user removed the media.
    comment.media.where.not(uuid: @new_media.map(&:uuid)).each(&:destroy!)

    @new_media.each do |media|
      media.update!(subject: comment, user: comment.user)
    end
  end
end
