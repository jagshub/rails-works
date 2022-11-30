# frozen_string_literal: true

# == Schema Information
#
# Table name: anthologies_story_mentions_associations
#
#  id           :bigint(8)        not null, primary key
#  story_id     :bigint(8)        not null
#  subject_type :string           not null
#  subject_id   :bigint(8)        not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_mentions_on_story_id_and_subject_id_and_subject_type  (story_id,subject_id,subject_type) UNIQUE
#  index_mentions_on_subject_id_and_subject_type               (subject_type,subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (story_id => anthologies_stories.id)
#
class Anthologies::StoryMentionsAssociation < ApplicationRecord
  include Namespaceable

  SUBJECT_TYPES = [
    Post,
    User,
    Product,
  ].freeze

  belongs_to :story, class_name: '::Anthologies::Story', foreign_key: :story_id, inverse_of: :story_mentions_associations
  belongs_to_polymorphic :subject, allowed_classes: SUBJECT_TYPES, inverse_of: :story_mentions_associations
end
