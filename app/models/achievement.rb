class Achievement < ApplicationRecord
  has_many :user_achievements
  has_many :users, through: :user_achievements
end
