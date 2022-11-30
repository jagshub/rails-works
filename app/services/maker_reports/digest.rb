# frozen_string_literal: true

module MakerReports
  class Digest
    MIN_ACTIVITIES_TO_SEND = 5

    def deliver(posts_created_before: 1.week.ago.end_of_day, activity_created_after: 1.week.ago.beginning_of_day, activity_created_before: Time.zone.now)
      posts = MakerReports::RecentlyUpdatedPost.call(
        posts_created_before: posts_created_before,
        activity_created_after: activity_created_after,
        activity_created_before: activity_created_before,
      )

      total = 0

      posts.find_each do |post|
        last_report = post.maker_reports.reverse_chronological.first

        post.makers.find_each do |user|
          next unless user.send_maker_report_email
          next if user.email.blank?

          begin
            report = MakerReport.new(
              user: user,
              post: post,
              activity_created_after: last_report&.activity_created_before || activity_created_after,
              activity_created_before: activity_created_before,
            )

            next if MakerReports::RecentlyUpdatedPost.new(report).activity_count < MIN_ACTIVITIES_TO_SEND

            report.save!
            total += 1

            MakerReports::DigestWorker.perform_later(report)
          rescue StandardError => e
            ErrorReporting.report_error(e)
          end
        end
      end

      total
    end
  end
end
