# frozen_string_literal: true

# == Schema Information
#
# Table name: golden_kitty_nominees
#
#  id                       :integer          not null, primary key
#  golden_kitty_category_id :integer          not null
#  post_id                  :integer          not null
#  user_id                  :integer          not null
#  comment                  :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
# Indexes
#
#  index_gk_post_id_category_id_user_id_u                   (post_id,golden_kitty_category_id,user_id) UNIQUE
#  index_golden_kitty_nominees_on_golden_kitty_category_id  (golden_kitty_category_id)
#  index_golden_kitty_nominees_on_user_id                   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (golden_kitty_category_id => golden_kitty_categories.id)
#

class GoldenKitty::Nominee < ApplicationRecord
  include Namespaceable

  validates :post_id, uniqueness: { scope: %i(golden_kitty_category_id user_id), message: 'already nominated!' }

  belongs_to :golden_kitty_category, class_name: '::GoldenKitty::Category', foreign_key: 'golden_kitty_category_id', inverse_of: :nominees
  belongs_to :post, inverse_of: :golden_kitty_nominations
  belongs_to :user, inverse_of: :golden_kitty_nominations
end
