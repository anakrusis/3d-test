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
	self.points = {};
	-- more organized verison of the above
	self.faces = {};
	
	self.color = {1,1,1};
	
	return self;
end
setmetatable(Shape, {__index = Node});

-- offets all points in the shape by a fixed amount
function Shape:translate(vec3_offset)
	for i = 1, #self.points do
		local nx = self.points[i].x + vec3_offset.x;
		local ny = self.points[i].y + vec3_offset.y;
		local nz = self.points[i].z + vec3_offset.z;
		
		self.points[i] = vec3.new(nx,ny,nz);
	end
end

-- rotates all points in the shape along the specified axes by fixed amounts
function Shape:rotate(vec3_offset)

end

function Shape:render()
	for i = 1, #self.points do
		local out = CAMERA_MAIN:transform(self.points[i]);
		local tx  = (out.x * CAMERA_MAIN.zoom) + WINDOW_WIDTH / 2;
		local ty  = (out.y * CAMERA_MAIN.zoom) + WINDOW_HEIGHT / 2;
		
		love.graphics.setColor( self.color );
		love.graphics.circle("fill",tx,ty,3);
	end
end

-- -- does nothing by default. each shape type will handle this differently
-- function Shape:render()

-- end

-- A quad is generated with a single extents vector. One of the three values therein must be zero!
-- (Otherwise it wouldnt be much of a quad)
ShapeQuad = {}; ShapeQuad.__index = ShapeQuad;
function ShapeQuad.new(parent, extents)
	local self = setmetatable(Shape.new(parent), ShapeQuad);
	local dim1, dim2 = nil;
	
	-- identifies the two nonzero number values in the extents vector, which are dimensions for iterating
	for k,v in pairs(extents) do
		if type(v) == "number" then
			if v ~= 0 and not dim1 then dim1 = k end
			if k ~= dim1 and v ~= 0 and not dim2 then dim2 = k end
		end
	end
	print( "dim1: " .. dim1 .. " dim2: " .. dim2 );
	
	local initialvec = vec3.new(extents.x,extents.y,extents.z);
	for i = 1, 4 do
		local newvec = vec3.new(initialvec.x, initialvec.y, initialvec.z)
		table.insert(self.basepoints, newvec)
		print(self.basepoints[i].x .. " " .. self.basepoints[i].y .. " " .. self.basepoints[i].z);
		
		if i == 1 or i == 3 then
			initialvec[dim1] = -initialvec[dim1]
		end
		if i == 2 then
			initialvec[dim2] = -initialvec[dim2]
		end
	end 
	
	-- deep copy of vectors for doing transforms
	for i = 1, #self.basepoints do
		local bp = self.basepoints[i];
		local newvec = vec3.new(bp.x,bp.y,bp.z);
		table.insert(self.points, newvec);
	end
	
	return self;
end
setmetatable(ShapeQuad, {__index = Shape});

function ShapeQuad:render()
	local prevx, prevy;

	for i = 1, #self.points + 1 do
		local index = 1 + ((i - 1) % #self.points);
		
		local out = CAMERA_MAIN:transform(self.points[index]);
		local tx  = (out.x * CAMERA_MAIN.zoom) + WINDOW_WIDTH / 2;
		local ty  = (out.y * CAMERA_MAIN.zoom) + WINDOW_HEIGHT / 2;
		
		if prevx then
			love.graphics.setColor( self.color );
			love.graphics.line(prevx,prevy,tx,ty);
		end
		
		prevx = tx; prevy = ty;
	end
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
	
	-- deep copy of vectors for doing transforms
	for i = 1, #self.basepoints do
		local bp = self.basepoints[i];
		local newvec = vec3.new(bp.x,bp.y,bp.z);
		table.insert(self.points, newvec);
	end
	
	-- shallow copy of vectors to the face objects
	
	return self;	
end
setmetatable(ShapeBox, {__index = Shape});