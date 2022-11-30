# frozen_string_literal: true

module Graph::Types
  class JobKindType < BaseEnum
    graphql_name 'JobKind'

    value 'inhouse'
    value 'angellist'
  end

  class JobType < BaseObject
    graphql_name 'Job'

    implements Graph::Types::SeoInterfaceType

    field :id, ID, null: false
    field :token, String, null: true
    field :slug, String, null: true
    field :company_jobs_url, String, null: true
    field :company_name, String, null: true
    field :company_tagline, String, null: true
    field :currency_code, String, null: false
    field :description, String, null: true
    field :image_uuid, String, null: false
    field :job_title, String, null: false
    field :job_type, String, null: true
    field :locations, [String], null: false
    field :locations_csv, String, null: false
    field :categories, [String], null: false
    field :remote_ok, Boolean, null: false
    field :published, Boolean, null: false
    field :roles, [String], null: false
    field :salary_max, Int, null: true
    field :salary_min, Int, null: true
    field :skills, [String], null: false
    field :kind, Graph::Types::JobKindType, null: false
    field :url, String, null: false
    field :external_created_at, Graph::Types::DateTimeType, null: true
    field :created_at, Graph::Types::DateTimeType, null: false
    field :cancelled_at, Graph::Types::DateTimeType, null: true
    field :billing_cycle_anchor, Graph::Types::DateTimeType, null: true
    field :can_cancel, Boolean, null: true
    field :related_jobs, [Graph::Types::JobType], null: false
    field :other_jobs_from_same_company, [Graph::Types::JobType], null: false
    field :is_featured, Boolean, null: false

    def can_cancel
      !object.cancelled_at && !!object.stripe_customer_id
    end

    def related_jobs
      Job.published.where.not(id: object.id).reverse_chronological.limit(5)
    end

    def is_featured
      object.extra_package_flags['feature_homepage']
    end

    def token
      return unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.token
    end
  end
end
