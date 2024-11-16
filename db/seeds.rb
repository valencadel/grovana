# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Limpiando base de datos..."
Employee.destroy_all
Company.destroy_all
User.destroy_all
# Creando usuarios
puts "Creando usuarios..."
users = [
  { first_name: "Valentin", last_name: "Cadel", email: "valentin@ejemplo.com", password: "123456" },
  { first_name: "Roberto", last_name: "Prada", email: "roberto@ejemplo.com", password: "123456" },
  { first_name: "Omar", last_name: "Gonzales", email: "omar@ejemplo.com", password: "123456" }
]
created_users = users.map do |user_data|
  User.create!(user_data)
end
# Creando empresas
puts "Creando empresas..."
companies = [
  { name: "Tech Corp", description: "Empresa de tecnología innovadora", user_id: created_users[0].id },
  { name: "Consultores Asociados", description: "Consultoría empresarial y estratégica", user_id: created_users[1].id },
  { name: "Construcciones Modernas", description: "Líderes en construcción sustentable", user_id: created_users[2].id }
]
created_companies = companies.map do |company_data|
  Company.create!(company_data)
end
# Creando empleados
puts "Creando empleados..."
employees = [
  { first_name: "Carlos", last_name: "Pérez", status: "Activo", company_id: created_companies[0].id, user_id: created_users[0].id },
  { first_name: "Ana", last_name: "López", status: "Activo", company_id: created_companies[1].id, user_id: created_users[1].id },
  { first_name: "Juan", last_name: "García", status: "Activo", company_id: created_companies[2].id, user_id: created_users[2].id }
]
employees.each do |employee_data|
  Employee.create!(employee_data)
end
puts "Datos creados exitosamente!"
