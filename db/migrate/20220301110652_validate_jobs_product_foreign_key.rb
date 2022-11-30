class ValidateJobsProductForeignKey < ActiveRecord::Migration[6.1]
  def change
    validate_foreign_key :jobs, :products
  end
end
