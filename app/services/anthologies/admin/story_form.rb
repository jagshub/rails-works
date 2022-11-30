# frozen_string_literal: true

class Anthologies::Admin::StoryForm < Admin::BaseForm
  ATTRIBUTES = %i(
    title
    body_html
    description
    header_image_uuid
    header_image_credit
    mins_to_read
    category
    published_at
    featured_position
    user_id
    author_name
    author_url
  ).freeze

  MENTION_ATTRIBUTES = %i(
    id
    story_id
    subject_type
    subject_id
    _destroy
  ).freeze

  RELATED_STORY_ATTRIBUTES = %i(
    id
    related_id
    story_id
    position
    _destroy
  ).freeze

  model(
    :anthologies_stories,
    attributes: ATTRIBUTES,
    nested_attributes: {
      related_story_associations: RELATED_STORY_ATTRIBUTES,
      story_mentions_associations: MENTION_ATTRIBUTES,
    },
    save: true,
  )

  main_model :anthologies_stories, Anthologies::Story

  delegate :slug, to: :anthologies_stories

  before_validation :remove_old_featured_story
  after_update :update_story_events

  def initialize(story = nil)
    @anthologies_stories = story || Anthologies::Story.new
  end

  private

  def remove_old_featured_story
    return unless featured_position

    scope = ::Anthologies::Story.where(featured_position: featured_position)
    scope = scope.where.not(id: id) if id.present?
    current_featured = scope.limit(1).first
    current_featured.update! featured_position: nil if current_featured.present?
  end

  def update_story_events
    Anthologies.update_story_events(anthologies_stories)
  end
end
