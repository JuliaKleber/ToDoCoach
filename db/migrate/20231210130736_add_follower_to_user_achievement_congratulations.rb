class AddFollowerToUserAchievementCongratulations < ActiveRecord::Migration[7.1]
  def change
    add_reference :user_achievement_congratulations, :follower, null: false, foreign_key: { to_table: :users }
  end
end
