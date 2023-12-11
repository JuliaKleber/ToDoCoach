class RemoveUserAchievementFromUserAchievementCongratulations < ActiveRecord::Migration[7.1]
  def change
    remove_reference :user_achievement_congratulations, :user_achievement, null: false, foreign_key: true
  end
end
