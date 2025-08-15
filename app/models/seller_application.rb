class SellerApplication < ApplicationRecord
  STATUSES = %w[pending approved rejected].freeze

  belongs_to :user
  belongs_to :reviewed_by, class_name: "User", optional: true

  validates :status, inclusion: { in: STATUSES }
  validates :user_id, uniqueness: { scope: :status, message: "already has a pending application" }, if: :pending?
  validate :user_must_be_buyer

  scope :pending, -> { where(status: "pending") }

  def approve!(admin_user, rejection_reason: nil)
    transaction do
      update!(
        status: "approved",
        reviewed_by: admin_user,
        reviewed_at: Time.current
      )
      user.update!(role: "seller") unless user.seller?
    end
  end

  def reject!(admin_user, rejection_reason: nil)
    update!(
      status: "rejected",
      reviewed_by: admin_user,
      rejection_reason: rejection_reason,
      reviewed_at: Time.current
    )
  end

  def pending?
    status == "pending"
  end

  private

  def user_must_be_buyer
    errors.add(:user, "must be a buyer") unless user&.role == "buyer"
  end
end
