# frozen_string_literal: true

# == Schema Information
#
# Table name: makers_festival_makers
#
#  id                             :integer          not null, primary key
#  user_id                        :integer          not null
#  makers_festival_participant_id :integer          not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#
# Indexes
#
#  index_makers_festival_makers_on_participant_id          (makers_festival_participant_id)
#  index_makers_festival_makers_on_user_id_participant_id  (user_id,makers_festival_participant_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (makers_festival_participant_id => makers_festival_participants.id)
#  fk_rails_...  (user_id => users.id)
#

class MakersFestival::Maker < ApplicationRecord
  include Namespaceable

  belongs_to :user, inverse_of: :makers_festival_makers
  belongs_to :makers_festival_participant, class_name: '::MakersFestival::Participant', inverse_of: :maker_associations
end
