import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "categorySelect",
    "productSelect",
    "quantityInput",
    "unitPriceDisplay",
    "productsList",
    "total",
    "totalInput"
  ]

  connect() {
    this.updateTotal()
  }

  filterProducts() {
    const selectedCategory = this.categorySelectTarget.value
    const productOptions = this.productSelectTarget.options

    for (let i = 0; i < productOptions.length; i++) {
      const option = productOptions[i]
      if (option.value !== "") {
        const productCategory = option.dataset.category
        option.hidden = selectedCategory !== "" && productCategory !== selectedCategory
      }
    }

    // Reset product selection and price
    this.productSelectTarget.value = ""
    this.unitPriceDisplayTarget.value = "0.00"
  }

  updatePrice() {
    const selectedOption = this.productSelectTarget.selectedOptions[0]
    if (selectedOption && selectedOption.value) {
      const price = selectedOption.dataset.price
      this.unitPriceDisplayTarget.value = parseFloat(price).toFixed(2)
    } else {
      this.unitPriceDisplayTarget.value = "0.00"
    }
  }

  addProduct(event) {
    event.preventDefault()

    const productSelect = this.productSelectTarget
    const selectedProduct = productSelect.selectedOptions[0]
    if (!selectedProduct || !selectedProduct.value) return

    const quantity = parseInt(this.quantityInputTarget.value)
    const unitPrice = parseFloat(this.unitPriceDisplayTarget.value)
    const total = quantity * unitPrice

    const tr = document.createElement('tr')
    tr.innerHTML = `
      <td class="py-3 px-6">${selectedProduct.text}</td>
      <td class="text-right py-3 px-6">$${unitPrice.toFixed(2)}</td>
      <td class="text-right py-3 px-6">${quantity}</td>
      <td class="text-right py-3 px-6">$${total.toFixed(2)}</td>
      <td class="text-center py-3 px-6">
        <div class="d-flex justify-content-center">
          <button type="button"
                  class="btn btn-danger btn-sm d-flex align-items-center gap-2 rounded"
                  data-action="click->purchases-form#removeProduct">
            <i class="fas fa-trash"></i>
          </button>
        </div>
        <input type="hidden" name="purchase[purchase_details_attributes][][product_id]" value="${selectedProduct.value}">
        <input type="hidden" name="purchase[purchase_details_attributes][][quantity]" value="${quantity}">
        <input type="hidden" name="purchase[purchase_details_attributes][][unit_price]" value="${unitPrice}">
      </td>
    `

    this.productsListTarget.appendChild(tr)
    this.updateTotal()

    // Reset form
    productSelect.value = ""
    this.categorySelectTarget.value = ""
    this.quantityInputTarget.value = "1"
    this.unitPriceDisplayTarget.value = "0.00"
  }

  removeProduct(event) {
    const tr = event.target.closest('tr')
    tr.remove()
    this.updateTotal()
  }

  updateTotal() {
    let total = 0
    this.productsListTarget.querySelectorAll('tr').forEach(tr => {
      const priceCell = tr.cells[3]
      if (priceCell) {
        const price = parseFloat(priceCell.textContent.replace('$', '')) || 0
        total += price
      }
    })

    this.totalTarget.textContent = total.toFixed(2)
    this.totalInputTarget.value = total.toFixed(2)
  }
}
