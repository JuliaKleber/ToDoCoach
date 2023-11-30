class TaskCategory < ApplicationRecord
  belongs_to :task
  belongs_to :category
end
