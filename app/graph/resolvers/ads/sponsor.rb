# frozen_string_literal: true

class Graph::Resolvers::Ads::Sponsor < Graph::Resolvers::Base
  argument :force_sponsor, String, required: false

  type Graph::Types::Newsletter::SponsorType, null: true

  def resolve(force_sponsor: nil)
    return unless object.is_a?(Newsletter::Content)
    return if object.skip_sponsor?

    sponsor = find_forced_sponsor(force_sponsor) if force_sponsor.present?
    sponsor ||= object.sponsor if object.sponsor.present?
    sponsor ||= Ads.for_newsletter_sponsor(max_only: true).sample

    sponsor
  end

  private

  def find_forced_sponsor(force_sponsor)
    return unless current_user&.admin?

    Ads::NewsletterSponsor.find_by(id: force_sponsor)
  end
end
