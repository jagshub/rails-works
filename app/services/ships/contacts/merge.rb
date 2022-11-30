# frozen_string_literal: true

class Ships::Contacts::Merge
  def self.call(result_contact:, delete_contract:)
    new(result_contact: result_contact, delete_contract: delete_contract).call
  end

  attr_reader :result_contact, :delete_contract

  def initialize(result_contact:, delete_contract:)
    @result_contact = result_contact
    @delete_contract = delete_contract
  end

  def call
    raise "Can't merge contacts from different accounts" if result_contact.ship_account_id != delete_contract.ship_account_id

    move_subscribers

    delete_contract.destroy!
  end

  private

  def move_subscribers
    delete_contract.subscribers.find_each do |record|
      duplicate = result_contact.subscribers.find_by(upcoming_page_id: record.upcoming_page_id)
      if duplicate
        record.destroy!
      else
        UpcomingPageSubscriber.where(id: record.id).update_all ship_contact_id: result_contact.id
      end
    end
  end
end
