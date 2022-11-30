# frozen_string_literal: true

class Iterable::PostLaunchedEventWorker < ApplicationJob
  def perform
    start_time = Redis.current.get('iterable:post_launched_event_worker:last_run_time')&.to_datetime
    start_time = 1.hour.ago if start_time.blank?

    current_time = DateTime.current

    posts = Post.where('scheduled_at BETWEEN ? AND ?', start_time, current_time)

    Redis.current.set('iterable:post_launched_event_worker:last_run_time', current_time)

    posts.each do |post|
      next if (post.created_at - post.scheduled_at).abs < 10.minutes # Note(Bharat): if diff is < 10 minutes means, the post was launched immediately and was not scheduled to launch on a later time.

      product = Product.find_by(id: post.product_id) if post.product_id.present?

      data_fields = {
        launch_name: post.name,
        tagline: post.tagline,
        product_name: product&.name,
        launch_scheduled_at: post.scheduled_at.strftime('%Y-%m-%d %H:%M:%S %:z'),
        scheduled_date: post.scheduled_at&.strftime('%d/%m/%Y'),
        scheduled_time: post.scheduled_at&.strftime('%H:%M:%S'),
        is_first_product_of_user: post.user.products&.count == 1,
        thumbnail_image_url: Image::BASE_URL + '/' + post.thumbnail_image_uuid,
        primary_link: post.primary_link&.url,
        post_slug: post.slug,
      }

      Iterable.trigger_event('post_launched', email: post.user.email, user_id: post.user.id, data_fields: data_fields)
    end
  end
end
