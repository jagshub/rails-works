# frozen_string_literal: true

module Posts::LaunchDay::Reports::S3
  extend self

  BUCKET = :insights
  CONTENT_TYPE = 'application/pdf'
  UPLOAD_PATH = 'launch-day'

  # NOTE(DZ): PDF Only!
  def upload_and_save(post_id, file)
    key = generate_s3_key
    External::S3Api.put_object(
      bucket: BUCKET,
      key: key,
      body: file,
      content_type: CONTENT_TYPE,
    )

    Posts::LaunchDayReport.create!(
      post_id: post_id,
      s3_key: key,
    )
  rescue Aws::Errors::ServiceError => e
    ErrorReporting.report_error(e, post_id: post_id)

    nil
  end

  def download_url(report)
    External::S3Api.signed_url(
      bucket: BUCKET,
      key: report.s3_key,
      expires_in: 900,
    )
  end

  private

  def generate_s3_key
    uuid = External::S3Api.generate_key

    "#{ UPLOAD_PATH }/#{ uuid }.pdf"
  end
end
