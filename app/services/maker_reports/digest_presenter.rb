# frozen_string_literal: true

module MakerReports
  class DigestPresenter
    attr_reader :post, :user, :recently_updated_post

    delegate :name, :tagline, to: :post, prefix: :post
    delegate :email, to: :user, prefix: :user

    delegate :comments, :reviews, :activities?, :activity_count,
             :votes, to: :recently_updated_post

    delegate :count, to: :comments, prefix: :comments
    delegate :count, to: :reviews, prefix: :reviews
    delegate :count, to: :votes, prefix: :votes
    delegate :count, to: :product_alternative_associations, prefix: :product_alternative_associations

    def initialize(maker_report)
      @post = maker_report.post
      @user = maker_report.user
      @recently_updated_post = MakerReports::RecentlyUpdatedPost.new(maker_report)
    end

    def email?
      user_email.present?
    end

    def tracking_params
      @tracking_params ||= {
        utm_campaign: "maker-report-digest-#{ Date.current.to_s(:db) }",
        utm_medium: 'email',
      }
    end

    def product
      post.new_product
    end

    def product_alternative_associations
      return Product.none if post.new_product.blank?

      post.new_product.alternative_associations
    end
  end
end
