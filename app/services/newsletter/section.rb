# frozen_string_literal: true

class Newsletter::Section
  attr_reader :title, :subtitle, :cta, :url, :content, :layout, :image_uuid, :position, :tracking_label

  LAYOUTS = {
    primary_featured: 'newsletter_section',
    secondary_featured: 'newsletter_section',
    story: 'newsletter_story',
    sponsor: 'newsletter_sponsor',
    text: 'newsletter_text',
    top_posts: 'newsletter_posts',
    tertiary_featured: 'newsletter_section',
  }.freeze

  class << self
    def default_sections
      LAYOUTS.keys.each_with_index.map { |layout, i| new layout: layout, position: i }
    end
  end

  def initialize(attributes)
    attributes = attributes.stringify_keys

    @title = attributes['title']
    @subtitle = attributes['subtitle']
    @cta = attributes['cta']
    @url = attributes['url']
    @content = HtmlSanitize.call(attributes['content'])
    @layout = (attributes['layout'] || LAYOUTS.keys.first).to_s
    @image_uuid = attributes['image_uuid']
    @position = attributes['position'].nil? ? LAYOUTS.keys.index(layout.to_sym).to_i : attributes['position'].to_i
    @tracking_label = attributes['tracking_label'].presence || @layout
  end

  def primary_featured?
    layout == 'primary_featured'
  end

  def image_url
    Image.call image_uuid
  end

  def image?
    image_uuid.present?
  end

  def empty?
    content.blank?
  end

  delegate :present?, to: :content

  def partial
    LAYOUTS.fetch(layout.to_sym)
  end

  def <=>(other)
    position <=> other.position
  end

  def to_h
    {
      title: title,
      subtitle: subtitle,
      cta: cta,
      url: url,
      content: content,
      layout: layout,
      image_uuid: image_uuid,
      position: position,
      tracking_label: tracking_label,
    }
  end
end
