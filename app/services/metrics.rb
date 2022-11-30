# frozen_string_literal: true

module Metrics
  extend self

  def track_create(user:, type:, options: {})
    track_action(user: user, action: 'create', options: options.merge(type: type))
  end

  def track_create_comment(comment)
    track_create(
      user: comment.user,
      type: 'comment',
      options: {
        post: comment.subject.name,
        post_id: comment.subject.id,
        nested: comment.parent_comment_id?,
      },
    )
  end

  def track_signin(user:, options: {})
    track_action_later(interval: 10.minutes, user: user, action: 'signin', options: options)
  end

  def track_click_through(post:, user:, track_code:, remote_ip:, via_application_id:)
    HandleRedisErrors.call do
      Metrics::TrackClickThroughWorker.perform_later(post, user, track_code, remote_ip, via_application_id)
    end
  end

  def track_action(user:, action:, options: {})
    Metrics::Worker.perform_later(distinct_id: distinct_id(user),
                                  action: action,
                                  params: properties(user, options))
  end

  def track_action_later(interval:, user:, action:, options: {})
    options.reverse_merge!(time: Time.current.utc.to_i)
    Metrics::Worker.set(wait: interval).perform_later(distinct_id: distinct_id(user),
                                                      action: action,
                                                      params: properties(user, options))
  end

  def super_properties(user)
    {
      created_at: user.created_at.to_i,
      email: user.email,
      name: "#{ user.name } (@#{ user.username })",
      user_id: user.id.to_s,
      username: user.username,
    }.as_json.with_indifferent_access
  end

  def url_tracking_params(url: nil, medium: nil, object: nil)
    Metrics::UrlTrackingParams.call(url: url, medium: medium, object: object)
  end

  private

  def properties(user, options)
    super_properties(user).merge(options)
  end

  def distinct_id(user)
    user.id.to_s
  end
end
