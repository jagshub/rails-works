# frozen_string_literal: true

class Iterable::SyncUserWorker < ApplicationJob
  include ActiveJobHandleNetworkErrors

  def perform(user:)
    return if user.email.blank?

    data_fields = Iterable::DataTypes.get_user_data_fields(user)

    External::IterableAPI.upsert_user(email: user.email, user_id: user.id, data_fields: data_fields)
  end
end
