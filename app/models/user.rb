class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :tasks
  has_many :categories
  has_many :user_achievements
  has_many :achievements, through: :user_achievements
  has_one_attached :photo

  has_many :task_users, dependent: :destroy
  has_many :tasks, through: :task_users

  has_many :follows_as_follower, class_name: "Follow", foreign_key: "follower_id"
  has_many :followeds, through: :follows_as_follower, class_name: "User"
  has_many :follows_as_followed, class_name: "Follow", foreign_key: "followed_id"
  has_many :followers, through: :follows_as_followed, class_name: "User"

  include PgSearch::Model
  pg_search_scope :search_by_username_and_email,
    against: [ :user_name, :email ],
    using: {
      tsearch: { prefix: true }
    }
end
