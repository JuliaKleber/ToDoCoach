class Task < ApplicationRecord
  belongs_to :user
  has_many :task_categories, dependent: :destroy
  has_many :categories, through: :task_categories

  validates :title, presence: true, length: {minimum: 10, maximum: 60}

  validates :description, presence: true, length: {maximum: 250}

  enum :priority, { low: 0, medium: 1, high: 2 }
end
