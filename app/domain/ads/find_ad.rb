# frozen_string_literal: true

module Ads::FindAd
  extend self
  include NewRelic::Agent::MethodTracer

  def call(kind:, bundles:, application: 'all_apps', exclude_ids: [])
    channel = active_ads.where(kind: kind).by_priority

    channel = channel.with_bundles(bundles) if bundles.present?
    channel = channel.where.not(id: exclude_ids) if exclude_ids.any?
    channel = channel.with_application(application) if application != 'all_apps'

    channel = channel.first

    return if channel.blank?

    Ads::Ad.new(channel)
  end
  add_method_tracer :call, 'Ads::FindAd/call'

  def active_ads
    # NOTE(rstankov): We don't use `Ads::Budget.active` it ads extra condition, which we don't need `active = true`
    #   It was valid when we support timed queries
    Ads::Channel
      .active
      .joins(:budget).merge(Ads::Budget.where(Ads::Budget.arel_table[:start_time].lteq(Time.current)))
      .where('? BETWEEN ads_budgets.active_start_hour AND ads_budgets.active_end_hour', Time.current.hour)
      .where('ads_budgets.today_date != ? OR NOT ads_budgets.today_cap_reached', Time.zone.today.to_s)
  end
end
