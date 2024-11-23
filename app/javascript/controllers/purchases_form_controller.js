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
    this.quantityInputTarget.addEventListener('keypress', (e) => {
      if (e.key === 'Enter') {
        e.preventDefault();
        return false;
      }
    });
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
    const selectedOption = this.productSelectTarget.selectedOptions[0];
    console.log("Selected option:", selectedOption);

    if (selectedOption && selectedOption.value) {
      const price = selectedOption.dataset.price;
      console.log("Raw price from dataset:", price);

      if (price) {
        const numericPrice = parseFloat(price);
        console.log("Parsed numeric price:", numericPrice);
        this.unitPriceDisplayTarget.value = numericPrice.toFixed(2);
        console.log("Final formatted price:", this.unitPriceDisplayTarget.value);
      } else {
        this.unitPriceDisplayTarget.value = "0.00";
      }
    } else {
      this.unitPriceDisplayTarget.value = "0.00";
    }
  }

  addProduct(event) {
    event.preventDefault()
    const selectedOption = this.productSelectTarget.selectedOptions[0]

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

    const newRow = document.createElement('tr')
    newRow.className = 'nested-fields'
    const timestamp = new Date().getTime()

    newRow.innerHTML = `
      <td class="py-3 px-6">${productName}</td>
      <td class="text-right py-3 px-6">$${unitPrice.toFixed(2)}</td>
      <td class="text-right py-3 px-6">${quantity}</td>
      <td class="text-right py-3 px-6">$${total.toFixed(2)}</td>
      <td class="text-center py-3 px-6">
        <button type="button"
                class="btn btn-danger btn-sm"
                data-action="click->purchases-form#removeProduct">
          <i class="bi bi-trash"></i>
          Eliminar
        </button>
        <input type="hidden" name="purchase[purchase_details_attributes][${timestamp}][product_id]" value="${productId}">
        <input type="hidden" name="purchase[purchase_details_attributes][${timestamp}][quantity]" value="${quantity}">
        <input type="hidden" name="purchase[purchase_details_attributes][${timestamp}][unit_price]" value="${unitPrice}">
      </td>
    `

    this.productsListTarget.appendChild(newRow)
    this.resetForm()
    this.updateTotal()
  }

  resetForm() {
    this.productSelectTarget.value = ""
    this.quantityInputTarget.value = "1"
    this.unitPriceDisplayTarget.value = "0.00"
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
