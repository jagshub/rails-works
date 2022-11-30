# frozen_string_literal: true

# == Schema Information
#
# Table name: badges
#
#  id           :integer          not null, primary key
#  subject_id   :integer          not null
#  subject_type :string           not null
#  type         :string           not null
#  data         :jsonb            not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_badges_on_subject_type_and_subject_id  (subject_type,subject_id)
#
class Badges::UserAwardBadge < Badge
  validates :data, presence: true
  validate :ensure_valid_status
  validate :ensure_identifier_present
  validate :ensure_valid_identifier

  belongs_to :user, class_name: 'User', foreign_key: 'subject_id', inverse_of: :badges

  enum statuses: %i(in_progress awarded_to_user_and_visible locked_and_hidden_by_admin)

  scope :visible, -> { where.not('data @> ?', { status: 'locked_and_hidden_by_admin' }.to_json) }
  scope :complete, -> { where('data @> ?', { status: 'awarded_to_user_and_visible' }.to_json) }
  scope :not_showcased, -> { where('data @> ?', { showcased: false }.to_json) }
  scope :by_identifier, ->(identifier) { where('data @> ?', { identifier: identifier }.to_json) }

  store_attributes :data do
    status String, default: 'in_progress'
    showcased Boolean, default: false
    identifier String
  end

  after_update :send_award_notifications
  after_update :remove_award_notification, if: :locked_and_hidden_by_admin?
  after_save :emit_iterable_event
  after_commit :refresh_counters, on: :destroy
  after_commit :check_and_refresh_counters, on: %i(create update)

  def award
    @award ||= Badges::Award.find_by_identifier(identifier)
  end

  def in_progress?
    status == 'in_progress'
  end

  def awarded_to_user_and_visible?
    status == 'awarded_to_user_and_visible'
  end

  def locked_and_hidden_by_admin?
    status == 'locked_and_hidden_by_admin'
  end

  def badge_progress
    UserBadges.award_for(identifier: data['identifier']).progress(data: data) || 1
  end

  private

  def ensure_valid_status
    status = data.symbolize_keys[:status]
    return if Badges::UserAwardBadge.statuses[status].present?

    errors.add :data, "status #{ status } is not a valid status."
  end

  def ensure_identifier_present
    return if data.symbolize_keys.key?(:identifier) && data.symbolize_keys[:identifier].present?

    errors.add :data, 'identifier is not present in data'
  end

  def ensure_valid_identifier
    identifier = data.symbolize_keys[:identifier]
    return if Badges::Award.identifiers.key?(identifier&.to_sym)

    errors.add :data, "identifier #{ identifier } does not exist in Badges::Award"
  end

  def send_award_notifications
    return unless saved_changes['data'] & [0] & ['status'] != 'awarded_to_user_and_visible' && data['status'] == 'awarded_to_user_and_visible'

    return unless UserBadges::AWARDS[identifier].send_notifications?

    UserMailer.badge_awarded(subject, self).deliver_later

    Stream::Events::UserBadgeAwarded.trigger(
      user: subject,
      subject: self,
      source: :application,
    )
  end

  def remove_award_notification
    # NOTE(DZ): Unforunately, we can't remove emails sent
    Stream::Workers::FeedItemsCleanUp.perform_later(
      target: self,
      verb: 'user-badge-awarded',
    )
  end

  def emit_iterable_event
    return unless saved_changes['data'] & [0] & ['status'] != 'awarded_to_user_and_visible' && data['status'] == 'awarded_to_user_and_visible'

    user = subject if subject.is_a?(User)

    data_fields = {
      badgeName: data.symbolize_keys[:identifier],
    }
    Iterable.trigger_event('new_badge_earned', email: user.email, user_id: user.id, data_fields: data_fields) if user.present?
  end

  def refresh_counters
    subject.refresh_badges_count
    subject.refresh_badges_unique_count
  end

  # NOTE(RAHUL): The refresh counter only considers completed badges
  #              so run this only on status changes related to that.
  def check_and_refresh_counters
    status_changes = (previous_changes[:data] || []).map do |changes|
      changes&.dig('status')
    end.compact

    return unless status_changes.include?('awarded_to_user_and_visible')

    refresh_counters
  end
end
