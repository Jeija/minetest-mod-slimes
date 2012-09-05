SLIME_SIZE = 0.5
SLIME_BOX = math.sqrt(2*math.pow(SLIME_SIZE, 2))/2
PI = math.pi

minetest.register_entity("slimes:small",{
	initial_properties = {
		hp_max = 4,
		visual_size = {x = SLIME_SIZE, y = SLIME_SIZE, z = SLIME_SIZE},
		visual = "cube",
		textures = {"slime.png", "slime.png", "slime.png", "slime.png", "slime.png", "slime.png"},
		collisionbox = {-SLIME_BOX, -0.25, -SLIME_BOX, SLIME_BOX, 0.25, SLIME_BOX},
		physical = true,
	},

	timer = 0,
	timer2 = 0,
	yaw = 0,
	direction = {},
	status = 2, --1 = jump, 2 = rotate

	on_activate = function(self)
		self.yaw = math.random() * 360
		self.direction = {x = math.cos(self.yaw), y = 6, z = math.sin(self.yaw)}
		self.object:setacceleration({x = 0, y = -9.8, z = 0})
	end,

	on_punch = function(self)
		self.object:remove()
	end,

	on_step = function(self, dtime)
		if self.status == 2 then
			local oldyaw = self.object:getyaw()
			if oldyaw >= PI then oldyaw = 0 end
			oldyaw = oldyaw + dtime
			self.object:setyaw(oldyaw)
			if approx(oldyaw*360/PI, self.yaw, 3) then
				self.object:setyaw(self.yaw)
				self.status = 1
			end
			return
		end

		self.timer = self.timer + dtime
		self.timer2 = self.timer2 + dtime

		if self.timer > 6 then
			local pos = self.object:getpos()
			if slime_lonely(pos) and not minetest.env:find_node_near(pos, 32, "default:mese") then
				self.object:remove()
			end
			self.yaw = math.random() * 360
			self.direction = {x = math.cos(self.yaw), y = 6, z = math.sin(self.yaw)}
			self.status = 2
			self.object:setvelocity({x = 0, y = 0, z = 0})
			self.timer = 0
			self.timer2 = 1.2
		end

		if self.timer2 > 1.2 then
			local pos = self.object:getpos()
			--local nu = minetest.env:get_node({x = pos.x, y = pos.y - self.initial_properties.visual_size.y/1.99, z = pos.z})
			--if nu.name ~= "air" then
				self.object:setvelocity(self.direction)
				self.timer2 = 0
			--end
		end
	end,
})


function slime_lonely (pos)
	objs = minetest.env:get_objects_inside_radius(pos, 32)
	for i, obj in pairs(objs) do
		if obj:is_player() then return false end
	end
	return true
end

function approx(val1, val2, deviation)
	if val1 + deviation > val2
	and val1 - deviation < val2 then
		return true
	end
	return false
end

minetest.register_abm({
	nodenames = {"default:dirt_with_grass"},
	interval = 10.0,
	chance = 10000,
	action = function(pos, node)
		minetest.env:add_entity({x=pos.x, y=pos.y+0.75, z=pos.z}, "slimes:small")
	end,
})

