class RemoveTaskUserIdFromTaskInvitations < ActiveRecord::Migration[7.1]
  def change
    remove_column :task_invitations, :task_user_id, :bigint
  end
end
