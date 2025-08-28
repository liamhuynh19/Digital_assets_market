class RolePermission < ApplicationRecord
  belongs_to :role
  belongs_to :permission

  validates :role_id, presence: true
  validates :permission_id, presence: true
  validates :role_id, uniqueness: { scope: :permission_id, message: "already has this permission" }
end
