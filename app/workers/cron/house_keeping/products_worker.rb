# frozen_string_literal: true

# This worker does three separate things:
# - Cleans up products without posts
# - Associates posts without products
# - Refreshes post counts that don't match
#
# Once it's done, it publishes a report to s3 with what it changed
#
class Cron::HouseKeeping::ProductsWorker < ApplicationJob
  def perform
    # Optionally turn off SQL/Rails logs, for nice clean output in console
    # ActiveRecord::Base.logger.level = 0
    # Rails.logger.level = 4

    report = CSV.generate do |csv|
      csv << ['Problem', 'Subject type', 'Slug', 'Old value', 'Fixed value']

      empty_products = Product
        .where(logo_uuid: nil)
        .where.missing(:post_associations)
      Rails.logger.info "Working on empty products: #{ empty_products.count }"

      empty_products.each do |product|
        csv << ['Empty product', 'Product', product.slug, nil, nil]
        product.destroy
      end

      orphaned_posts = Post
        .not_trashed
        .where.missing(:product_association)
      Rails.logger.info "Working on orphaned posts: #{ orphaned_posts.count }"

      orphaned_posts.find_each do |post|
        product = Products::Find.by_url(post.primary_link.url)

        begin
          if product
            Products::MovePost.call(post: post, product: product, source: 'data_migration')
          else
            product = Products::Create.for_post(post)
          end

          Products::RefreshActivityEvents.new(product).call

          csv << ['Orphaned post', 'Post', post.slug, nil, product.slug]
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.info "Invalid record: #{ e }"
          csv << ['Orphaned post', 'Post', post.slug, nil, "Error: #{ e.message }"]
        end
      end

      nonzero_post_count = Product
        .joins(:posts)
        .group('products.id')
        .merge(Post.visible)
        .having('COUNT(posts.id) != products.posts_count')
        .to_a
      zero_post_count = Product
        .where.missing(:posts)
        .where('posts_count > 0')
        .to_a
      invalid_post_count = nonzero_post_count + zero_post_count
      Rails.logger.info "Working on products with invalid post counts: #{ invalid_post_count.count }"

      invalid_post_count.each do |product|
        old_count = product.posts_count

        product.refresh_posts_count
        product.refresh_review_counts
        product.update_reviews_rating
        product.update_vote_counts
        product.reload

        csv << ['Invalid posts_count', 'Product', product.slug, old_count, product.posts_count]
      end
    end

    # rubocop:disable Style/GuardClause:
    if Rails.env.production?
      External::S3Api.put_object(
        bucket: :insights,
        key: "product-reports/report-#{ Time.current.to_date.to_s(:db) }.csv",
        body: report,
        content_type: 'text/csv',
      )
    end
    # rubocop:enable Style/GuardClause
  end
end
