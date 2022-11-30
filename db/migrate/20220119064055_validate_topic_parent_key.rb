class ValidateTopicParentKey < ActiveRecord::Migration[6.1]
  def change
    validate_foreign_key :topics, :topics
  end
end
