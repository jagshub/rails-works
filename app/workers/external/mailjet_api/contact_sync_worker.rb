# frozen_string_literal: true

class External::MailjetApi::ContactSyncWorker < ApplicationJob
  include ActiveJobHandleMailjetErrors

  def perform(user)
    return if user.email.blank?

    if receive_notifications?(user: user)
      External::MailjetApi.add_contact_to_list(name: user.name, email: user.email, list_id: Config.mailjet_contact_list_id)
    else
      External::MailjetApi.remove_contact_from_list(user_email: user.email, list_id: Config.mailjet_contact_list_id)
    end
  end

  private

  def receive_notifications?(user:)
    product = Product.find_by(id: Config.ph_product_id)
    Subscribe.subscribed?(product, user)
  end
end
