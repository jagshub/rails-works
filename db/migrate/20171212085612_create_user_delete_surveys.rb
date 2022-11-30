class CreateUserDeleteSurveys < ActiveRecord::Migration[5.0]
  def change
    create_table :user_delete_surveys do |t|
      t.string :reason,   null: false
      t.text :feedback
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
