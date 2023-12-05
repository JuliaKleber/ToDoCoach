class Task < ApplicationRecord
  has_many :task_categories, dependent: :destroy
  has_many :categories, through: :task_categories
  has_many :task_users, dependent: :destroy
  has_many :users, through: :task_users
  belongs_to :user

  validates :title, presence: true, length: {minimum: 5, maximum: 60}

  validates :description, presence: true, length: {maximum: 250}

  accepts_nested_attributes_for :task_categories
  validates_associated :task_categories
  enum :priority, { low: 0, medium: 1, high: 2 }

  # validate :at_least_one_user

  private

  # def at_least_one_user
  #   errors.add(:base, 'Task must have at least one user') if users.empty?
  # end
end
