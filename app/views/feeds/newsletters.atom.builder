# frozen_string_literal: true

cache @stories do
  atom_feed do |feed|
    feed.title 'A daily digest of the best of Product Hunt'
    feed.updated @newsletters[0].updated_at unless @newsletters.empty?
    feed.link href: newsletters_url

    @newsletters.each do |newsletter|
      social_image = newsletter.social_image_uuid || newsletter.sections[0].image_uuid

      content_body = '<![CDATA['

      newsletter.sections.each do |section|
        if section.content.present?
          content_body += section.content
          content_body += ' '
        end
      end

      content_body += ']]>'

      feed.entry newsletter, url: newsletter_url(newsletter) do |entry|
        entry.title newsletter.subject
        entry.link href: (::Image.call social_image, width: 1024, height: 512, fit: 'crop', frame: 1), rel: 'enclosure', type: 'image/jpeg' if social_image
        entry.content content_body, type: 'text/html'
        entry.author do |author|
          author.name 'Product Hunt Daily'
        end
      end
    end
  end
end
