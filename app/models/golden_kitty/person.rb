# frozen_string_literal: true

# == Schema Information
#
# Table name: golden_kitty_people
#
#  id                       :bigint(8)        not null, primary key
#  user_id                  :bigint(8)        not null
#  golden_kitty_category_id :bigint(8)        not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  winner                   :boolean          default(FALSE), not null
#  position                 :integer
#
# Indexes
#
#  index_gk_people_on_position_and_category_id            (position,golden_kitty_category_id) UNIQUE WHERE ("position" IS NOT NULL)
#  index_golden_kitty_people_on_golden_kitty_category_id  (golden_kitty_category_id)
#  index_golden_kitty_people_on_user_id_and_category_id   (user_id,golden_kitty_category_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (golden_kitty_category_id => golden_kitty_categories.id)
#  fk_rails_...  (user_id => users.id)
#

class GoldenKitty::Person < ApplicationRecord
  include Namespaceable
  include RandomOrder

  belongs_to :user, inverse_of: :golden_kitty_people
  belongs_to :golden_kitty_category, class_name: '::GoldenKitty::Category', foreign_key: 'golden_kitty_category_id', inverse_of: :people
  validates :position, presence: { if: :winner? }, uniqueness: { allow_blank: true, scope: :golden_kitty_category, message: 'already used for this category!' }, inclusion: { allow_blank: true, in: 1..4 }

  def self.graphql_type
    Graph::Types::GoldenKittyPersonType
  end
end
