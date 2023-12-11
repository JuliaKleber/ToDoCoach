class AddDateToUserAchievements < ActiveRecord::Migration[7.1]
  def change
    add_column :user_achievements, :date, :date
  end
end
