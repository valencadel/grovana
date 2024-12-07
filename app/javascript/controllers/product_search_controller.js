import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "suggestions", "productList"]

  connect() {
    this.selectedIndex = -1

    // Mantener el valor de búsqueda al cargar la página
    const urlParams = new URLSearchParams(window.location.search)
    const query = urlParams.get('query')
    if (query) {
      this.inputTarget.value = query
    }

    // Cerrar sugerencias al hacer click fuera
    document.addEventListener('click', (e) => {
      if (!this.element.contains(e.target)) {
        this.hideSuggestions()
      }
    })
  }

  search() {
    const query = this.inputTarget.value

    // Actualizar URL sin recargar
    this.updateURL(query)

    // Filtrar productos en tiempo real
    this.filterProducts(query)

    // Mostrar sugerencias si hay 2 o más caracteres
    if (query.length >= 2) {
      fetch(`/products/search?query=${encodeURIComponent(query)}`, {
        headers: {
          "Accept": "application/json"
        }
      })
      .then(response => response.json())
      .then(products => {
        this.showSuggestions(products)
      })
    } else {
      this.hideSuggestions()
    }
  }

  updateURL(query) {
    const url = new URL(window.location)
    if (query) {
      url.searchParams.set('query', query)
    } else {
      url.searchParams.delete('query')
    }
    window.history.pushState({}, '', url)
  }

  filterProducts(query) {
    const rows = document.querySelectorAll('table tbody tr')
    rows.forEach(row => {
      const productName = row.querySelector('td:first-child').textContent.toLowerCase()
      if (query.length === 0 || productName.includes(query.toLowerCase())) {
        row.style.display = ''
      } else {
        row.style.display = 'none'
      }
    })
  }

  showSuggestions(products) {
    if (products.length === 0) {
      this.suggestionsTarget.innerHTML = `
        <div class="px-4 py-3 text-sm text-gray-500">
          No products found
        </div>`
    } else {
      this.suggestionsTarget.innerHTML = products
        .map(product => `
          <div class="suggestion-item cursor-pointer transition duration-150 ease-in-out"
               data-action="mousedown->product-search#selectSuggestion"
               data-product-id="${product.id}">
            <div class="flex justify-between items-center px-4 py-3">
              <span class="product-name">${product.name}</span>
              <span class="product-stock">
                Stock: ${product.stock}
              </span>
            </div>
          </div>
        `)
        .join('')
    }

    // Agregar animación
    this.suggestionsTarget.classList.remove('hidden')
    this.suggestionsTarget.classList.add('suggestions-enter')
    requestAnimationFrame(() => {
      this.suggestionsTarget.classList.add('suggestions-enter-active')
    })
  }

  hideSuggestions() {
    this.suggestionsTarget.classList.add('hidden')
    this.selectedIndex = -1
  }

  selectSuggestion(event) {
    event.preventDefault()
    const selectedText = event.target.closest('.suggestion-item').querySelector('span').textContent
    this.inputTarget.value = selectedText
    this.hideSuggestions()
    this.filterProducts(selectedText)
    this.updateURL(selectedText)
  }

  clearSearch() {
    this.inputTarget.value = ''
    this.hideSuggestions()
    this.filterProducts('')
    this.updateURL('')
  }

  navigate(event) {
    const items = this.suggestionsTarget.querySelectorAll('.suggestion-item')

    switch(event.key) {
      case 'ArrowDown':
        event.preventDefault()
        this.selectedIndex = Math.min(this.selectedIndex + 1, items.length - 1)
        this.highlightSuggestion()
        break
      case 'ArrowUp':
        event.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, 0)
        this.highlightSuggestion()
        break
      case 'Enter':
        event.preventDefault()
        if (this.selectedIndex >= 0) {
          const selectedItem = items[this.selectedIndex]
          const selectedText = selectedItem.querySelector('span').textContent
          this.inputTarget.value = selectedText
          this.hideSuggestions()
          this.filterProducts(selectedText)
          this.updateURL(selectedText)
        }
        break
      case 'Escape':
        this.hideSuggestions()
        break
    }
  }

  highlightSuggestion() {
    const items = this.suggestionsTarget.querySelectorAll('.suggestion-item')
    items.forEach((item, index) => {
      if (index === this.selectedIndex) {
        item.classList.add('bg-gray-100')
      } else {
        item.classList.remove('bg-gray-100')
      }
    })
  }
}
