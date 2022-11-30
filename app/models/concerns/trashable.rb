# frozen_string_literal: true

# NOTE(rstankov): Makes a model trashable.
#
# Required database columns for the model:
#
#   add_column :table_name, :trashed_at, :datetime, null: true
#
# Optional database column for the model:
#
#   add_index :table_name, :trashed_at
#
# Most of the time you filter for non trashed records, so the index can be:
#
#   add_index :table_name, :trashed_at, where: 'trashed_at IS NULL'
#
# For existing tables we can create the index concurrently:
#
#   disable_ddl_transaction!
#
#   def change
#     add_column :table_name, :trashed_at, :datetime, null: true
#     add_index :table_name, :trashed_at, where: 'trashed_at IS NULL', algorithm: :concurrently
#   end
#
module Trashable
  extend ActiveSupport::Concern

  included do
    scope :trashed, -> { where.not(trashed_at: nil) }
    scope :not_trashed, -> { where(trashed_at: nil) }
  end

  def trashed?
    trashed_at.present?
  end

  def trash
    ActiveRecord::Base.transaction do
      before_trashing

      update! trashed_at: Time.current

      after_trashing
    end
  end

  def restore
    ActiveRecord::Base.transaction do
      before_restoring

      update! trashed_at: nil

      after_restoring
    end
  end

  private

  def before_trashing
    # override this in model
  end

  def before_restoring
    # override this in model
  end

  def after_trashing
    # override this in model
  end

  def after_restoring
    # override this in model
  end
end
