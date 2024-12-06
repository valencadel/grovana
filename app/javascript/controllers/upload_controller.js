import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static targets = ["input", "dropZone", "initialContent", "preview", "placeholder", "submitButton"]

  connect() {
    this.dropZoneTarget.addEventListener("dragover", this.handleDragOver.bind(this))
    this.dropZoneTarget.addEventListener("dragleave", this.handleDragLeave.bind(this))
    this.dropZoneTarget.addEventListener("drop", this.handleDrop.bind(this))
    this.dropZoneTarget.addEventListener("click", () => this.inputTarget.click())
    this.previewTarget.classList.add('hidden') // Ensure preview is hidden initially
    this.placeholderTarget.classList.add('hidden') // Ensure placeholder is hidden initially
    this.submitButtonTarget.classList.add('hidden') // Ensure submit button is hidden initially
  }

  handleDragOver(e) {
    e.preventDefault()
    this.dropZoneTarget.classList.add("dragging")
  }

  handleDragLeave(e) {
    e.preventDefault()
    this.dropZoneTarget.classList.remove("dragging")
  }

  handleDrop(e) {
    e.preventDefault()
    e.stopPropagation()
    this.dropZoneTarget.classList.remove("dragging")
    const file = e.dataTransfer.files[0]
    if (file) {
      this.inputTarget.files = e.dataTransfer.files
      this.previewFile(file)
      this.uploadFile(file)
    }
  }

  handleChange(e) {
    const file = e.target.files[0]
    if (file) {
      this.previewFile(file)
      this.uploadFile(file)
    }
  }

  previewFile(file) {
    const reader = new FileReader()
    reader.onload = (e) => {
      const previewImage = this.previewTarget.querySelector('img')
      previewImage.src = e.target.result

      previewImage.onload = () => {
        this.placeholderTarget.style.display = 'none'
        this.previewTarget.classList.remove('hidden')
        this.dropZoneTarget.classList.add('hidden')
        this.submitButtonTarget.classList.remove('hidden')
      }
    }
    reader.readAsDataURL(file)
  }

  uploadFile(file) {
    const upload = new DirectUpload(file, this.inputTarget.dataset.directUploadUrl)
    upload.create((error, blob) => {
      if (error) {
        console.error(error)
      } else {
        const hiddenField = document.createElement('input')
        hiddenField.setAttribute("type", "hidden")
        hiddenField.setAttribute("value", blob.signed_id)
        hiddenField.name = this.inputTarget.name
        this.element.closest('form').appendChild(hiddenField)
      }
    })
  }
}
