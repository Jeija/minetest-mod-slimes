minetest.register_entity("slimes:small",{
	initial_properties = {
		hp_max = 4,
		visual_size = {x = 0.5, y = 0.5, z = 0.5},
		visual = "cube",
		textures = {"default_cactus_top.png"},
		selection_box = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
	},

	timer = 0,
	yaw = 0,
	direction = {},
	ground_touched = false,

	on_activate = function(self)
		self.yaw = math.random() * 360
		self.direction = {x = math.cos(self.yaw), y = 5, z = math.sin(self.yaw)}
	end,

	on_punch = function(self)
		self.object:remove()
	end,

	on_step = function(self, dtime)
		local pos = self.object:getpos()
		self.timer = self.timer + dtime

		if self.timer > 4 then
			if slime_lonely(pos) and not minetest.env:find_node_near(pos, 32, "default:mese") then
				self.object:remove()
			end
			if not ground_touched then
				self.object:setacceleration({x = 0, y = -1, z = 0})
			end
			ground_touched = false
			self.timer = 0
			self.yaw = math.random() * 360
			self.direction = {x = math.cos(self.yaw), y = 5, z = math.sin(self.yaw)}
		end

		if slime_collides(pos, self.direction, self.initial_properties.visual_size.x) then
			self.direction = {x = 0, y = 4, z = 0}
		end

		local nu = minetest.env:get_node({x = pos.x, y = pos.y - self.initial_properties.visual_size.y/1.99, z = pos.z})
		if nu.name ~= "air" then
			ground_touched = true
			self.object:setyaw(self.yaw)
			self.object:setvelocity(self.direction)
			self.object:setacceleration({x = 0, y = -9.8, z = 0})
		end
	end,
})

function slime_collides(pos, direction, size)
	local np = {	x = pos.x + direction.x * size * 2,
			y = pos.y + 1,
			z = pos.z + direction.z * size * 2,}
	local node = minetest.env:get_node(np)
	if node.name ~= "air" then return true end
	return false
end

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
	chance = 100000,
	action = function(pos, node)
		minetest.env:add_entity({x=pos.x, y=pos.y+0.75, z=pos.z}, "slimes:small")
	end,
})

