class RenameEmbedSubjectTypeFromProductToLegacyProduct < ActiveRecord::Migration[5.2]
  def up
    safety_assured {
      execute "DELETE FROM embeds WHERE embeds.subject_type = 'Team'"
      execute "UPDATE embeds SET subject_type = 'LegacyProduct'"
    }
  end

  def down
    safety_assured {
      execute "UPDATE embeds SET subject_type = 'Product'"
    }
  end
end
