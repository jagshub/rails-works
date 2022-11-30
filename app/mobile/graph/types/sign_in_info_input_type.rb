# frozen_string_literal: true

module Mobile::Graph::Types
  class InfoFullNameInputType < BaseInputObject
    argument :given_name, String, required: false
    argument :middle_name, String, required: false
    argument :family_name, String, required: false
  end

  class SignInInfoInputType < BaseInputObject
    argument :full_name, InfoFullNameInputType, required: false
    argument :email, String, required: false
    argument :user, String, required: false
  end
end
