# frozen_string_literal: true

module Ads::Fill
  extend self

  def interaction(interaction)
    ActiveRecord::Base.transaction do
      update_interaction_counter interaction
      update_budget_daily_cap interaction if interaction.budget.daily_cap?
      update_budget_counter interaction.channel.budget, "#{ interaction.kind }s_count"
    end
  end

  def newsletter(subject:, event:, request_info: {})
    ActiveRecord::Base.transaction do
      unless event == 'sent'
        Ads::NewsletterInteraction.create!(
          subject: subject,
          kind: event,
          **request_info.slice(:user_agent, :is_bot, :user_id, :ip_address, :visitor_id),
        )
      end

      increment_newsletter_counter(subject, event) unless request_info.fetch(:is_bot, false)
    end
  end

  def refresh_fill(channel)
    channel.update!(
      clicks_count: channel.interactions.click.size,
      closes_count: channel.interactions.close.size,
      impressions_count: channel.interactions.impression.size,
    )

    update_budget_counter channel.budget, 'impressions_count'
    update_budget_counter channel.budget, 'clicks_count'
    update_budget_counter channel.budget, 'closes_count'
  end

  private

  def budget_filled?(budget)
    return false unless budget.cpm?

    total_fill = budget.impressions_count * budget.unit_price / 1000
    total_fill >= budget.amount
  end

  def update_interaction_counter(interaction)
    Ads::Channel.increment_counter("#{ interaction.kind }s_count", interaction.channel_id, touch: true)
  end

  # NOTE(DZ): It's possible to reduce 2 queries by skipping the reads and just
  # directly increment specified counter, but will bring possible errors
  def update_budget_counter(budget, counter_name)
    channel_sum = budget.channels.send :sum, counter_name
    newsletter_counter =
      "#{ Ads::Newsletter::BUDGET_COUNTERS.key(counter_name) }s_count"
    newsletter_sum = budget.newsletter&.reload.try(newsletter_counter) || 0
    newsletter_sponsor_sum =
      budget.newsletter_sponsor&.reload.try(newsletter_counter) || 0

    budget.update_columns(
      counter_name => channel_sum + newsletter_sum + newsletter_sponsor_sum,
      updated_at: Time.current,
    )

    return unless budget_filled? budget

    Audited.audit_class.as_user('System') do
      budget.channels.update active: false
      budget.newsletter_sponsor.update active: false if budget.newsletter_sponsor.present?
      budget.newsletter.update active: false if budget.newsletter.present?
      budget.refresh_active_channels_count
      budget.campaign.refresh_active_budgets_count
    end
  end

  def update_budget_daily_cap(interaction)
    budget = interaction.budget
    today = Time.zone.today.to_s

    if budget.today_date != today
      # NOTE(rstankov): In race-condition we might loose couple of impressions when day starts
      budget.update_columns(
        today_date: today,
        today_impressions_count: 1,
        today_cap_reached: false,
        updated_at: Time.current,
      )
    elsif !interaction.budget.today_cap_reached?
      # NOTE(rstankov): SQL is used here to protect against race-conditions
      #
      #   If we do update only via Rails we will lose impressions on update.
      #
      #   Illustration of this issue:
      #
      #   worker1                              worker2
      #
      #   budget = find                        budget = find
      #   budget.impressions_count       # 1   budget.impressions_count       # 1
      #   budget.impressions_count += 1  # 2   budget.impressions_count += 1  # 2
      #   budget.save!                   # 2
      #                                       budget.save!                    # 2
      #
      #   Expected result: budget.impressions_count to be 3
      #   Actual result: budget.impressions_count is 2
      #
      Ads::Budget.where(id: budget.id).update_all <<-SQL
        today_impressions_count = today_impressions_count + 1,
        today_cap_reached = (today_impressions_count + 1)::float * unit_price / 1000 >= daily_cap_amount,
        updated_at = NOW()
      SQL
    end
  end

  def increment_newsletter_counter(subject, event)
    counter = "#{ event }s_count"
    subject.class.increment_counter counter, subject.id, touch: true

    budget_counter = Ads::Newsletter::BUDGET_COUNTERS[event]
    return if budget_counter.blank?

    update_budget_counter subject.budget, budget_counter
  end
end
