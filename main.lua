Class = require 'class'
push = require 'push'

require 'Paddle'
require 'Ball'

--The size of the window, but it's resizable
WINDOW_HEIGHT = 720 
WINDOW_WIDTH = 1280

--The size of virtual windows to do a focus 
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

--Speed at which we will move our paddle; Multiplied by dt in update
PADDLE_SPEED = 200

--[[
    Runs when the game first starts up, only once;
    Used to initialize the game.
]]
function love.load()
    math.randomseed(os.time())

    love.window.setTitle('Pong')

    --Use nearest-neighbor filtering on upscalind and downscaling to prevent blurring of text
    --and graphics;
    love.graphics.setDefaultFilter('nearest', 'nearest')
    
    --More "retro-looking" font object we can use for any text
    smallFont = love.graphics.newFont('font.TTF', 8)
    --Draw the same font, but using a big scale
    scoreFont = love.graphics.newFont('font.TTF', 32)
    victoryFont = love.graphics.newFont('font.TTF', 24)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('paddle_hit.wav', 'static'),
        ['point_score'] = love.audio.newSource('point_score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('wall_hit.wav', 'static')
    }
    --Initialize our virutal resolution, which will be rendered within our
    --actual window no matter its dimensions
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false, vsync = true, resizable = true})

    --Initialize variables
    player1Score = 0
    player2Score = 0
    servingPlayer = math.random(2) == 1 and 1 or 2
    winningPLayer = 0

    --Create the paddles (they can only move up or down)
    paddle1 = Paddle(5, 20, 5, 20)
    paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
    --Create the ball
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    if servingPlayer == 1 then
        ball.dx = 100
    else
        ball.dx = -100
    end

    gameState = 'start'
end

--[[
    Runs when the players resize the window
]]
function love.resize(w, h)
    push:resize(w, h)
end

--[[
    Runs each dt interval over and over again
]]
function love.update(dt)
    if gameState == 'play' then
        ball:update(dt) --Update the ball position
        --Update the paddles position
        paddle1:update(dt)
        paddle2:update(dt)

        --Check colisions betwenn ball and paddles
        if ball:collides(paddle1) then
            --deflect ball to the right
            ball.dx = -ball.dx * 1.05 --Increase the speed each time
            ball.x = paddle1.x + 5

            sounds['paddle_hit']:play()

            if ball.dy < 0 then --Assign a random value to Y movement of the ball
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        if ball:collides(paddle2) then
            --deflect ball to the left
            ball.dx = -ball.dx * 1.03
            ball.x = paddle2.x - 4

            sounds['paddle_hit']:play()

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        if ball.y <= 0 then
            --Deflect the ball down
            ball.dy = -ball.dy
            ball.y = 0

            sounds['wall_hit']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            --Deflect the ball up
            ball.dy = -ball.dy
            ball.y = VIRTUAL_HEIGHT - 4

            sounds['wall_hit']:play()
        end

        if ball.x <= 0 then
            --Player1 lose the ball
            player2Score = player2Score + 1
            servingPlayer = 1

            sounds['point_score']:play()
            
            ball:reset()
            ball.dx = 100
            if player2Score >= 3 then
                gameState = 'victory'
                winningPLayer = 2
            else
                gameState = 'serve'
            end
        end

        if ball.x >= VIRTUAL_WIDTH - 4 then
            --Player2 lose the ball
            player1Score = player1Score + 1
            servingPlayer = 2

            sounds['point_score']:play()

            ball:reset()
            ball.dx = -100
            if player1Score >= 10 then
                gameState = 'victory'
                winningPLayer = 1
            else
                gameState = 'serve'
            end
        end

        --Player1 movement
        if love.keyboard.isDown('w') then
            --Add negative paddle speed
            paddle1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
            --Add positive paddle speed
            paddle1.dy = PADDLE_SPEED
        else
            paddle1.dy = 0
        end
        
        --Player2 movement
        if love.keyboard.isDown('up') then
            paddle2.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down') then
            paddle2.dy = PADDLE_SPEED
        else
            paddle2.dy = 0
        end
    
    end
end

--[[
    Runs when a key is pressed.
]]
function love.keypressed(key)
    --Keys can be accessed by string name
    if key == 'escape' then
        --Funciton LOVE gives us to terminate application
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        --Change the gameState
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'victory' then
            gameState = 'start'
            player1Score = 0
            player2Score = 0
        elseif gameState == 'serve' then
            gameState = 'play'
        end
    end
end

--[[
    Called after updated by LOVE, used to draw anything to the screen, updated or otherwise.
]]
function love.draw()
    --Begin rendering at virtual resolution
    push:apply('start')

    --Change the collor of the background
    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)
    
    ball:render() --Render ball
    paddle1:render() --Render first paddle (left side)
    paddle2:render() --Render second paddle (right side)

    love.graphics.setFont(smallFont) --Set a font to the next text

    if gameState == 'start' then
        love.graphics.printf("Welcome to Pong!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to Play!", 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s turn", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to Serve!", 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'victory' then
        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player " .. tostring(winningPLayer) .. " wins!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to Restart!", 0, 42, VIRTUAL_WIDTH, 'center')
    end

    love.graphics.setFont(scoreFont)
    love.graphics.print(player1Score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(player2Score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    displayFPS()

    --End rendering at virtual resolution
    push:apply('end')
end

function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40, 20)
    love.graphics.setColor(1, 1, 1, 1)
end