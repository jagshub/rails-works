# frozen_string_literal: true

# == Schema Information
#
# Table name: makers_festival_categories
#
#  id                         :integer          not null, primary key
#  emoji                      :string           not null
#  name                       :string           not null
#  tagline                    :text             not null
#  makers_festival_edition_id :integer          not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_makers_festival_categories_on_edition_id  (makers_festival_edition_id)
#
# Foreign Keys
#
#  fk_rails_...  (makers_festival_edition_id => makers_festival_editions.id)
#

class MakersFestival::Category < ApplicationRecord
  include Namespaceable

  validates :emoji, presence: true
  validates :name, presence: true, uniqueness: { scope: :makers_festival_edition_id }
  validates :tagline, presence: true

  belongs_to :makers_festival_edition, class_name: '::MakersFestival::Edition', inverse_of: :categories, optional: true

  has_many :participants, class_name: '::MakersFestival::Participant', foreign_key: 'makers_festival_category_id', inverse_of: :makers_festival_category, dependent: :destroy
end
