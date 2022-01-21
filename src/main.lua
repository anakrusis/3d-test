require "transform"
require "camera"
require "shape";
require "struct";

function love.load()
	SCENE = Node.new();
	
	obj1  = Body.new(SCENE); obj1.name = "Obj1";
	obj1.mesh = ShapeBox.new(obj1, vec3.new(1,1,1));

	obj2  = Body.new(SCENE); obj2.name = "Obj2";
	obj2.mesh = ShapeBox.new(obj2, vec3.new(1,1,1));
	obj2.mesh:translate( vec3.new(0,2,0) );
	
	CAMERA_MAIN = Camera.new(SCENE);
	CAMERA_MAIN.position  = vec3.new(0,0,2)
	CAMERA_MAIN.direction = vec3.new(0,0,0)
end

function love.update(dt)
	WINDOW_WIDTH,WINDOW_HEIGHT = love.graphics.getDimensions();
	
	local d = CAMERA_MAIN.direction;
	local p = CAMERA_MAIN.position;
	
	if love.keyboard.isDown("left") then
		CAMERA_MAIN.direction = vec3.new(d.x + 0.01,d.y,d.z)
	end
	if love.keyboard.isDown("right") then
		CAMERA_MAIN.direction = vec3.new(d.x - 0.01,d.y,d.z)
	end
	
	if love.keyboard.isDown("up") then
		CAMERA_MAIN.direction = vec3.new(d.x,d.y + 0.01,d.z)
	end
	if love.keyboard.isDown("down") then
		CAMERA_MAIN.direction = vec3.new(d.x,d.y - 0.01,d.z)
	end
	
	if love.keyboard.isDown("w") then
		CAMERA_MAIN.position = vec3.new(p.x + 0.01,p.y,p.z)
	end
	if love.keyboard.isDown("s") then
		CAMERA_MAIN.position = vec3.new(p.x - 0.01,p.y,p.z)
	end
	if love.keyboard.isDown("a") then
		CAMERA_MAIN.position = vec3.new(p.x,p.y,p.z + 0.01)
	end
	if love.keyboard.isDown("d") then
		CAMERA_MAIN.position = vec3.new(p.x,p.y,p.z - 0.01)
	end
end

function love.draw()
	obj1.mesh:render();
	obj2.mesh:render();
end