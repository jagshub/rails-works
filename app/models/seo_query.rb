# frozen_string_literal: true

# == Schema Information
#
# Table name: seo_queries
#
#  id           :integer          not null, primary key
#  subject_type :string           not null
#  subject_id   :integer          not null
#  query        :string           not null
#  ctr          :float            default(0.0)
#  position     :float            default(0.0)
#  clicks       :integer          default(0)
#  impressions  :integer          default(0)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_seo_queries_on_subject_type_and_subject_id  (subject_type,subject_id)
#

class SeoQuery < ApplicationRecord
  belongs_to :subject, polymorphic: true

  def self.with_keywords(scope)
    join_sql = %(
        LEFT JOIN seo_queries
        ON  seo_queries.subject_id=#{ scope.table_name }.id
        #{ ActiveRecord::Base.sanitize_sql_for_conditions(['AND seo_queries.subject_type= ?', scope.model_name.name]) }
    )
    scope
      .where('seo_queries.id IS NOT NULL')
      .joins(join_sql)
      .group("#{ scope.table_name }.id")
      .reorder(Arel.sql('COUNT(seo_queries.id) DESC'))
  end
end
