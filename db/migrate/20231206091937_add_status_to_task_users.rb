class AddStatusToTaskUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :task_users, :status, :integer, default: 0
  end
end
