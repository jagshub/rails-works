# frozen_string_literal: true

class Posts::LaunchReport
  attr_reader :post, :summary

  HEADERS = %w(
    employment_title
    employment_seniority
    gender
    geo_country
  ).freeze

  def initialize(post)
    @post = post
  end

  def summary
    @summary ||= HEADERS.map do |data_key|
      grouped_data = raw_data.group_by { |d| d[data_key] }
      data_rows = grouped_data.map do |data_value, profiles|
        [
          data_value.presence || 'Unknown',
          profiles.length,
        ]
      end
      sorted_rows = data_rows.sort_by { |row| row[1] }.reverse

      if sorted_rows.length > 4
        top_4 = sorted_rows.slice(0, 4)
        rest = sorted_rows[4..-1].inject(0) { |sum, v| sum + v[1] }
        [data_key, top_4 + [['Other', rest]]]
      else
        [data_key, sorted_rows]
      end
    end.to_h
  end

  def as_csv_data
    [
      CSV.generate do |csv|
        csv << HEADERS
        raw_data.each do |datum|
          csv << HEADERS.map { |header| datum[header].presence || 'Unknown' }
        end
      end,
      type: 'text/csv',
      disposition: disposition('attachment; filename=voters_%s_%s.csv'),
    ]
  end

  def as_email_csv_data
    [
      CSV.generate do |csv|
        csv << %w(emails)
        emails.each do |email_row|
          csv << [email_row.email]
        end
      end,
      type: 'text/csv',
      disposition: disposition('attachment; filename=emails_%s_%s.csv'),
    ]
  end

  private

  def disposition(template)
    format(template, post.slug, DateTime.now.in_time_zone.to_s)
  end

  def emails
    @emails ||=
      post
      .votes
      .credible
      .joins(user: :subscriber)
      .where.not(users: { notifications_subscribers: { email: nil } })
      .select(:email)
  end

  def raw_data
    @raw_data ||= Clearbit::PersonProfile.where(email: emails).map do |profile|
      profile.slice(*HEADERS)
    end
  end
end
