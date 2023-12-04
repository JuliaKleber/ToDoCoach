class Category < ApplicationRecord
  belongs_to :user
  has_many :task_categories, dependent: :destroy

  validates :name, presence: true
  scope :filter_by_starts_with, -> (category) {where("name 1like ?", "#{name}%")}
end
