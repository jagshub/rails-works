# frozen_string_literal: true

# NOTE(rstankov): We support various types of homefeed
#   Homefeed is split into pages (Homefeed::Page). The page content is stored in items.
module Homefeed
  extend self
  include NewRelic::Agent::MethodTracer

  POPULAR = 'POPULAR'
  NEWEST = 'NEWEST'

  ALL = [POPULAR, NEWEST].freeze

  def feed_for(graphql_context:, kind:, after:, mobile: false)
    cursor = Cursor.after(after)

    case kind
    when POPULAR then popular(cursor, graphql_context: graphql_context, mobile: mobile)
    when NEWEST then newest(cursor, graphql_context: graphql_context, mobile: mobile)
    else raise "Unknown feed kind - #{ kind }"
    end
  end
  add_method_tracer :feed_for, 'Homefeed/feed_for'

  private

  def title(date)
    return get_homepage_tagline(day: date.strftime('%u').to_i) if date.today?
    return 'Yesterday' if date.yesterday?
    return date.strftime('%A') if date.year == Time.current.year

    date.strftime('%e %B %Y')
  end

  def subtitle(date)
    return if date.today?
    return "#{ date.strftime('%b') } #{ date.day.ordinalize }" if date.yesterday? || (date.year == Time.current.year)

    date.strftime('%A')
  end

  def newest(cursor, graphql_context:, mobile:)
    date = cursor.page.days.ago.to_date

    scheduled_posts = Post.visible.where_date_eq(:scheduled_at, date)
    unscheduled_posts = Post.visible.where(scheduled_at: nil).where_date_eq(:created_at, date)

    posts = scheduled_posts.or(unscheduled_posts).by_created_at

    items = if mobile
              inject_extra_content_mobile(posts, graphql_context: graphql_context, post_offset: cursor.previous_posts_count)
            else
              inject_extra_content_web(posts, graphql_context: graphql_context, post_offset: cursor.previous_posts_count)
            end

    Homefeed::Page.new(
      page: cursor.page,
      cursor: cursor.to_s(posts.size),
      items: items,
      kind: NEWEST,
      title: title(cursor.page.days.ago),
      subtitle: subtitle(cursor.page.days.ago),
      date: cursor.page.days.ago,
    )
  end

  def popular(cursor, graphql_context:, mobile: false)
    posts = Post
            .featured
            .for_featured_date(cursor.page.days.ago.to_date)
            .order('daily_rank ASC')
            .to_a
    # Note(maciesielka): save the original count for the cursor, since the "inject" function will consume the post items
    posts_count = posts.size

    if mobile
      items = inject_extra_content_mobile(posts, graphql_context: graphql_context, post_offset: cursor.previous_posts_count)

      return Homefeed::Page.new(
        page: cursor.page,
        cursor: cursor.to_s(posts_count),
        items: items,
        kind: POPULAR,
        hide_after: items.size,
        title: title(cursor.page.days.ago),
        subtitle: subtitle(cursor.page.days.ago),
      )
    end

    hide_after = cursor.page > 2 ? 10 : [posts.count, 10].max
    items = inject_extra_content_web(posts.first(hide_after), graphql_context: graphql_context, post_offset: cursor.previous_posts_count)

    Homefeed::Page.new(
      page: cursor.page,
      cursor: cursor.to_s(posts_count),
      items: items + posts[hide_after..-1].to_a,
      kind: POPULAR,
      hide_after: items.size,
      title: title(cursor.page.days.ago),
      subtitle: subtitle(cursor.page.days.ago),
      date: cursor.page.days.ago,
    )
  end

  # NOTE(rstankov): Content in a page is split into blocks.
  #   Page can have multiple blocks depending on post count
  #
  #   block content
  #    - post
  #    - post
  #    - post
  #    - ad
  #    - post
  #    - discussion / story / featured collection (depending on shuffled order)

  POSTS_PER_BLOCK = 4

  def inject_extra_content_mobile(posts, graphql_context:, post_offset: 0)
    return posts if posts.size < POSTS_PER_BLOCK

    # NOTE(rstankov): Why we use `ceil` and `floor`?
    #   If we have 3 blocks we have to show 2 discussions and only 1 story
    #
    #   discussions_count = (3.0 / 2).ceil    # => (1.5).ceil -> 2
    #   stories_count     = (3.0 / 2).floor   # => (1.5).floor -> 1
    blocks_count = posts.size / POSTS_PER_BLOCK
    discussions_count = (blocks_count.to_f / 2).ceil
    stories_count = (blocks_count.to_f / 2).floor

    previous_blocks_count = post_offset / POSTS_PER_BLOCK
    discussions_offset = (previous_blocks_count.to_f / 2).ceil
    stories_offset = (previous_blocks_count.to_f / 2).floor

    posts = posts.to_a
    discussions =
      Discussion::Thread
      .approved
      .featured
      .visible
      .where('featured_at <= ?', Time.current)
      .order(featured_at: :desc, id: :desc)
      .offset(discussions_offset)
      .limit(discussions_count)
      .to_a

    stories =
      Anthologies::Story
      .published
      .by_published_at
      .order(id: :desc)
      .offset(stories_offset)
      .limit(stories_count)
      .to_a

    items = []
    blocks_count.times do |i|
      items << posts.shift
      items << posts.shift
      items << posts.shift
      items << find_ad(bundle: 'homepage_primary', graphql_context: graphql_context)
      items << posts.shift
      items << (i.even? ? discussions.shift : stories.shift)
    end
    items += posts
    items.compact
  end

  def inject_extra_content_web(posts, graphql_context:, post_offset: 0)
    return posts if posts.size < POSTS_PER_BLOCK

    blocks_count = posts.size / POSTS_PER_BLOCK
    posts = posts.to_a

    content = [
      Discussion::Thread.approved.featured.visible.where('featured_at <= ?', Time.current).order(featured_at: :desc, id: :desc),
      Anthologies::Story.published.by_published_at.order(id: :desc),
      Collection.featured.order(featured_at: :desc, id: :desc),
    ]

    offset_float = (post_offset / POSTS_PER_BLOCK).to_f / content.size
    count_float = blocks_count.to_f / content.size

    extra_content = generate_extra_content(content, count_float, offset_float)

    items = []
    blocks_count.times do
      items << posts.shift
      items << posts.shift
      items << posts.shift
      items << find_ad(bundle: 'homepage_primary', graphql_context: graphql_context)
      items << posts.shift
      items << extra_content.shift
    end
    items += posts
    items.compact
  end

  CONVERT_METHODS = %i(ceil round floor).freeze

  # Note(TE): This will generate a randomly ordered array of content (discussions/stories/collections)
  def generate_extra_content(content, count_float, offset_float)
    content.each_with_index.flat_map do |scope, index|
      # We want to iterate on the items of content such that we have a distributed number of items.
      # So if we have 4 blocks, from the shuffled content, we want to see 2 discussions, 1 story, and 1 collection.
      # discussions_count     = (4.0 / 3).ceil   => (1.33).ceil  = 2
      # stories_count         = (4.0 / 3).round  => (1.33).round = 1
      # collections_count     = (4.0 / 3).floor  => (1.33).floor = 1
      convert_method = CONVERT_METHODS.fetch(index)

      offset = offset_float.public_send(convert_method)
      count = count_float.public_send(convert_method)

      # This will result in a flat array like [discussion_1, discussion_2, story_1, collection_1]
      scope.offset(offset).limit(count).to_a
      # Which we want to shuffle one last time to get => [story_2, collection_1, story_1, discussion_1]
    end.shuffle
  end

  def find_ad(bundle:, graphql_context:)
    args = { bundle: bundle, kind: 'feed' }

    graphql_context.session[:served_ads] ||= []
    exclude_ids = graphql_context.session[:served_ads]
    ad = Ads.find_web_ad(**args, exclude_ids: exclude_ids)

    # NOTE(DZ): If we can't find an ad, reset exclusion
    if ad.blank?
      graphql_context.session[:served_ads] = []
      ad = Ads.find_web_ad(**args)
    end

    # NOTE(DZ): When ad is timed, we never want it to be excluded
    graphql_context.session[:served_ads] << ad.id if ad.present? && ad.kind == 'cpm'

    ad
  end

  def get_homepage_tagline(day:)
    return 'Meowy Monday' if day == 1
    return 'Fresh products Friday' if day == 5
    return 'Your next favorite thing 👇' if day.even?

    'Is the next 🦄 here?'
  end
end
