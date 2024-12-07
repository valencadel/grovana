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

    if (this.hasProductSelectTarget) {
      this.productSelectTarget.addEventListener('change', this.updateUnitPrice.bind(this))
    }

    // Inicializar los detalles existentes
    const existingDetails = this.element.querySelectorAll('.nested-fields')
    existingDetails.forEach(detail => {
      const deleteButton = detail.querySelector('[data-action*="purchases-form#removeProduct"]')
      if (deleteButton) {
        deleteButton.addEventListener('click', this.removeProduct.bind(this))
      }
    })

    // Actualizar el total inicial
    this.updateTotal()
  }

  updateUnitPrice() {
    this.unitPriceDisplayTarget.value = ''
  }

  addProduct(event) {
    event.preventDefault()

    const productSelect = this.productSelectTarget
    const quantityInput = this.quantityInputTarget
    const selectedOption = productSelect.selectedOptions[0]

    if (!selectedOption || !selectedOption.value) {
      alert("Por favor seleccione un producto")
      return
    }

    const productId = selectedOption.value
    const productName = selectedOption.text
    const price = parseFloat(this.unitPriceDisplayTarget.value.replace('$', ''))
    const quantity = parseInt(quantityInput.value)

    if (isNaN(quantity) || quantity <= 0) {
      alert("Por favor ingrese una cantidad válida")
      return
    }

    const subtotal = (quantity * price).toFixed(2)
    const nextIndex = this.productsListTarget.children.length

    const detailHtml = `
      <tr class="nested-fields" data-new-record="true">
        <td class="py-3 px-6">${productName}</td>
        <td class="text-right py-3 px-6">$${price.toFixed(2)}</td>
        <td class="text-right py-3 px-6">${quantity}</td>
        <td class="text-right py-3 px-6">$${subtotal}</td>
        <td class="text-center py-3 px-6">
          <div class="d-flex justify-content-center">
            <button type="button"
                    class="btn btn-danger btn-sm d-flex align-items-center gap-2 rounded"
                    data-action="click->purchases-form#removeProduct">
              <i class="fas fa-trash"></i>
            </button>
          </div>
          <input type="hidden" name="purchase[purchase_details_attributes][${nextIndex}][product_id]" value="${productId}">
          <input type="hidden" name="purchase[purchase_details_attributes][${nextIndex}][quantity]" value="${quantity}">
          <input type="hidden" name="purchase[purchase_details_attributes][${nextIndex}][unit_price]" value="${price}">
        </td>
      </tr>
    `

    this.productsListTarget.insertAdjacentHTML('beforeend', detailHtml)

    // Resetear campos
    productSelect.value = ""
    quantityInput.value = "1"
    this.unitPriceDisplayTarget.value = ""

    this.updateTotal()
  }

  removeProduct(event) {
    const row = event.target.closest('tr')
    const detailId = row.querySelector('input[name*="[id]"]')?.value

    if (detailId) {
      // Si existe un ID, es un registro existente, agregamos el campo _destroy
      const destroyInput = document.createElement('input')
      destroyInput.type = 'hidden'
      destroyInput.name = `purchase[purchase_details_attributes][${detailId}][_destroy]`
      destroyInput.value = '1'
      row.appendChild(destroyInput)
      row.style.display = 'none'
    } else {
      // Si no existe ID, es un nuevo registro, simplemente removemos la fila
      row.remove()
    }

    this.updateTotal()
  }

  updateTotal() {
    let total = 0
    this.element.querySelectorAll('.nested-fields').forEach(row => {
      if (row.style.display !== 'none') { // Solo contar filas visibles
        const priceText = row.querySelector('td:nth-child(4)').textContent
        const price = parseFloat(priceText.replace('$', ''))
        total += price
      }
    })

    this.totalTarget.textContent = `$${total.toFixed(2)}`
    this.totalInputTarget.value = total
  }

  filterProducts() {
    const selectedCategory = this.categorySelectTarget.value
    const productOptions = this.productSelectTarget.options

    for (let i = 0; i < productOptions.length; i++) {
      const option = productOptions[i]
      if (option.value === "") continue // Skip placeholder option

      if (!selectedCategory || option.dataset.category === selectedCategory) {
        option.style.display = ""
      } else {
        option.style.display = "none"
      }
    }

    // Reset product selection
    this.productSelectTarget.value = ""
    this.unitPriceDisplayTarget.value = ""
  }
}
