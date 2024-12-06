import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropZone", "input", "preview", "placeholder", "initialContent"]

  connect() {
    this.dropZone = this.dropZoneTarget
    this.setupDragAndDrop()
  }

  setupDragAndDrop() {
    ;["dragenter", "dragover", "dragleave", "drop"].forEach(eventName => {
      this.dropZone.addEventListener(eventName, this.preventDefaults, false)
    })

    ;["dragenter", "dragover"].forEach(eventName => {
      this.dropZone.addEventListener(eventName, this.highlight.bind(this), false)
    })

    ;["dragleave", "drop"].forEach(eventName => {
      this.dropZone.addEventListener(eventName, this.unhighlight.bind(this), false)
    })

    this.dropZone.addEventListener("drop", this.handleDrop.bind(this), false)
  }

  preventDefaults(e) {
    e.preventDefault()
    e.stopPropagation()
  }

  highlight(e) {
    this.dropZoneTarget.classList.add("border-blue-500")
  }

  unhighlight(e) {
    this.dropZoneTarget.classList.remove("border-blue-500")
  }

  handleDrop(e) {
    const dt = e.dataTransfer
    const files = dt.files
    this.handleFiles(files)
  }

  handleChange(e) {
    this.handleFiles(e.target.files)
  }

  handleFiles(files) {
    if (files.length > 0) {
      this.initialContentTarget.classList.add("hidden")
      this.previewFile(files[0])
      this.uploadFile(files[0])
    }
  }

  previewFile(file) {
    const reader = new FileReader()
    reader.onload = (e) => {
      const previewImage = this.previewTarget.querySelector('img')
      previewImage.src = e.target.result
      this.placeholderTarget.style.display = 'none'
      this.previewTarget.classList.remove('hidden')
    }
    reader.readAsDataURL(file)
  }

  uploadFile(file) {
    const upload = new FormData()
    upload.append('sales_upload[image]', file)

    fetch('/sales_uploads', {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector("[name='csrf-token']").content
      },
      body: upload
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        window.location.href = '/sales_uploads'
      } else {
        console.error('Upload failed:', data.error)
        alert(data.error)
      }
    })
    .catch(error => {
      console.error('Error:', error)
      alert('An error occurred during upload')
    })
  }

  triggerFileInput(e) {
    this.inputTarget.click()
  }
} 
