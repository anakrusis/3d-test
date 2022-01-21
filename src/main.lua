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
	obj2.mesh.color = {0,1,1}
	
	CAMERA_MAIN = Camera.new(SCENE);
	CAMERA_MAIN.position  = vec3.new(0,0,2)
	CAMERA_MAIN.direction = vec3.new(0,0,0)
end

function love.update(dt)
	WINDOW_WIDTH,WINDOW_HEIGHT = love.graphics.getDimensions();
	
	local d = CAMERA_MAIN.direction;
	local p = CAMERA_MAIN.position;
	
	if love.keyboard.isDown("left") then
		CAMERA_MAIN.direction = vec3.new(d.x,d.y - 0.01,d.z)
	end
	if love.keyboard.isDown("right") then
		CAMERA_MAIN.direction = vec3.new(d.x,d.y + 0.01,d.z)
	end
	
	if love.keyboard.isDown("up") then
		--CAMERA_MAIN.direction = vec3.new(d.x,d.y + 0.01,d.z)
	end
	if love.keyboard.isDown("down") then
		--CAMERA_MAIN.direction = vec3.new(d.x,d.y - 0.01,d.z)
	end
	
	if love.keyboard.isDown("a") then
		--CAMERA_MAIN.position = vec3.new(p.x + 0.01,p.y,p.z)
	end
	if love.keyboard.isDown("d") then
		--CAMERA_MAIN.position = vec3.new(p.x - 0.01,p.y,p.z)
	end
	
	local c = 0.1;
	if love.keyboard.isDown("w") then
		CAMERA_MAIN.position = vec3.new( p.x + (c * math.cos(d.y)), p.y, p.z + (c * math.sin(d.y)) )
	end
	if love.keyboard.isDown("s") then
		CAMERA_MAIN.position = vec3.new( p.x - (c * math.cos(d.y)), p.y, p.z - (c * math.sin(d.y)) )
	end
	if love.keyboard.isDown("q") then
		CAMERA_MAIN.position = vec3.new(p.x,p.y + 0.01,p.z)
	end
	if love.keyboard.isDown("e") then
		CAMERA_MAIN.position = vec3.new(p.x,p.y - 0.01,p.z)
	end
end

function love.draw()
	obj1.mesh:render();
	obj2.mesh:render();
	
	local info = "cam pos\n"
	info = info .. "x: " .. CAMERA_MAIN.position.x .. "\n"
	info = info .. "y: " .. CAMERA_MAIN.position.y .. "\n"
	info = info .. "z: " .. CAMERA_MAIN.position.z .. "\n"

	info = info .. "cam dir\n"
	info = info .. "x: " .. CAMERA_MAIN.direction.x .. "\n"
	info = info .. "y: " .. CAMERA_MAIN.direction.y .. "\n"
	info = info .. "z: " .. CAMERA_MAIN.direction.z .. "\n"
	
	love.graphics.print(info);
	
	local orig  = 128;
	local scale = 16;
	local tx = orig + ( scale * CAMERA_MAIN.position.x );
	local ty = orig + ( scale * CAMERA_MAIN.position.z );
	
	love.graphics.circle("fill", tx, ty, 3)
	love.graphics.line(tx,ty,tx + (8 * math.cos( CAMERA_MAIN.direction.y) ), ty + (8 * math.sin( CAMERA_MAIN.direction.y) ) );
	
	love.graphics.line(0,128,256,128)
	love.graphics.line(128,0,128,256)
end