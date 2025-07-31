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

  def admin?
    role == "admin"
  end

  def seller?
    role == "seller"
  end

  private
  def set_default_role
    self.role ||= "buyer"
  end
end
