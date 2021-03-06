require "transform";
require "struct";
require "shape";
require "billboard";
require "camera";
require "tileset";

function love.load()
	
	PIXEL_SCALE = 4;
	
	success = love.window.setMode( 800, 800, {resizable=true, minwidth=800, minheight=600} )
	love.graphics.setLineJoin( "none" );
	love.graphics.setLineStyle( "rough" );
	
	SCENE = Node.new();
	
	-- obj1  = Body.new(SCENE); obj1.name = "Obj1";
	-- obj1.mesh = ShapeBox.new(obj1, vec3.new(1,1,1));

	-- obj2  = Body.new(SCENE); obj2.name = "Obj2";
	-- obj2.mesh = ShapeBox.new(obj2, vec3.new(1,1,1));
	-- obj2.mesh:translate( vec3.new(0,6,0) );
	-- obj2.mesh:setColor(0,1,1)

	-- obj3  = Body.new(SCENE); obj3.name = "Obj3";
	-- obj3.mesh = ShapeQuad.new(obj3, vec3.new(1,1,0));
	-- obj3.mesh:translate( vec3.new(4,0,4) );
	-- obj3.mesh.color = {1,0,0}

	obj4  = Body.new(SCENE); obj4.name = "Obj4";
	local m = ShapeQuad.new(obj4, vec3.new(4,0,4));
	m:translate( vec3.new(6,8,4) ); m.color = {0,1,0}
	obj4:addMesh("m",m);

	-- obj5  = Body.new(SCENE); obj5.name = "Obj5";
	-- obj5.mesh = ShapeQuad.new(obj5, vec3.new(0,3,1));
	-- obj5.mesh:translate( vec3.new(10,0,6) );
	-- obj5.mesh.color = {1,1,0}
	
	BILL = Body.new(SCENE);
	local bmesh = ShapeBillboard.new(BILL, vec2.new(1,1));
	bmesh:translate( vec3.new(5,8,5) );
	bmesh.texture = love.graphics.newImage("assets/shroom.png");
	BILL:addMesh("b",bmesh);

	b2 = Body.new(SCENE); 
	m = ShapeBox.new(b2, vec3.new(1,1,1));
	m:translate( vec3.new(9,7,5) );
	m:setColor(1,0.2,1)
	b2:addMesh("m",m);
	
	PLAYER = Body.new(SCENE); PLAYER.name = "Player";
	local torsomesh = ShapeBillboard.new(PLAYER, vec3.new(0.5,1));
	torsomesh.texture = love.graphics.newImage("assets/torso.png");
	PLAYER:addMesh("torso", torsomesh);
	
	local headmesh = ShapeEightWayBillboard.new(PLAYER, vec3.new(0.5,0.5));
	headmesh.textures = {
		front = love.graphics.newImage("assets/head_front.png"),
		tqf = love.graphics.newImage("assets/head_3qf.png"),
		side = love.graphics.newImage("assets/head_side.png"),
		tqb = love.graphics.newImage("assets/head_3qb.png"),
		back = love.graphics.newImage("assets/head_back.png")
	}
	headmesh.position = vec3.new(0,-1.25,0);
	PLAYER:addMesh("head", headmesh);
	
	PLAYER:translate( vec3.new(4,2,4) );
	--PLAYER.mesh:setColor(1,1,0)
	
	CAMERA_MAIN = Camera.new(PLAYER);
	CAMERA_MAIN.position  = vec3.new(4,0,0)
	CAMERA_MAIN:lookAt(PLAYER);
	--CAMERA_MAIN.direction = vec3.new(-math.pi/4,0,0)
	
	A = love.graphics.newImage("assets/a.png");
	
	WINDOW_WIDTH,WINDOW_HEIGHT = love.graphics.getDimensions();
	CANVAS = love.graphics.newCanvas( WINDOW_WIDTH / PIXEL_SCALE, WINDOW_HEIGHT / PIXEL_SCALE )
	
	TILESET1 = Tileset.new("assets/chr000.png");
	
	TILEMAP1 = {}
	for x = 1, 20 do
		TILEMAP1[x] = {};
	end
	
	drawText("testing three d",3,3);
end

function love.resize(w,h)
	WINDOW_WIDTH = w; WINDOW_HEIGHT = h;
	CANVAS = love.graphics.newCanvas( WINDOW_WIDTH / PIXEL_SCALE, WINDOW_HEIGHT / PIXEL_SCALE )
end

