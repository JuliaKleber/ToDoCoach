class TaskInvitation < ApplicationRecord
  belongs_to :user
  belongs_to :task_user
end
