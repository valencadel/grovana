import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "suggestions"]

  connect() {
    this.selectedIndex = -1

    const urlParams = new URLSearchParams(window.location.search)
    const query = urlParams.get('query')
    if (query) {
      this.inputTarget.value = query
    }

    document.addEventListener('click', (e) => {
      if (!this.element.contains(e.target)) {
        this.hideSuggestions()
      }
    })
  }

  search() {
    const query = this.inputTarget.value

    this.updateURL(query)
    this.filterPurchases(query)

    if (query.length >= 2) {
      fetch(`/suppliers/search?query=${encodeURIComponent(query)}`, {
        headers: {
          "Accept": "application/json"
        }
      })
      .then(response => response.json())
      .then(suppliers => {
        this.showSuggestions(suppliers)
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

  filterPurchases(query) {
    const rows = document.querySelectorAll('table tbody tr')
    rows.forEach(row => {
      const supplierName = row.querySelector('td:nth-child(4)').textContent.toLowerCase() // Ajusta el índice según la posición de la columna Supplier
      if (query.length === 0 || supplierName.includes(query.toLowerCase())) {
        row.style.display = ''
      } else {
        row.style.display = 'none'
      }
    })
  }

  showSuggestions(suppliers) {
    if (suppliers.length === 0) {
      this.suggestionsTarget.innerHTML = `
        <div class="px-4 py-3 text-sm text-gray-500">
          No suppliers found
        </div>`
    } else {
      this.suggestionsTarget.innerHTML = suppliers
        .map(supplier => `
          <div class="suggestion-item cursor-pointer transition duration-150 ease-in-out"
               data-action="mousedown->supplier-search#selectSuggestion"
               data-supplier-id="${supplier.id}">
            <div class="flex justify-between items-center px-4 py-3">
              <span class="supplier-name">${supplier.name}</span>
              <span class="supplier-detail text-sm text-gray-500">
                ${supplier.email || supplier.phone || ''}
              </span>
            </div>
          </div>
        `)
        .join('')
    }

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
    const selectedText = event.target.closest('.suggestion-item').querySelector('.supplier-name').textContent
    this.inputTarget.value = selectedText
    this.hideSuggestions()
    this.filterPurchases(selectedText)
    this.updateURL(selectedText)
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
          const selectedText = selectedItem.querySelector('.supplier-name').textContent
          this.inputTarget.value = selectedText
          this.hideSuggestions()
          this.filterPurchases(selectedText)
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
        item.classList.add('bg-indigo-50')
      } else {
        item.classList.remove('bg-indigo-50')
      }
    })
  }
}
