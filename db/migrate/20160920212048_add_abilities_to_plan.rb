class AddAbilitiesToPlan < ActiveRecord::Migration
  def change
    # Not all plans will be in Stripe. Enterpise plans will be billed outside of Stripe
    # Removing null constraint since it's not required for those plans
    change_column :plans, :remote_id, :string, null: true

    add_column :plans, :abilities, :json, default: {}, null: false
  end
end
