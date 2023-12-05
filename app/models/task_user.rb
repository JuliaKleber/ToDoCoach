class TaskUser < ApplicationRecord
  belongs_to :task
  belongs_to :user

  validates :user, uniqueness: { scope: :task }
end
