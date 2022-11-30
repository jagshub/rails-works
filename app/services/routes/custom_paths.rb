# frozen_string_literal: true

module Routes
  module CustomPaths # rubocop:disable Metrics/ModuleLength
    module OriginalRoutes
      class << self
        include Rails.application.routes.url_helpers

        def default_url_options
          Rails.application.routes.default_url_options
        end
      end
    end

    def profile_url(user_or_username, options = {})
      username = user_or_username.is_a?(User) ? user_or_username.username : user_or_username
      OriginalRoutes.profile_url(username, options)
    end

    def profile_path(user_or_username, options = {})
      username = user_or_username.is_a?(User) ? user_or_username.username : user_or_username
      OriginalRoutes.profile_path(username, options)
    end

    def my_upcoming_page_conversation_message_url(message)
      "#{ Routes.my_upcoming_page_message_url(message.upcoming_page.slug, message.upcoming_page_message.id) }#conversation-message-#{ message.id }"
    end

    def comment_path(comment, options = {})
      case comment.subject
      when Post
        # NOTE(ayrton) doesn't use post_comment_path because it gives too little context
        post_or_product_path(comment.subject, options.merge(comment: comment.id))
      when Review
        review_path(comment.subject, options)
      when UpcomingPageMessage
        upcoming_page_message_path(comment.subject, options)
      when Anthologies::Story
        story_path(comment.subject, options.merge(comment: comment.id))
      when Discussion::Thread
        discussion_path(comment.subject, options.merge(comment: comment.id))
      when ProductRequest
        product_request_comment_path(comment.subject, comment, options)
      when Recommendation
        product_request_recommendation_comment_path(comment.subject.product_request, comment.subject, comment, options)
      when Goal
        root_path
      else
        raise ArgumentError, "Unknown comment subject type #{ comment.subject.class }"
      end
    end

    def comment_url(comment, options = {})
      case comment.subject
      when Post
        # NOTE(ayrton) doesn't use post_comment_url because it gives too little context
        post_or_product_url(comment.subject, options.merge(comment: comment.id))
      when Review
        # NOTE (k1): Reviews won't have permalinked comments right away.
        review_url(comment.subject, options)
      when UpcomingPageMessage
        upcoming_page_message_url(comment.subject, options)
      when Anthologies::Story
        story_url(comment.subject, options.merge(comment: comment.id))
      when Discussion::Thread
        discussion_url(comment.subject, options.merge(comment: comment.id))
      when ProductRequest
        product_request_comment_url(comment.subject, comment, options)
      when Recommendation
        product_request_recommendation_comment_url(comment.subject.product_request, comment.subject, comment, options)
      else
        raise ArgumentError, "Unknown comment subject type #{ comment.subject.class }"
      end
    end

    def collection_path(collection, options = {})
      if collection.without_curator?
        official_collection_path(collection, options)
      else
        profile_collection_path(collection.user.username, collection, options)
      end
    end

    def collection_url(collection, options = {})
      if collection.without_curator?
        official_collection_url(collection, options)
      else
        profile_collection_url(collection.user.username, collection, options)
      end
    end

    def post_or_product_path(post, options = {})
      if post.archived? && post.new_product.present?
        if options.empty?
          "/products/#{ post.new_product.slug }##{ post.slug }"
        else
          "/products/#{ post.new_product.slug }?#{ options.to_query }##{ post.slug }"
        end
      else
        post_path(post, options)
      end
    end

    def post_or_product_url(post, options = {})
      if post.archived? && post.new_product.present?
        "#{ root_url.chomp('/') }#{ post_or_product_path(post, options) }"
      else
        post_url(post, options)
      end
    end

    def auth_twitter_url(options = {})
      if options.present?
        "#{ root_url }auth/twitter?#{ options.to_query }"
      else
        "#{ root_url }auth/twitter"
      end
    end

    def auth_facebook_url(options = {})
      if options.present?
        "#{ root_url }auth/facebook?#{ options.to_query }"
      else
        "#{ root_url }auth/facebook"
      end
    end

    def subject_path(subject, options = {})
      case subject
      when Comment
        comment_path(subject, options)
      when UpcomingPageMessage
        upcoming_page_message_path(subject, options)
      when Review
        subject.product ? product_reviews_path(subject.product) : post_reviews_path(subject.post, subject, options)
      when MakerGroup
        maker_group_path(subject, options)
      when MakersFestival::Edition
        makers_festival_path(subject.slug)
      when ProductRequest
        product_request_path(subject, options)
      when Recommendation
        recommendation_path(subject, options)
      when Product
        product_path(subject)
      else
        raise ArgumentError, "Unknown subject type #{ subject.class }"
      end
    end

    def subject_url(subject, options = {})
      case subject
      when User
        profile_url(subject, options)
      when Comment
        comment_url(subject, options)
      when Collection
        collection_url(subject, options)
      when Topic
        topic_url(subject, options)
      when MakerGroup
        maker_group_url(subject, options)
      when Post
        post_or_product_url(subject, options)
      when Review
        subject.product ? product_reviews_url(subject.product) : post_reviews_url(subject.post, subject, options)
      when Newsletter, Newsletter::Content
        newsletter_url(subject, options)
      when UpcomingPage
        upcoming_page_url(subject, options)
      when UpcomingPageMessage
        upcoming_page_message_url(subject, options)
      when Anthologies::Story
        story_url(subject, options)
      when MakersFestival::Edition
        makers_festival_url(subject.slug)
      when Discussion::Thread
        discussion_url(subject.to_param)
      when ChangeLog::Entry
        change_log_url(subject, options)
      when ProductRequest
        product_request_url(subject, options)
      when Recommendation
        recommendation_url(subject, options)
      when Product
        product_url(subject)
      else
        raise ArgumentError, "Unknown subject type #{ subject.class }"
      end
    end

    def recommendation_path(recommendation, options = {})
      product_request_recommendation_path(recommendation.product_request, recommendation, options)
    end

    def recommendation_url(recommendation, options = {})
      product_request_recommendation_url(recommendation.product_request, recommendation, options)
    end

    def upcoming_page_message_path(upcoming_page_message, options = {})
      rest = options.blank? ? '' : "?#{ options.to_query }"
      identifier = upcoming_page_message.slug || upcoming_page_message.id
      "/upcoming/#{ upcoming_page_message.upcoming_page.slug }/messages/#{ identifier }#{ rest }"
    end

    def my_upcoming_page_path(upcoming_page)
      "/my/upcoming/#{ upcoming_page.slug }"
    end

    def my_upcoming_page_url(upcoming_page)
      "#{ root_url }my/upcoming/#{ upcoming_page.slug }"
    end

    def edit_my_upcoming_page_path(upcoming_page)
      "/my/upcoming/#{ upcoming_page.slug }/edit"
    end

    def edit_my_upcoming_page_url(upcoming_page)
      "#{ root_url }my/upcoming/#{ upcoming_page.slug }/edit"
    end

    def import_my_upcoming_page_subscribers_path(upcoming_page)
      "/my/upcoming/#{ upcoming_page.slug }/imports/new"
    end

    def import_my_upcoming_page_subscribers_url(upcoming_page)
      "#{ root_url }my/upcoming/#{ upcoming_page.slug }/imports/new"
    end

    def my_upcoming_page_surveys_path(upcoming_page)
      "/my/upcoming/#{ upcoming_page.slug }/surveys"
    end

    def my_upcoming_page_surveys_url(upcoming_page)
      "#{ root_url }my/upcoming/#{ upcoming_page.slug }/surveys"
    end

    def upcoming_page_message_url(upcoming_page_message, options = {})
      rest = options.blank? ? '' : "?#{ options.to_query }"
      identifier = upcoming_page_message.slug || upcoming_page_message.id
      "#{ root_url }upcoming/#{ upcoming_page_message.upcoming_page.slug }/messages/#{ identifier }#{ rest }"
    end

    def upcoming_page_survey_url(survey, options = {})
      rest = options.blank? ? '' : "?#{ options.to_query }"
      "#{ root_url }upcoming/#{ survey.upcoming_page.slug }/surveys/#{ survey.id }#{ rest }"
    end

    def apps_url(options = {})
      rest = options.blank? ? '' : "?#{ options.to_query }"
      "#{ root_url }apps#{ rest }"
    end

    def job_url(job, options = {})
      rest = options.blank? ? '' : "?#{ options.to_query }"
      "#{ root_url }jobs/#{ job.slug }#{ rest }"
    end

    def discussions_index_url(options = {})
      rest = options.blank? ? '' : "?#{ options.to_query }"
      "#{ root_url }discussions#{ rest }"
    end

    def stories_index_url(options = {})
      rest = options.blank? ? '' : "?#{ options.to_query }"
      "#{ root_url }stories#{ rest }"
    end

    def apps_url(options = {})
      rest = options.blank? ? '' : "?#{ options.to_query }"
      "#{ root_url }apps#{ rest }"
    end

    def topics_url(options = {})
      rest = options.blank? ? '' : "?#{ options.to_query }"
      "#{ root_url }topics#{ rest }"
    end

    def newsletter_index_url(options = {})
      rest = options.blank? ? '' : "?#{ options.to_query }"
      "#{ root_url }newsletter#{ rest }"
    end

    def collections_url(options = {})
      rest = options.blank? ? '' : "?#{ options.to_query }"
      "#{ root_url }collections#{ rest }"
    end

    def new_job_url
      "#{ root_url }jobs/new"
    end

    def edit_job_url(job)
      "#{ root_url }#{ edit_job_path(job)[1..-1] }"
    end

    def edit_job_path(job)
      "/jobs/#{ job.token }/edit"
    end

    def stories_category_url(category, options = {})
      rest = options.blank? ? '' : "?#{ options.to_query }"
      "#{ root_url }stories/category/#{ category }#{ rest }"
    end

    def my_upcoming_pages_url
      "#{ root_url }my/upcoming"
    end

    def promoted_products_path(options = {})
      rest = options.blank? ? '' : "?#{ options.to_query }"
      "promoted-products#{ rest }"
    end

    def promoted_products_url(options = {})
      "#{ root_url }#{ promoted_products_path(options) }"
    end

    def my_upcoming_page_subscriber_url(upcoming_page, subscriber)
      "#{ root_url }my/upcoming/#{ upcoming_page.slug }/subscribers/#{ subscriber.id }"
    end

    def ship_signup_url(options = {})
      rest = options.blank? ? '' : "?#{ options.to_query }"
      "#{ root_url }ship#{ rest }"
    end

    def ship_early_sub_url
      "#{ root_url }ship/promo/earlysub"
    end

    def ship_instant_access_page_path(ship_instant_access_page)
      "/ship/in/#{ ship_instant_access_page.slug }"
    end

    def my_upcoming_new_message_url(upcoming_page, subscriber)
      "#{ root_url }my/upcoming/#{ upcoming_page.slug }/messages/new?layout=personal&subscriberId=#{ subscriber.id }"
    end

    def my_settings_url(options = {})
      rest = options.blank? ? '' : "?#{ options.to_query }"
      "#{ root_url }my/settings/edit#{ rest }"
    end

    def social_twitter_url
      'https://twitter.com/ProductHunt'
    end

    def social_facebook_url
      'https://www.facebook.com/producthunt'
    end

    def embed_post_path(slug)
      "/posts/#{ slug }/embed"
    end

    def embed_upcoming_widget_path(slug)
      "/my/upcoming/#{ slug }/embed"
    end

    def help_center_article_url(slug, options = {})
      rest = options.blank? ? '' : "?#{ options.to_query }"
      "https://help.producthunt.com/en/articles/#{ slug }#{ rest }"
    end

    def blog_article_url(slug, options = {})
      rest = options.blank? ? '' : "?#{ options.to_query }"
      "https://blog.producthunt.com/#{ slug }#{ rest }"
    end

    def questions_path
      'questions'
    end

    def questions_url
      "#{ root_url }#{ questions_path }"
    end

    def question_path(question)
      "questions/#{ question.slug }"
    end

    def question_url(question)
      "#{ root_url }#{ question_path(question) }"
    end

    def my_products_path
      '/my/products'
    end

    def my_products_url
      "#{ root_url }#{ my_products_path }"
    end

    def post_launch_dashboard_path(post)
      "/posts/#{ post.slug }/launch-day"
    end

    def post_launch_dashboard_url(post)
      "#{ root_url }#{ post_launch_dashboard_path(post) }"
    end

    def review_path(review, options = {})
      if review.product.present?
        product_reviews_path(review.product, options.merge(review: review.id))
      else
        post_all_reviews_path(review.post, options.merge(review: review.id))
      end
    end

    def review_url(review, options = {})
      if review.product.present?
        product_reviews_url(review.product, options.merge(review: review.id))
      else
        post_all_reviews_url(review.post, options.merge(review: review.id))
      end
    end

    def product_alternatives_path(product)
      "/products/#{ product.slug }/alternatives"
    end

    def product_alternatives_url(product, tracking_params = nil)
      query = "?#{ tracking_params.to_query }" if tracking_params.present?
      "#{ root_url.chomp('/') }#{ product_alternatives_path(product) }#{ query }"
    end

    def product_addons_path(product)
      "/products/#{ product.slug }/addons"
    end

    def product_jobs_path(product)
      "/products/#{ product.slug }/jobs"
    end

    def product_makers_path(product)
      "/products/#{ product.slug }/makers"
    end

    def product_team_path(product)
      "/products/#{ product.slug }/team"
    end

    def maker_stories
      '/stories/category/maker-stories'
    end

    def top_post_badge(post, theme, period)
      "https://api.producthunt.com/widgets/embed-image/v1/top-post-badge.svg?post_id=#{ post.id }&theme=#{ theme }&period=#{ period }"
    end

    def top_post_topic_badge(post, theme, period, topic)
      "https://api.producthunt.com/widgets/embed-image/v1/top-post-topic-badge.svg?post_id=#{ post.id }&theme=#{ theme }&period=#{ period }&topic=#{ topic }"
    end

    def product_reviews_new_path(product)
      "/products/#{ product.slug }/reviews/new"
    end

    def team_invite_path(invite)
      "/team-invites/#{ invite.code }"
    end
  end
end
