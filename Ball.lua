Ball = Class{}

--Initialize a ball with position (x,y) and size (width,height)
function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self.dx = 0
    self.dy = math.random(-50, 50)
end

--Verify a collision between the ball and a box
function Ball:collides(box)
    if  self.x > box.x + box.width or self.x + self.width < box.x then
        return false
    end
    if self.y > box.y + box.height or self.y + self.height < box.y then
        return false
    end
    return true
end

--Reset the ball to the initial position
function Ball:reset()
    --Start ball's position in the middle of the screen
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2

    --Given ball's y velocity a random starting value
    self.dy = math.random(-50, 50)
end

--Updates the ball position
function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

----Render the ball, make it visible on the screen
function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end