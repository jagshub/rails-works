# frozen_string_literal: true

module ActiveAdmin::AdsHelper
  def budget_status_tag(budget)
    noneditable = 'non-editable status_tag'

    html = if budget.pending?
             content_tag :span, 'Pending', class: noneditable + ' pending'
           elsif budget.complete?
             content_tag :span, 'Complete', class: noneditable + ' complete'
           elsif budget.active?
             content_tag :span, 'Active', class: noneditable + ' yes'
           else
             content_tag :span, 'N/A', class: 'status_tag'
           end

    if budget.today_date == Time.zone.today.to_s && budget.today_cap_reached?
      html += tag :br
      html += content_tag :span, 'Daily cap reached', style: 'white-space: nowrap;', class: noneditable + ' complete'
    end

    html
  end
end
