class AddUniqueIndexToTopicName < ActiveRecord::Migration
  def up
    execute 'CREATE UNIQUE INDEX "index_topics_on_lower(name)" ON "topics" (lower(name))'
  end

  def down
    execute 'DROP INDEX "index_topics_on_lower(name)"'
  end
end
