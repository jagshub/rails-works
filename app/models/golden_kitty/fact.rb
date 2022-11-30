# frozen_string_literal: true

# == Schema Information
#
# Table name: golden_kitty_facts
#
#  id          :bigint(8)        not null, primary key
#  image_uuid  :string           not null
#  description :string           not null
#  category_id :bigint(8)        not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_golden_kitty_facts_on_category_id  (category_id)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => golden_kitty_categories.id)
#

class GoldenKitty::Fact < ApplicationRecord
  include Namespaceable
  include Uploadable
  include RandomOrder

  uploadable :image

  validates :image_uuid, :description, presence: true

  belongs_to :category, class_name: '::GoldenKitty::Category', inverse_of: :facts
end
