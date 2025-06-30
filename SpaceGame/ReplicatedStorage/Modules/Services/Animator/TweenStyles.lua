return {
	outQuad = (function(x) return 1 - (1 - x) * (1 - x); end),
	outQuint = (function(x) return 1 - math.pow(1 - x, 5); end),
	outExpo = (function(x) return (x == 1 and 1 or 1) - math.pow(2, -10 * x); end),
	outSine = (function(x) return math.sin((x * math.pi) * 0.5); end),
	inOutExpo = (
		function(x)
			return (x == 0) and 0 or (x == 1) and 1 or (x < 0.5) and math.pow(2, 20 * x - 10) * 0.5 or (2 - math.pow(2, -20 * x + 10)) * 0.5;
		end
	),
	inOutCircle = (
		function(x)
			return x < 0.5
				and (1 - math.sqrt(1 - math.pow(2 * x, 2))) * 0.5
				or (math.sqrt(1 - math.pow(-2 * x + 2, 2)) + 1) * 0.5;
		end
	),
	inOutSine = (function(x) return -(math.cos(math.pi * x) - 1) * 0.5; end)
}