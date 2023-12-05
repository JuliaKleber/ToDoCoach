class TaskUser < ApplicationRecord
  belongs_to :task
  belongs_to :user

  validates_uniqueness_of :user_id, scope: :task_id
end
