# frozen_string_literal: true

class Graph::Resolvers::Newsletter < Graph::Resolvers::Base
  argument :id, ID, required: false
  argument :preview, String, required: false

  type Graph::Types::NewsletterType, null: true

  def resolve(id: nil, preview: nil)
    newsletter = id ? ::Newsletter.find_by(id: id) : ::Newsletter.sent.daily.last

    return unless newsletter
    return unless user_can_see_newsletter?(newsletter, preview)

    ::Newsletter::Content.new(newsletter)
  end

  private

  def user_can_see_newsletter?(newsletter, preview_token)
    return true if current_user&.admin?
    return true if preview_token.present? && preview_token == newsletter.preview_token

    newsletter.sent?
  end
end
