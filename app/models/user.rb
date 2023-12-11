class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :user_name, presence: true, uniqueness: true

  has_many :tasks_as_creator, class_name: "Task", foreign_key: "user_id"
  has_many :user_categories
  has_many :categories, through: :user_categories
  has_many :user_achievements
  has_many :achievements, through: :user_achievements
  has_many :user_achievement_congratulations, dependent: :destroy
  has_many :congratulated_achievements, through: :user_achievement_congratulations, source: :user_achievement
  has_many :follower_congratulations, foreign_key: :user_id, class_name: 'UserAchievementCongratulation'
  has_many :followers, through: :follower_congratulations, source: :follower
  has_many :task_invitations
  has_one_attached :photo

  has_many :task_users, dependent: :destroy
  has_many :tasks, through: :task_users

  has_many :follows_as_follower, class_name: "Follow", foreign_key: "follower_id", dependent: :destroy
  has_many :followeds, through: :follows_as_follower, class_name: "User"
  has_many :follows_as_followed, class_name: "Follow", foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :follows_as_followed, class_name: "User"

  include PgSearch::Model
  pg_search_scope :search_by_username_and_email,
                  against: %i[user_name email],
                  using: { tsearch: { prefix: true } }

  after_create :initialize_user_progress

  private

  def initialize_user_progress
    UserProgress.create(user_id: User.last.id)
    UserAchievement.create(user_id: User.last.id, achievement_id: Achievement.first.id, date: Time.now.to_date)
    UserCategory.create(user_id: User.last.id, category_id: Category.first.id)
    UserCategory.create(user_id: User.last.id, category_id: Category.second.id)
    UserCategory.create(user_id: User.last.id, category_id: Category.third.id)
  end
end
