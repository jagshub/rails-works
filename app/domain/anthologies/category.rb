# frozen_string_literal: true

module Anthologies::Category
  extend self

  DESCRIPTION = {
    news: "We keep our fingers on the pulse of tech, startups, and emerging products. We'll dive deeper into the news stories that impact the Product Hunt community right here.",
    maker_stories: 'Makers are the builders, creators, and innovators who help to power the Product Hunt community by launching their products into reality. Read their stories.',
    how_to: 'From venture capitalists to entrepreneurs, the Product Hunt community is rich with leaders with insight on how to launch and grow ideas. Learn from their experience.',
    announcements: 'Dive into the latest announcements from Product Hunt, from events like hackathons and the Golden Kitty Awards to new features and opportunities for startups.',
    interviews: 'We spoke with some of the most inspiring thought leaders and founders in the Product Hunt community. See what they shared about their journey and what drives them.',
    opinions: 'Opinion pieces are guest essays submitted by members of our community. They offer a unique idea, perspective, or vision of an emerging space or technology, drawing on the author’s own experience and expertise.',
    web3: 'The future on blockchain. All things wagmi, ngmi, and more.',
  }.freeze

  def call(slug)
    category = slug.tr('-', '_')
    return unless ::Anthologies::Story.categories.key?(category)

    StoryCategory.new(slug, category)
  end

  class StoryCategory
    attr_reader :slug, :category

    def initialize(slug, category)
      @slug = slug
      @category = category
    end

    def name
      @category.titleize
    end

    def stories
      @stories ||=
        Anthologies::Story
        .where(category: @category)
        .published
        .by_published_at
    end

    def description
      DESCRIPTION[@category.to_sym] || ''
    end
  end
end
