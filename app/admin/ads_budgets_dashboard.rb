# frozen_string_literal: true

# NOTE(DZ): This is a quick solution. This code is not tested / optimized.
# Do not use this as a data source for anything.
ActiveAdmin.register_page 'Active Budgets Dashboard' do
  menu label: 'Ads -> Active Budgets Dashboard', parent: 'Revenue'

  controller do
    def index
      budgets =
        Ads::Budget
        .includes(:campaign)
        .cpm
        .with_impressions
        .where.not(end_time: nil)
        .order(end_time: :desc)

      # NOTE(DZ): Current budgets are active, but can roll over into future
      # budgets
      @current_budgets = budgets.select do |b|
        b.start_time <= Time.current.end_of_month
      end

      # NOTE(DZ): Get monthly booked impressions day by day
      first_budget_day = Time.current.next_month.beginning_of_month.to_date
      last_budget_day = budgets.first.end_time.to_date
      total_days = (last_budget_day - first_budget_day).to_i
      future_budgets =
        budgets.select { |budget| budget.end_time >= Time.current.end_of_month }
      future_budget_daily_rates =
        future_budgets
        .map { |budget| [budget, budget.impressions / budget.number_of_days] }
        .to_h
      daily_booked_rate = 0.upto(total_days).map do |day|
        date = first_budget_day + day
        total_rate = future_budget_daily_rates.sum do |budget, rate|
          budget.end_time >= date && budget.start_time <= date ? rate : 0
        end
        [date, total_rate]
      end.to_h
      monthly_booked_rate =
        daily_booked_rate
        .group_by { |date, _rate| key_from_date(date) }
        .transform_values { |daily_rate| daily_rate.sum(&:last) }
      days_left_in_month =
        (Time.current.end_of_month.to_date - Time.current.to_date).to_i
      rollover_budgets = @current_budgets & future_budgets
      rollover_booked_impresssions = rollover_budgets.sum do |budget|
        days_left_in_month * budget.impressions / budget.number_of_days
      end

      # NOTE(DZ): Calculate summary values
      @total_booked = @current_budgets.sum(&:impressions)
      @total_filled_dollar = @current_budgets.sum(&:fill_dollar)
      @total_filled = @current_budgets.sum(&:impressions_count)

      # NOTE(DZ): Get historical values
      @historical_monthly_impressions = 1.upto(12).map do |months_ago|
        fetch_historical_month(months_ago.months.ago)
      end.to_h

      # NOTE(DZ): Calculate projections
      projected_monthly_impressions = calculate_projections(
        @historical_monthly_impressions,
        3.months.from_now,
      )

      # NOTE(DZ): Average of last three months + last year this month
      @est_monthly_impressions =
        projected_monthly_impressions[key_from_date(Time.current)]
      @est_daily_impressions =
        @est_monthly_impressions / Time.current.end_of_month.day
      @est_carryover_impressions =
        @total_booked - @total_filled - @est_monthly_impressions -
        rollover_booked_impresssions

      # NOTE(DZ): Drop first projection since it's the current month
      @projected_monthly_values =
        projected_monthly_impressions.drop(1).map do |date_key, projection|
          impressions = monthly_booked_rate[date_key] || 0
          [
            date_key,
            {
              impressions: impressions,
              projection: projection,
              carryover: impressions - projection,
            },
          ]
        end.to_h

      # NOTE(DZ): Calculate carry over
      carryover = [@est_carryover_impressions, 0].max
      @projected_monthly_values.inject(carryover) do |acc, (key, _)|
        values = @projected_monthly_values[key]
        values[:prev_month_carryover] = acc
        values[:capacity] = -(values[:carryover] + acc)

        [-values[:capacity], 0].max
      end
    end

    private

    # NOTE(DZ): Projections are average of previous 3 months + last year same
    # month
    def calculate_projections(historical_monthly_impressions, ending_month)
      month = Time.current.beginning_of_month
      projections = historical_monthly_impressions.dup

      while month <= ending_month
        month1 = month.prev_month
        month2 = month1.prev_month
        month3 = month2.prev_month
        month_last_year = month.last_year

        projections[key_from_date(month)] = (
          projections[key_from_date(month1)] +
          projections[key_from_date(month2)] +
          projections[key_from_date(month3)] +
          projections[key_from_date(month_last_year)]
        ) / 4

        month = month.next_month
      end

      projections.except(*historical_monthly_impressions.keys)
    end

    def fetch_historical_month(date)
      # NOTE(DZ): Current month is still being populated, don't cache
      key = key_from_date(date)
      if key == key_from_date(Time.current)
        fetch_impressions(date)
      else
        cache_key = "active_budgets_dashboard/historical-#{ key }"
        Rails.cache.fetch(cache_key) { fetch_impressions(date) }
      end
    end

    def fetch_impressions(date)
      arel_key = Ads::Interaction.arel_table[:created_at]
      start_date = date.beginning_of_month
      end_date = date.end_of_month

      impressions =
        Ads::Interaction
        .impression
        .where(arel_key.gteq(start_date))
        .where(arel_key.lt(end_date))
        .count

      [key_from_date(start_date), impressions]
    end

    def key_from_date(date)
      date.strftime('%Y-%m')
    end
  end

  content do
    div do
      h3 'Current Month Active Budgets'

      table do
        thead do
          tr do
            th 'Campaign'
            th 'Budget'
            th 'Amount ($)'
            th 'CPM'
            th 'Start date'
            th 'End date'
            th '# Days'
            th 'Booked / Day'
            th 'Remaining Days'
            th 'Remaining Impressions'
            th 'Booked'
            th 'Delivered'
            th '% Fill'
            th 'Clicks'
            th 'Days Live'
          end
        end

        tbody do
          current_budgets.each do |budget|
            tr do
              # Campaign
              td do
                link_to(
                  budget.campaign.name,
                  admin_campaign_path(budget.campaign),
                )
              end
              # Budget
              td { link_to budget.id, admin_budget_path(budget) }
              # Amount ($)
              td { number_to_currency(budget.amount) }
              # CPM
              td { number_to_currency(budget.unit_price) }
              # Start date
              td { budget.start_time.to_date }
              # End date
              td { budget.end_time.to_date }
              # # Days
              td { budget.number_of_days }
              # Impressions / Day (Target)
              td do
                number_with_delimiter(
                  budget.impressions / budget.number_of_days,
                  precision: 0, delimiter: ',',
                )
              end
              # Remaining Days
              td do
                now = Time.current.to_date
                eom = Time.current.end_of_month.to_date
                [(budget.end_time.to_date - now).to_i, (eom - now).to_i].min
              end
              # Remaining Impressions
              td do
                number_with_delimiter(
                  budget.impressions - budget.impressions_count,
                  precision: 0, delimiter: ',',
                )
              end
              # Booked
              td do
                number_with_delimiter(
                  budget.impressions,
                  precision: 0, delimiter: ',',
                )
              end
              # Delivered
              td do
                number_with_delimiter budget.impressions_count, delimiter: ','
              end
              # % Fill
              td { number_to_percentage budget.fill, precision: 1 }
              # Clicks
              td { number_with_delimiter budget.clicks_count, delimiter: ',' }
              # Days live
              td { ((Time.zone.now - budget.start_time) / 1.day).round }
            end
          end
        end
      end
    end

    div do
      h3 'Projections and Future Budgets'
      table do
        thead do
          tr do
            th 'Month'
            th 'Projected Impressions'
            th 'Booked'
            th 'Prev. Month Carry Over'
            th 'Projected Carry Over'
            th 'Total Capacity'
          end
        end

        tbody do
          projected_monthly_values.each do |month, values|
            tr do
              # Month
              td { month }
              # Projected Impressions
              td { number_with_delimiter values[:projection], delimiter: ',' }
              # Booked
              td { number_with_delimiter values[:impressions], delimiter: ',' }
              # Prev. Month Carry Over
              td do
                number_with_delimiter(
                  values[:prev_month_carryover],
                  delimiter: ',',
                )
              end
              # Projected Carry Over
              td { number_with_delimiter values[:carryover], delimiter: ',' }
              # Total Capacity
              td { number_with_delimiter values[:capacity], delimiter: ',' }
            end
          end
        end
      end
    end
  end

  sidebar 'Current Month Active Budgets Summary' do
    table do
      tr do
        td { strong 'Total Budget Booked' }
        td do
          number_to_currency(
            current_budgets.sum(&:amount),
            delimiter: ',',
            precision: 2,
          )
        end
      end
      tr do
        td { strong 'Total Budget Delivered' }
        td do
          number_to_currency total_filled_dollar, delimiter: ',', precision: 2
        end
      end
      tr do
        td { strong 'Impressions Booked (r)' }
        td { number_with_precision total_booked, delimiter: ',', precision: 0 }
      end
      tr do
        td { strong 'Impressions Delivered' }
        td { number_with_delimiter total_filled, delimiter: ',' }
      end
      tr do
        td { strong 'Percent to complete' }
        td do
          number_to_percentage(
            total_filled * 100 / [total_booked, 1].max,
            precision: 1,
          )
        end
      end
    end
  end

  sidebar 'Current Month Projections' do
    table do
      tr do
        td { strong '(Est.) Impressions Available' }
        td { number_with_delimiter est_monthly_impressions, delimiter: ',' }
      end
      tr do
        td { strong '(Est.) Daily Rate' }
        td { number_with_delimiter est_daily_impressions, delimiter: ',' }
      end
      tr do
        td { strong '(Est.) Carry Over' }
        td { number_with_delimiter est_carryover_impressions, delimiter: ',' }
      end
    end
  end

  sidebar 'Historical Monthly' do
    table do
      historical_monthly_impressions.each do |date, count|
        tr do
          td { strong date }
          td { number_with_delimiter count, delimiter: ',' }
        end
      end
    end
  end
end
