json.array!(@points) do |point|
  json.extract! point, :id, :point, :user_name
  json.url point_url(point, format: :json)
end
