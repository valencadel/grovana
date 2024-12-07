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
    this.filterSales(query)

    if (query.length >= 2) {
      fetch(`/sales/search?query=${encodeURIComponent(query)}`, {
        headers: {
          "Accept": "application/json"
        }
      })
      .then(response => response.json())
      .then(sales => {
        this.showSuggestions(sales)
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

  filterSales(query) {
    if (!query) {
      document.querySelectorAll('table tbody tr').forEach(row => {
        row.style.display = ''
      })
      return
    }

    const searchTerm = query.toLowerCase()
    const rows = document.querySelectorAll('table tbody tr')

    rows.forEach(row => {
      const clientName = row.querySelector('td:nth-child(2)').textContent.toLowerCase()
      const saleDate = row.querySelector('td:nth-child(1)').textContent.toLowerCase()

      if (clientName.includes(searchTerm) || saleDate.includes(searchTerm)) {
        row.style.display = ''
      } else {
        row.style.display = 'none'
      }
    })
  }

  showSuggestions(sales) {
    if (sales.length === 0) {
      this.suggestionsTarget.innerHTML = `
        <div class="px-4 py-3 text-sm text-gray-500">
          No matches found
        </div>`
    } else {
      this.suggestionsTarget.innerHTML = sales
        .map(sale => `
          <div class="suggestion-item cursor-pointer transition duration-150 ease-in-out hover:bg-indigo-50"
               data-action="mousedown->sale-search#selectSuggestion">
            <div class="flex justify-between items-center px-4 py-3">
              <span class="client-name">${sale.client_name}</span>
              <div class="text-sm text-gray-500">
                <span class="order-date">${sale.sale_date}</span>
                <span class="ml-2">${sale.total_price}</span>
              </div>
            </div>
          </div>
        `)
        .join('')
    }

    this.suggestionsTarget.classList.remove('hidden')
  }

  hideSuggestions() {
    this.suggestionsTarget.classList.add('hidden')
    this.selectedIndex = -1
  }

  selectSuggestion(event) {
    event.preventDefault()
    const item = event.target.closest('.suggestion-item')
    const selectedText = item.querySelector('.client-name').textContent

    this.inputTarget.value = selectedText
    this.hideSuggestions()
    this.filterSales(selectedText)
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
          const selectedText = selectedItem.querySelector('.client-name').textContent
          this.inputTarget.value = selectedText
          this.hideSuggestions()
          this.filterSales(selectedText)
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
