class AddTaskIdToTaskInvitations < ActiveRecord::Migration[7.1]
  def change
    add_column :task_invitations, :task_id, :bigint
  end
end
