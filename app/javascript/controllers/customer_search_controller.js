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
    this.filterCustomers(query)

    if (query.length >= 2) {
      fetch(`/customers/search?query=${encodeURIComponent(query)}`, {
        headers: {
          "Accept": "application/json"
        }
      })
      .then(response => response.json())
      .then(customers => {
        this.showSuggestions(customers)
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

  filterCustomers(query) {
    if (!query) {
      document.querySelectorAll('table tbody tr').forEach(row => {
        row.style.display = ''
      })
      return
    }

    const searchTerm = query.toLowerCase()
    const rows = document.querySelectorAll('table tbody tr')

    rows.forEach(row => {
      const name = row.querySelector('td:nth-child(1)').textContent.toLowerCase()
      const address = row.querySelector('td:nth-child(2)').textContent.toLowerCase()

      if (name.includes(searchTerm) || address.includes(searchTerm)) {
        row.style.display = ''
      } else {
        row.style.display = 'none'
      }
    })
  }

  showSuggestions(customers) {
    if (customers.length === 0) {
      this.suggestionsTarget.innerHTML = `
        <div class="px-4 py-3 text-sm text-gray-500">
          No matches found
        </div>`
    } else {
      this.suggestionsTarget.innerHTML = customers
        .map(customer => `
          <div class="suggestion-item cursor-pointer transition duration-150 ease-in-out hover:bg-indigo-50"
               data-action="mousedown->customer-search#selectSuggestion">
            <div class="flex flex-col px-4 py-3">
              <span class="customer-name font-medium">${customer.name}</span>
              ${customer.address ? `<span class="text-sm text-gray-500">${customer.address}</span>` : ''}
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
    const selectedText = item.querySelector('.customer-name').textContent

    this.inputTarget.value = selectedText
    this.hideSuggestions()
    this.filterCustomers(selectedText)
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
          const selectedText = selectedItem.querySelector('.customer-name').textContent
          this.inputTarget.value = selectedText
          this.hideSuggestions()
          this.filterCustomers(selectedText)
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
