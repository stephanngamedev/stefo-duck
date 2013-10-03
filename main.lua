display.setStatusBar( display.HiddenStatusBar )

require "physics"

physics.start()

local center_x = display.contentCenterX 
local center_y = display.contentCenterY
local screen_width = display.contentWidth
local screen_height = display.contentHeight

local background
local player
local floor

local arrow_left
local arrow_right
local score = 0
local score_display

local bg_sound
local coin_sound

local function init()
	background = display.newImage( 'background.png', 0, 0 )
	
	player = display.newImage( 'player.png', center_x, center_y )
	player.name = 'player'
	physics.addBody( player )
	
	floor = display.newImage( 'floor.png', 0, screen_height - 30 )
	floor.name = 'floor'
	physics.addBody( floor, "static" )

	arrow_left = display.newImage( 'arrow-left.png')
	arrow_left.x = 50 
	arrow_left.y = screen_height - 60
	arrow_left.alpha = .3
	
	arrow_right = display.newImage( 'arrow-right.png' )
	arrow_right.x = screen_width - 50
	arrow_right.y = screen_height - 60
	arrow_right.alpha = .3

	score_display = display.newText{ text = "Score:0", fontSize = 30 }
	score_display.x = 30 + score_display.width * .5
	score_display.y = 30
	score_display:setTextColor( 0, 0, 0 )

	bg_sound = audio.loadStream('bg.mp3')
	coin_sound = audio.loadSound('coin.wav')

	audio.play( bg_sound, { loops = -1 } )
end

local function update()
	if player.x < -50 or player.x > screen_width + 50 or player.y > screen_height then
		physics.removeBody( player )
		player.x = center_x
		player.y = center_y
		player.rotation = 0
		physics.addBody( player )
	end
end

local function touch_left()
	player:applyLinearImpulse( -0.005, 0 )
end

local function touch_right()
	player:applyLinearImpulse( 0.005, 0 )
end

local function update_score()
	score = score + 10
	score_display.text = "Score:"..score
	score_display.x = 30 + score_display.width * .5
end

local function create_coin()
	local coin = display.newImage( 'coin.png', math.random(0, screen_width), 0)
	physics.addBody( coin, { radius = 12 } )

	function coin:collision( event )
		local other = event.other
		if other.name == "floor" then
			self:removeSelf()
		elseif other.name == "player" then
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
	Runtime:addEventListener( 'enterFrame', update )
end

init()
add_listeners()
timer.performWithDelay( 2000, create_coin, 0 )