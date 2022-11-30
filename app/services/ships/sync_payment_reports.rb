# frozen_string_literal: true

class Ships::SyncPaymentReports
  attr_reader :start_date, :end_date

  BASE_URL = 'https://api.baremetrics.com/v1/metrics/net_revenue'

  def initialize(start_date = nil, end_date = nil)
    @start_date = start_date || 3.days.ago
    @end_date = end_date || Time.zone.now
  end

  def call
    reports = fetch_reports

    reports.each do |report|
      date = Time.zone.parse(report['human_date'])

      payment_report = ShipPaymentReport.find_or_initialize_by(date: date)
      payment_report.net_revenue = report['value']
      payment_report.save!
    end
  end

  private

  def fetch_reports
    params = {
      start_date: start_date.strftime('%Y-%m-%d'),
      end_date: end_date.strftime('%Y-%m-%d'),
    }

    response = RestClient.get(BASE_URL, params: params, Authorization: "Bearer #{ ENV['BAREMETRICS_API_KEY'] }")

    results = JSON.parse(response.body)

    raise results['error'] if results['error'].present?

    results['metrics']
  end
end
