class RemoveStatusFromTaskUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :task_users, :status, :integer
  end
end
