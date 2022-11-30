# frozen_string_literal: true

module Notifications::Notifiers::MissedPostNotifier
  extend Notifications::Notifiers::BaseNotifier
  extend self

  def channels
    {
      browser_push: {
        priority: :mandatory,
        user_setting: :send_product_recommendation_browser_push,
      },
      mobile_push: {
        priority: :mandatory,
        user_setting: :send_product_recommendation_email,
      },
    }
  end

  def fan_out(object, kind:, user:)
    return if object.nil? || user.nil? || user.subscriber.nil?

    Notifications::ScheduleWorker.perform_later kind: kind, object: object, subscriber_id: user.subscriber.id
  end

  def push_text_heading(notification)
    pick_title_for(notification)
  end

  def push_text_body(notification)
    post = notification.notifyable
    BetterFormatter.strip_tags(post.tagline)
  end

  def push_text_oneliner(notification)
    post = notification.notifyable
    post.tagline
  end

  private

  # Note(TC): requires is the key(s) you expect from collect_adlibs to fill out
  # they are filled in the order they are required
  # EG. ":wave: Hey! did you see %s? It's a new %s product we found for you!", requires: [:name, :topic]
  # adlibs = {name: 'Zap', topic: 'Productivity'}
  # => :wave: Hey! did you see Zap? It's a new Productivity product we found for you!"
  TEMPLATES = [
    { requires: [:topic], text: '👋 Hey! did you catch this new %s product?' },
    { requires: %i(name topic), text: "👋 Hey! did you see %s? It's a new %s product we found for you!" },
    { requires: [:topic], text: 'ICYMI, a new %s product for you!' },
    { requires: [:name], text: "Did you check out %s? We think you'll like it!" },
    { requires: [:topic], text: 'Check out this new %s product we found!' },
    { requires: [:topic], text: 'While you were away, we spotted this neat %s product you might like' },
    { requires: [:topic], text: 'Whats that? A new %s product.. 👀' },
  ].freeze

  # Will search for user<->post topic intersection. Should no intersection
  # exist we just return a random topic the post is attached to.
  # and if the post has no topic, just leave the template empty
  # as the sentences are still readable without the topic present.
  def topic_intersection(post_topics, user_topics)
    return '' if post_topics.empty?

    topic_of_interest = post_topics.sample
    return topic_of_interest.name if user_topics.empty?

    matched_topic = post_topics.find { |pt| user_topics.map(&:id).include?(pt.id) }

    matched_topic.nil? ? topic_of_interest.name : matched_topic.name
  end

  # Note (TC): If a key is required once out of any TEMPLATES message, you
  # must always specify it here, as the message template is chosen at random and may
  # require that key.
  def collect_adlibs(notification)
    post = notification.notifyable
    user = notification.subscriber.user
    {
      name: post.name,
      topic: topic_intersection(post.topics, user.followed_topics),
    }
  end

  # Note (TC): This will create a title for the message, the :requires key
  # will then select all the correct message params and insert them into the string
  # as required by the string.
  def pick_title_for(notification)
    adlibs = collect_adlibs(notification)
    msg_settings = TEMPLATES.sample
    inputs = msg_settings[:requires].map { |arg| adlibs[arg] }

    format(msg_settings[:text], *inputs)
  end
end
