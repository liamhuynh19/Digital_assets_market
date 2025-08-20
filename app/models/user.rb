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
  validates :role, presence: true, inclusion: { in: ROLES }
  before_validation :set_default_role

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
    role == "admin"
  end

  def seller?
    role == "seller"
  end

  def buyer?
    role == "buyer"
  end

  def can_apply_for_seller?
    buyer? && !seller_applications.pending.exists?
  end

  def latest_seller_application
    seller_applications.order(created_at: :desc).first
  end

  def purchased_products
    Product.joins(order_items: :order)
            .where(orders: { user_id: id, status: "paid" })
            .select("products.*, |
            orders.id as order_id,
            orders.created_at as purchase_date,
            order_items.price_at_purchase as price_at_purchase")
            .distinct
  end

  private
  def set_default_role
    self.role ||= "buyer"
  end
end
