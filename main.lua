display.setStatusBar( display.HiddenStatusBar )

local physics = require 'physics'
physics.start()

--screen values
local center_x = display.contentCenterX
local center_y = display.contentCenterY
local screen_width = display.contentWidth
local screen_height = display.contentHeight

--game element
local background
local player
local floor

--controls
local arrow_left
local arrow_right

--hud
local score_display
local life_display

--timers
local coin_timer

--numbers
local score = 0
local life = 3

--sounds
local bg_sound
local coin_sound

local function init()
	background = display.newImage( 'images/background.png', 0, 0 )

	player = display.newImage( 'images/player.png', center_x, center_y )
	player.name = 'player'
	physics.addBody( player )

	floor = display.newImage( 'images/floor.png', 0, screen_height - 35 ) 
	floor.name = 'floor'
	physics.addBody( floor, 'static' )

	arrow_left = display.newImage( 'arrow-left.png' )
	arrow_left.x = 50
	arrow_left.y = screen_height - 60
	arrow_left.alpha = 0.3

	arrow_right = display.newImage( 'arrow-right.png' )
	arrow_right.x = screen_width - 50
	arrow_right.y = screen_height - 60
	arrow_right.alpha = 0.3

	score_display = display.newText{ text = 'Score:0', fontSize = 20 }
	score_display.x = 30 + score_display.width/2
	score_display.y = 30
	score_display:setTextColor( 0,0,0 )

	life_display = display.newText{ text = 'Life:3', fontSize = 20 }
	life_display.x = (screen_width - 70) + life_display.width/2
	life_display.y = 30
	life_display:setTextColor( 0,0,0 )

	bg_sound = audio.loadStream( 'sounds/bg.mp3' )
	coin_sound = audio.loadSound( 'sounds/coin.wav' )

	audio.play( bg_sound, { loops = -1 })
end

local function update_life()
	life = life - 1
	life_display.text = 'Life:'..life
	life_display.x = ( screen_width - 70 ) + life_display.width/2

	if life == 0 then
		timer.cancel( coin_timer )
		local game_over_bg = display.newRect( 0, 0, screen_width, screen_height )
		game_over_bg:setFillColor( 0, 0, 0 )
		local game_over_txt = display.newText{ text= 'Game Over', x = center_x, y = center_y, fontSize = 40 }
	end
end 

local function update()
	if player.x < -50 or player.x > screen_width + 50 or player.y > screen_height then
		update_life()
		physics.removeBody( player )
		player.x = center_x
		player.y = center_y
		player.rotation = 0
		physics.addBody( player )
	end
end

local function touch_left()
	player:applyLinearImpulse( -0.005, 0)
end

local function touch_right()
	player:applyLinearImpulse( 0.005, 0)
end

local function update_score()
	score = score + 10
	score_display.text = 'Score:'..score
	score_display.x = 30 + score_display.width/2
end

local function create_coin()
	local coin = display.newImage( 'images/coin.png' )
	coin.x = math.random( 0, screen_width )
	physics.addBody( coin )

	function coin:collision( event )
		local other = event.other
		if other.name == 'floor' then
			self:removeSelf()
		elseif other.name == 'player' then
			audio.play( coin_sound )
			self:removeSelf()
			update_score()
		end
	end

	coin:addEventListener( 'collision', coin )
end

local function add_listeners()
	arrow_left:addEventListener( 'touch', touch_left )
	arrow_right:addEventListener( 'touch', touch_right )
	Runtime:addEventListener( 'enterFrame', update)
end

init()
add_listeners()
coin_timer = timer.performWithDelay( 2000, create_coin, 0 )