class Upload < ApplicationRecord
  belongs_to :company
  has_one_attached :image

  validates :image, presence: true,
                   content_type: ['image/png', 'image/jpg', 'image/jpeg'],
                   size: { less_than: 5.megabytes }
end
