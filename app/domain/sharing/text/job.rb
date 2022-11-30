# frozen_string_literal: true

module Sharing::Text
  module Job
    def self.call(job)
      Twitter::Message
        .new
        .add_mandatory(tweet_text(job))
        .add_mandatory(Routes.job_url(job))
        .to_s
    end

    def self.tweet_text(job)
      "#{ job.company_name.strip } is hiring " \
        "#{ article_for(job.job_title) } #{ job.job_title } " \
        "(#{ job.locations.join(', ') }) " \
        "#{ tweet_hashtags(job) }"
    end

    def self.tweet_hashtags(job)
      ['#job', job.remote_ok ? '#Remote' : nil].reject(&:blank?).join(' ')
    end

    def self.article_for(word)
      %w(a e i o u).include?(word[0].downcase) ? 'an' : 'a'
    end
  end
end
