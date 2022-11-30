# frozen_string_literal: true

# == Schema Information
#
# Table name: drip_mails_scheduled_mails
#
#  id           :bigint(8)        not null, primary key
#  user_id      :bigint(8)        not null
#  mailer_name  :string           not null
#  drip_kind    :string           not null
#  send_on      :datetime         not null
#  completed    :boolean          default(FALSE)
#  sent_at      :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  subject_type :string           not null
#  subject_id   :integer          not null
#  delivering   :boolean          default(FALSE)
#
# Indexes
#
#  index_drip_mails_on_mailer_drip_and_subject    (user_id,mailer_name,drip_kind,subject_type,subject_id) UNIQUE
#  index_drip_mails_scheduled_mails_on_completed  (completed)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class DripMails::ScheduledMail < ApplicationRecord
  include Namespaceable

  HasTimeAsFlag.define self, :opened
  HasTimeAsFlag.define self, :clicked

  belongs_to :user, inverse_of: :scheduled_drip_mails
  belongs_to :subject, polymorphic: true, optional: true
  validates :mailer_name, presence: true
  validates :send_on, presence: true
  validates :drip_kind, presence: true
  validates :user_id, uniqueness: { scope: %i(mailer_name drip_kind subject subject_id) }

  scope :pending, -> { where_time_lteq(:send_on, Time.current).unprocessed }
  scope :unprocessed, -> { where(completed: false, delivering: false) }
  scope :sent, -> { where(completed: true).where.not(sent_at: nil) }

  enum drip_kind: DripMails.drip_kinds
end
