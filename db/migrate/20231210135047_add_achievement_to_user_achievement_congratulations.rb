class AddAchievementToUserAchievementCongratulations < ActiveRecord::Migration[7.1]
  def change
    add_reference :user_achievement_congratulations, :achievement, null: false, foreign_key: true
  end
end
