class Product < ApplicationRecord
  has_one_attached :asset
  has_one_attached :preview
  has_one_attached :thumbnail
  has_one_attached :video_hd
  has_one_attached :video_full_hd
  has_one_attached :video_4k

  belongs_to :user
  belongs_to :category
  has_many :reviews, dependent: :destroy
  has_many :order_items, dependent: :destroy


  validates :name, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  # after_commit :process_image_thumbnail, on: [ :create ], if: :image?

  # def image?
  #   asset.attached? && asset.content_type.start_with?("image/")
  # end
  STATUSES = %w[draft processing uploaded published].freeze

  validates :status, inclusion: { in: STATUSES }
  after_initialize :set_default_status

  def set_default_status
    self.status ||= "draft"
  end

  def published?
    status == "published"
  end

  def allow_to_publish?
    status == "uploaded"
  end

  def process_image_thumbnail
    ImageThumbnailJob.perform_later(id)
  end

  def purchased_by?(user)
    OrderItem.includes(:order)
    .where(product_id: id, orders: { user_id: user.id, status: "paid" })
    .exists?
  end

  # Define which attributes can be searched/filtered with Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[name description price status category_id created_at]
  end

  # Define which associations can be searched/filtered with Ransack
  def self.ransackable_associations(auth_object = nil)
    %w[category user]
  end

  # Define custom ransackers for more complex searches
  ransacker :created_at_month do
    Arel.sql("EXTRACT(MONTH FROM created_at)")
  end

  ransacker :price_range do |parent|
    Arel.sql("CAST(price AS DECIMAL)")
  end
end
