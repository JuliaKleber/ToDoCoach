class RemoveTaskIdFromTaskInvitations < ActiveRecord::Migration[7.1]
  def change
    remove_column :task_invitations, :task_id, :bigint
  end
end
