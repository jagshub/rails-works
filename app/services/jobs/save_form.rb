# frozen_string_literal: true

class Jobs::SaveForm
  include MiniForm::Model

  ATTRIBUTES = %i(
    company_name
    company_tagline
    image_uuid
    job_title
    locations_csv
    categories
    url
    remote_ok
    email
  ).freeze

  model :job, attributes: ATTRIBUTES, save: true

  validates :email, presence: true, email_format: true

  attributes :discount_page_slug

  alias node job
  alias graphql_result job

  def initialize(job)
    @job = job
  end

  def discount_page_slug=(value)
    @job.discount_page = Jobs::DiscountPage.find_by(slug: value) if @job.new_record?
  end

  def discount_page_slug
    @job.discount_page&.slug
  end
end
