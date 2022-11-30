# frozen_string_literal: true

class Graph::Resolvers::UpcomingPages::Message < Graph::Resolvers::Base
  type Graph::Types::UpcomingPageMessageType, null: true

  argument :upcoming_page_slug, String, required: false
  argument :id, ID, required: true
  argument :draft, Boolean, required: false
  argument :publicly_accessible, Boolean, required: false

  def resolve(upcoming_page_slug:, id:, draft: nil, publicly_accessible: nil)
    upcoming_page = find_page upcoming_page_slug

    return if upcoming_page.blank?

    return find_publicly_accessible_message(upcoming_page, id) if publicly_accessible

    if ApplicationPolicy.can?(current_user, ApplicationPolicy::MAINTAIN, upcoming_page) && draft
      find_draft_or_sent_message upcoming_page, id
    else
      find_send_message upcoming_page, id
    end
  end

  private

  def find_publicly_accessible_message(upcoming_page, id)
    upcoming_page.messages.publicly_accessible.find_by(slug: id) || upcoming_page.messages.publicly_accessible.find_by(id: id)
  end

  def find_send_message(upcoming_page, id)
    states = [UpcomingPageMessage.states[:sent], UpcomingPageMessage.states[:paused]]
    upcoming_page.messages.where(state: states).find_by(slug: id) || upcoming_page.messages.where(state: states).find_by(id: id)
  end

  def find_draft_or_sent_message(upcoming_page, id)
    upcoming_page.messages.find_by(slug: id) || upcoming_page.messages.find_by(id: id)
  end

  def find_page(slug)
    UpcomingPage.not_trashed.friendly.find(slug)
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
