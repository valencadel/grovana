import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["subtotal"]

  connect() {
    this.updateSubtotal()
  }

  updateSubtotal() {
    const quantity = parseFloat(this.element.querySelector('input[name*="[quantity]"]').value) || 0
    const price = parseFloat(this.element.querySelector('input[name*="[unit_price]"]').value) || 0
    const subtotal = quantity * price

    this.subtotalTarget.textContent = `$${subtotal.toFixed(2)}`

    // Actualizar la fila correspondiente en el resumen
    const rowIndex = Array.from(this.element.parentNode.children).indexOf(this.element)
    const summaryBody = document.querySelector('[data-sales-form-target="summaryBody"]')
    if (summaryBody && summaryBody.children[rowIndex]) {
      const summaryRow = summaryBody.children[rowIndex]
      summaryRow.querySelector('td:last-child').textContent = `$${subtotal.toFixed(2)}`
    }

    // Disparar evento para actualizar el total general
    const event = new CustomEvent('sale-detail:subtotalChanged', {
      bubbles: true,
      detail: { subtotal }
    })
    this.element.dispatchEvent(event)
  }
}
