class TaskInvitation < ApplicationRecord
  belongs_to :user
  belongs_to :task
  has_many :invited_users, class_name: 'User'
end
