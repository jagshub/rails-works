# frozen_string_literal: true

# == Schema Information
#
# Table name: jobs
#
#  id                     :integer          not null, primary key
#  image_uuid             :text             not null
#  company_name           :text             not null
#  job_title              :text             not null
#  url                    :text             not null
#  published              :boolean          default(FALSE), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  remote_ok              :boolean          default(FALSE), not null
#  data                   :jsonb            not null
#  company_jobs_url       :string
#  company_tagline        :string
#  job_type               :string
#  external_id            :integer
#  external_created_at    :datetime
#  kind                   :integer          default("inhouse"), not null
#  slug                   :string
#  token                  :string
#  user_id                :integer
#  stripe_customer_id     :string
#  stripe_billing_email   :string
#  stripe_subscription_id :string
#  cancelled_at           :datetime
#  email                  :string
#  jobs_discount_page_id  :integer
#  billing_cycle_anchor   :datetime
#  trashed_at             :datetime
#  renew_notice_sent_at   :datetime
#  extra_packages         :string           is an Array
#  last_payment_at        :datetime
#  extra_package_flags    :jsonb
#  product_id             :bigint(8)
#
# Indexes
#
#  index_jobs_on_email                  (email)
#  index_jobs_on_external_created_at    (external_created_at)
#  index_jobs_on_jobs_discount_page_id  (jobs_discount_page_id)
#  index_jobs_on_kind                   (kind)
#  index_jobs_on_product_id             (product_id)
#  index_jobs_on_published              (published)
#  index_jobs_on_slug                   (slug) UNIQUE
#  index_jobs_on_stripe_billing_email   (stripe_billing_email) WHERE ((stripe_subscription_id IS NOT NULL) AND (cancelled_at IS NULL))
#  index_jobs_on_stripe_customer_id     (stripe_customer_id)
#  index_jobs_on_token                  (token) UNIQUE
#  index_jobs_on_trashed_at             (trashed_at) WHERE (trashed_at IS NULL)
#  index_jobs_on_user_id                (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (jobs_discount_page_id => jobs_discount_pages.id)
#  fk_rails_...  (product_id => products.id) ON DELETE => nullify
#  fk_rails_...  (user_id => users.id)
#

class Job < ApplicationRecord
  include Uploadable
  include RandomOrder
  include Storext.model
  include Sluggable
  include Trashable

  # Note(andreasklinger): see monkey_patches/jsonb_monkey_patch.rb
  include JsonbTypeMonkeyPatch[:data]

  HasUniqueCode.define self, field_name: :token, length: 22

  uploadable :image
  sluggable candidate: :slug_to_generate

  belongs_to :user, optional: true
  belongs_to :product, inverse_of: :jobs, optional: true
  belongs_to :discount_page, class_name: 'Jobs::DiscountPage', foreign_key: 'jobs_discount_page_id', inverse_of: :jobs, counter_cache: true, optional: true

  # Limited lengths to prevent the slug from going over the character limit.
  validates :company_name, presence: true, length: { maximum: 80 }
  validates :job_title, presence: true, length: { maximum: 160 }

  extension HasWebsiteUrl, column: :company_jobs_url, allow_blank: true
  extension HasWebsiteUrl, column: :url, allow_blank: false

  validates :token, uniqueness: true, presence: true
  validates :image_uuid, presence: true

  validates :email, email_format: true, allow_nil: true

  store_attributes :data do
    locations Array[String], default: []
    categories Array[String], default: []
    roles Array[String], default: []
    skills Array[String], default: []
    currency_code String, default: 'USD'
    salary_min Integer
    salary_max Integer
    description String
  end

  store_attributes :extra_package_flags do
    feature_homepage Boolean, default: false
    feature_job_digest Boolean, default: false

    # NOTE(DZ): Deprecated store attributes. This data still exists in db.
    feature_newsletter Boolean, default: false
  end

  ransacker :feature_homepage do |parent|
    Arel::Nodes::InfixOperation.new('->>', parent.table[:extra_package_flags], Arel::Nodes.build_quoted('feature_homepage'))
  end

  ransacker :feature_job_digest do |parent|
    Arel::Nodes::InfixOperation.new('->>', parent.table[:extra_package_flags], Arel::Nodes.build_quoted('feature_job_digest'))
  end

  ransacker :feature_newsletter do |parent|
    Arel::Nodes::InfixOperation.new('->>', parent.table[:extra_package_flags], Arel::Nodes.build_quoted('feature_newsletter'))
  end

  enum kind: { inhouse: 0, angellist: 10 }

  scope :published, -> { not_trashed.where(published: true) }
  scope :featured_in_job_digest, -> { where("extra_package_flags->>'feature_job_digest' = 'true'") }
  scope :featured_in_homepage, -> { where("extra_package_flags->>'feature_homepage' = 'true'") }
  scope :featured_in_homepage_order, -> { order(Arel.sql("CASE WHEN extra_package_flags->>'feature_homepage'::varchar = 'true' THEN 1 ELSE 0 END DESC, created_at DESC")) }
  scope :not_featured_in_homepage, -> { where("COALESCE(extra_package_flags->>'feature_homepage', 'false') = 'false'") }
  scope :reverse_chronological, -> { order(arel_table[:created_at].desc) }
  scope :chronological, -> { order(arel_table[:created_at].asc) }
  scope :between_dates, ->(start_date, end_date) { where_date_between(:created_at, start_date, end_date) }

  scope :with_active_subscription, -> { where.not(stripe_subscription_id: nil).where(cancelled_at: nil) }

  after_create :update_product_counter
  after_update :update_product_counter, if: :published_changed?

  def locations_csv
    locations.join(', ')
  end

  def locations_csv=(value)
    self.locations = (value || '').split(',').map(&:strip)
  end

  def categories_csv
    categories.join(', ')
  end

  def categories_csv=(value)
    self.categories = (value || '').split(',').map(&:strip)
  end

  # Combines company name and job title for slug, but limits to 230 characters
  # to prevent exceeding the slug length limit.
  def slug_to_generate
    "#{ company_name }-#{ job_title }"[0..230]
  end

  def should_generate_new_friendly_id?
    slug.blank? || job_title_changed?
  end

  def other_jobs_from_same_company
    return [] unless stripe_subscription_id?

    Job.with_active_subscription.where(stripe_billing_email: stripe_billing_email).where.not(id: id)
  end

  def notifyable?
    !trashed? && inhouse? && published && cancelled_at.blank? && roles.any? && skills.any?
  end

  private

  def update_product_counter
    product&.refresh_jobs_count
  end

  def before_trashing
    self.published = false

    Jobs::Cancel.call(self, immediate: true)
  end

  def after_trashing
    product&.refresh_jobs_count
  end
end
