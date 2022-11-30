# frozen_string_literal: true

# == Schema Information
#
# Table name: discussion_categories
#
#  id                      :bigint(8)        not null, primary key
#  name                    :string           not null
#  slug                    :string           not null
#  description             :string           default(""), not null
#  thumbnail_uuid          :string
#  discussion_thread_count :integer          default(0), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_discussion_categories_on_name  (name) UNIQUE
#  index_discussion_categories_on_slug  (slug) UNIQUE
#
class Discussion::Category < ApplicationRecord
  include Namespaceable
  include Sluggable
  include Uploadable
  include ExplicitCounterCache

  extension(
    Search.searchable_association,
    association: :discussion_threads,
    if: :saved_change_to_name?,
  )

  sluggable
  uploadable :thumbnail

  has_many :category_associations,
           class_name: 'Discussion::CategoryAssociation',
           foreign_key: :category_id,
           dependent: :delete_all,
           inverse_of: :category

  has_many :discussion_threads,
           class_name: 'Discussion::Thread',
           through: :category_associations,
           inverse_of: :category

  explicit_counter_cache(
    :discussion_thread_count,
    -> { discussion_threads.visible.where(status: 'approved') },
  )

  scope :having_discussions, -> { where('discussion_thread_count >= 6') }
end
