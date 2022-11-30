# frozen_string_literal: true

module Graph::Mutations
  class JobSave < BaseMutation
    argument :token, String, required: false
    argument :discount_page_slug, String, required: false

    argument :email, String, required: false
    argument :company_name, String, required: false
    argument :company_tagline, String, required: false
    argument :image_uuid, String, required: false
    argument :job_title, String, required: false
    argument :locations_csv, String, required: false
    argument :categories, [String], required: false
    argument :url, String, required: false
    argument :remote_ok, Boolean, required: false

    returns Graph::Types::JobType
    field :token, String, null: true

    def perform(inputs)
      inputs[:categories] = [] unless inputs.key?(:categories)
      form = Jobs::SaveForm.new(find_or_build_job(inputs))

      if form.update(inputs)
        { node: form.job, token: form.node.token }
      else
        { node: form, token: nil }
      end
    end

    private

    def find_or_build_job(inputs)
      if inputs[:token].present?
        Job.find_by!(token: inputs[:token])
      else
        Job.new(user: current_user, external_created_at: Time.current)
      end
    end
  end
end
