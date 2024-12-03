class Upload < ApplicationRecord
  belongs_to :company

  validates :photo, presence: true
  attr_accessor :photo_file

  before_validation :upload_photo, if: :photo_file_present?

  private

  def upload_photo
    return unless photo_file.present?

    begin
      result = Cloudinary::Uploader.upload(
        photo_file.path,
        resource_type: :auto
      )
      self.photo = result['secure_url']
    rescue => e
      errors.add(:base, e.message)
      false
    end
  end

  def photo_file_present?
    photo_file.present?
  end
end
