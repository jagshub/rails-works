# frozen_string_literal: true

# NOTE(vesln): If you want to use paths that are in the frontend app's routes.js file, you can
# specify them here.
module Routes
  module FrontendPaths
    def self.register(path, as:)
      define_method("#{ as }_url") do |*options|
        "#{ root_url }#{ build_url(path, options) }"
      end

      define_method("#{ as }_path") do |*options|
        "/#{ build_url(path, options) }"
      end
    end

    def build_url(path, options)
      parts = path.split('/').map do |part|
        if part.include?(':')
          prefix, part = part.split(':')

          option = options.shift

          if option.is_a?(Hash)
            "#{ prefix }#{ option.fetch(part.to_sym) }"
          elsif option.is_a?(String) || option.is_a?(Numeric)
            "#{ prefix }#{ option }"
          else
            "#{ prefix }#{ option.public_send(part.to_sym) }"
          end
        else
          part
        end
      end

      url = parts.join('/')
      url << "?#{ options.first.to_query }" if options.any? && options.first.is_a?(Hash) && options.first.any?
      url
    end

    register '@:username/activity', as: 'profile_activity'
    register '@:username/badges', as: 'profile_badges'
    register '@:username/collections', as: 'profile_collections'
    register '@:username/collections/:slug', as: 'profile_collection'
    register '404', as: 'not_found'
    register 'about', as: 'about'
    register 'activity_feed', as: 'activity_feed'
    register 'apps', as: 'apps'
    register 'apps/slack/failure', as: 'landing_slack_failure'
    register 'apps/slack/success', as: 'landing_slack_success'
    register 'branding', as: 'branding'
    register 'changes', as: 'change_logs'
    register 'changes/:slug', as: 'change_log'
    register 'collections', as: 'collections'
    register 'collections/:slug', as: 'featured_collection'
    register 'coming-soon', as: 'coming_soon'
    register 'copyright-dispute', as: 'copyright_dispute'
    register 'date', as: 'archive'
    register 'dev/markdown', as: 'dev_markdown'
    register 'dev/styleguide', as: 'dev_styleguide'
    register 'digest/:key', as: 'email_digest'
    register 'discussions', as: 'discussions'
    register 'discussions/:slug/edit', as: 'edit_discussion'
    register 'discussions/new', as: 'new_discussion'
    register 'duplicate-account', as: 'duplicate_account'
    register 'collections/:slug', as: 'official_collection'
    register 'faq', as: 'faq'
    register 'friends', as: 'friends'
    register 'giveaway', as: 'disrupt'
    register 'jobs', as: 'jobs'
    register 'jobs/:slug', as: 'job'
    register 'jobs/new', as: 'new_job'
    register 'jobs/new/discount/:slug', as: 'jobs_discount_page'
    register 'login', as: 'login'
    register 'makers', as: 'makers'
    register 'makers/:to_param', as: 'maker_group'
    register 'makers/:to_param/members', as: 'maker_group_members'
    register 'makers/:to_param/welcome', as: 'maker_group_welcome'
    register 'makers-festival/:slug', as: 'makers_festival'
    register 'makers-festival/:slug/voting', as: 'makers_festival_voting'
    register 'my/profile', as: 'my_profile'
    register 'my/profile/collections', as: 'my_profile_collections'
    register 'my/collections/:id/edit', as: 'edit_my_collection'
    register 'my/confirm', as: 'my_confirm_email'
    register 'my/founder-club', as: 'my_founder_club_claims'
    register 'my/founder-club/invitations', as: 'my_founder_club_invitations'
    register 'my/invites', as: 'my_invites'
    register 'my/moderation', as: 'moderation_queue'
    register 'my/moderation/other-flags', as: 'other_moderation_flags'
    register 'my/moderation/urgent-flags', as: 'urgent_moderation_flags'
    register 'my/moderation/team-claims', as: 'moderation_team_claims'
    register 'my/settings/edit', as: 'edit_my_settings'
    register 'my/details/edit', as: 'edit_my_details'
    register 'my/upcoming', as: 'my_upcoming_pages'
    register 'my/upcoming/:slug/surveys', as: 'my_upcoming_page_surveys'
    register 'my/upcoming/:slug/surveys/new', as: 'new_my_upcoming_page_survey'
    register 'my/upcoming/:slug/messages/:id', as: 'my_upcoming_page_message'
    register 'my/upcoming/:slug/messages/new', as: 'new_my_upcoming_page_message'
    register 'my/upcoming/:slug/slack', as: 'my_upcoming_page_slack'
    register 'my/upcoming/:slug/subscribers', as: 'my_upcoming_page_subscribers'
    register 'my/ship/surveys/:survey_id/subscriber/:id', as: 'my_ship_survey_answer'
    register 'my/ship/contacts/:id', as: 'my_ship_contact'
    register 'my/ship/plans', as: 'my_ship_plans'
    register 'my/ship/trial-expired', as: 'my_ship_trial_expired'
    register 'my/unsubscribe', as: 'my_unsubscribe'
    register 'my/subscriptions/founder-club', as: 'my_subscriptions_founder_club'
    register 'my/subscriptions/products', as: 'my_subscriptions_products'
    register 'my/subscriptions/ship', as: 'my_subscriptions_ship'
    register 'my/subscriptions/jobs', as: 'my_subscriptions_jobs'
    register 'my/multi_factor_token', as: 'my_multi_factor_token'
    register 'newest', as: 'newest'
    register 'newsletter', as: 'newsletters'
    register 'newsletter/:slug', as: 'newsletter'
    register 'notifications', as: 'notifications_page'
    register 'posts/new', as: 'new_post_submission'
    register 'posts/:slug', as: 'slug_post'
    register 'posts/:slug/edit', as: 'edit_post_submission'
    register 'posts/:id/comments', as: 'post_comments'
    register 'posts/:slug/reviews', as: 'post_all_reviews'
    register 'posts/:slug/reviews/:id', as: 'post_reviews'
    register 'posts/:slug/reviews/:id/edit', as: 'edit_post_review'
    register 'posts/:slug/maker-invite', as: 'post_maker_invite'
    register 'posts/:slug/embed', as: 'post_embed'
    register 'posts/:slug/launch-day', as: 'post_launch_dashboard'
    register 'privacy', as: 'privacy'
    register 'products', as: 'products'
    register 'products/:slug', as: 'product'
    register 'products/:slug/edit', as: 'edit_product'
    register 'products/:slug/team', as: 'product_team'
    register 'products/:slug/addons', as: 'product_addons'
    register 'products/:slug/alternatives', as: 'product_alternatives'
    register 'products/:slug/embed', as: 'product_embed'
    register 'products/:slug/jobs', as: 'product_jobs'
    register 'products/:slug/makers', as: 'product_makers'
    register 'products/:slug/reviews', as: 'product_reviews'
    register 'products/:slug/reviews/new', as: 'new_product_review'
    register 'products/:slug/reviews/:id/edit', as: 'edit_product_review'
    register 'promoted-products', as: 'landing_promoted_products'
    register 'protips', as: 'protips'
    register 'radio', as: 'radio'
    register 'search', as: 'search'
    register 'search/launches', as: 'search_launches'
    register 'search/users', as: 'search_users'
    register 'ship', as: 'ship'
    register 'ship/in/:slug', as: 'ship_instant_access_page'
    register 'ship/signup/details', as: 'ship_signup_details'
    register 'ship/surveys/:id', as: 'upcoming_page_survey'
    register 'submit/:id', as: 'submit'
    register 'team-invites/:code', as: 'team_invite'
    register 'team-requests/:token', as: 'team_request'
    register 'test/cards', as: 'test_cards'
    register 'thenextbillion', as: 'next_billion_giveaway'
    register 'topics', as: 'topics'
    register 'topics/:slug', as: 'topic'
    register 'tos', as: 'tos'
    register 'upcoming', as: 'upcoming_pages'
    register 'upcoming/:slug', as: 'upcoming'
    register 'upcoming/:slug/c/content', as: 'edit_my_upcoming_page'
    register 'upcoming/:slug/c/team', as: 'my_upcoming_page_team_members'
    register 'upcoming/:slug/c/design', as: 'my_upcoming_page_team_design'
    register 'voteplz', as: 'voteplz'
    register 'my/welcome', as: 'welcome_onboarding'
    register ':year/shoutouts/:id', as: 'shoutout'
    register 'stories', as: 'stories'
    register 'stories/new', as: 'new_story'
    register 'stories/:slug/edit', as: 'edit_story'
    register 'stories/:slug', as: 'show_story'
    register 'stories/category/:slug', as: 'stories_category'
    register 'founder-club', as: 'founder_club'
    register 'founder-club/benefits', as: 'founder_club_benefits'
    register 'advertising', as: 'advertising'
    register 'golden-kitty-awards', as: 'golden_kitty_awards'
    register 'golden-kitty-awards-:year', as: 'golden_kitty_edition'
    register 'golden-kitty-awards-:year/:slug', as: 'golden_kitty_category'
    register 'launch', as: 'launch_guide'
    register 'sponsor', as: 'sponsor'
  end
end
