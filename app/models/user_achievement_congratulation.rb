class UserAchievementCongratulation < ApplicationRecord
  belongs_to :achievement
  belongs_to :user
  belongs_to :follower, class_name: 'User', foreign_key: :follower_id
end
