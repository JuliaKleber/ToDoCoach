class Task < ApplicationRecord
  has_many :task_categories, dependent: :destroy
  has_many :categories, through: :task_categories
  belongs_to :user

  validates :title, presence: true, length: {minimum: 5, maximum: 60}

  validates :description, presence: true, length: {maximum: 250}

  accepts_nested_attributes_for :task_categories
end
