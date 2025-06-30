local Camera = _G.get "Services/Animator"

return {
	Camera.keySingle(CFrame.new(0, 0, -3), 0.8, nil, "inOutExpo"),
	Camera.keySingle(CFrame.Angles(math.rad(30), 0, 0), 0, 0.1, "outSine"),
	Camera.keySingle(CFrame.Angles(math.rad(-70), 0, 0), 0.1, 0.3, "outSine"),
	Camera.keySingle(CFrame.Angles(0, math.rad(20), 0), 0.35, 0.5, "inOutSine"),
	Camera.keySingle(CFrame.fromEulerAnglesYXZ(math.rad(40), math.rad(-20), 0), 0.6, 0.8, "inOutSine")
}