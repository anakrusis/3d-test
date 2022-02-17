Tileset = {}; Tileset.__index = Tileset;
function Tileset.new(source)
	local self = setmetatable({}, Tileset);
	
	self.source = love.graphics.newImage(source);
	self.widthInTiles = math.floor(self.source:getWidth() / 8);
	self.heightInTiles = math.floor(self.source:getHeight() / 8);
	
	self.quads = {};
	for i = 1, self.widthInTiles * self.heightInTiles do
		local x = (i - 1) % self.widthInTiles;
		local y = math.floor((i - 1) / self.widthInTiles);
		local quad = love.graphics.newQuad( 8 * x, 8 * y, 8, 8, self.source:getWidth(), self.source:getHeight());
		table.insert(self.quads,quad);
	end
	
	return self;
end