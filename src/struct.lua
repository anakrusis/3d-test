-- Base type for everything in the engine.
-- has a pointer to its parent, and a table of pointers for its children

Node = {}; Node.__index = Node;
function Node.new(parent)
	local self = setmetatable({}, Node);
	
	self.name = "Node";
	self.parent = parent;
	self.children = {};
	
	if (parent) then
		--print(parent.name);
		for k,v in pairs(parent) do
			--print(k);
		end
		--print("\n");
		
		parent:appendElement( self );
	else
		-- batman node
	end
	
	return self;
end

-- Wow this is going back to lua unchanged, truly full circle
function Node:appendElement(e)
	--print( e.name .. " added to " .. self.name )
	e.parent = self;
	table.insert(self.children, e);
end

-- Physical object with position and stuff
Body = {}; Body.__index = Body;
function Body.new(parent)
	local self = setmetatable(Node.new(parent), Body);
	
	self.position       = vec3.new(0,0,0);
	self.direction      = vec3.new(0,0,0);
	
	self.mesh           = nil;
	self.collisionShape = nil;
	
	return self;
end
setmetatable(Body, {__index = Node});