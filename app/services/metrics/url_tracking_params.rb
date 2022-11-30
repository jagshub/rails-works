# frozen_string_literal: true

class Metrics::UrlTrackingParams
  class << self
    def call(url: nil, medium:, object: nil)
      params = params_for medium: medium, object: object

      return apply_params_to_url(url, params) if url.present?

      params
    end

    private

    def params_for(medium:, object:)
      case medium
      when :api
        api_params(object)
      when :email
        email_params(object)
      when :news
        news_params(object)
      when :rss
        rss_params(object)
      when :widget
        widget_params(object)
      when :browser_notification
        browser_notification_params(object)
      when :slack
        slack_notification_params(object)
      when :newsletter
        newsletter_params(object)
      when :external_angellist
        external_angellist_params(object)
      else
        raise ArgumentError, "Could not find medium #{ medium } for UrlTrackingParams"
      end
    end

    # NOTE(andreasklinger): strictly speaking we are using source and campaign wrong way around (or differently put campaign should be something more specific than source)
    #   To avoid any breaking changes we will just keep it for now until we are sure we want to change it.
    def api_params(application)
      utm_medium = application.blank? || application.legacy ? 'api' : 'api-v2'
      { utm_medium: utm_medium, utm_source: "Application: #{ application.try(:name) } (ID: #{ application.try(:id) })", utm_campaign: 'producthunt-api' }
    end

    def email_params(email_type)
      { utm_medium: 'email', utm_source: email_type, utm_campaign: 'email-notification' }
    end

    def rss_params(_object)
      { utm_medium: 'rss-feed', utm_source: 'producthunt-atom-posts-feed', utm_campaign: 'producthunt-atom-posts-feed' }
    end

    def widget_params(object)
      { utm_medium: 'widget', utm_source: "Widget: #{ object }", utm_campaign: 'producthunt-widget-api' }
    end

    def browser_notification_params(notification)
      { utm_medium: 'browser_notification', utm_source: "Browser Notification: #{ notification.kind }", utm_campaign: 'browser_notification' }
    end

    def slack_notification_params(notification)
      { utm_medium: 'slack', utm_source: "Slack Notification: #{ notification.kind } (#{ notification.subscriber&.user_id })", utm_campaign: 'slack' }
    end

    def newsletter_params(newsletter)
      { utm_medium: 'newsletter', utm_source: 'Daily Digest', utm_campaign: "#{ newsletter.id }_#{ newsletter.date }" }
    end

    def news_params(location)
      { utm_medium: 'web', utm_source: 'producthunt-news', utm_campaign: location }
    end

    def external_angellist_params(location)
      { utm_medium: 'web', utm_source: 'product_hunt', utm_campaign: location }
    end

    def apply_params_to_url(url, params)
      uri = URI.parse(url)
      uri.query = uri.query ? uri.query + '&' + params.to_query : params.to_query
      uri.to_s
    end
  end
end
