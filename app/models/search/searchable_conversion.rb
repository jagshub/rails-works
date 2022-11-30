# frozen_string_literal: true

# == Schema Information
#
# Table name: search_searchable_conversions
#
#  id                    :bigint(8)        not null, primary key
#  searchable_type       :string           not null
#  searchable_id         :bigint(8)        not null
#  search_user_search_id :bigint(8)        not null
#  converted_at          :datetime         not null
#  source                :string           not null
#
# Indexes
#
#  index_search_searchable_conversions_on_search_user_search_id  (search_user_search_id)
#  index_search_searchable_conversions_on_searchable             (searchable_type,searchable_id)
#
class Search::SearchableConversion < ApplicationRecord
  include Namespaceable

  belongs_to_polymorphic :searchable,
                         allowed_classes: Search::Searchable.models,
                         inverse_of: :searchable_conversions

  belongs_to :user_search,
             class_name: 'Search::UserSearch',
             inverse_of: :conversions,
             counter_cache: :conversions_count,
             foreign_key: :search_user_search_id

  enum source: {
    web: 'web',
    mobile: 'mobile',
  }
end
