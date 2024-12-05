import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static targets = ["input", "dropZone", "initialContent", "preview", "placeholder"]

  connect() {
    this.dropZone.addEventListener("dragover", this.handleDragOver.bind(this))
    this.dropZone.addEventListener("dragleave", this.handleDragLeave.bind(this))
    this.dropZone.addEventListener("drop", this.handleDrop.bind(this))
    this.dropZone.addEventListener("click", () => this.inputTarget.click())
  }

  handleDragOver(e) {
    e.preventDefault()
    this.dropZone.classList.add("dragging")
  }

  handleDragLeave(e) {
    e.preventDefault()
    this.dropZone.classList.remove("dragging")
  }

  handleDrop(e) {
    e.preventDefault()
    e.stopPropagation()
    this.dropZone.classList.remove("dragging")
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

  get dropZone() {
    return this.dropZoneTarget
  }
}
