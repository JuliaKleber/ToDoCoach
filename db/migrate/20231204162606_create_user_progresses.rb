class CreateUserProgresses < ActiveRecord::Migration[7.1]
  def change
    create_table :user_progresses do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :number_completed_low_priority, default: 0, null: false
      t.integer :number_completed_medium_priority, default: 0, null: false
      t.integer :number_completed_high_priority, default: 0, null: false
      t.integer :number_completed_all, default: 0, null: false
      t.integer :number_completed_work, default: 0, null: false
      t.integer :number_completed_personal, default: 0, null: false
      t.integer :number_completed_groceries, default: 0, null: false

      t.timestamps
    end
  end
end
