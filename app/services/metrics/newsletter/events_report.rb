# frozen_string_literal: true

module Metrics::Newsletter::EventsReport
  include ActionView::Helpers::NumberHelper
  extend self

  URL = 'https://www.producthunt.com'
  def data(id)
    newsletter = Newsletter.find id

    campaign = "#{ id }_#{ newsletter.date }"

    content_links = extract_section_links newsletter.sections

    counts = newsletter.events.group(:event_name).count

    total_clicks = counts['click'] || 0

    OpenStruct.new(
      newsletter: newsletter,
      view_online: find_view_online_clicks(newsletter, total_clicks),
      primary: run_clicks_query(section_links(links: content_links['primary_featured'],
                                              campaign: campaign, term: 'editorial'), newsletter, total_clicks),
      primary_read_more: run_clicks_query(section_links(links: [view_online_url(newsletter)],
                                                        campaign: campaign, term: 'editorial'), newsletter, total_clicks),
      secondary: run_clicks_query(section_links(links: content_links['secondary_featured'],
                                                campaign: campaign, term: 'editorial'), newsletter, total_clicks),
      tertiary: run_clicks_query(section_links(links: content_links['tertiary_featured'],
                                               campaign: campaign, term: 'editorial'), newsletter, total_clicks),
      top_posts: run_clicks_query(section_links(links: top_post_links(newsletter.posts),
                                                campaign: campaign, term: 'featured'), newsletter, total_clicks),
      jobs: run_custom_query(newsletter, 'job_by_newsletter', total_clicks),
      upcoming: run_custom_query(newsletter, 'upcoming_newsletter_promotion', total_clicks),
      total_clicks: total_clicks,
      sent_count: counts['sent'] || 0,
      open_count: counts['open'] || 0,
      unique_clicks: newsletter.events.select(:subscriber_id).distinct.where(event_name: 'click').count,
      subscription_events: subscription_events(newsletter, total_clicks),
    )
  end

  private

  def view_online_url(newsletter)
    # NOTE(DZ): This uses URL since dev `_url`s will be identified as external
    "#{ URL }#{ Routes.newsletter_path(newsletter) }"
  end

  def extract_section_links(sections)
    Hash[
      sections.map { |section| [section.tracking_label, section.content.to_s.scan(/href\s*=\s*"([^"]*)"/).flatten.push(section.url).uniq.reject(&:blank?)] }
    ]
  end

  def external_link?(link)
    domain = URI.parse(link).host
    return true if domain.nil?

    !domain.include?('producthunt.com')
  rescue URI::InvalidURIError
    true
  end

  def section_links(links:, campaign:, medium: 'email', term:)
    return if links.blank?

    links.map do |link|
      link.include?('utm_') || external_link?(link) ? CGI.unescapeHTML(link) : "#{ link }#{ add_utm_params(link, campaign, medium, term) }"
    end
  end

  def top_post_links(posts)
    posts.map do |post|
      "#{ URL }#{ Routes.post_path(Post.find(post['id']).slug) }"
    end
  end

  def add_missing_links(result, links)
    links.each { |link| result[link] = 0 unless result.key?(link) }

    result
  end

  def run_clicks_query(links, newsletter, total_clicks)
    return [] if links.blank?

    result = add_missing_links newsletter.events.where(link_url: links, event_name: 'click').group(:link_url).order('1 desc').count, links
    total = result.values.sum

    [format_data(result, total), "#{ total } (#{ number_to_percentage(total.to_f * 100.0 / total_clicks.to_f, precision: 2) })"]
  end

  def format_data(data, total)
    data.map do |key, value|
      {
        url: key.split('?').first,
        clicks: "#{ value } (#{ number_to_percentage(value.to_f * 100.0 / total.to_f, precision: 2) })",
      }
    end
  end

  def add_utm_params(link, campaign, medium, term)
    prefix = link.include?('?') ? '&' : '?'

    utm_term = term.present? ? "&utm_term=#{ term }" : ''
    "#{ prefix }utm_campaign=#{ campaign }&utm_medium=#{ medium }&utm_source=Product+Hunt#{ utm_term }"
  end

  def subscription_events(newsletter, total)
    clicks = []
    ['newsletter', 'daily_newsletter'].each do |kind|
      count = newsletter.events.select(:subscriber_id).distinct.where('link_url LIKE ? and link_url LIKE ?', '%/unsubscribe%', "%kind=#{ kind }%").count
      clicks.push("#{ count } (#{ number_to_percentage(count.to_f * 100.0 / total.to_f, precision: 2) })")
    end

    clicks
  end

  def run_custom_query(newsletter, value, total_clicks)
    result = newsletter.events.where('link_url LIKE ?', "%utm_campaign=#{ value }%").group(:link_url).order('1 desc').count
    total = result.values.sum

    [format_data(result, total), "#{ total } (#{ number_to_percentage(total.to_f * 100.0 / total_clicks.to_f, precision: 2) })"]
  end

  def format_to_percent(total_clicks, total)
    value = number_to_percentage(total.to_f * 100.0 / total_clicks.to_f, precision: 2)
    "#{ total } (#{ value })"
  end

  def find_view_online_clicks(newsletter, total_clicks)
    link = view_online_url(newsletter)
    result =
      newsletter
      .events
      .where(event_name: 'click')
      .where('LOWER(link_url) like ?', LikeMatch.simple(link))
      .size

    [
      format_data({ link => result }, total_clicks),
      "#{ result } (#{ number_to_percentage(result / total_clicks.to_f, precision: 2) })",
    ]
  end
end
