# frozen_string_literal: true

class Discussion::Admin::ThreadForm < Admin::BaseForm
  ATTRIBUTES = %i(
    title
    description
    user_id
    subject_type
    subject_id
    anonymous
    pinned
    featured_at
    trending_at
  ).freeze

  CATEGORY_ATTRIBUTES = %i(
    id
    discussion_thread_id
    category_id
    _destroy
  ).freeze

  model(
    :discussion_thread,
    attributes: ATTRIBUTES,
    nested_attributes: {
      category_associations: CATEGORY_ATTRIBUTES,
    },
    save: true,
  )

  main_model :discussion_thread, Discussion::Thread

  delegate :slug, :trashed?, :featured_at?, :hidden?, to: :discussion_thread

  def initialize(thread = nil)
    @discussion_thread = thread || Discussion::Thread.new
  end
end
