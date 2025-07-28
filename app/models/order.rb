class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items, allow_destroy: true


  STATUSES = %w[pending paid cancelled failed].freeze
  validates :status, presence: true, inclusion: { in: STATUSES }

  after_initialize :set_default_status

  private
  def set_default_status
    self.status ||= "pending"
  end
end
