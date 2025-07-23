class Product < ApplicationRecord
  has_one_attached :asset
  has_one_attached :thumbnail

  belongs_to :user
  belongs_to :category
  has_many :reviews, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  # after_commit :process_image_thumbnail, on: [ :create ], if: :image?

  # def image?
  #   asset.attached? && asset.content_type.start_with?("image/")
  # end

  # private

  def process_image_thumbnail
    ImageThumbnailJob.perform_later(id)
  end
end
