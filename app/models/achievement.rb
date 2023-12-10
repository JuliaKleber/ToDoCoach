class Achievement < ApplicationRecord
  has_many :user_achievements
  has_many :users, through: :user_achievements
  has_many :user_achievement_congratulations
  has_many :congratulators, through: :user_achievement_congratulations, source: :user
end
