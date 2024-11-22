import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["product", "quantity", "unitPrice", "subtotal"]

  connect() {
    this.updateSubtotal()
  }

  updatePrice() {
    const productId = this.productTarget.value
    if (productId) {
      fetch(`/products/${productId}/price`)
        .then(response => response.json())
        .then(data => {
          this.unitPriceTarget.value = data.price
          this.updateSubtotal()
        })
    }
  }

  updateSubtotal() {
    const quantity = parseFloat(this.quantityTarget.value) || 0
    const unitPrice = parseFloat(this.unitPriceTarget.value) || 0
    const subtotal = quantity * unitPrice

    this.subtotalTarget.textContent = `$${subtotal.toFixed(2)}`
    this.dispatch("subtotalChanged", { detail: { subtotal } })
  }
}
