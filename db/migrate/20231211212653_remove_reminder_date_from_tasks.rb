class RemoveReminderDateFromTasks < ActiveRecord::Migration[7.1]
  def change
    remove_column :tasks, :reminder_date, :datetime
  end
end
