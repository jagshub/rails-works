# frozen_string_literal: true

module UpcomingPages::Form::Links
  extend ActiveSupport::Concern

  included do
    validate :validate_links
    after_update :update_links
  end

  module ClassMethods
    def url_attributes(*kinds)
      kinds.map(&:to_s).each do |kind|
        attributes "#{ kind }_url".to_sym

        define_method("#{ kind }_url=") do |value|
          assign_link(kind, value)
        end
      end
    end
  end

  private

  def assign_link(kind, value)
    # NOTE(rstankov): Not using `@upcoming_page.links` because of validation/caching issues with ActiveRecord relationships
    @link_assoc ||= UpcomingPageLink.where(upcoming_page_id: @upcoming_page.id)

    # NOTE(jag): After upgrading to rails 6, the validations for association(UpcomingPageLink) are getting triggered, when
    # parent(UpcomingPage) is created, resulting in links is invalid error set in graphql response and page creation
    # fails. We dont want to trigger these validations unless we have link values to validate.
    link = @link_assoc.detect { |l| l.kind == kind }
    return if link.nil? && value.blank?

    link ||= UpcomingPageLink.new(upcoming_page: upcoming_page)

    if value.present?
      link.url = value
      link.kind = kind
    else
      link.mark_for_destruction
    end

    @links ||= []
    @links << link
    value
  end

  def validate_links
    (@links || []).reject(&:marked_for_destruction?).select(&:invalid?).each do |link|
      errors.add :"#{ link.kind }_url", :invalid
    end
  end

  def update_links
    (@links || []).each do |link|
      if link.marked_for_destruction?
        link.destroy!
      else
        link.save!
      end
    end
  end
end
