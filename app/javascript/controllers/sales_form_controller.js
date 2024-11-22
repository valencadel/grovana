import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["totalDisplay", "totalInput"]

  connect() {
    this.updateTotal()
  }

  updateTotal() {
    const details = this.element.querySelectorAll('.nested-fields')
    let total = 0

    details.forEach(detail => {
      const subtotalElement = detail.querySelector('[data-sale-detail-target="subtotal"]')
      if (subtotalElement) {
        const subtotal = parseFloat(subtotalElement.textContent.replace('$', '')) || 0
        total += subtotal
      }
    })

    this.totalDisplayTarget.textContent = `$${total.toFixed(2)}`
    this.totalInputTarget.value = total.toFixed(2)
  }
}
