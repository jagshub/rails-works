# frozen_string_literal: true

cache [@posts, @application_id] do
  atom_feed do |feed|
    feed.title('Product Hunt — The best new products, every day')
    feed.updated(@posts[0].featured_at) unless @posts.empty?

    @posts.each do |post|
      feed.entry(post, url: Routes.post_url(post)) do |entry|
        entry.title(post.name)

        content_body = <<-HTML
          <p>
            #{ post.tagline }
          </p>
          <p>
            #{ link_to 'Discussion', post_url(post, Metrics.url_tracking_params(medium: :rss)) }
            |
            #{ link_to 'Link', short_link_to_post_url(post.id, app_id: @application_id) }
          </p>
        HTML

        entry.content(content_body, type: 'html')

        entry.author do |author|
          author.name(post.user.name)
        end
      end
    end
  end
end
