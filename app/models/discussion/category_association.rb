# frozen_string_literal: true

# == Schema Information
#
# Table name: discussion_category_associations
#
#  id                   :bigint(8)        not null, primary key
#  category_id          :bigint(8)        not null
#  discussion_thread_id :bigint(8)        not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_discussion_category_associations_on_category_id           (category_id)
#  index_discussion_category_associations_on_discussion_thread_id  (discussion_thread_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (category_id => discussion_categories.id)
#  fk_rails_...  (discussion_thread_id => discussion_threads.id)
#
class Discussion::CategoryAssociation < ApplicationRecord
  include Namespaceable
  attr_readonly :discussion_thread_id
  extension RefreshExplicitCounterCache, :category, :discussion_thread_count

  belongs_to :category, class_name: 'Discussion::Category', inverse_of: :category_associations
  belongs_to :discussion_thread, class_name: 'Discussion::Thread', inverse_of: :category
end