function love.update(dt)
	if PLAYER.position.y < 8 then
		PLAYER:translate( vec3.new(0,0.1,0));
	end
	
	for k,v in pairs(SCENE.children) do
		v:update();
	end
	
	local d = PLAYER.direction;
	local p = PLAYER.position;
	
	if love.keyboard.isDown("left") then
		--PLAYER:rotate(vec3.new(0, -0.025, 0));
		--CAMERA_MAIN:rotate( vec3.new(0,-0.025,0) );
		
		local cx = CAMERA_MAIN.radius * math.sin( CAMERA_MAIN.direction.y + 0.025 + math.pi ) + p.x;
		local cy = CAMERA_MAIN.position.y;
		local cz = CAMERA_MAIN.radius * math.cos( CAMERA_MAIN.direction.y + 0.025 + math.pi ) + p.z;
		CAMERA_MAIN.position = vec3.new( cx, cy, cz )
		CAMERA_MAIN:lookAt(PLAYER);
	end
	if love.keyboard.isDown("right") then
		--PLAYER:rotate(vec3.new(0, 0.025, 0));
		--CAMERA_MAIN:rotate( vec3.new(0,0.025,0) );
		
		local cx = CAMERA_MAIN.radius * math.sin( CAMERA_MAIN.direction.y - 0.025 + math.pi ) + p.x;
		local cy = CAMERA_MAIN.position.y;
		local cz = CAMERA_MAIN.radius * math.cos( CAMERA_MAIN.direction.y - 0.025 + math.pi ) + p.z;
		CAMERA_MAIN.position = vec3.new( cx, cy, cz )
		CAMERA_MAIN:lookAt(PLAYER);
	end
	
	if love.keyboard.isDown("up") then
		CAMERA_MAIN:rotate( vec3.new(0.025,0,0) );
	end
	if love.keyboard.isDown("down") then
		CAMERA_MAIN:rotate( vec3.new(-0.025,0,0) );
	end
	
	if love.keyboard.isDown("a") then
		PLAYER:rotate(vec3.new(0, -0.025, 0));
	end
	if love.keyboard.isDown("d") then
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
		CAMERA_MAIN:lookAt(PLAYER);
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
	--love.graphics.push();
	love.graphics.setCanvas(CANVAS)
	--love.graphics.scale(PIXEL_SCALE);
	
	love.graphics.clear(1,1,1);
	love.graphics.setLineWidth( 2 )
	
	-- this will contain a table of all the quads to render, sorted from back to front
	-- PAINTERS ALGORITHM STYLE I think?
	SORTED_QUADS = {}

	for k,v in pairs(SCENE.children) do
		for key, mesh in pairs(v.meshes) do
			if mesh.type == "ShapeQuad" or mesh.type == "ShapeBillboard" then
				table.insert(SORTED_QUADS, mesh);
			
			elseif mesh.type == "ShapeBox" then
				for i = 1, #mesh.faces do
					table.insert(SORTED_QUADS, mesh.faces[i]);
				end
			end
		
		end
	end
	table.sort(SORTED_QUADS, sortQuads)
	for i = 1, #SORTED_QUADS do
		SORTED_QUADS[i]:render();
	end
	
	-- Tilemap overlay
	for y = 1, WINDOW_HEIGHT / PIXEL_SCALE / 8 do
		for x = 1, WINDOW_WIDTH / PIXEL_SCALE / 8 do
		
			if TILEMAP1[x] then
				if TILEMAP1[x][y] then
				
					local quad = TILESET1.quads[ TILEMAP1[x][y] ];
					love.graphics.draw(TILESET1.source, quad, (x - 1) * 8, (y - 1) * 8)
				end
			else
			
			end
		end
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
	
	--love.graphics.print(info);
	
	local orig  = 128;
	local scale = 16;
	local tx = orig + ( scale * CAMERA_MAIN.position.x );
	local ty = orig + ( scale * CAMERA_MAIN.position.z );
	
	-- minimap icon with direction pointing arrow
	love.graphics.circle("fill", tx, ty, 3)
	local arrowsize = 8;
	local ex = arrowsize * math.sin( CAMERA_MAIN.direction.y );
	local ey = arrowsize * math.cos( CAMERA_MAIN.direction.y );
	love.graphics.line(tx,ty,tx+ex,ty+ey);
	
	-- icon showing player
	local px = orig + ( scale * PLAYER.position.x );
	local py = orig + ( scale * PLAYER.position.z );
	love.graphics.setColor(1,1,0);
	love.graphics.circle("fill", px, py, 3)
	ex = arrowsize * math.sin( PLAYER.direction.y );
	ey = arrowsize * math.cos( PLAYER.direction.y );
	love.graphics.line(px,py,px+ex,py+ey);
	
	love.graphics.line(0,128,256,128)
	love.graphics.line(128,0,128,256)
	
	love.graphics.setCanvas()
	love.graphics.setColor(1,1,1)
	love.graphics.draw(CANVAS,0,0,0,PIXEL_SCALE,PIXEL_SCALE);
	--love.graphics.pop();
end

-- we can add wrapping and stuff soon
function drawText(str, x, y)
	local tx = x; local ty = y;
	for i = 1, #str do
		local chara = string.sub(str,i,i)
		local num = string.byte(chara);
		
		if TILEMAP1[tx] then
			TILEMAP1[tx][ty] = num + 1;
		end
		
		tx = tx + 1;
	end
end 