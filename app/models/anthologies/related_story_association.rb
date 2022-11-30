# frozen_string_literal: true

# == Schema Information
#
# Table name: anthologies_related_story_associations
#
#  id         :bigint(8)        not null, primary key
#  story_id   :bigint(8)
#  related_id :bigint(8)
#  position   :integer          default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_anthologies_related_story_associations_on_related_id  (related_id)
#  index_anthologies_related_story_associations_unique         (story_id,related_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (related_id => anthologies_stories.id)
#  fk_rails_...  (story_id => anthologies_stories.id)
#

class Anthologies::RelatedStoryAssociation < ApplicationRecord
  include Namespaceable

  acts_as_list scope: :story, column: :position

  belongs_to :story, class_name: 'Anthologies::Story', inverse_of: :related_stories
  belongs_to :related, class_name: 'Anthologies::Story', inverse_of: :related_stories
end
