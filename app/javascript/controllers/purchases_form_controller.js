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
    console.log("Purchases form controller connected")
    this.updateTotal()
  }

  filterProducts() {
    console.log("Filtering products")
    const selectedCategory = this.categorySelectTarget.value
    const productOptions = this.productSelectTarget.options

    for (let i = 0; i < productOptions.length; i++) {
      const option = productOptions[i]
      if (option.value === "") continue

      const productCategory = option.dataset.category
      option.style.display = !selectedCategory || productCategory === selectedCategory ? "" : "none"
    }

    this.productSelectTarget.value = ""
    this.updatePrice()
  }

  updatePrice() {
    console.log("Updating price")
    const selectedOption = this.productSelectTarget.selectedOptions[0]
    if (selectedOption && selectedOption.value) {
      const price = selectedOption.dataset.price
      console.log("Selected price:", price)
      this.unitPriceDisplayTarget.value = price
    } else {
      this.unitPriceDisplayTarget.value = ""
    }
  }

  addProduct(event) {
    console.log("Adding product")
    event.preventDefault()

    const productSelect = this.productSelectTarget
    const selectedOption = productSelect.selectedOptions[0]

    if (!selectedOption || !selectedOption.value) {
      alert("Por favor seleccione un producto")
      return
    }

    const quantity = parseInt(this.quantityInputTarget.value)
    if (!quantity || quantity < 1) {
      alert("Por favor ingrese una cantidad válida")
      return
    }

    const productId = selectedOption.value
    const productName = selectedOption.text
    const unitPrice = parseFloat(this.unitPriceDisplayTarget.value)
    const total = quantity * unitPrice

    console.log("Adding product with:", { productId, productName, unitPrice, quantity, total })

    const newRow = document.createElement('tr')
    newRow.className = 'nested-fields'

    const timestamp = new Date().getTime()
    const rowHtml = `
      <td class="py-3 px-6">${productName}</td>
      <td class="text-right py-3 px-6">$${unitPrice.toFixed(2)}</td>
      <td class="text-right py-3 px-6">${quantity}</td>
      <td class="text-right py-3 px-6">$${total.toFixed(2)}</td>
      <td class="text-center py-3 px-6">
        <div class="d-flex justify-content-center">
          <button type="button"
                  class="btn btn-danger btn-sm d-flex align-items-center gap-2"
                  data-action="click->purchases-form#removeProduct">
            <i class="fas fa-trash"></i>
          </button>
        </div>
        <input type="hidden" name="purchase[purchase_details_attributes][${timestamp}][product_id]" value="${productId}">
        <input type="hidden" name="purchase[purchase_details_attributes][${timestamp}][quantity]" value="${quantity}">
        <input type="hidden" name="purchase[purchase_details_attributes][${timestamp}][unit_price]" value="${unitPrice}">
      </td>
    `
    newRow.innerHTML = rowHtml
    this.productsListTarget.appendChild(newRow)

    productSelect.value = ""
    this.quantityInputTarget.value = "1"
    this.unitPriceDisplayTarget.value = ""

    this.updateTotal()
  }

  removeProduct(event) {
    const row = event.target.closest('tr')
    if (row) {
      row.remove()
      this.updateTotal()
    }
  }

  updateTotal() {
    let total = 0
    const rows = this.productsListTarget.querySelectorAll('tr')

    rows.forEach(row => {
      const quantityInput = row.querySelector('input[name*="[quantity]"]')
      const priceInput = row.querySelector('input[name*="[unit_price]"]')

      if (quantityInput && priceInput) {
        const quantity = parseFloat(quantityInput.value) || 0
        const price = parseFloat(priceInput.value) || 0
        total += quantity * price
      }
    })

    this.totalTarget.textContent = `$${total.toFixed(2)}`
    this.totalInputTarget.value = total
  }
}
