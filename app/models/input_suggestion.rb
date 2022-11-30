# frozen_string_literal: true

# == Schema Information
#
# Table name: input_suggestions
#
#  id         :integer          not null, primary key
#  name       :citext           not null
#  kind       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  parent_id  :integer
#
# Indexes
#
#  index_input_suggestions_on_name_and_kind  (name,kind) UNIQUE
#  index_input_suggestions_on_parent_id      (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => input_suggestions.id)
#

class InputSuggestion < ApplicationRecord
  validates :name, uniqueness: { scope: :kind, case_sensitive: false }

  belongs_to :parent, class_name: 'InputSuggestion', foreign_key: 'parent_id', inverse_of: :childrens, optional: true
  has_many :childrens, class_name: 'InputSuggestion', foreign_key: 'parent_id', inverse_of: :parent, dependent: :destroy

  enum kind: { role: 0, skill: 1, location: 2, country: 3, city_state: 4 }
end
