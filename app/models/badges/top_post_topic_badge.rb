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

class Badges::TopPostTopicBadge < Badge
  has_many :activity_events, class_name: 'Products::ActivityEvent', as: :subject, dependent: :destroy

  validates :data, presence: true
  validates :position, numericality: { less_than_or_equal_to: 5, only_integer: true }
  validates :period, presence: true
  validates :date, presence: true
  validates :topic_name, presence: true

  store_attributes :data do
    position Integer, default: 1
    period String, default: nil
    date Date, default: nil
    topic_name String, default: nil
  end

  private

  def ensure_not_duplicated
    return if subject.blank? && position.blank? && period.blank? && date.blank?

    exist = self.class.where(subject: subject).with_data(position: position, period: period, date: date).exists?
    errors.add(:base, 'Topic Award already exist on this position') if exist
  end
end
