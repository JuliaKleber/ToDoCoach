class Task < ApplicationRecord
  has_many :task_categories, dependent: :destroy
  has_many :categories, through: :task_categories
  has_many :task_users, dependent: :destroy
  has_many :users, through: :task_users
  has_many :task_invitations
  belongs_to :user

  validates :title, presence: true, length: { minimum: 3, maximum: 60 }

  validates :description, length: { maximum: 250 }

  accepts_nested_attributes_for :task_categories
  validates_associated :task_categories

  enum :priority, { low: 0, medium: 1, high: 2 }
  before_validation :set_default_priority

  accepts_nested_attributes_for :task_users
  validates_associated :task_users

  private

  def set_default_priority
    self.priority ||= :low if priority.nil?
  end
end
