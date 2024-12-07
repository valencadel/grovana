class Upload < ApplicationRecord
  belongs_to :company
  has_one_attached :image

  validates :image, presence: true,
                   content_type: [ "image/png", "image/jpg", "image/jpeg" ],
                   size: { less_than: 5.megabytes }

  def gemini(gemini_prompt)
    client = Gemini.new(
      credentials: {
        service: "generative-language-api",
        api_key: ENV["GEMINI_API_KEY"]
      },
      options: { model: "gemini-1.5-flash", server_sent_events: true }
    )

    result = client.stream_generate_content(
      { contents: [
        { role: "user", parts: [
          { text: gemini_prompt },
          { inline_data: {
            mime_type: "image/jpeg",
            data: Base64.strict_encode64(File.read(image_path)) # image_path # "factura_4.jpg"
          } }
        ] }
      ] }
    )

    response_text = result.flat_map do |entry|
      entry["candidates"].flat_map do |candidate|
        candidate["content"]["parts"].map { |part| part["text"] }
      end
    end.join

    cleaned_text = response_text.gsub(/```json\s*|\s*```/, "").strip

    content = JSON.parse(cleaned_text)
    content
  end

  private

  def image_path
    ActiveStorage::Blob.service.path_for(image.key)
  end
end
