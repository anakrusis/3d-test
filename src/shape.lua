vec3 = {}; vec3.__index = vec3;
function vec3.new(x,y,z)
	local self = setmetatable({}, vec3);
	self.x = x;
	self.y = y;
	self.z = z;
	
	return self;
end

-- base type for meshes, collision shapes, etc.
-- will have methods for rotation, scaling, translation
Shape = {}; Shape.__index = Shape;
function Shape.new(parent)
	local self = setmetatable(Node.new(parent), Shape);
	
	-- original set of points (vec3's) with no transforms applied
	local basepoints = {};
	-- points in their actual position on which all transforms are done
	local realpoints = {};
	
	return self;
end

function Shape.translate(vec3_offset)

end

function Shape.rotate(vec3_offset)

end