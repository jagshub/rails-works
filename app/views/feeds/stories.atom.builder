# frozen_string_literal: true

description = <<~STR
  At Product Hunt, we hear a lot about what it means to make a product —
  whether it's in the comments of a launch post, in a tweetstorm, on our
  podcast or in our DMs. The details behind these stories often translate
  into a lesson another Maker could use. So we decided to put these
  “How I did X” anecdotes in one place. Today, we're excited to take the
  hood off Maker Stories, a platform for Makers to share their knowledge
  on Product Hunt.
STR

cache @stories do
  atom_feed do |feed|
    feed.title description
    feed.updated @stories[0].published_at unless @stories.empty?
    feed.link href: stories_url
    feed.logo S3Helper.image_url('ph-stories-og-image.png')

    @stories.each do |story|
      feed.entry story, url: story_url(story) do |entry|
        entry.link href: (::Image.call story.header_image_uuid, width: 1024, height: 512, fit: 'crop'), rel: 'enclosure', type: 'image/jpeg' if story.header_image_uuid
        entry.title story.title
        entry.author do |author|
          author.name story.author.name
          author.uri profile_url(story.author)
        end
        entry.link href: story_url(story)
        entry.summary story.description
        entry.content src: story_url(story), type: 'text/html'
      end
    end
  end
end
