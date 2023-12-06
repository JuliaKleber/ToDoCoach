class TaskUser < ApplicationRecord
  belongs_to :task
  belongs_to :user

  validates :user, uniqueness: { scope: :task }
  # enum :status, { unconfirmed: 0, accepted: 1 }
end
