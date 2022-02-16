Camera = {}; Camera.__index = Camera;
function Camera.new(parent)
	local self = setmetatable(Body.new(parent), Camera);
	
	self.zoom = 800;
	
	return self;
end
setmetatable(Camera, {__index = Body});

function Camera:tra_x(x) -- translate x based on camera values
	return (( x - self.position.x ) * self.zoom ) + (WINDOW_WIDTH / 2)
end
function Camera:tra_y(y) -- translate y based on camera values
	return (( y - self.position.x ) * self.zoom ) + (WINDOW_HEIGHT / 2)
end

function Camera:lookAt(body)
	local ah = ( body.position.y - self.position.y ) / ( self.position:distance( body.position ));
	local newx = math.acos( ah ) - math.pi/2
	local newy = math.atan2( body.position.z - self.position.z, body.position.x - self.position.x ) - math.pi/2;
	
	self.direction = vec3.new( newx, newy, self.direction.z);
end

function Camera:transform(vec3d_in)
	
	local x = vec3d_in.x - self.position.x; 
	local y = vec3d_in.y - self.position.y; 
	local z = vec3d_in.z - self.position.z;
	
	local sx = math.sin(self.direction.x); 
	local sy = math.sin(self.direction.y); 
	local sz = math.sin(self.direction.z);
	local cx = math.cos(self.direction.x); 
	local cy = math.cos(self.direction.y); 
	local cz = math.cos(self.direction.z);
	
	local dx = cy * ((sz * y) + (cz * x)) - ( sy * z );
	local dy = sx * ((cy * z) + sy * ((sz * y) + (cz * x))) + cx * ((cz * y) - (sz * x)); 
	local dz = cx * ((cy * z) + sy * ((sz * y) + (cz * x))) - (sx * ((cz * y) - (sz * x)));
	
	--print(dz)
	if dz <= 0 then
		dz = 0.001-- * ( dz > 0 and 1 or dz < 0 and 1 or 0);
		--bx = -bx; by = -by;
		--dx = -dx; dy = -dy; --dz = -dz;
	
	-- if any point is here or more than its not offscreen
	else
		OFFSCREEN_FLAG = false;
	end
	
	local fov = 1
	local bx = ((fov / dz) * dx)  --+ self.position.x
	local by = ((fov / dz) * dy)  --+ self.position.y
	
	return vec2.new(bx,by);
end