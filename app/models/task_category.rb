class TaskCategory < ApplicationRecord
  belongs_to :task
  belongs_to :category

  accepts_nested_attributes_for :category
end
