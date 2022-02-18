-- this is for meshes that dont render in 3d, but are 2d sprites overlaid.
-- If i ever figure out how to texture quads, this will be merged with it
ShapeBillboard = {}; ShapeBillboard.__index = ShapeBillboard;
function ShapeBillboard.new(parent, vec2_extents)
	local self = setmetatable(Shape.new(parent), ShapeBillboard);
	self.type = "ShapeBillboard";
	self.height = 2 * vec2_extents.y;
	self.width  = 2 * vec2_extents.x;
	self.texture = nil;
	self.hflip = false;
	
	return self;
end
setmetatable(ShapeBillboard, {__index = Shape});

-- renders with the position vector at the bottom-center of the image
-- (for now)
function ShapeBillboard:render()
	if not self.texture then return end

	-- first getting the origin point to draw
	local out = CAMERA_MAIN:transform(self.position);
	local tx  = (out.x * CAMERA_MAIN.zoom) + WINDOW_WIDTH / PIXEL_SCALE / 2;
	local ty  = (out.y * CAMERA_MAIN.zoom) + WINDOW_HEIGHT / PIXEL_SCALE / 2;
	
	-- and the position of a hypothetical point above the origin
	out = CAMERA_MAIN:transform(self.position:add(vec3.new(0,-self.height,0)));
	local hx  = (out.x * CAMERA_MAIN.zoom) + WINDOW_WIDTH / PIXEL_SCALE / 2;
	local hy  = (out.y * CAMERA_MAIN.zoom) + WINDOW_HEIGHT / PIXEL_SCALE / 2;
	
	local xsign; if self.hflip then xsign = -1 else xsign = 1 end
	
	local drawnheight = ty - hy;
	local drawnwidth = drawnheight / ( self.height / self.width);
	local sx = xsign * (drawnwidth / self.texture:getWidth());
	local sy = drawnheight / self.texture:getHeight();
	
	-- offscreen culling
	if (ty < 0 and ty - drawnheight < 0) or 
	   (ty > WINDOW_HEIGHT and ty - drawnheight > WINDOW_HEIGHT) then
		return
	end
	if sx > 20 or sy > 20 then return end
	
	love.graphics.setColor(1,1,1)
	love.graphics.draw(self.texture, tx - (xsign * (drawnwidth/2)), ty - drawnheight, 0, sx, sy);
	
	love.graphics.setColor(1,0,0)
	love.graphics.line(tx,ty,hx,hy)
end

-- special subclass of billboard meshes which have 8-directional sprite animations
-- (This will probably need to be entirely reworked when real animation is implemented)
ShapeEightWayBillboard = {}; ShapeEightWayBillboard.__index = ShapeEightWayBillboard;
function ShapeEightWayBillboard.new(parent, vec2_extents)
	local self = setmetatable(ShapeBillboard.new(parent, vec2_extents), ShapeEightWayBillboard);
	
	-- keys: "front", "side", "back", "tqf", "tqb"
	self.textures = {};
	
	return self;
end
setmetatable(ShapeEightWayBillboard, {__index = ShapeBillboard});

function ShapeEightWayBillboard:update()
	local angle = math.atan2( self.position.x - CAMERA_MAIN.position.x, self.position.z - CAMERA_MAIN.position.z )
	print(angle)
	self.hflip = (angle > 0);
	local aa = math.abs(angle)
	
	if aa < math.pi/8 then
		self.texture = self.textures["back"];
	elseif aa < 3*math.pi/8 then
		self.texture = self.textures["tqb"];
	elseif aa < 5*math.pi/8 then
		self.texture = self.textures["side"];
	elseif aa < 7*math.pi/8 then
		self.texture = self.textures["tqf"];
	else
		self.texture = self.textures["front"];
	end
end