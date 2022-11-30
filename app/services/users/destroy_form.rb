# frozen_string_literal: true

class Users::DestroyForm
  include MiniForm::Model

  OPTIONS = [
    'This account was a duplicate account.',
    'I had a bad experience on the platform.',
    "I'm no longer interested in this community.",
    "I'm just taking a break.",
    'Other',
  ].freeze

  model :survey, attributes: %i(reason feedback), save: true

  validates :reason, inclusion: { in: OPTIONS, message: 'Please select a reason.' }

  def initialize(user)
    @user = user
    @survey = @user.build_delete_survey
  end

  def node
    @user
  end

  # NOTE(emilov): ensure this works with new style mutations
  alias graphql_result node

  def perform
    @user.trash
  end
end
