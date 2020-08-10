Ball = Class{}

--Initialize a ball with position (x,y) and size (width,height)
function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.previousX = x
    self.previousY = y
    self.dx = 0
    self.dy = math.random(-50, 50)
end

--Verify a collision between the ball and a box
function Ball:collides(box)
    if  self.x > box.x + box.width or self.x + self.width < box.x then
        if ((self.previousY + self.height >= box.previous_y and self.previousY <= box.previous_y + box.height) and 
        (self.x + self.width < box.x and self.previousX > box.x + box.width) or (self.x > box.x + box.width and self.previousX + self.width < box.x)) then
            return true
        end
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
    self.previousX = self.x
    self.previousY = self.y
    --Given ball's y velocity a random starting value
    self.dy = math.random(-50, 50)
end

--Updates the ball position
function Ball:update(dt)
    self.previousX = self.x
    self.previousY = self.y
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

----Render the ball, make it visible on the screen
function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end