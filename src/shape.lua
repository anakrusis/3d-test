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

function vec3:add( vec3_in )
	local x = self.x + vec3_in.x; local y = self.y + vec3_in.y; local z = self.z + vec3_in.z;
	return vec3.new(x,y,z);
end

function vec3:subtract( vec3_in )
	local x = self.x - vec3_in.x; local y = self.y - vec3_in.y; local z = self.z - vec3_in.z;
	return vec3.new(x,y,z);
end

function vec3:distance( vec3_in )
	local x = math.pow( vec3_in.x - self.x , 2 );
	local y = math.pow( vec3_in.y - self.y , 2 );
	local z = math.pow( vec3_in.z - self.z , 2 );
	return math.sqrt( x + y + z );
end

function vec3:dot( vec3_in )
	return ( self.x * vec3_in.x ) + ( self.y * vec3_in.y ) + ( self.z * vec3_in.z );
end

function vec3:cross( vec3_in )
	local x = (self.y * vec3_in.z) - (self.z * vec3_in.y);
	local y = (self.z * vec3_in.x) - (self.x * vec3_in.z);
	local z = (self.x * vec3_in.y) - (self.y * vec3_in.x);
	return vec3.new(x,y,z);
end

-- base type for meshes, collision shapes, etc.
-- will have methods for rotation, scaling, translation
Shape = {}; Shape.__index = Shape;
function Shape.new(parent)	
	local self = setmetatable(Node.new(parent), Shape);
	
	-- should match the parents position
	self.position = vec3.new(0,0,0);
	-- original set of points (vec3's) with no transforms applied
	self.basepoints = {};
	-- points in their actual position on which all transforms are done
	self.points = {};
	
	self.color = {0.75,0.75,0.75};
	
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
	self.position = self.position:add( vec3_offset );
end

-- rotates all points in the shape around the point self.position
function Shape:rotate(vec3_rot, origin)
	if not origin then
		origin = self.position;
	end

	local cosa = math.cos(vec3_rot.x)
	local sina = math.sin(vec3_rot.x)
	
	local cosb = math.cos(vec3_rot.y)
	local sinb = math.sin(vec3_rot.y)
	
	local cosc = math.cos(vec3_rot.z)
	local sinc = math.sin(vec3_rot.z)
	
	local Axx = cosa * cosb;
	local Axy = ( cosa * sinb * sinc ) - ( sina * cosc )
	local Axz = ( cosa * sinb * cosc ) + ( sina * sinc )
	
	local Ayx = sina * cosb;
	local Ayy = ( sina * sinb * sinc ) + ( cosa * cosc )
	local Ayz = ( sina * sinb * cosc ) - ( cosa * sinc )
	
	local Azx = - sinb;
	local Azy = ( cosb * sinc )
	local Azz = ( cosb * cosc )

	-- translating all the points in the shape
	for i = 1, #self.points do
		local ox = self.points[i].x - origin.x;
		local oy = self.points[i].y - origin.y;
		local oz = self.points[i].z - origin.z;
		
		local nx = (Axx * ox) + (Axy * oy) + (Axz * oz)
		local ny = (Ayx * ox) + (Ayy * oy) + (Ayz * oz)
		local nz = (Azx * ox) + (Azy * oy) + (Azz * oz)
		
		self.points[i] = vec3.new(nx + origin.x, ny + origin.y, nz + origin.z);
		--print(nx + origin.x .. " " .. ny + origin.y .. " " .. nz + origin.z);
	end

	-- translating the position vector of the shape along with its points	
	if origin ~= self.position then
		local ox = self.position.x - origin.x;
		local oy = self.position.y - origin.y;
		local oz = self.position.z - origin.z;
		
		local nx = (Axx * ox) + (Axy * oy) + (Axz * oz)
		local ny = (Ayx * ox) + (Ayy * oy) + (Ayz * oz)
		local nz = (Azx * ox) + (Azy * oy) + (Azz * oz)
		
		self.position = vec3.new(nx + origin.x, ny + origin.y, nz + origin.z);
	end
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
	self.type = "ShapeQuad";
	
	-- identifies the two nonzero number values in the extents vector, which are dimensions for iterating
	local dim1, dim2 = nil;
	for k,v in pairs(extents) do
		if type(v) == "number" then
			if v ~= 0 and not dim1 then dim1 = k end
			if k ~= dim1 and v ~= 0 and not dim2 then dim2 = k end
		end
	end
	--print( "dim1: " .. dim1 .. " dim2: " .. dim2 );
	
	local initialvec = vec3.new(extents.x,extents.y,extents.z);
	for i = 1, 4 do
		local newvec = vec3.new(initialvec.x, initialvec.y, initialvec.z)
		table.insert(self.basepoints, newvec)
		--print(self.basepoints[i].x .. " " .. self.basepoints[i].y .. " " .. self.basepoints[i].z);
		
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
		
	--print(parent.name);
	for k,v in pairs(parent) do
			--print(k);
	end
	--print("\n");
	
	print(self.parent.color);
	if self.parent.color then self.color = self.parent.color end
	
	return self;
end
setmetatable(ShapeQuad, {__index = Shape});

function ShapeQuad:getNormal()
	local edge1 = self.points[1]:subtract( self.position )
	local edge2 = self.points[2]:subtract( self.position )
	
	local prod = edge1:cross( edge2 );
	return prod;
end

function ShapeQuad:render()
	local vertices = {};
	
	-- backface culling
	local camtoquad = self.position:subtract( CAMERA_MAIN.position );
	local dot = camtoquad:dot( self:getNormal() );
	if dot >= 0 then return end

	--print("points")
	OFFSCREEN_FLAG = true;
	-- indexes/transforms the points of the surface
	for i = 1, #self.points do
		local index = 1 + ((i - 1) % #self.points);
		
		local out = CAMERA_MAIN:transform(self.points[index]);
		local tx  = (out.x * CAMERA_MAIN.zoom) + WINDOW_WIDTH / 2;
		local ty  = (out.y * CAMERA_MAIN.zoom) + WINDOW_HEIGHT / 2;
		
		table.insert(vertices, tx); table.insert(vertices, ty); 
	end
	if OFFSCREEN_FLAG then return end
	
	-- Draws the surface
	love.graphics.setColor(self.color);
	love.graphics.polygon("fill", vertices);
	love.graphics.setColor(0,0,0)
	love.graphics.polygon("line", vertices);
	
	--print("center")
	-- Draws a single point at the position vector of the surface
	local out = CAMERA_MAIN:transform(self.position);
	local tx  = (out.x * CAMERA_MAIN.zoom) + WINDOW_WIDTH / 2;
	local ty  = (out.y * CAMERA_MAIN.zoom) + WINDOW_HEIGHT / 2;
	love.graphics.circle("fill", tx, ty, 5);
	
	-- Draws a line perpendicular to the surface
	local normal = self:getNormal();
	local point2 = self.position:add(normal);
	out = CAMERA_MAIN:transform(point2); 
	local nx  = (out.x * CAMERA_MAIN.zoom) + WINDOW_WIDTH / 2;
	local ny  = (out.y * CAMERA_MAIN.zoom) + WINDOW_HEIGHT / 2;
	love.graphics.line(tx,ty,nx,ny);
end

-- rectangular prism
ShapeBox = {}; ShapeBox.__index = ShapeBox;
function ShapeBox.new(parent, vec3_extents)
	local self = setmetatable(Shape.new(parent), ShapeBox);
	self.type = "ShapeBox";
	
	-- extents values
	local ex = vec3_extents.x; local ey = vec3_extents.y; local ez = vec3_extents.z; 
	
	-- set of six ShapeQuad objects for rendering/culling
	self.faces = {};
	local f1 = ShapeQuad.new(self, vec3.new(ex, ey, 0)); 
	f1:rotate( vec3.new( 0, math.pi, 0 ));
	f1:translate( vec3.new( 0, 0, -ez ) );
	
	local f2 = ShapeQuad.new(self, vec3.new(ex, 0, ez)); 
	f2:translate( vec3.new( 0, -ey, 0 ) );
	
	local f3 = ShapeQuad.new(self, vec3.new(0, ey, ez)); 
	f3:rotate( vec3.new( 0, math.pi, 0 ));
	f3:translate( vec3.new( -ex, 0, 0 ) );
	
	local f4 = ShapeQuad.new(self, vec3.new(ex, ey, 0))
	f4:translate( vec3.new( 0, 0, ez ) );
	
	local f5 = ShapeQuad.new(self, vec3.new(ex, 0, ez))
	f5:rotate( vec3.new( 0, 0, math.pi ));
	f5:translate( vec3.new( 0, ey, 0 ) );
	
	local f6 = ShapeQuad.new(self, vec3.new(0, ey, ez))
	f6:translate( vec3.new( ex, 0, 0 ) );
	
	self.faces = {f1, f2, f3, f4, f5, f6};
	
	-- -- the eight vertices of the box shape will here be defined
	-- table.insert(self.basepoints,  vec3.new(  ex,  ey, ez ))
	-- table.insert(self.basepoints,  vec3.new( -ex,  ey, ez ))
	-- table.insert(self.basepoints,  vec3.new( -ex, -ey, ez ))
	-- table.insert(self.basepoints,  vec3.new(  ex, -ey, ez ))
	
	-- table.insert(self.basepoints,  vec3.new(  ex,  ey, -ez ))
	-- table.insert(self.basepoints,  vec3.new( -ex,  ey, -ez ))
	-- table.insert(self.basepoints,  vec3.new( -ex, -ey, -ez ))
	-- table.insert(self.basepoints,  vec3.new(  ex, -ey, -ez ))
	
	-- -- deep copy of vectors for doing transforms
	-- for i = 1, #self.basepoints do
		-- local bp = self.basepoints[i];
		-- local newvec = vec3.new(bp.x,bp.y,bp.z);
		-- table.insert(self.points, newvec);
	-- end
	
	-- -- shallow copy of vectors to the face objects
	
	return self;	
end
setmetatable(ShapeBox, {__index = Shape});

-- for some reason we have to redundantly define this here, otherwise the faces arent able to call it on the parent node ("self") in the above constructor
-- (does anyone know why this is?)
-- function ShapeBox:appendElement(e)
	-- e.parent = self;
	-- table.insert(self.children, e);
-- end

function ShapeBox:translate(vec3_offset)
	for i = 1, #self.faces do
		self.faces[i]:translate(vec3_offset);
	end
	self.position = self.position:add( vec3_offset );
end

function ShapeBox:rotate( vec3_rot )
	for i = 1, #self.faces do
		self.faces[i]:rotate(vec3_rot, self.position);
	end
end

function ShapeBox:setColor(r,g,b)
	self.color = {r,g,b};
	for i = 1, #self.faces do
		self.faces[i].color = self.color;
	end
end

function ShapeBox:render()
	for i = 1, #self.faces do
		self.faces[i]:render();
	end
end