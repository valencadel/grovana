import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    wrapperSelector: String,
    template: String
  }

  add(event) {
    event.preventDefault()
    const content = this.templateValue.replace(/NEW_RECORD/g, new Date().getTime())
    this.element.closest("form")
      .querySelector(this.wrapperSelectorValue)
      .insertAdjacentHTML("beforeend", content)
  }

  remove(event) {
    event.preventDefault()
    const wrapper = event.target.closest(".nested-fields")
    if (wrapper.dataset.newRecord === "true") {
      wrapper.remove()
    } else {
      wrapper.style.display = "none"
      wrapper.querySelector("input[name*='_destroy']").value = "1"
    }
  }
}
