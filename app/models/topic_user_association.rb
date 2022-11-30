# frozen_string_literal: true

# == Schema Information
#
# Table name: topic_user_associations
#
#  id         :integer          not null, primary key
#  topic_id   :integer          not null
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_topic_user_associations_on_topic_id_and_user_id  (topic_id,user_id) UNIQUE
#  index_topic_user_associations_on_user_id_and_topic_id  (user_id,topic_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (topic_id => topics.id)
#  fk_rails_...  (user_id => users.id)
#

class TopicUserAssociation < ApplicationRecord
  belongs_to :topic, inverse_of: :topic_user_association
  belongs_to :user, inverse_of: :topic_user_association
end
