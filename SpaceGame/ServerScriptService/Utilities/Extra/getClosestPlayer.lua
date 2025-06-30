return function(point)
	local _c, _d = nil, math.huge
	for _, plr in next, game.Players:GetPlayers() do
		local new_d = plr:DistanceFromCharacter(point)
		if new_d < _d then
			_c = plr
			_d = new_d
		end
	end
	return _c
end