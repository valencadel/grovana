# README

# Grovana - AI-Powered Business Management System 🚀

Grovana is a modern web application for comprehensive business management that leverages artificial intelligence for automated invoice processing. Built with Ruby on Rails and designed to streamline daily business operations.

## Features ✨

### 🤖 AI Integration
- Automated invoice processing using Gemini AI
- Intelligent document-to-data conversion
- Automatic data extraction from uploaded images

### 💼 Business Management
- Complete sales and purchase cycle management
- Real-time inventory tracking
- Customer and supplier relationship management
- Multi-company support
- Employee management with role-based access

### 📊 Analytics & Reporting
- Interactive dashboard with key metrics
- Sales and purchase trends visualization
- Inventory status monitoring
- Financial performance tracking
- Customizable date range reports

### 🗺️ Location Services
- Customer location tracking
- Address geocoding
- Interactive maps integration

## Prerequisites 🛠️

- Ruby 3.1.2
- Rails 7.1.2
- PostgreSQL
- Gemini API Key
- Mapbox API Key

## Installation 📦

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/grovana.git
cd grovana
```

2. **Install dependencies**
```bash
bundle install
```

3. **Database Setup**
```bash
rails db:create
rails db:migrate
rails db:seed
```

4. **Configure environment variables**

Create a `.env` file in the root directory and add:
```bash
GEMINI_API_KEY=your_gemini_api_key
MAPBOX_API_KEY=your_mapbox_api_key
```

5. **Start the server**
```bash
rails server
```

## Dependencies 📦

```ruby
source "https://rubygems.org"

# Core
ruby "3.1.2"
gem "rails", "~> 7.1.2"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"

# Authentication & Authorization
gem "devise"
gem "pundit"

# Frontend
gem "sprockets-rails"
gem "jsbundling-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "sassc-rails"

# File Processing
gem "image_processing", "~> 1.2"

# AI & APIs
gem "gemini-ai"
gem "geocoder"

# Utilities
gem "bootsnap", require: false
gem "tzinfo-data"
gem "browser"
gem "chartkick"
gem "groupdate"

# Development & Testing
group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
end

group :development do
  gem "web-console"
  gem "error_highlight", ">= 0.4.0", platforms: [:ruby]
end
```

## Database Schema 📚

### Core Models and Relationships

#### User
- `has_many :companies`
- `belongs_to :company` (optional)
- Fields: email, first_name, last_name, phone

#### Company
- `belongs_to :user`
- `has_many :users`
- `has_many :customers`
- `has_many :products`
- `has_many :employees`
- `has_many :suppliers`
- `has_many :purchases`
- `has_many :uploads`
- `has_many :sales_uploads`
- Fields: name (unique, max 100 chars)

#### Product
- `belongs_to :company`
- `has_many :purchase_details`
- `has_many :purchases`, through: :purchase_details
- `has_many :sale_details`
- `has_many :sales`, through: :sale_details
- Fields: name, price, stock, min_stock, status

#### Sale
- `belongs_to :customer`
- `has_many :sale_details`
- `has_many :products`, through: :sale_details
- Fields: payment_method, sale_date, total_price

#### Purchase
- `belongs_to :supplier`
- `belongs_to :company`
- `has_many :purchase_details`
- `has_many :products`, through: :purchase_details
- Fields: order_date, expected_delivery_date, total_price

#### Customer
- `belongs_to :company`
- `has_many :sales`
- Fields: first_name, last_name, email, phone, tax_id, address
- Includes geocoding for address

#### Supplier
- `has_many :purchases`
- `belongs_to :company`
- Fields: company_name, email, tax_id, phone

#### Employee
- `belongs_to :company`
- Devise authentication
- Fields: email, first_name, last_name, role, status

#### Upload & SalesUpload
- `belongs_to :company`
- `has_one_attached :image`
- AI document processing capabilities

## Security Features 🔐

- Multi-level authentication
- Role-based access control
- CSRF protection
- SQL injection prevention
- XSS protection
- Secure password handling

## Browser Support 🌐

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

## Development 🛠️

### Running Tests
```bash
rails test
```

### Code Style
```bash
rubocop
```

### Generate Documentation
```bash
yard doc
```

## Contributing 🤝

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License 📄

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Support 💬

For support, email support@grovana.com or join our Slack channel.

## Acknowledgments 🙏

- Ruby on Rails community
- Gemini AI team
- Mapbox team
- All our contributors

---

Made with ❤️ by Grovana Team

© 2024 Grovana. All rights reserved.
