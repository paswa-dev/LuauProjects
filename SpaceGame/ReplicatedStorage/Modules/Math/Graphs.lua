local graphs = {}

function graphs.figuregraph(t: number, frequency: number)
	frequency = frequency or 2
	return Vector2.new(
		math.cos(
			t * (frequency * 0.5)
		),
		math.sin(
			t * frequency
		)
	)
end

return graphs