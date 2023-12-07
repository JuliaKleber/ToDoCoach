class AddTaskToTaskInvitations < ActiveRecord::Migration[7.1]
  def change
    add_reference :task_invitations, :task, null: false, foreign_key: true
  end
end
