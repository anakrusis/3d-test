vec2 = {}; vec2.__index = vec2;
function vec2.new(x,y)
	local self = setmetatable({}, vec2);
	self.x = x;
	self.y = y;
	
	return self;
end

vec3 = {}; vec3.__index = vec3;
function vec3.new(x,y,z)
	local self = setmetatable({}, vec3);
	self.x = x;
	self.y = y;
	self.z = z;
	
	self.xy = vec2.new(self.x, self.y)
	self.xz = vec2.new(self.x, self.z)
	self.yz = vec2.new(self.y, self.z)
	
	return self;
end

-- base type for meshes, collision shapes, etc.
-- will have methods for rotation, scaling, translation
Shape = {}; Shape.__index = Shape;
function Shape.new(parent)	
	local self = setmetatable(Node.new(parent), Shape);
	
	-- original set of points (vec3's) with no transforms applied
	self.basepoints = {};
	-- points in their actual position on which all transforms are done
	self.traapoints = {};
	
	self.color = {1,1,1};
	
	return self;
end
setmetatable(Shape, {__index = Node});

function Shape:translate(vec3_offset)
	for i = 1, #self.traapoints do
	
		local nx = self.traapoints[i].x + vec3_offset.x;
		local ny = self.traapoints[i].y + vec3_offset.y;
		local nz = self.traapoints[i].z + vec3_offset.z;
		
		self.traapoints[i] = vec3.new(nx,ny,nz);
		print(self.traapoints[i]);
	end
end

function Shape:rotate(vec3_offset)

end

-- does nothing by default. each shape type will handle this differently
function Shape:render()

end

-- rectangular prism
ShapeBox = {}; ShapeBox.__index = ShapeBox;
function ShapeBox.new(parent, vec3_extents)
	local self = setmetatable(Shape.new(parent), ShapeBox);
	-- extents values
	local ex = vec3_extents.x; local ey = vec3_extents.y; local ez = vec3_extents.z; 
	
	-- the eight vertices of the box shape will here be defined
	table.insert(self.basepoints,  vec3.new(  ex,  ey, ez ))
	table.insert(self.basepoints,  vec3.new( -ex,  ey, ez ))
	table.insert(self.basepoints,  vec3.new( -ex, -ey, ez ))
	table.insert(self.basepoints,  vec3.new(  ex, -ey, ez ))
	
	table.insert(self.basepoints,  vec3.new(  ex,  ey, -ez ))
	table.insert(self.basepoints,  vec3.new( -ex,  ey, -ez ))
	table.insert(self.basepoints,  vec3.new( -ex, -ey, -ez ))
	table.insert(self.basepoints,  vec3.new(  ex, -ey, -ez ))
	
	-- deep copy of points for doing transforms
	-- TODO: deep copy the vector objects so that they can be independently modified!!!
	for i = 1, #self.basepoints do
		table.insert(self.traapoints, self.basepoints[i]);
	end
	
	return self;	
end
setmetatable(ShapeBox, {__index = Shape});

function ShapeBox:render()
	for i = 1, #self.traapoints do
	
		local out = CAMERA_MAIN:transform(self.traapoints[i]);
		local tx  = (out.x * CAMERA_MAIN.zoom) + WINDOW_WIDTH / 2;
		local ty  = (out.y * CAMERA_MAIN.zoom) + WINDOW_HEIGHT / 2;
			--CAMERA_MAIN:tra_x(out.x); local ty = CAMERA_MAIN:tra_y(out.y);
		
		-- local cx = self.traapoints[i].x; local cy = self.traapoints[i].y; local cz = self.traapoints[i].z;
		-- local tx = CAMERA_MAIN:tra_x(cx / (CAMERA_MAIN.position.z - cz)); 
		-- local ty = CAMERA_MAIN:tra_y(cy / (CAMERA_MAIN.position.z - cz));
		
		--print(out.x .. " " .. out.y );
		
		love.graphics.setColor( self.color );
		love.graphics.circle("fill",tx,ty,3);
	end
end