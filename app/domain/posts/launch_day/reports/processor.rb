# frozen_string_literal: true

class Posts::LaunchDay::Reports::Processor
  attr_accessor :post

  TRUNCATE_AT = 10
  # NOTE(DZ): This represents the index inside each data tuple
  PROFILES = 1
  COMPANIES = 2

  def initialize(post)
    @post = post
  end

  def data
    @data ||= {
      user_country: aggregate_on(:geo_country, PROFILES),
      user_employment_role: aggregate_on(:employment_role, PROFILES),
      company_sector: aggregate_on(:category_sector, COMPANIES),
      company_industry: aggregate_on(:category_industry, COMPANIES),
      company_sub_industry: aggregate_on(:category_sub_industry, COMPANIES),
      company_hq_location: aggregate_on(:geo_country, COMPANIES),
      company_employees_range:
        aggregate_on(:metrics_employees_range, COMPANIES),
      company_estimated_annual_revenue:
        aggregate_on(:metrics_estimated_annual_revenue, COMPANIES),
      company_year_founded: aggregate_on(:founded_year, COMPANIES),

      # TODO(DZ): Add fill rate to record of report
      fill_rate: (voters_tuple[0] + clickers_tuple[0] + viewers_tuple[0]) / 3,
    }
  end

  private

  def aggregate_on(key, idx)
    viewers = viewers_tuple[idx]
    voters = voters_tuple[idx]
    clickers = clickers_tuple[idx]
    # NOTE(DZ): Viewers act as the top level sort order for rest of the data
    categories = categorize(viewers, key)

    {
      categories: categories,
      votes: normalize(voters, categories, key),
      clicks: normalize(clickers, categories, key),
      views: normalize(viewers, categories, key),
    }
  end

  def categorize(profiles, key)
    counts =
      profiles
      .where.not(key => nil)
      .group(key)
      .order(count: :desc)
      .count

    counts.first(TRUNCATE_AT).map(&:first)
  end

  def normalize(profiles, categories, key)
    counts = profiles.where.not(key => nil).group(key).count
    total = profiles.count
    return Array.new(categories.size) { 0 } if total.zero?

    categories.map do |category|
      ((counts[category] || 0) * 100.0 / total).round(2)
    end
  end

  def voters_tuple
    @voters_tuple ||= begin
      emails =
        Subscriber
        .joins(user: :votes)
        .merge(post.votes.joins(:user).credible)
        .where.not(email: nil)
        .select(:email)

      data_tuple(emails)
    end
  end

  def clickers_tuple
    @clickers_tuple ||= begin
      emails =
        Subscriber
        .joins(user: :link_trackers)
        .merge(post.link_trackers)
        .where.not(email: nil)
        .select(:email)

      data_tuple(emails)
    end
  end

  def viewers_tuple
    @viewers_tuple ||= begin
      user_ids = fetch_viewer_user_ids.to_a.pluck('user_id')

      emails =
        Subscriber
        .where(user_id: user_ids)
        .where.not(email: nil)
        .select(:email)

      data_tuple(emails)
    end
  end

  def data_tuple(emails)
    profiles = Clearbit::PersonProfile.where(email: emails)
    companies = Clearbit::CompanyProfile.joins(:people).merge(profiles)
    fill_rate = emails.empty? ? 0 : profiles.count * 1.0 / emails.count

    [fill_rate, profiles, companies]
  end

  def fetch_viewer_user_ids
    Redshift::Base.connection.execute <<-SQL
      SELECT DISTINCT(user_id)
      FROM producthunt_production.pages
      WHERE path = '#{ Routes.post_path(post) }'
      AND user_id IS NOT NULL
    SQL
  end
end
