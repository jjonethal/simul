-- simul.lua
-- twoWheelRobot
movingObjects={}
time = 0
motor = {
	Name = "Igarashi SP 3650-065-GHC-29-3",
	Uref = 6.0,   -- [V]olt
	N0   = 5600,  -- leerlaufdrehzahl [1/min]
	I0   = 0.6,   -- leerlauf strom   [A]
	Mmax = 0.065, -- Anhaltemoment    [N*m]
	Imax = 7.5,   -- Anlaufstrom      [A]
	init = function(m,J)
		initMotor(m,J)
	end,
	new = function(self,J)
		print("new motor")
		local t = {}
		local mt = getmetatable(t) or {}
		mt.__index=self
		setmetatable(t,mt)
		t:init(J)
		return t
	end
}

function initMotor(m,J)
	m.Ri = m.Uref / m.Imax  -- Ohmscher Widerstand
	m.Km = m.Mmax / m.Imax  -- Drehmomentkonstante
	m.Kn = m.N0   / m.Uref  -- Drehzahlkonstante
	m.Mr = m.Km   * m.I0    -- reibmoment
	m.Pwm = 1
	m.N   = 0
	m.J   = J
end

function motor.step(m,dt)
	m.U    = m.Pwm * m.Uref
	m.Uind = m.N   / m.Kn
	m.I    = (m.U   - m.Uind) / m.Ri
	m.M    = m.Km  * m.I  -- drehmoment = DrehmomentKonstante * Strom
	m.a    = m.M   / m.J  -- winkel beschleunigung
	m.N    = m.N + dt * m.a
end



robot2w = {
	x             = 0.0,
	y             = 0.0,
	vx            = 0.0,
	vy            = 0.0,
	m             = 0.5,  -- masse [kg]
	phi           = 0.0,  -- bewegungsrichtung in [radian]
	wheelDistance = 0.3,  -- rad abstand in [m]
	wheelDiameter = 0.05, -- rad durchmesser [m]
	wL            = 0,
	wR            = 0,
	wmax          = 5600, -- rpm maximum rpm
	pwmL          = 0,
	pwmR          = 0,
	
	step = function(r,dt) end,
	mL            = motor:new(0.5*(0.05/2)^2),
	mR            = motor:new(0.5*(0.05/2)^2),
}

function dumpRobot2w(r)
	io.write(string.format("\r%5.3f aL:%2.3f Nl:%2.3f",time,r.mL.a,r.mL.N))
end

function robot2w:step(dt)
	self.mL:step(dt)
	self.mR:step(dt)
	dumpRobot2w(self)
end

movingObjects[1]=robot2w

function step(dt)
	for k,o in pairs(movingObjects) do
		o:step(dt)
	end
end

for i=1,300000 do
	step(0.001)
	time = time + 0.001
end

