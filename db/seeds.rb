# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
#
# Example for User Groups
#
# [{ id: 100, group: 'admin' }].each do |group|
#   UserGroup.find_or_create_by!(id: group[:id], group: group[:group])
# end
#

[
  {
    email: 'test1@example.com',
    password: 'test'
  },
  {
    email: 'test2@example.com',
    password: 'test'
  },
  {
    email: 'test3@example.com',
    password: 'test'
  },
].each do |user|
  User.create(email: user[:email], password: user[:password])
end
