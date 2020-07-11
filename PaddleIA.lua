PaddleIA = Class{}

local w11, w21, w31, w41, w51, w61, w12, w22, w32, w42, w52, w62 = 505.76, 69780.36, -186.78, -1709.64, 210.63, -69244.43, 226.82, -54670.46, 276.34, 5907.17, 83.54, 56708.28
local learningRate = 0.05

--Initialize a paddle with position (x,y) and size (width,height)
function PaddleIA:init(x, y, width, height, paddle_speed, percent)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.PADDLE_SPEED = paddle_speed
    self.dy = 0
    w11, w21, w31, w41, w51, w61, w12, w22, w32, w42, w52, w62 =  w11 * percent, w21 * percent, w31 * percent, w41 * percent, w51 * percent, w61 * percent, w12 * percent, w22 * percent, w32 * percent, w42 * percent, w52 * percent, w62 * percent
end

--Update the position of the paddle
function PaddleIA:update(dt, ball)
    decision(ball, self)
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    elseif self.dy > 0 then
        self.y = math.min(VIRTUAL_HEIGHT  - 20, self.y + self.dy * dt)
    end
    updateW(ball, self)
end

--Render the paddle, make it visible on the screen
function PaddleIA:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

function sigmoid(x)
    return (1/(1+ math.exp(-x)))
end

function decision(ball, paddle)
    o1 = sigmoid(ball.x * w11 + ball.y * w21 + ball.dx * w31 + ball.dy * w41 + paddle.x * w51 + paddle.y * w61) <= 0.5 and -1 or 1
    o2 = sigmoid(ball.x * w12 + ball.y * w22 + ball.dx * w32 + ball.dy * w42 + paddle.x * w52 + paddle.y * w62) <= 0.5 and -1 or 1
    if o1 == -1 and o2 == 1 then paddle.dy = -paddle.PADDLE_SPEED
    elseif o1 == 1 and o2 == -1 then paddle.dy = paddle.PADDLE_SPEED
    else paddle.dy = 0
    end
end

function updateW(ball, paddle)
    if paddle.y <= ball.y and paddle.y + paddle.height >= ball.y + ball.height then
        targeto1 = 1
        targeto2 = 1
    elseif paddle.y > ball.y + ball.height then
        targeto1 = -1
        targeto2 = 1
    else
        targeto1 = 1
        targeto2 = -1
    end
    w11 = w11 + learningRate * (targeto1 - o1) * ball.x
    w21 = w21 + learningRate * (targeto1 - o1) * ball.y
    w31 = w31 + learningRate * (targeto1 - o1) * ball.dx
    w41 = w41 + learningRate * (targeto1 - o1) * ball.dy
    w51 = w51 + learningRate * (targeto1 - o1) * paddle.x
    w61 = w61 + learningRate * (targeto1 - o1) * paddle.y
    w12 = w12 + learningRate * (targeto2 - o2) * ball.x
    w22 = w22 + learningRate * (targeto2 - o2) * ball.y
    w32 = w32 + learningRate * (targeto2 - o2) * ball.dx
    w42 = w42 + learningRate * (targeto2 - o2) * ball.dy
    w52 = w52 + learningRate * (targeto2 - o2) * paddle.x
    w62 = w62 + learningRate * (targeto2 - o2) * paddle.y
end

function PaddleIA:save(filePath)
    -- Opens a file in read
    file = io.open(filePath, "a+")

    -- sets the default output file as test.lua
    io.output(file)

    -- appends a word test to the last line of the file
    io.write(string.format("%.2f", w11) .. ", " .. string.format("%.2f", w21) .. ", " .. string.format("%.2f", w31) .. ", " .. string.format("%.2f", w41) .. ", " .. string.format("%.2f", w51) .. ", " .. string.format("%.2f", w61) .. "\n")
    io.write(string.format("%.2f", w12) .. ", " .. string.format("%.2f", w22) .. ", " .. string.format("%.2f", w32) .. ", " .. string.format("%.2f", w42) .. ", " .. string.format("%.2f", w52) .. ", " .. string.format("%.2f", w62) .. "\n" .. "\n")

    -- closes the open file
    io.close(file)
end

function PaddleIA:changeLR(newLR)
    learningRate = newLR
end