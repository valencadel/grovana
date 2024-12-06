class SalesUpload < ApplicationRecord
  belongs_to :company
  has_one_attached :image

  validates :image, presence: true
  validate :acceptable_image

  private

  def acceptable_image
    return unless image.attached?

    unless image.blob.byte_size <= 5.megabyte
      errors.add(:image, "is too big - should be less than 5MB")
    end

    acceptable_types = ["image/jpeg", "image/png", "image/jpg"]
    unless acceptable_types.include?(image.content_type)
      errors.add(:image, "must be a JPEG, JPG or PNG")
    end
  end
end
