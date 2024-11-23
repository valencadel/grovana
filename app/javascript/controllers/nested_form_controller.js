import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  remove(event) {
    event.preventDefault()
    const wrapper = event.target.closest('.nested-fields')

    if (wrapper.dataset.newRecord) {
      wrapper.remove()
    } else {
      wrapper.style.display = 'none'
      const destroyInput = wrapper.querySelector("input[name*='_destroy']")
      if (destroyInput) {
        destroyInput.value = "1"
      }
    }
  }
}
