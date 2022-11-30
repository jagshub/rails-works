# frozen_string_literal: true

class Admin::CreateTestMobileNotificationsForm < Admin::BaseForm
  NOTIFICATIONS = {
    'mention' => { text: 'SEND MENTION PUSH' },
    'friend_product_maker' => { text: 'SEND FRIEND PRODUCT MAKER PUSH' },
    'new_follower' => { text: 'SEND NEW FOLLOWER PUSH' },
    'visit_streak_ending' => { text: 'SEND VISIT STREAK ENDING PUSH' },
  }.freeze

  attributes :receiver_id, :kind, :subject_id, :subject_type
  attr_reader :receiver, :object, :current_user

  validates :kind, presence: true, inclusion: { in: NOTIFICATIONS.keys }
  validates :subject_id, presence: true, if: :need_subject_id?
  validates :current_user, presence: true
  validates :receiver_id, presence: true

  validate :ensure_user
  validate :ensure_object

  def initialize(current_user:)
    @current_user = current_user
  end

  private

  def need_subject_id?
    !visit_streak_notification?
  end

  def get_mention_object
    errors.add(:subject_type, ' Invalid Subject Type.') unless Comment::SUBJECT_TYPES.include?(@subject_type)

    errors.add(:subject_id, ' Subject id\'s type does not match provided Subject Type') if @subject_type.safe_constantize&.find_by(id: @subject_id).blank?
    @object = Comment.new(body: "@#{ receiver.username } Hi", user_id: @current_user.id, subject_id: @subject_id, subject_type: @subject_type) if Comment::SUBJECT_TYPES.include?(@subject_type) && receiver.present?
  end

  def get_friend_product_maker_object
    post = Post.find_by id: @subject_id

    errors.add(:subject_id, ' Post with id provided in subject id does not exists.') if post.blank?
    @object = ProductMaker.new(id: 1, user: current_user, post: post)
  end

  def get_new_follower_object
    followed_by_user = User.find_by id: @subject_id

    errors.add(:subject_id, ' User with id provided in subject id does not exists.') if followed_by_user.blank?
    @object = UserFriendAssociation.new(
      followed_by_user: followed_by_user,
      following_user: receiver,
      source: 'admin-test-tool',
    )
  end

  def ensure_object
    case kind
    when 'mention'
      get_mention_object
    when 'top_maker'
      get_top_maker_object
    when 'friend_product_maker'
      get_friend_product_maker_object
    when 'new_follower'
      get_new_follower_object
    when 'visit_streak_ending'
      @object = @current_user
    end
    errors.add(:subject_id, ' Not found') if object.nil?
  end

  def ensure_user
    @receiver = User.find_by(id: receiver_id) if receiver_id.present?

    if receiver.nil?
      errors.add(:user_id, :not_found)
    else
      mobile_devices = Mobile::Device.enabled_push_for(user_id: receiver_id, option: "send_#{ kind }_push")
      tokens = mobile_devices.map(&:push_notification_token) if mobile_devices.present?

      # NOTE(Bharat): This is temporary. Used as a fallback option.
      tokens = [receiver.subscriber.mobile_push_token] if tokens.blank? && receiver.subscriber.mobile_push_token.present?

      errors.add(:user_id, ' No Tokens available for user.') if tokens.nil?
    end
  end

  def perform
    event = get_fake_event
    event.channel.deliver(event)
  end

  def get_fake_event
    notifyable =
      if visit_streak_notification?
        user_streak_reminder(current_user)
      else
        Notifications::Notifiers.for(kind).extract_notifyable(object)
      end
    notification = NotificationLog.new(
      id: 1,
      subscriber_id: receiver.subscriber.id,
      kind: NotificationLog.kinds.fetch(kind),
      notifyable: notifyable,
    )

    NotificationEvent.new(id: 1, notification: notification, channel_name: 'mobile_push')
  end

  def user_streak_reminder(user)
    UserVisitStreaks::Reminder.create!(user_id: user.id, streak_duration: 1)
  end

  def visit_streak_notification?
    kind == 'visit_streak_ending'
  end
end
