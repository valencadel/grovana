import { Controller } from "@hotwired/stimulus"
import Swal from 'sweetalert2'

export default class extends Controller {
  static targets = [
    "categorySelect",
    "productSelect",
    "quantityInput",
    "unitPriceDisplay",
    "productsList",
    "total",
    "totalInput",
    "stockDisplay"
  ]

  connect() {
    console.log("Sales form controller connected")

    if (this.hasProductSelectTarget) {
      this.productSelectTarget.addEventListener('change', () => {
        this.updateUnitPrice()
        this.updateStockDisplay()
      })
    }

    // Inicializar los detalles existentes
    const existingDetails = this.element.querySelectorAll('.nested-fields')
    existingDetails.forEach(detail => {
      const deleteButton = detail.querySelector('[data-action*="sales-form#removeProduct"]')
      if (deleteButton) {
        deleteButton.addEventListener('click', this.removeProduct.bind(this))
      }
    })

    // Actualizar el total inicial
    this.updateTotal()
  }
  showAlert(text) {
    Swal.fire({
      icon: 'error',
      title: 'Oops...',
      text: text,
    })
  }
  updateUnitPrice() {
    const selectedOption = this.productSelectTarget.selectedOptions[0]
    if (selectedOption && selectedOption.value !== "") {
      const price = selectedOption.dataset.price
      const stock = selectedOption.dataset.stock
      if (price) {
        this.unitPriceDisplayTarget.value = `$${parseFloat(price).toFixed(2)}`
        this.stockDisplayTarget.value = stock
      } else {
        this.unitPriceDisplayTarget.value = ''
        this.stockDisplayTarget.value = ''
      }
    } else {
      this.unitPriceDisplayTarget.value = ''
      this.stockDisplayTarget.value = ''
    }
  }

  addProduct(event) {
    event.preventDefault()

    const productSelect = this.productSelectTarget
    const quantityInput = this.quantityInputTarget
    const selectedOption = productSelect.selectedOptions[0]

    if (!selectedOption || !selectedOption.value) {
      console.log("Por favor seleccione un producto")
      this.showAlert("Por favor seleccione un producto")
      return
    }

    const productId = selectedOption.value
    const productName = selectedOption.text
    const price = parseFloat(this.unitPriceDisplayTarget.value.replace('$', ''))
    const stock = parseInt(selectedOption.dataset.stock)
    const quantity = parseInt(quantityInput.value)

    if (isNaN(quantity) || quantity <= 0) {
      console.log('Por favor ingrese una cantidad válida')
      this.showAlert('Por favor ingrese una cantidad válida')
      return
    }

    if (quantity > stock) {
      console.log('Stock insuficiente.')
      this.showAlert(`Stock insuficiente. Stock disponible: ${stock}`)
      return
    }

    const subtotal = (quantity * price).toFixed(2)
    const nextIndex = this.productsListTarget.children.length

    const detailHtml = `
      <tr class="nested-fields" data-new-record="true">
        <td class="py-3 px-6">${productName}</td>
        <td class="text-right py-3 px-6">$${price.toFixed(2)}</td>
        <td class="text-right py-3 px-6">${quantity}</td>
        <td class="text-right py-3 px-6">${stock}</td>
        <td class="text-right py-3 px-6">$${subtotal}</td>
        <td class="text-center py-3 px-6">
          <div class="d-flex justify-content-center">
            <button type="button"
                    class="btn btn-danger btn-sm d-flex align-items-center gap-2"
                    data-action="click->sales-form#removeProduct">
              <i class="fas fa-trash"></i>
            </button>
          </div>
        </td>
        <input type="hidden" name="sale[sale_details_attributes][${nextIndex}][product_id]" value="${productId}">
        <input type="hidden" name="sale[sale_details_attributes][${nextIndex}][quantity]" value="${quantity}">
        <input type="hidden" name="sale[sale_details_attributes][${nextIndex}][unit_price]" value="${price}">
      </tr>
    `

    // Agregar a la tabla principal
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
      destroyInput.name = `sale[sale_details_attributes][${detailId}][_destroy]`
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
        const priceText = row.querySelector('td:nth-child(2)').textContent
        const quantity = parseInt(row.querySelector('td:nth-child(3)').textContent)
        const price = parseFloat(priceText.replace('$', ''))
        total += price * quantity
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

    // Reset product selection and displays
    this.productSelectTarget.value = ""
    this.unitPriceDisplayTarget.value = ""
    this.stockDisplayTarget.value = ""
  }
}
