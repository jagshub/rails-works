# frozen_string_literal: true

module Topics::Recommendations
  extend self

  # NOTE(k1): Uses MinHash
  #   `topics.post_ids_minhash_signature` is generated via trigger on post_topic_association using `compute_minhash_signature`
  #   `compute_minhash_signature` is postgresql function written by k1
  #
  #   More info:
  #   - https://en.wikipedia.org/wiki/MinHash
  #   - http://infolab.stanford.edu/~ullman/mmds/ch3.pdf
  #   - http://www2007.org/papers/paper570.pdf
  def based_on(record_with_minhash)
    sql = ActiveRecord::Base.sanitize_sql([%(
      SELECT topics.id AS topic_id,
        ((30 - coalesce(array_length(akeys(a.post_ids_minhash_signature - topics.post_ids_minhash_signature), 1), 0))/30.0) AS score
      FROM topics
      INNER JOIN #{ record_with_minhash.class.table_name } a ON a.post_ids_minhash_signature != '' AND a.id = :id
      WHERE topics.posts_count > 0
    ), { id: record_with_minhash.id }])

    Topic
      .select('*, score ')
      .from('topics')
      .joins("INNER JOIN (#{ sql }) AS scores ON scores.topic_id = topics.id")
      .where('score > 0')
      .order('score DESC NULLS LAST')
  end

  MAPPED_STORES = {
    'chrome' => 'chrome-extensions',
    'android' => 'android',
    'ios' => 'iphone',
    'kickstarter' => 'crowdfunding',
    'indiegogo' => 'crowdfunding',
    'github' => 'github',
    'youtube' => 'youtube',
    'playstation' => 'ps4',
    'amazon' => 'amazon',
    'slack' => 'slack',
    'itunes' => 'mac',
    'windows' => 'windows',
    'xbox' => 'xbox-one',
  }.freeze

  def based_on_product_links(post)
    stores = post.links.map(&:store).uniq.compact

    topic_stores = stores.map { |store| MAPPED_STORES[store] }

    Topic.where(slug: topic_stores).to_a
  end
end
