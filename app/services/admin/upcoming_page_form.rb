# frozen_string_literal: true

class Admin::UpcomingPageForm
  include MiniForm::Model

  model :upcoming_page, save: true, attributes: %i(
    name
    tagline
    slug
    hiring
    user_id
    status
    featured_at
    inbox_slug
    ship_account_id
  )

  delegate :new_record?, to: :upcoming_page

  def initialize(upcoming_page, current_user)
    @upcoming_page = upcoming_page
    @moderator = current_user
  end

  private

  def after_update
    emit_featured
  end

  def emit_featured
    prev_featured_at, featured_at = @upcoming_page.previous_changes[:featured_at]

    return if featured_at.blank?
    return if prev_featured_at.present?

    UpcomingPages::FeatureUpcomingPage.call(@upcoming_page, @moderator)
  end
end
