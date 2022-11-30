# frozen_string_literal: true

class Cron::Products::NewLaunchUpdate < ApplicationJob
  def perform
    return unless can_run?

    Rails.logger.info "Running new launch update mailer job for #{ Time.zone.today }"

    posts_to_run.each do |post|
      run_object = Products.new_launch_update_with_throttle(post)

      followers_to_notify(post).find_each do |user|
        run_object.send_email(user)
      end
    end
  end

  RECENT_SUBSCRIPTIONS = 48.hours
  def followers_to_notify(post)
    product = post.new_product
    return User.none if product.blank?

    # NOTE(DZ): followers already have active scope. Also prevent recent upvotes
    # from being notified
    product
      .followers
      .where.not(id: product.maker_ids)
      .where(Subscription.arel_table[:created_at].lteq(RECENT_SUBSCRIPTIONS.ago))
      .where.not(id: upcoming_event_followers(post))
  end

  def can_run?
    # NOTE(DZ): The job only runs at 10 PST everyday
    Time.now.in_time_zone.hour == 10 &&
      !Products::NewLaunchUpdateWithThrottle.run_today?
  end

  def posts_to_run
    Post.featured.visible.where_date_eq(:scheduled_at, Time.zone.today)
  end

  private

  def upcoming_event_followers(post)
    return [] unless post.upcoming_event

    # Note(DT): We filter out the post-product subscribers also following the upcoming_event of this post,
    # since the upcoming_event followers will be notified separately with a higher priority.
    post.upcoming_event.followers
  end
end
