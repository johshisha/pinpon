json.array!(@attacks) do |attack|
  json.extract! attack, :id, :attacker_id, :defender_id
  json.url attack_url(attack, format: :json)
end
