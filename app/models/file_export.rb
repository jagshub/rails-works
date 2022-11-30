# frozen_string_literal: true

# == Schema Information
#
# Table name: file_exports
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  file_key   :string           not null
#  file_name  :string           not null
#  expires_at :datetime         not null
#  note       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_file_exports_on_expires_at  (expires_at)
#  index_file_exports_on_file_key    (file_key) UNIQUE
#  index_file_exports_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class FileExport < ApplicationRecord
  self.table_name = 'file_exports'

  HasExpirationDate.define self, limit: 1.week

  belongs_to :user, inverse_of: :file_exports

  validates :file_key, presence: true
  validates :file_name, presence: true

  before_destroy :delete_file

  def file_download_url
    External::S3Api.signed_url(bucket: :exports, key: file_key, file_name: file_name)
  end

  def delete_file
    External::S3Api.delete_object(bucket: :exports, key: file_key)
  end
end
