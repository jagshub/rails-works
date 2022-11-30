# frozen_string_literal: true

module Newsletters
  class RescheduleDeliveryWorker < ApplicationJob
    include ActiveJobHandleMailjetErrors

    JOBS_IN_NEWSLETTER_QUEUE = 10

    def perform(newsletter)
      return retry_job(wait: 30.minutes) if newsletter_delivery_in_progress? || fan_out?(newsletter)

      mailjet_delivered_count = Metrics::Newsletter::Stats.retrieve_delivered_count(newsletter)
      subscribers = Subscriber.with_newsletter_subscription(newsletter.subscription_kind).with_email_confirmed.count

      reschedule_delivery(newsletter, mailjet_delivered_count, subscribers) if (subscribers - mailjet_delivered_count.to_i) > 50_000
    end

    private

    def newsletter_delivery_in_progress?
      Sidekiq::Queue.new('newsletters').size > JOBS_IN_NEWSLETTER_QUEUE
    end

    def fan_out?(newsletter)
      newsletter_gid = { 'aj_globalid' => newsletter.to_global_id.to_s }

      Sidekiq::Workers.new.each do |_process_id, _thread_id, work|
        payload = work['payload']

        next unless payload['wrapped'] == Notifications::FanOutWorker.name

        argument = payload['args'][0]['arguments'].first

        return true if argument['object'] == newsletter_gid && argument['kind'] == 'newsletter'
      end

      false
    end

    def reschedule_delivery(newsletter, delivered, subscribers)
      SlackNotify.call(
        channel: :engineering,
        text: "Product Hunt: Newsletter #{ newsletter.id } (#{ newsletter.subject }) failed! Stats - Subscribers: #{ subscribers }, Delivered: #{ delivered }. Rescheduling",
      )

      Newsletter::Send.start_delivery(newsletter)
    end
  end
end
