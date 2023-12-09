class UserAchievement < ApplicationRecord
  belongs_to :user
  belongs_to :achievement
  has_many :user_achievement_congratulations
end
