local order = { "Sovereign", "Warrior", "Pride" }

local Characters = {
	Order = order,
	Default = order[1],
	List = {},
}

for _, id in order do
	local def = require(script:WaitForChild(id))
	def.Id = id
	Characters.List[id] = def
end

function Characters.get(id)
	return Characters.List[id] or Characters.List[Characters.Default]
end

return Characters
