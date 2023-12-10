class UserAchievementCongratulation < ApplicationRecord
  belongs_to :user_achievement
  belongs_to :user
end
