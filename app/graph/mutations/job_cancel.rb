# frozen_string_literal: true

module Graph::Mutations
  class JobCancel < BaseMutation
    argument :token, String, required: false

    returns Graph::Types::JobType

    def perform(token:)
      job = Job.find_by!(token: token)
      Jobs::Cancel.call(job, immediate: true)
      job
    end
  end
end
