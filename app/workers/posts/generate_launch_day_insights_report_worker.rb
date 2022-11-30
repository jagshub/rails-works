# frozen_string_literal: true

class Posts::GenerateLaunchDayInsightsReportWorker < ApplicationJob
  include ActiveJobHandleDeserializationError

  queue_as :long_running

  def perform(post_id)
    post = Post.find(post_id)

    report = Posts::LaunchDay::Reports::Processor.new(post)

    pdf = Posts::LaunchDay::Reports::Pdf.generate_pdf(report)

    Posts::LaunchDay::Reports::S3.upload_and_save(post.id, pdf)
  end
end
