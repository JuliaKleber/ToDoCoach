class CreateUserAchievementCongratulations < ActiveRecord::Migration[7.1]
  def change
    create_table :user_achievement_congratulations do |t|
      t.references :user_achievement, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.date :date

      t.timestamps
    end
  end
end
