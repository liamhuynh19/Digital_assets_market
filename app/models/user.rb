require "attr_encrypted"
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
        :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  ROLES = %w[admin buyer seller].freeze
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  # validates :password, presence: true, length: { minimum: 6 }
  # before_validation :set_default_role

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  belongs_to :current_role, class_name: "Role", optional: true

  has_one :cart, dependent: :destroy
  has_many :products
  has_many :orders
  has_many :seller_applications, dependent: :destroy

  # Add encryption key to credentials
  attr_encrypted :phone_number,
                key: Rails.application.credentials.phone_number_encryption_key || ENV["PHONE_NUMBER_ENCRYPTION_KEY"],
                encode: true,
                encode_iv: true,
                algorithm: "aes-256-gcm"

  # Add phone number validation
  validates :phone_number,
            format: { with: /\A\+?[\d\s-]{10,}\z/, message: "must be valid" },
            allow_blank: true

  def admin?
    has_role?("admin")
  end

  def seller?
    has_role?("seller")
  end

  def buyer?
    has_role?("buyer")
  end

  def has_role?(role_name)
    roles.exists?(name: role_name)
  end

  def add_role(role_name)
    return if has_role?(role_name)
    role = Role.find_or_create_by(name: role_name)
    user_roles.create(role: role)
  end

  def remove_role(role_name)
    role = Role.find_by(name: role_name)
    user_roles.where(role: role).destroy_all if role
  end

  def set_current_role(role_name)
    role = roles.find_by(name: role_name)
    update(current_role: role) if role
  end

  def current_view
    current_role&.name || default_role
  end

  def default_role
    return "admin" if admin?
    roles.first&.name || "buyer"
  end

  def migrate_legacy_role
    add_role(role) if role.present?
    self.current_role = roles.find_by(name: role)
    save
  end

  def can_apply_for_seller?
    buyer? && !has_role?("seller") && !seller_applications.pending.exists?
  end

  def latest_seller_application
    seller_applications.order(created_at: :desc).first
  end

  def purchased_products
    Product.joins(order_items: :order)
            .where(orders: { user_id: id, status: "paid" })
            .select("products.*,
            orders.id as order_id,
            orders.created_at as purchase_date,
            order_items.price_at_purchase as price_at_purchase")
            .distinct
  end
  after_create :assign_pending_role
  private
  def assign_pending_role
    # add_role(pending_role) if pending_role.present?
    add_role("buyer") unless roles.any?
    update_column(:current_role_id, roles.first.id) if current_role_id.nil? && roles.any?
  end

  def set_default_role
    self.role ||= "buyer"
    # add_role("buyer") unless roles.any?
    # self.current_role ||= roles.first if roles.any?
  end
end
