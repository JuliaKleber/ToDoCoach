class CreateTaskInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :task_invitations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :task_user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
