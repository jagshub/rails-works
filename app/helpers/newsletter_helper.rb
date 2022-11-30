# frozen_string_literal: true

module NewsletterHelper
  def newsletter_top_items_title(newsletter)
    if newsletter.weekly?
      "Last Week's Top Products"
    elsif newsletter.weekend_newsletter?
      "This Weekend's Top Products"
    else
      "Yesterday's Top Products"
    end
  end

  def newsletter_top_items_date(newsletter)
    today = Time.zone.today
    if newsletter.daily?
      Time.zone.today.strftime('%A, %-d %B %Y')
    else
      bow = today.last_week
      eow = today.last_week.end_of_week

      "#{ bow.strftime('%B') } #{ bow.day.ordinalize } - #{ eow.strftime('%B') } #{ eow.day.ordinalize }"
    end
  end

  def newsletter_section_content(section, tracking_params: {})
    raw add_utm_params_to_html(section.content, tracking_params.to_query)
  end

  def newsletter_section_content_as_text(section, tracking_params: {})
    strip_tags add_utm_params_to_html(section.content, tracking_params.to_query, inline_links: true)
  end

  def newsletter_section_url(section, tracking_params: {})
    add_utm_params_to_url(section.url, tracking_params.to_query)
  end

  private

  def add_utm_params_to_html(html, query, inline_links: false)
    doc = Nokogiri::HTML.fragment(html)
    doc.css('a[href]').each do |a|
      href = add_utm_params_to_url(a['href'], query)

      a['href'] = href
      a['target'] = '_blank'
      a.content = "#{ a.content } ( #{ a['href'].gsub('&amp;', '&') } )" if inline_links
    end
    doc.to_html
  end

  def add_utm_params_to_url(url, query)
    uri = URI.parse(url)

    return url unless uri.host =~ /producthunt\.com/

    uri.query = uri.query ? uri.query + '&' + query : query
    uri.to_s
  rescue URI::InvalidURIError
    url
  end
end
