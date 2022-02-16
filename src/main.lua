require "transform";
require "struct";
require "shape";
require "camera";

function love.load()
	
	success = love.window.setMode( 800, 800, {resizable=true, minwidth=800, minheight=600} )
	love.graphics.setLineJoin( "none" );
	
	SCENE = Node.new();
	
	obj1  = Body.new(SCENE); obj1.name = "Obj1";
	obj1.mesh = ShapeBox.new(obj1, vec3.new(1,1,1));

	obj2  = Body.new(SCENE); obj2.name = "Obj2";
	obj2.mesh = ShapeBox.new(obj2, vec3.new(1,1,1));
	obj2.mesh:translate( vec3.new(0,6,0) );
	obj2.mesh:setColor(0,1,1)

	-- obj3  = Body.new(SCENE); obj3.name = "Obj3";
	-- obj3.mesh = ShapeQuad.new(obj3, vec3.new(1,1,0));
	-- obj3.mesh:translate( vec3.new(4,0,4) );
	-- obj3.mesh.color = {1,0,0}

	obj4  = Body.new(SCENE); obj4.name = "Obj4";
	obj4.mesh = ShapeQuad.new(obj4, vec3.new(4,0,4));
	obj4.mesh:translate( vec3.new(6,8,4) );
	obj4.mesh.color = {0,1,0}

	-- obj5  = Body.new(SCENE); obj5.name = "Obj5";
	-- obj5.mesh = ShapeQuad.new(obj5, vec3.new(0,3,1));
	-- obj5.mesh:translate( vec3.new(10,0,6) );
	-- obj5.mesh.color = {1,1,0}
	
	BILL = Body.new(SCENE);
	BILL.mesh = ShapeBillboard.new(BILL, vec2.new(1,1));
	BILL.mesh:translate( vec3.new(5,8,5) );
	BILL.mesh.texture = love.graphics.newImage("assets/shroom.png");
	
	PLAYER = Body.new(SCENE); PLAYER.name = "Player";
	PLAYER.mesh = ShapeBox.new(PLAYER, vec3.new(0.5,0.5,0.5));
	PLAYER:translate( vec3.new(4,2,4) );
	PLAYER.mesh:setColor(1,1,0)
	
	CAMERA_MAIN = Camera.new(PLAYER);
	CAMERA_MAIN.position  = vec3.new(4,-2,0)
	CAMERA_MAIN:lookAt(PLAYER);
	--CAMERA_MAIN.direction = vec3.new(-math.pi/4,0,0)
end

function love.update(dt)
	WINDOW_WIDTH,WINDOW_HEIGHT = love.graphics.getDimensions();
	
	if PLAYER.position.y < 8 then
		PLAYER:translate( vec3.new(0,0.1,0));
	end
	
	local d = PLAYER.direction;
	local p = PLAYER.position;
	
	if love.keyboard.isDown("left") then
		--PLAYER:rotate(vec3.new(0, -0.025, 0));
		CAMERA_MAIN:rotate( vec3.new(0,-0.025,0) );
	end
	if love.keyboard.isDown("right") then
		--PLAYER:rotate(vec3.new(0, 0.025, 0));
		CAMERA_MAIN:rotate( vec3.new(0,0.025,0) );
	end
	
	if love.keyboard.isDown("up") then
		CAMERA_MAIN:rotate( vec3.new(0.025,0,0) );
	end
	if love.keyboard.isDown("down") then
		CAMERA_MAIN:rotate( vec3.new(-0.025,0,0) );
	end
	
	if love.keyboard.isDown("a") then
		--CAMERA_MAIN.position = vec3.new(p.x + 0.01,p.y,p.z)
		PLAYER:rotate(vec3.new(0, -0.025, 0));
	end
	if love.keyboard.isDown("d") then
		--CAMERA_MAIN.position = vec3.new(p.x - 0.01,p.y,p.z)
		PLAYER:rotate(vec3.new(0, 0.025, 0));
	end
	
	local coeff = 0.1;
	local c = coeff * ( math.sin(d.y) );
	local s = coeff * ( math.cos(d.y) );
	
	if love.keyboard.isDown("w") then
		PLAYER:translate( vec3.new( c, 0, s ));
		
		--CAMERA_MAIN.position = CAMERA_MAIN.position:add( vec3.new( d.x * 0.01, d.y * 0.01, d.z * 0.01 ) );
		--CAMERA_MAIN.position = vec3.new( p.x + c, p.y, p.z + s )
	end
	if love.keyboard.isDown("s") then
		PLAYER:translate( vec3.new( -c, 0, -s ));
		--CAMERA_MAIN.position = vec3.new( p.x - c, p.y, p.z - s )
	end
	if love.keyboard.isDown("q") then
		--CAMERA_MAIN.position = vec3.new(p.x,p.y + 0.025,p.z)
	end
	if love.keyboard.isDown("e") then
		--CAMERA_MAIN.position = vec3.new(p.x,p.y - 0.025,p.z)
	end
end

function sortQuads(a,b)
	local a_furthest_dist = 0;
	if a.type == "ShapeBillboard" then
		a_furthest_dist = a.position:distance( CAMERA_MAIN.position )
	else
		a_furthest_dist = a:getFurthestDistance();
	end
	local b_furthest_dist = 0;
	if b.type == "ShapeBillboard" then
		b_furthest_dist = b.position:distance( CAMERA_MAIN.position )
	else
		b_furthest_dist = b:getFurthestDistance();
	end
	return a_furthest_dist > b_furthest_dist;
end

function love.draw()
	love.graphics.push();
	--love.graphics.scale(2);

	love.graphics.setBackgroundColor( 1,1,1 )
	love.graphics.setLineWidth( 5 )
	
	-- this will contain a table of all the quads to render, sorted from back to front
	-- PAINTERS ALGORITHM STYLE I think?
	SORTED_QUADS = {}

	for k,v in pairs(SCENE.children) do
		if v.mesh then
			if v.mesh.type == "ShapeQuad" or v.mesh.type == "ShapeBillboard" then
				table.insert(SORTED_QUADS, v.mesh);
			
			elseif v.mesh.type == "ShapeBox" then
				for i = 1, #v.mesh.faces do
					table.insert(SORTED_QUADS, v.mesh.faces[i]);
				end
			end
		end
	end
	table.sort(SORTED_QUADS, sortQuads)
	for i = 1, #SORTED_QUADS do
		SORTED_QUADS[i]:render();
	end
	
	-- DEBUG TEXT
	love.graphics.setColor(0,0,0)
	love.graphics.setLineWidth( 1 )

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
	
	-- minimap icon with direction pointing arrow
	love.graphics.circle("fill", tx, ty, 3)
	local arrowsize = 8;
	local ex = arrowsize * math.sin( CAMERA_MAIN.direction.y );
	local ey = arrowsize * math.cos( CAMERA_MAIN.direction.y );
	--love.graphics.line(tx,ty,tx+ex,ty+ey);
	
	love.graphics.line(0,128,256,128)
	love.graphics.line(128,0,128,256)
	
	love.graphics.pop();
end