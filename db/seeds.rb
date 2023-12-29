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
  { id: 100, group: 'admin' },
  { id: 200, group: 'user' },
  { id: 300, group: 'guest' },
].each do |group|
  UserGroup.find_or_create_by!(id: group[:id], group: group[:group])
end

# [
#   { id: 111, model: 'Lockheed Martin' },
#   { id: 222, model: 'Rockwell International' },
#   { id: 333, model: 'McDonnell Douglas' },
# ].each do |aircraft|
#   Aircraft.find_or_create_by!(id: aircraft[:id], model: aircraft[:model])
# end

[
  {
    email: 'test@example.com',
    password: 'test',
    user_group_id: 100
  }
].each do |user|
  User.create(email: user[:email], password: user[:password], user_group_id: user[:user_group_id])
end
