# frozen_string_literal: true

module Jobs
  class DigestPresenter
    attr_reader :subscriber, :lookback_period, :standard_job_limit, :featured_job_limit
    delegate :email, to: :subscriber

    def initialize(subscriber, lookback_period: 1.week.ago, standard_job_limit: 10, featured_job_limit: 2)
      @subscriber = subscriber
      @lookback_period = lookback_period
      @standard_job_limit = standard_job_limit
      @featured_job_limit = featured_job_limit
    end

    def featured_jobs
      @featured_jobs ||= Job.published.inhouse.featured_in_job_digest.reverse_chronological.limit(featured_job_limit)
    end

    def standard_jobs
      return @standard_jobs if @standard_jobs.present?

      published_last_week = Job.published
                               .inhouse
                               .between_dates(lookback_period, Time.zone.now)
                               .where.not(id: featured_jobs.pluck(:id))
                               .reverse_chronological

      jobs_needed = standard_job_limit - published_last_week.count

      @standard_jobs = published_last_week.to_a

      return @standard_jobs if jobs_needed <= 0

      other = Job.published
                 .inhouse
                 .where.not(id: published_last_week.pluck(:id))
                 .where.not(id: featured_jobs.pluck(:id))
                 .reverse_chronological
                 .limit(jobs_needed)

      @standard_jobs += other.to_a
    end

    def tracking_params
      @tracking_params ||= {
        utm_campaign: "jobs-digest-#{ Date.current.to_s(:db) }",
        utm_medium: 'email',
      }
    end
  end
end
