# == Schema Information
#
# Table name: users
#
#  id                 :bigint           not null, primary key
#  email              :string           not null
#  encrypted_password :string           not null
#  name               :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :validatable

  has_many :user_associations, class_name: 'UserAssociation', foreign_key: :followed_by_user_id, dependent: :destroy
  has_many :followees, through: :user_associations, source: :following_user
  has_many :followers, through: :user_associations, source: :followed_by_user

  has_many :posts, dependent: :destroy, inverse_of: :user
  has_many :comments, dependent: :destroy, inverse_of: :user
  has_many :votes, dependent: :destroy, inverse_of: :user

  validates :name, presence: true

  def follow(other_user)
    followees << other_user unless self == other_user
  end

  def following?(other_user)
    followees.include?(other_user)
  end

  def unfollow(other_user)
    followees.delete(other_user)
  end

end
