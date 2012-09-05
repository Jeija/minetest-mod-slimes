SLIME_SIZE = 0.5
SLIME_BOX = math.sqrt(2*math.pow(SLIME_SIZE, 2))/2

minetest.register_entity("slimes:small",{
	initial_properties = {
		hp_max = 4,
		visual_size = {x = SLIME_SIZE, y = SLIME_SIZE, z = SLIME_SIZE},
		visual = "cube",
		textures = {"default_cactus_top.png"},
		collisionbox = {-SLIME_BOX, -0.25, -SLIME_BOX, SLIME_BOX, 0.25, SLIME_BOX},
		physical = true,
	},

	timer = 0,
	timer2 = 0,
	yaw = 0,
	direction = {},
	ground_touched = false,

	on_activate = function(self)
		self.yaw = math.random() * 360
		self.direction = {x = math.cos(self.yaw), y = 5, z = math.sin(self.yaw)}
		self.object:setacceleration({x = 0, y = -9.8, z = 0})
	end,

	on_punch = function(self)
		self.object:remove()
	end,

	on_step = function(self, dtime)
		local pos = self.object:getpos()
		self.timer = self.timer + dtime
		self.timer2 = self.timer2 + dtime

		if self.timer > 4 then
			if slime_lonely(pos) and not minetest.env:find_node_near(pos, 32, "default:mese") then
				self.object:remove()
			end
			ground_touched = false
			self.timer = 0
			self.yaw = math.random() * 360
			self.direction = {x = math.cos(self.yaw), y = 5, z = math.sin(self.yaw)}
		end

		if self.timer2 > 1 then
			local nu = minetest.env:get_node({x = pos.x, y = pos.y - self.initial_properties.visual_size.y/1.99, z = pos.z})
			if nu.name ~= "air" then
				self.object:setyaw(self.yaw)
				self.object:setvelocity(self.direction)
				self.timer2 = 0
			end
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

minetest.register_abm({
	nodenames = {"default:dirt_with_grass"},
	interval = 10.0,
	chance = 10000,
	action = function(pos, node)
		minetest.env:add_entity({x=pos.x, y=pos.y+0.75, z=pos.z}, "slimes:small")
	end,
})

