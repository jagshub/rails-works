class CreateCollaborators < ActiveRecord::Migration[5.0]
  def change
    create_table :collaborator_associations do |t|
      t.references :subject, null: false, polymorphic: true, index: true
      t.references :user, null: false, foreign_key: true
      t.timestamps null: false
    end

    add_index :collaborator_associations, %i(subject_type subject_id user_id), unique: true, name: 'index_collaborator_associations_on_subject_and_user_id'
  end
end
