# frozen_string_literal: true

class ChangeLog::Admin::EntryForm < Admin::BaseForm
  ATTRIBUTES = %i(
    date
    description_md
    has_discussion
    major_update
    state
    title
  ).freeze

  MEDIA_ATTRIBUTES = %i(id media image_uuid priority _destroy).freeze

  attributes :author_id

  model :entry,
        attributes: ATTRIBUTES,
        nested_attributes: { media: MEDIA_ATTRIBUTES },
        save: true

  main_model :entry, ChangeLog::Entry

  before_update :parse_description_md
  after_update :toggle_discussion_on_publish

  delegate :has_discussion, :discussion, :major_update, to: :entry

  def initialize(entry = nil)
    @entry = entry || ChangeLog::Entry.new
    @author_id = @entry.discussion&.user_id
  end

  private

  def parse_description_md
    return if entry.description_md.blank?

    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    entry.description_html = markdown.render(entry.description_md)
  end

  def toggle_discussion_on_publish
    return unless entry.has_discussion?

    status = entry.published? ? 'approved' : 'pending'

    if entry.discussion.blank? && entry.published?
      discussion = Discussion::Thread.create!(
        subject: MakerGroup.find(MakerGroup::MAIN_ID),
        title: "[ChangeLog] #{ entry.title }",
        # NOTE(DZ): Discussions use white-space: pre-line css. Remove newlines.
        description: entry.description_html&.squeeze("\n"),
        status: status,
        user_id: author_id,
      )

      entry.update(discussion_thread_id: discussion.id)
    elsif entry.discussion.present?
      entry.discussion.update!(status: status)
      entry.discussion.update!(user_id: author_id) if author_id.present?
    end
  end
end
