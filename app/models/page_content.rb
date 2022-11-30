# frozen_string_literal: true

# == Schema Information
#
# Table name: page_contents
#
#  id          :bigint(8)        not null, primary key
#  page_key    :string           not null
#  element_key :string           not null
#  content     :text
#  image_uuid  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_page_contents_on_page_key  (page_key)
#

class PageContent < ApplicationRecord
  include Uploadable

  uploadable :image

  validates :page_key, presence: true
  validates :element_key, presence: true
  validate :content_present?

  before_save :format_keys, :format_content

  private

  def content_present?
    return if content.present? || image_uuid.present?

    errors.add :base, 'must have at least one type of content'
  end

  # Note(Rahul): Downcase & replace space with underscore for better index
  def format_keys
    self.page_key = key_formatter(page_key)
    self.element_key = key_formatter(element_key)
  end

  def key_formatter(column)
    column.downcase.strip.tr(' ', '_')
  end

  def format_content
    self.content = ActionController::Base.helpers.strip_tags(content).tr("\r", '') if content.present?
  end
end
