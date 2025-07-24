class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy

  STATUSES = %w[pending paid failed].freeze
  validates :status, presence: true, inclusion: { in: STATUSES }

  after_initialize :set_default_status

  private
  def set_default_status
    self.status ||= "pending"
  end
end
