# frozen_string_literal: true

# == Schema Information
#
# Table name: spam_manual_logs
#
#  id             :bigint(8)        not null, primary key
#  action         :integer          not null
#  user_id        :bigint(8)        not null
#  activity_type  :string
#  activity_id    :bigint(8)
#  reason         :text
#  handled_by_id  :bigint(8)        not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  reverted_by_id :bigint(8)
#  revert_reason  :string
#
# Indexes
#
#  index_spam_manual_logs_on_activity_type_and_activity_id  (activity_type,activity_id)
#  index_spam_manual_logs_on_handled_by_id                  (handled_by_id)
#  index_spam_manual_logs_on_reverted_by_id                 (reverted_by_id)
#  index_spam_manual_logs_on_user_id                        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (handled_by_id => users.id)
#  fk_rails_...  (reverted_by_id => users.id)
#  fk_rails_...  (user_id => users.id)
#
class Spam::ManualLog < ApplicationRecord
  include Namespaceable

  # Note(Rahul): To add new subject do the following
  #             1. Add the subject with it's GraphQL type in the GRAPH_TYPE_TO_MODEL_MAP hash
  #             2. Handle new subject trash or hide in SpamChecks::Admin::MarkAsBadActor (private method take_action_on_activity)
  #             3. Run bin/graphql2ts
  GRAPH_TYPE_TO_MODEL_MAP = {
    'Comment' => Comment,
    'Review' => Review,
    'Post' => Post,
    'DiscussionThread' => Discussion::Thread,
    'Vote' => Vote,
    'TeamRequest' => Team::Request,
  }.freeze

  SUBJECTS = GRAPH_TYPE_TO_MODEL_MAP.values

  class << self
    def find_subject_from_type(graph_type:, id:)
      subject_model = GRAPH_TYPE_TO_MODEL_MAP[graph_type]

      raise ArgumentError, "#{ graph_type } is not handled" if subject_model.nil?

      subject_model.find id
    end

    def subject_graph_types
      GRAPH_TYPE_TO_MODEL_MAP.keys.map(&:to_s)
    end
  end

  belongs_to :user, class_name: '::User', inverse_of: :spam_manual_logs
  belongs_to_polymorphic :activity, allowed_classes: SUBJECTS, optional: true
  belongs_to :handled_by, class_name: '::User', inverse_of: :handled_spam_manual_logs
  belongs_to :reverted_by, class_name: '::User', inverse_of: :reverted_spam_manual_logs, optional: true

  enum action: {
    mark_as_bad_actor: 1,
    mark_as_spammer: 2,
    send_warning: 3,
    mark_vote_as_spam: 4,
  }

  def can_revert_action?
    reverted_by_id.blank? && (mark_as_spammer? || mark_as_bad_actor?)
  end
end
