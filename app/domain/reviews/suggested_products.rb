# frozen_string_literal: true

class Reviews::SuggestedProducts
  def self.call(user_id:, limit: nil, offset: 0)
    new(user_id: user_id).fetch(limit: limit, offset: offset)
  end

  attr_reader :user_id, :total_count

  def initialize(user_id:)
    @user_id = user_id
    @total_count = fetch_total_count
  end

  def fetch(limit: nil, offset: 0)
    return unless user_id

    query = build_query(limit: limit, offset: offset)
    Product.find_by_sql(query)
  end

  private

  def fetch_total_count
    return 0 unless user_id

    Reviews::SuggestedProductsCache.fetch(user_id: user_id) do
      ExecSql.call(build_query(count_only: true)).entries.first['count']
    end
  end

  # NOTE(Raj): Returns distinct products list sorted in the order of
  #            commented, upvoted, visit clicked, legacy reviewed launches respectively.
  def build_query(limit: nil, offset: nil, count_only: false)
    <<-SQL.squish
      WITH commented_products AS (
        SELECT products.id, comments.created_at AS action_created_at, 4 AS sort_number
        FROM products
        INNER JOIN product_post_associations ON product_post_associations.product_id = products.id
        INNER JOIN comments ON comments.subject_id = product_post_associations.post_id
        WHERE comments.subject_type = 'Post'
          AND comments.user_id = #{ Integer(user_id) }
          AND date_trunc('day', comments.created_at ) <= date_trunc('day', now() - INTERVAL '3 DAYS')
      ),
      upvoted_products AS (
        SELECT products.id, votes.created_at AS action_created_at, 3 AS sort_number
        FROM products
        INNER JOIN product_post_associations ON product_post_associations.product_id = products.id
        INNER JOIN votes ON votes.subject_id = product_post_associations.post_id
        WHERE votes.subject_type = 'Post'
          AND votes.user_id = #{ Integer(user_id) }
          AND date_trunc('day', votes.created_at) <= date_trunc('day', now() - INTERVAL '3 DAYS')
      ),
      visit_clicked_products AS (
        SELECT products.id, link_trackers.created_at AS action_created_at, 2 AS sort_number
        FROM products
        INNER JOIN product_post_associations ON product_post_associations.product_id = products.id
        INNER JOIN link_trackers ON link_trackers.post_id = product_post_associations.post_id
        WHERE link_trackers.user_id = #{ Integer(user_id) }
          AND date_trunc('day', link_trackers.created_at) <= date_trunc('day', now() - INTERVAL '3 DAYS')
      ),
      legacy_reviewed_products AS (
        SELECT products.id, reviews.created_at AS action_created_at, 1 AS sort_number
        FROM products
        INNER JOIN reviews ON reviews.product_id = products.id
        WHERE reviews.user_id = #{ Integer(user_id) }
          AND reviews.rating IS NULL
      ),
      products_list AS (
        SELECT id, MAX(CONCAT(sort_number, action_created_at)) sort_number FROM (
          SELECT id, action_created_at, sort_number from commented_products
          UNION ALL
          SELECT id, action_created_at, sort_number from upvoted_products
          UNION ALL
          SELECT id, action_created_at, sort_number from visit_clicked_products
          UNION ALL
          SELECT id, action_created_at, sort_number from legacy_reviewed_products
        ) AS products
        GROUP BY id
        ORDER BY sort_number DESC
      )

      SELECT
      #{ count_only ? 'COUNT(*)' : 'products.*, products_list.sort_number' }
      FROM products
      INNER JOIN products_list on products_list.id = products.id
      WHERE NOT EXISTS (
          SELECT 1
          FROM products_skip_review_suggestions
          WHERE user_id = #{ Integer(user_id) }
            AND product_id = products.id
        )
        AND NOT EXISTS (
          SELECT 1
          FROM reviews
          WHERE user_id = #{ Integer(user_id) }
            AND product_id = products.id
            AND rating IS NOT NULL
        )
        AND products.id NOT IN (
          SELECT product_post_associations.product_id
          FROM product_post_associations
          WHERE EXISTS (
              SELECT 1
              FROM product_makers
              WHERE post_id = product_post_associations.post_id
              AND user_id = #{ Integer(user_id) }
          )
        )
      #{ 'ORDER BY products_list.sort_number DESC' unless count_only }
      #{ "LIMIT #{ Integer(limit) }" if limit }
      #{ "OFFSET #{ Integer(offset) }" if offset }
    SQL
  end
end
