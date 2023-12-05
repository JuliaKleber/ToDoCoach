class Category < ApplicationRecord
  has_many :task_categories, dependent: :destroy
  has_many :user_categories

  validates :name, presence: true
  scope :filter_by_starts_with, -> (category) {where("name 1like ?", "#{name}%")}
end
