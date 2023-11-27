class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :description
      t.integer :priority
      t.boolean :completed
      t.datetime :due_date
      t.datetime :reminder_date

      t.timestamps
    end
  end
end
