# frozen_string_literal: true

class API::V1::PostSerializer < API::V1::BasicPostSerializer
  delegated_attributes(:reviews_count, to: :resource)

  attributes(
    :badges,
    :comments,
    :votes,
    :related_links,
    :related_posts,
    :install_links,
    :media,
    :external_links,
    :description,
  )

  def description
    resource.description_text
  end

  def votes
    API::V1::VoteWithUserSerializer.collection(votes_collection, scope, root: false)
  end

  def badges
    API::V1::BadgesSerializer.collection(resource.badges, scope, root: false)
  end

  def comments
    new_scope = scope.dup
    new_scope[:exclude] << :post

    API::V1::ThreadSerializer.collection(comments_collection, new_scope, root: false)
  end

  # Note(andreasklinger): 2016-06-30 We removed the related_links from db/app
  def related_links
    []
  end

  def related_posts
    return [] if resource.new_product.blank?

    posts = Post.joins(:new_product).where(products: { id: resource.new_product.associated_products })
    API::V1::BasicPostSerializer.collection(posts, scope, root: false)
  end

  def media
    API::V1::MediaSerializer.collection(resource.media, scope, root: false)
  end

  # Note(AR): 2022-04-28 We're removing "embeds" from LegacyProduct
  def external_links
    []
  end

  # NOTE(rstankov): 2017-10-30 We removed the header_media_id from db/app
  def header_media_id
    nil
  end

  def install_links
    product_link_presenter = ProductLinksPresenter.decorate_links(post: resource)
    API::V1::ProductLinkSerializer.collection(product_link_presenter, scope, root: false)
  end

  def positive_reviews_count
    resource.reviews.with_sentiment.not_hidden.positive.count
  end

  def negative_reviews_count
    resource.reviews.with_sentiment.not_hidden.negative.count
  end

  def neutral_reviews_count
    resource.reviews.with_sentiment.not_hidden.neutral.count
  end

  private

  def comments_collection
    resource.comments
            .top_level
            .with_preloads_for_api
            .order(id: :asc)
            .first(20)
  end

  def votes_collection
    Voting.votes(subject: resource, as_seen_by: scope[:current_user]).includes(:user).last(20)
  end
end
