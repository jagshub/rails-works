# frozen_string_literal: true

# == Schema Information
#
# Table name: search_user_searches
#
#  id               :bigint(8)        not null, primary key
#  user_id          :bigint(8)
#  search_type      :string           not null
#  query            :string           not null
#  normalized_query :string(255)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  platform         :string           default("web"), not null
#
# Indexes
#
#  index_search_user_searches_on_created_at                  (created_at)
#  index_search_user_searches_on_search_type_and_created_at  (search_type,created_at)
#  index_search_user_searches_on_search_type_query           (search_type,normalized_query,created_at)
#  index_search_user_searches_on_user_id                     (user_id)
#
class Search::UserSearch < ApplicationRecord
  include Namespaceable

  before_save :set_normalized_query

  belongs_to :user, optional: true

  enum platform: {
    web: 'web',
    ios: 'ios',
    android: 'android',
  }

  scope :after, ->(time) { where(arel_table[:created_at].gteq(time)) }

  protected

  def set_normalized_query
    return if query.blank?

    temp = query.downcase.strip
    temp = temp.gsub(/[^a-z0-9\s]/i, '').squeeze(' ').truncate(255)
    self.normalized_query = temp
  end
end
