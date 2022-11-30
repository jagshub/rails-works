class RemoveNewsletterEventsDuplicatedIndex < ActiveRecord::Migration[6.1]
  def change
    remove_index(
      :newsletter_events,
      name: "index_newsletter_events_on_newsletter_id",
      column: :newsletter_id,
    )
  end
end
