# frozen_string_literal: true

# == Schema Information
#
# Table name: change_log_entries
#
#  id                   :bigint(8)        not null, primary key
#  slug                 :string           not null
#  state                :string           default("pending"), not null
#  title                :string           not null
#  description_md       :text
#  date                 :date
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  major_update         :boolean          default(FALSE), not null
#  has_discussion       :boolean          default(FALSE), not null
#  discussion_thread_id :bigint(8)
#  notification_sent    :boolean          default(FALSE), not null
#  votes_count          :integer          default(0), not null
#  credible_votes_count :integer          default(0), not null
#  description_html     :text
#
# Indexes
#
#  index_change_log_entries_on_credible_votes_count  (credible_votes_count)
#  index_change_log_entries_on_discussion_thread_id  (discussion_thread_id)
#  index_published_change_logs_date                  (date) WHERE ((state)::text = 'published'::text)
#
# Foreign Keys
#
#  fk_rails_...  (discussion_thread_id => discussion_threads.id)
#

class ChangeLog::Entry < ApplicationRecord
  include Namespaceable
  include Votable

  HasUniqueCode.define self, field_name: :slug, length: 8

  belongs_to :discussion,
             class_name: 'Discussion::Thread',
             inverse_of: :change_log_entry,
             foreign_key: :discussion_thread_id,
             optional: true

  has_many :media, -> { by_priority }, as: :subject, dependent: :destroy

  enum state: {
    pending: 'pending',
    published: 'published',
  }

  validates :title, presence: true
  validates :state, presence: true
  validates :date, presence: true, if: -> { published? }
  validates :slug, presence: true

  def can_unpublish?
    published? && !notification_sent
  end

  def can_publish?
    pending? && date.present?
  end

  class << self
    def graphql_type
      Graph::Types::ChangeLogType
    end
  end
end
