# frozen_string_literal: true

module StructuredData::Generators::Anthologies::Story
  extend self

  # Note(DZ): This is the structure for a full AMP HTML story page.
  # For now, we don't have an AMP page, but regular stories is a subset of this.
  def structured_data_for(story)
    {
      "@context": 'https://schema.org',
      "@type": 'NewsArticle',
      "mainEntityOfPage": main_entity_of_page_from(story),
      "headline": headline_from(story),
      "image": image_from(story),
      "author": author_from(story),
      "publisher": publisher,
      "description": description_from(story),
      "datePublished": date_published_from(story),
      "dateModified": date_modified_from(story),
    }
  end

  private

  def description_from(story)
    story.description
  end

  def author_from(story)
    StructuredData::Types::Person.call(story.author)
  end

  def publisher
    StructuredData::Types::Publisher.call
  end

  def image_from(story)
    [Sharing.image_for(story)]
  end

  def headline_from(story)
    story.title
  end

  def main_entity_of_page_from(story)
    {
      "@type": 'WebPage',
      "@id": Routes.story_url(story),
    }
  end

  def date_published_from(story)
    story.published_at || story.created_at
  end

  def date_modified_from(story)
    [story.updated_at, story.published_at || story.created_at].max
  end
end
