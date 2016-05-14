json.array!(@users) do |user|
  json.extract! user, :id, :name, :mail, :pass, :UUID
  json.url user_url(user, format: :json)
end
