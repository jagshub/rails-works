# frozen_string_literal: true

# == Schema Information
#
# Table name: golden_kitty_finalists
#
#  id                       :integer          not null, primary key
#  post_id                  :integer          not null
#  golden_kitty_category_id :integer          not null
#  winner                   :boolean          default(FALSE), not null
#  votes_count              :integer          default(0), not null
#  credible_votes_count     :integer          default(0), not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  position                 :integer
#
# Indexes
#
#  index_golden_kitty_finalists_on_golden_kitty_category_id  (golden_kitty_category_id)
#  index_golden_kitty_finalists_post_category                (post_id,golden_kitty_category_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (golden_kitty_category_id => golden_kitty_categories.id)
#  fk_rails_...  (post_id => posts.id)
#

class GoldenKitty::Finalist < ApplicationRecord
  include Namespaceable
  include Votable
  include RandomOrder

  validates :post, uniqueness: { scope: :golden_kitty_category, message: 'already added to the category!' }
  validates :position, presence: { if: :winner? }, uniqueness: { allow_blank: true, scope: :golden_kitty_category, message: 'already used for this category!' }, inclusion: { allow_blank: true, in: 1..4 }

  belongs_to :post, inverse_of: :golden_kitty_finalist
  belongs_to :golden_kitty_category, class_name: '::GoldenKitty::Category', foreign_key: 'golden_kitty_category_id', inverse_of: :finalists

  def self.graphql_type
    Graph::Types::GoldenKittyFinalistType
  end
end
