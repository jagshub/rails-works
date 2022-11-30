# frozen_string_literal: true

class AddSubscriberIdIndexToNewsletterEvents < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index :newsletter_events, :subscriber_id, algorithm: :concurrently
  end
end
