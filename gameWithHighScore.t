%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Programmer: Almen Ng
%Program Name: Pac-Man
%Date: June 15, 2016
%Course:  ICS3CU1  Final Project 15%
%Teacher:  Mr. Simon Huang
%Descriptions: This game can either be player single player or multi-player.
% Within this maze, there will be 4 monsters whose movements will be controlled by the program.
% Using the arrow keysPacMan/ "ASDW" keysPacMan (if in multi-player mode), players must collect the "food"
% (circles on game board tiles) scattered throughout the maze without being caught by a monster.
% Game ends when all food is collected or Pac-man/Pac-woman caught by a monster.
% Players get 3 chances to try again before they lose.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Declarations and Intializations 
% Record for the characters (Took me a long time to do this...but it works!)
type Main :
record
    speed : real
    % Basically, when the game mode is fright (Pacman eats the large dot and the ghosts turn blue), the speed will definitely change. This variable will keep track of the fright speed for each level.
    speedFright : real
    radiusX : real
    radiusY : real
    xPosition : int
    yPosition : int
    xTilePosition : int
    yTilePosition : int
    direction : int
    % Pause the character 
    pauseCharacter : int
    % Pose of the character 
    pose : int
    column : int
    row : int
    turns : int
    dots : int
    dotsLimit : int
    chaseMode : int
    scatterMode : int
    % Determines what mode the game is in (e.g. eaten, ghosthouse)
    mode : string
    % Determines if the ghosts leave or not 
    leave : boolean
    % Determines if the game is in fright mode or not. 
    fright : boolean
end record

% Pacman and Ghosts (using records)
var Pac : Main
var Ghost : array 1 .. 4 of Main

% Constants 
const SHORTESTPATH : real := 1000 / 60
% Number of scores for highscores 
const NUMBEROFSCORES : int := 5 

%Setting up FONTs 
const FONT := Font.New ("Emulogic:17")
const FONT1 := Font.New ("Emulogic:30")
const FONT2 := Font.New ("namco regular:6")
const FONT3 := Font.New ("Emulogic:8")
const FONT4 := Font.New ("Emulogic:10")
const FONT5 := Font.New ("Emulogic:18") 
const FONT6 := Font.New ("Emulogic:40")
const FONT7 := Font.New ("Emulogic:12")


% Regular Variable declaractions 
var ghostEaten, possibleDirection, ghostLeave, countingDots, lastDot, columnTarget, rowTarget, newDirection, timeNow, pastTime, frames, pacmanFrames, modeFrames, ghostFrames, frightFrames, frightLimit, flash, dotsEaten, fileName, value, numberOfLives, levelNumber, gameScore, mouseX, mouseY, button, lifeScore, highscore, introTitleFrameNumber, introTitleFrame, introLoopFrameNumber, introLoopFrame : int
var restrictingGhost, restrictingPath, restrictingPacman, closest, delayNum : real
% ghostMode: Determining individual ghost mode (e.g. scatter, chase) 
% username: This is for the end when a player has a highscore. If so, the user will have to input their name to be on the highscore board. 
var ghostMode, username : string
var win, death, continue, instructions, closeAllWindows : boolean

% Arrays 
% Reflective of the 4 directions. Helps determine which direction the character will go at an intersection. 
var distanceTarget : array 1 .. 4 of real
% Ghost eyes (up, down, right, left) 
var ghostEyePics : array 1 .. 4 of int
% Key. If pressed, it's true. Else false. 
var keys : array char of boolean
% For highscore purposes (Temps are for sorting) 
var names, namesTemp, scores, scoresTemp : array 1..NUMBEROFSCORES of string 

% 2D arrays: 
% Pacman pictures of movement 
var pacmanPics : array 1 .. 4 of array 1 .. 4 of int
% Ghost pictures of movement 
var ghostPics : array 1 .. 6 of array 1 .. 2 of int

%Setting up dot and board values
var dots : array 1 .. 36 of array 0 .. 31 of int
var wallValues : array 1 .. 36 of array 0 .. 31 of int

% Opening the text file for the board values. 
open : fileName, "Files/Text/boardvalues.txt", get
for decreasing i : 36 .. 1
    for j : 0 .. 31
        % Gets the values in the file and puts it in the array. 
        get : fileName, value
        wallValues (i) (j) := value
    end for
end for
    close : fileName

% Opening the text file for dot values. 
open : fileName, "Files/Text/dotvalues.txt", get
for decreasing i : 36 .. 1
    for j : 0 .. 31
        % Gets the value in the file and puts it in the array. 
        get : fileName, value
        dots (i) (j) := value
    end for
end for
    close : fileName

% Opening the textile for highscores. 
open : fileName, "Files/Text/highScores.txt", get 
for i : 1..NUMBEROFSCORES 
    % Gets the value in the file and puts it in the array. 
    get : fileName, names (i) 
    get : fileName, scores (i)
    % Makes a temporary array for names and scores. 
    namesTemp (i) := names (i) 
    scoresTemp (i) := scores (i)
end for 
    close : fileName

% Setting the pictures up by assigning them to the array. 
var background : int := Pic.FileNew ("Images/background.bmp")
var powerUpDot : int := Pic.FileNew ("Images/Dot.bmp")

pacmanPics (1) (1) := Pic.FileNew ("Images/Character/Pacman/PacmanClosed.bmp")
pacmanPics (1) (2) := Pic.FileNew ("Images/Character/Pacman/Pacman1Half.bmp")
pacmanPics (1) (3) := Pic.FileNew ("Images/Character/Pacman/Pacman1Open.bmp")
pacmanPics (1) (4) := pacmanPics (1) (2)

pacmanPics (2) (1) := Pic.FileNew ("Images/Character/Pacman/PacmanClosed.bmp")
pacmanPics (2) (2) := Pic.FileNew ("Images/Character/Pacman/Pacman2Half.bmp")
pacmanPics (2) (3) := Pic.FileNew ("Images/Character/Pacman/Pacman2Open.bmp")
pacmanPics (2) (4) := pacmanPics (2) (2)

pacmanPics (3) (1) := Pic.FileNew ("Images/Character/Pacman/PacmanClosed.bmp")
pacmanPics (3) (2) := Pic.FileNew ("Images/Character/Pacman/Pacman3Half.bmp")
pacmanPics (3) (3) := Pic.FileNew ("Images/Character/Pacman/Pacman3Open.bmp")
pacmanPics (3) (4) := pacmanPics (3) (2)

pacmanPics (4) (1) := Pic.FileNew ("Images/Character/Pacman/PacmanClosed.bmp")
pacmanPics (4) (2) := Pic.FileNew ("Images/Character/Pacman/Pacman4Half.bmp")
pacmanPics (4) (3) := Pic.FileNew ("Images/Character/Pacman/Pacman4Open.bmp")
pacmanPics (4) (4) := pacmanPics (4) (2)

ghostPics (1) (1) := Pic.FileNew ("Images/Character/Ghosts/RedGhost1.bmp")
ghostPics (1) (2) := Pic.FileNew ("Images/Character/Ghosts/RedGhost2.bmp")

ghostPics (2) (1) := Pic.FileNew ("Images/Character/Ghosts/PinkGhost1.bmp")
ghostPics (2) (2) := Pic.FileNew ("Images/Character/Ghosts/PinkGhost2.bmp")

ghostPics (3) (1) := Pic.FileNew ("Images/Character/Ghosts/BlueGhost1.bmp")
ghostPics (3) (2) := Pic.FileNew ("Images/Character/Ghosts/BlueGhost2.bmp")

ghostPics (4) (1) := Pic.FileNew ("Images/Character/Ghosts/BrownGhost1.bmp")
ghostPics (4) (2) := Pic.FileNew ("Images/Character/Ghosts/BrownGhost2.bmp")

ghostPics (5) (1) := Pic.FileNew ("Images/Character/Ghosts/Frightened1.bmp")
ghostPics (5) (2) := Pic.FileNew ("Images/Character/Ghosts/Frightened2.bmp")

ghostPics (6) (1) := Pic.FileNew ("Images/Character/Ghosts/White1.bmp")
ghostPics (6) (2) := Pic.FileNew ("Images/Character/Ghosts/White2.bmp")

ghostEyePics (1) := Pic.FileNew ("Images/Character/Ghosts/EyesUp.bmp")
ghostEyePics (2) := Pic.FileNew ("Images/Character/Ghosts/EyesLeft.bmp")
ghostEyePics (3) := Pic.FileNew ("Images/Character/Ghosts/EyesDown.bmp")
ghostEyePics (4) := Pic.FileNew ("Images/Character/Ghosts/EyesRight.bmp")

% Setting the screen 
var windows : int := Window.Open ("position:top;center,graphics:450,580,offscreenonly,nobuttonbar,nocursor, title: PacMan")
% Hide the window 
Window.Hide(defWinID)

% Process to play the background music. Badada Badadada DAAAA!  
process endMusic 
    loop
        % If statement: If continue is true and instructions is false or if closeAllWindows then stop all the music 
        if continue = true and instructions = false or closeAllWindows then
            Music.PlayFileStop
            exit 
        end if 
    end loop
end endMusic

% Process to play the music before pacman starts moving around 
process IntroMusic
    Music.PlayFile ("Sound/gameStartMusic.mp3")
end IntroMusic

% Process to loop the gif frames for introduction 
process introLoop
    loop 
        % Exit condition: Exit when continue is true and closeAllWindows is true 
        exit when continue = true or closeAllWindows = true 
        % If statement: If 'introLoopFrameNumber' is not equal to 586 then increase it by one. 
        if introLoopFrameNumber not= 586 then
            introLoopFrameNumber += 1
            % Else go back to 1 
        else
            introLoopFrameNumber := 1
        end if
        % Update the frame number 
        introLoopFrame := Pic.FileNew ("Images/introScreen/introLoop (" + intstr (introLoopFrameNumber) + ").jpg")
        % Draw the frame 
        Pic.Draw (introLoopFrame, 25, 190, picCopy)
        delay (20)
        % Free the picture so there will be no errors when it exceeds the mask amount of stored images. 
        Pic.Free (introLoopFrame)
        
        View.Update         
    end loop
end introLoop

% Process for making the buttons. 
process introduction
    cls 
    % Draw my name :D. Nice FONT ay? 
    Font.Draw ("created by almen ng", 130, 25, FONT2, brightred) 
    % Loop for the highlighting and clicking text (Play Game, Instructions, Quit) 
    loop 
        % Checks current information about the mouse (x, y, and if the button was clicked)
        Mouse.Where (mouseX, mouseY, button)
        
        % If statement: If the mouse is within these coordinates then draw 'Play Game' in blue.  
        if mouseX >= 120 and mouseX <= 330 and mouseY >= 170 and mouseY <= 190 then
            Font.Draw ("Play Game", 120, 170, FONT, 55)
            % If statement: if the button is pressed then make continue true and instructions false. 
            if button = 1 then
                continue := true
                instructions := false 
            end if
            % Else draw it white. 
        else
            Font.Draw ("Play Game", 120, 170, FONT, white)
        end if
        
        % If statement: If the mouse is within these coordinates then draw 'Instructions' in blue.
        if mouseX >= 85 and mouseX <= 363 and mouseY >= 120 and mouseY <= 140 then
            Font.Draw ("Instructions", 85, 120, FONT, 55)
            % If statement: if the button is pressed then make continue true and instructions true.
            if button = 1 then
                continue := true
                instructions := true
            end if
            % Else draw it white. 
        else
            Font.Draw ("Instructions", 85, 120, FONT, white)
        end if
        
        % If statement: If the mouse is within these coordinates then draw 'Quit' in blue.
        if mouseX >= 175 and mouseX <= 271 and mouseY >= 70 and mouseY <= 90 then
            Font.Draw ("Quit", 175, 70, FONT, 55)
            % If statement: if the button is pressed then make closeAllWindows true and close the window.
            if button = 1 then
                closeAllWindows:=true
                Window.Close (windows)
                exit
            end if
            % Else draw it white. 
        else
            Font.Draw ("Quit", 175, 70, FONT, white)
        end if
        
        % Exit condition: Exit when continue is true. 
        exit when continue = true 
        
        View.Update 
        
    end loop 
end introduction

% Passing by values: Procedure makes it 60 frames (by delaying) and draws the score and highscore. 
proc timer
    pastTime := timeNow + round (delayNum)
    timeNow := Time.Elapsed
    if timeNow - pastTime < SHORTESTPATH then
        delayNum := SHORTESTPATH - (timeNow - pastTime)
    end if
    
    Font.Draw ("SCORE", 10, 565, FONT4, white)
    Font.Draw (intstr (gameScore), 10, 540, FONT5, white)
    Font.Draw ("LIVES", 160, 8, FONT, white) 
    Font.Draw (intstr (numberOfLives, 3), 250, 7, FONT, white)
    if gameScore > highscore then
        Font.Draw ("HIGHSCORE", 330, 565, FONT4, white)
        Font.Draw (intstr (gameScore, 6), 303, 540, FONT5, white)
    else
        Font.Draw ("HIGHSCORE", 330, 565, FONT4, white)
        Font.Draw (intstr (highscore, 6), 303, 540, FONT5, white)
    end if    
    
    % Faster than view.Update o-o 
    View.UpdateArea (0, 0, 448, 576)
    delay (round (delayNum))
    cls
end timer

% Passing by values: Gets the input of the keys and determins Pacman's new direction 
proc Turning
    Input.KeyDown (keys)
    
    % If statement: If Pacman can turn 
    if wallValues (Pac.row) (Pac.column) = 2 then
        
        % If statment: If pacman is in the right position to turn
        if (Pac.direction = 1 and Pac.yTilePosition <= 9) or (Pac.direction = 3 and Pac.yTilePosition >= 9) or (Pac.direction = 4 and Pac.xTilePosition <= 6) or (Pac.direction = 2 and Pac.xTilePosition >= 6) then
            
            % If statement: If up arrow key is pressed and the path is not blocked then go change the direction and turn 
            if keys (KEY_UP_ARROW) and wallValues (Pac.row + 1) (Pac.column) not = 0 then
                Pac.direction := 1
                Pac.turns := 5
                % If statement: If left arrow key is pressed and the path is not blocked then go change the direction and turn 
            elsif keys (KEY_LEFT_ARROW) and wallValues (Pac.row) (Pac.column - 1) not= 0 then
                Pac.direction := 2
                Pac.turns := 5
                % If statement: If down arrow key is pressed and the path is not blocked then go change the direction and turn 
            elsif keys (KEY_DOWN_ARROW) and wallValues (Pac.row - 1) (Pac.column) not= 0 then
                Pac.direction := 3
                Pac.turns := 5
                % If statement: If right arrow arrow key is pressed and the path is not blocked then go change the direction and turn 
            elsif keys (KEY_RIGHT_ARROW) and wallValues (Pac.row) (Pac.column + 1) not= 0 then
                Pac.direction := 4
                Pac.turns := 5
            end if
        end if
    end if
    
    % If statement: This allows pacman to go backwards 
    if (Pac.direction = 1 or Pac.direction = 3) and (wallValues (Pac.row) (Pac.column) = 1 or wallValues (Pac.row) (Pac.column) = 3) then
        if keys (KEY_UP_ARROW) then
            Pac.direction := 1
        elsif keys (KEY_DOWN_ARROW) then
            Pac.direction := 3
        end if
    elsif (Pac.direction = 2 or Pac.direction = 4) and (wallValues (Pac.row) (Pac.column) = 1 or wallValues (Pac.row) (Pac.column) = 3) then
        if keys (KEY_LEFT_ARROW) then
            Pac.direction := 2
        elsif keys (KEY_RIGHT_ARROW) then
            Pac.direction := 4
        end if
    end if
end Turning

% Passing by values: Stops pacman from running into walls
proc Collisions
    if wallValues (Pac.row) (Pac.column) = 2 then
        if Pac.direction = 1 and Pac.yTilePosition = 9 and wallValues (Pac.row + 1) (Pac.column) = 0 then
            Pac.pauseCharacter += 1
        elsif Pac.direction = 3 and Pac.yTilePosition = 9 and wallValues (Pac.row - 1) (Pac.column) = 0 then
            Pac.pauseCharacter += 1
        elsif Pac.direction = 4 and Pac.xTilePosition = 6 and wallValues (Pac.row) (Pac.column + 1) = 0 then
            Pac.pauseCharacter += 1
        elsif Pac.direction = 2 and Pac.xTilePosition = 6 and wallValues (Pac.row) (Pac.column - 1) = 0 then
            Pac.pauseCharacter += 1
        end if
    end if
end Collisions

% Passing by values: Moves pacman the direction he is going 
proc Movement
    
    % If statement: Tunnel movement: 1 located on the left of the screen...and one located on the right. If he's going through the left one, he appears through the right.  
    if Pac.column = 0 and Pac.xTilePosition = 2 then
        Pac.radiusX := 482
        Pac.column := 31
        % If he goes through the right one, he appears through the left. 
    elsif Pac.column = 31 and Pac.xTilePosition = 2 then
        Pac.radiusX := -14
        Pac.column := 0
    end if
    
    % If statement: Determine the pose of pacman 
    pacmanFrames += 1
    if pacmanFrames mod 2 = 0 then
        Pac.pose += 1
    end if
    if Pac.pose > 4 then
        Pac.pose := 1
    end if
    
    % If statement: Determine the speed of pacman 
    if Pac.fright then
        Pac.speed := Pac.speedFright
    else
        Pac.speed := restrictingPacman
    end if
    
    % If statement: Based on speed and the direction he's going at, determine his movement. 
    if Pac.direction = 1 then
        Pac.radiusY += (2 * Pac.speed)
    elsif Pac.direction = 2 then
        Pac.radiusX -= (2 * Pac.speed)
    elsif Pac.direction = 3 then
        Pac.radiusY -= (2 * Pac.speed)
    elsif Pac.direction = 4 then
        Pac.radiusX += (2 * Pac.speed)
    end if
    
    % If statement: Allows pacman to "pre-turn" (in other words, smoother, nicer turns) (x) 
    if Pac.direction = 1 or Pac.direction = 3 then
        if Pac.xTilePosition < 5 then
            Pac.radiusX += (2 * Pac.speed)
        elsif Pac.xTilePosition > 7 then
            Pac.radiusX -= (2 * Pac.speed)
        end if
    end if
    
    % If statement: Allows pacman to "pre-turn" (in other words, smoother, nicer turns) (y)
    if Pac.direction = 2 or Pac.direction = 4 then
        if Pac.yTilePosition < 8 then
            Pac.radiusY += (2 * Pac.speed)
        elsif Pac.yTilePosition > 10 then
            Pac.radiusY -= (2 * Pac.speed)
        end if
    end if
end Movement

% Passing by values: Determine the direction the ghosts are moving (according to their number) 
proc GhostMovement (i : int)
    
    % If statement: Tunnel movement: 1 located on the left of the screen...and one located on the right. If ghost goes through the left one, it appears through the right.  
    if Ghost (i).column = 0 and Ghost (i).xTilePosition = 2 then
        Ghost (i).radiusX := 481.3
        Ghost (i).column := 31
        % If it goes through the right one, it appears through the left. 
    elsif Ghost (i).column = 31 and Ghost (i).xTilePosition = 2 then
        Ghost (i).radiusX := -13.3
        Ghost (i).column := 0
    end if
    
    % If statement: Determine the pose of pacman 
    if ghostFrames mod 8 = 0 then
        Ghost (i).pose += 1
    end if
    if Ghost (i).pose > 2 then
        Ghost (i).pose := 1
    end if
    
    % If statement: Determine the speed of ghost 
    % If the ghost is eaten, then make it go faster.
    if Ghost (i).mode = "eaten" then
        Ghost (i).speed := 2
        
        % Move the ghosts to the ghost house located in the centre of the game, movement around the house, and changing their mode (e.g. eaten, ghostHouse) 
        if Ghost (i).xPosition = 222 and Ghost (i).yPosition = 345 then
            Ghost (i).direction := 3
        elsif Ghost (i).xPosition = 222 and Ghost (i).yPosition = 289 then
            if i = 1 or i = 2 then
                Ghost (i).xPosition := 224
                Ghost (i).radiusX := 224
                Ghost (i).direction := 1
                Ghost (i).mode := "ghosthouse"
            elsif i = 3 then
                Ghost (i).direction := 2
            elsif i = 4 then
                Ghost (i).direction := 4
            end if
        elsif Ghost (i).xPosition = 190 and Ghost (i).yPosition = 289 then
            Ghost (i).direction := 4
            Ghost (i).mode := "ghosthouse"
        elsif Ghost (i).xPosition = 258 and Ghost (i).yPosition = 289 then
            Ghost (i).direction := 2
            Ghost (i).mode := "ghosthouse"
        end if
        
    elsif Ghost (i).mode = "ghosthouse" or wallValues (Ghost (i).row) (Ghost (i).column) = 3 then
        Ghost (i).speed := restrictingPath
    elsif Ghost (i).fright then
        Ghost (i).speed := Ghost (i).speedFright
    else
        Ghost (i).speed := restrictingGhost
    end if
    
    % If statement: Determines movement of ghosts(based on speed, direction, and locations to avoid errors in turning)
    if Ghost (i).direction = 1 then
        if Ghost (i).turns > 0 and ((round (((Ghost (i).radiusY + (2 * Ghost (i).speed)) - 1) / 2)) * 2) + 1 = Ghost (i).yPosition then
            Ghost (i).radiusY += 2
        else
            Ghost (i).radiusY += (2 * Ghost (i).speed)
        end if
    elsif Ghost (i).direction = 2 then
        if Ghost (i).turns > 0 and (round ((Ghost (i).radiusX - (2 * Ghost (i).speed)) / 2)) * 2 = Ghost (i).xPosition then
            Ghost (i).radiusX -= 2
        else
            Ghost (i).radiusX -= (2 * Ghost (i).speed)
        end if
    elsif Ghost (i).direction = 3 then
        if Ghost (i).turns > 0 and ((round (((Ghost (i).radiusY - (2 * Ghost (i).speed)) - 1) / 2)) * 2) + 1 = Ghost (i).yPosition then
            Ghost (i).radiusY -= 2
        else
            Ghost (i).radiusY -= (2 * Ghost (i).speed)
        end if
    elsif Ghost (i).direction = 4 then
        if Ghost (i).turns > 0 and (round ((Ghost (i).radiusX + (2 * Ghost (i).speed)) / 2)) * 2 = Ghost (i).xPosition then
            Ghost (i).radiusX += 2
        else
            Ghost (i).radiusX += (2 * Ghost (i).speed)
        end if
    end if
    if Ghost (i).turns > 0 then
        Ghost (i).turns -= 1
    end if
end GhostMovement

% Function (passing by values): Retirms the direction a ghost will travel at an intersection
function GhostTurn (i : int) : int
    
    % If statement: Determining distances to target (aka pacman) in each direction (and limiting directions based on direction ghost is travelling and location)
    if (wallValues (Ghost (i).row + 1) (Ghost (i).column) = 0) or (Ghost (i).direction = 3) or (Ghost (i).row = 10 and (Ghost (i).column = 13 or Ghost (i).column = 16)) or (Ghost (i).row = 22 and (Ghost (i).column = 13 or Ghost (i).column = 16)) then
        distanceTarget (1) := maxint
    else
        distanceTarget (1) := Math.Distance ((Ghost (i).column) * 16, (Ghost (i).row + 1) * 16, columnTarget * 16, rowTarget * 16)
    end if
    
    if (wallValues (Ghost (i).row) (Ghost (i).column - 1) = 0) or (Ghost (i).direction = 4) then
        distanceTarget (2) := maxint
    else
        distanceTarget (2) := Math.Distance ((Ghost (i).column - 1) * 16, (Ghost (i).row) * 16, columnTarget * 16, rowTarget * 16)
    end if
    
    if (wallValues (Ghost (i).row - 1) (Ghost (i).column) = 0) or (Ghost (i).direction = 1) then
        distanceTarget (3) := maxint
    else
        distanceTarget (3) := Math.Distance ((Ghost (i).column) * 16, (Ghost (i).row - 1) * 16, columnTarget * 16, rowTarget * 16)
    end if
    
    if (wallValues (Ghost (i).row) (Ghost (i).column + 1) = 0) or (Ghost (i).direction = 2) then
        distanceTarget (4) := maxint
    else
        distanceTarget (4) := Math.Distance ((Ghost (i).column + 1) * 16, (Ghost (i).row) * 16, columnTarget * 16, rowTarget * 16)
    end if
    
    % Finds the closest distance to the target and returning the new direction. 
    closest := maxint
    for j : 1 .. 4
        if distanceTarget (j) < closest then
            closest := distanceTarget (j)
            newDirection := j
        end if
    end for
        
    Ghost (i).turns += 1
    
    result newDirection
end GhostTurn

% Passing by values: Determines which tile the ghost will target, and finds the direction it needs to turn (using the function (ghostTurn))
proc GhostTarget (i : int)
    
    % If statement: This helps find the tile the ghost will go to based on the mode and pacman's position 
    if Ghost (i).mode = "eaten" then
        rowTarget := 22
        columnTarget := 14
    elsif Ghost (i).mode = "scatter" then
        if i = 1 then
            rowTarget := 36
            columnTarget := 26
        elsif i = 2 then
            rowTarget := 36
            columnTarget := 3
        elsif i = 3 then
            rowTarget := 2
            columnTarget := 28
        elsif i = 4 then
            rowTarget := 2
            columnTarget := 1
        end if
    elsif Ghost (i).mode = "chase" then
        if i = 1 then
            rowTarget := Pac.row
            columnTarget := Pac.column
        elsif i = 2 then
            if Pac.direction = 1 then
                rowTarget := Pac.row + 4
                columnTarget := Pac.column - 4
            elsif Pac.direction = 2 then
                rowTarget := Pac.row
                columnTarget := Pac.column - 4
            elsif Pac.direction = 3 then
                rowTarget := Pac.row - 4
                columnTarget := Pac.column
            elsif Pac.direction = 4 then
                rowTarget := Pac.row
                columnTarget := Pac.column + 4
            end if
        elsif i = 3 then
            if Pac.direction = 1 then
                rowTarget := (Pac.row + 2) + ((Pac.row + 2) - Ghost (1).row)
                columnTarget := (Pac.column - 2) + ((Pac.column - 2) - Ghost (1).column)
            elsif Pac.direction = 2 then
                rowTarget := Pac.row + (Pac.row - Ghost (1).row)
                columnTarget := (Pac.column - 2) + ((Pac.column - 2) - Ghost (1).column)
            elsif Pac.direction = 3 then
                rowTarget := (Pac.row - 2) + ((Pac.row - 2) - Ghost (1).row)
                columnTarget := Pac.column + ((Pac.column - 2) - Ghost (1).column)
            elsif Pac.direction = 4 then
                rowTarget := Pac.row + (Pac.row - Ghost (1).row)
                columnTarget := (Pac.column + 2) + ((Pac.column + 2) - Ghost (1).column)
            end if
        elsif i = 4 then
            if Math.Distance (Pac.column, Pac.row, Ghost (i).column, Ghost (i).row) >= 8 then
                rowTarget := Pac.row
                columnTarget := Pac.column
            else
                rowTarget := 2
                columnTarget := 1
            end if
        end if
    end if
    
    % Calls the function (ghostTurn) to determine which path the ghosts should take
    Ghost (i).direction := GhostTurn (i)
end GhostTarget

% Passing by values: Ghost behavior inside the ghost house (Each of the ghosts have different behaviors and I tried to impliment that into the game http://mentalfloss.com/uk/games/31287/the-different-strategies-of-each-of-pac-mans-ghosts) 
proc GhostHouse (i, frames : int)
    
    %Determining which ghost, then determining the ghost's direction based on location and whether it can leave or not
    if i = 1 then
        if Ghost (1).xPosition = 224 and Ghost (1).yPosition = 345 then
            Ghost (1).mode := ghostMode
            Ghost (i).direction := 2
        else
            Ghost (1).direction := 1
        end if
    elsif i = 2 then
        if Ghost (2).leave = false and (countingDots = 7 or (frames - lastDot) = ghostLeave) then
            Ghost (2).leave := true
            lastDot := frames
        end if
        if Ghost (2).leave = true then
            Ghost (2).direction := 1
            if Ghost (2).xPosition = 224 and Ghost (2).yPosition = 345 then
                Ghost (2).mode := ghostMode
                Ghost (i).direction := 2
            end if
        else
            if Ghost (2).xPosition = 224 and Ghost (2).yPosition = 289 then
                Ghost (2).direction := 1
            elsif Ghost (2).xPosition = 224 and Ghost (2).yPosition = 305 then
                Ghost (2).direction := 3
            end if
        end if
    elsif i = 3 then
        if Ghost (3).leave = false and ((countingDots < 0 and Ghost (3).dotsLimit = Ghost (3).dots) or countingDots = 17 or (frames - lastDot) = ghostLeave) then
            Ghost (3).leave := true
            lastDot := frames
        end if
        if Ghost (3).leave = true then
            if Ghost (3).xPosition < 224 then
                Ghost (3).direction := 4
            end if
            if Ghost (3).xPosition = 224 then
                Ghost (3).direction := 1
            end if
            if Ghost (3).xPosition = 224 and Ghost (3).yPosition = 345 then
                Ghost (3).mode := ghostMode
                Ghost (i).direction := 2
            end if
        else
            if Ghost (3).yPosition = 289 then
                Ghost (3).direction := 1
            elsif Ghost (3).yPosition = 305 then
                Ghost (3).direction := 3
            end if
        end if
    elsif i = 4 then
        if Ghost (4).leave = false and ((countingDots < 0 and Ghost (4).dotsLimit = Ghost (4).dots) or countingDots = 32 or (frames - lastDot) = ghostLeave) then
            Ghost (4).leave := true
            lastDot := frames
        end if
        if Ghost (4).leave = true then
            if Ghost (4).xPosition > 224 then
                Ghost (4).direction := 2
            end if
            if Ghost (4).xPosition = 224 then
                Ghost (4).direction := 1
            end if
            if Ghost (4).xPosition = 224 and Ghost (4).yPosition = 345 then
                Ghost (4).mode := ghostMode
                Ghost (i).direction := 2
            end if
        else
            if Ghost (4).yPosition = 289 then
                Ghost (4).direction := 1
            elsif Ghost (4).yPosition = 305 then
                Ghost (4).direction := 3
            end if
        end if
    end if
end GhostHouse

% Passing by values: Determines if pacman has eaten the dots. Also determines when the fright mode is on or off based on if pacman eats the larger dot. Draws the dots as well. 
proc Dots (frames : int)
    
    % If statement: Eating a dot when pacman is on a tile that has a dot on it. 
    if dots (Pac.row) (Pac.column) = 1 then
        dots (Pac.row) (Pac.column) := 0
        Pac.pauseCharacter := 1
        dotsEaten += 1
        % Increases the gameScore 
        gameScore += 10
        % Increases the lifeScore so if he reaches 10000, another life would be given to pacman 
        lifeScore += 10
        
        % Also part of ghost behavior. Determines whether the ghosts can leave the ghosthouse or not
        if countingDots > -1 then
            countingDots += 1
        elsif Ghost (3).mode = "ghosthouse" and Ghost (3).leave = false then
            Ghost (3).dots += 1
        elsif Ghost (4).mode = "ghosthouse" and Ghost (4).leave = false then
            Ghost (4).dots += 1
        end if
        lastDot := frames
        
        % Elsif pacman is eating a large dot 
    elsif dots (Pac.row) (Pac.column) = 2 then
        dots (Pac.row) (Pac.column) := 0
        Pac.pauseCharacter := 3
        dotsEaten += 1
        % Increases the gameScore 
        gameScore += 50
        % Increases the lifeScore so if he reaches 10000, another life would be given to pacman 
        lifeScore += 50
        
        % For Loop: Changing the ghost mode from scatter to fright
        for i : 1 .. 4
            if Ghost (i).mode not= "eaten" then
                Ghost (i).fright := true
                Ghost (i).direction += 2
                if Ghost (i).direction > 4 then
                    Ghost (i).direction -= 2
                end if
            end if
        end for
            frightFrames := 1
        Pac.fright := true
    end if
    
    % Adding numberOfLives based on gameScore using lifeScore that has been updated along with gameScore 
    if lifeScore >= 10000 then
        lifeScore -= 10000
        numberOfLives += 1
    end if
    
    % If statement: Turning off the fright mode 
    if frightFrames = frightLimit then
        frightFrames := 0
        for i : 1 .. 4
            if Ghost (i).fright then
                Ghost (i).fright := false
            end if
        end for
            Pac.fright := false
        ghostEaten := 0
    end if
    
    % For loop: Drawing the small dots on the screen 
    for i : 4 .. 34
        for j : 2 .. 28
            if dots (i) (j) = 1 then
                Draw.FillBox ((j * 16) - 10, (i * 16) - 10, (j * 16) - 6, (i * 16) - 6, 0)
            end if
        end for
    end for
        
    % If statement: Drawing the large dots that help with fright mode 
    if dots (10) (2) = 2 and (ceil (frames / 8)) mod 2 = 1 then
        Pic.Draw (powerUpDot, 16, 145, picCopy)
    end if
    if dots (10) (27) = 2 and (ceil (frames / 8)) mod 2 = 1 then
        Pic.Draw (powerUpDot, 416, 145, picCopy)
    end if
    if dots (30) (2) = 2 and (ceil (frames / 8)) mod 2 = 1 then
        Pic.Draw (powerUpDot, 16, 465, picCopy)
    end if
    if dots (30) (27) = 2 and (ceil (frames / 8)) mod 2 = 1 then
        Pic.Draw (powerUpDot, 416, 465, picCopy)
    end if
    
    % If statement: Determines if pacman has eaten all the dots or not. 
    if dotsEaten = 244 then
        win := true
        Pac.pose := 1
    end if
end Dots

% Loop for the game 
loop    
    % Initializations 
    continue:= false
    closeAllWindows:=false
    instructions := false 
    introTitleFrameNumber:= 0
    introTitleFrame := 0
    introLoopFrameNumber := 0
    introLoopFrame := 0
    highscore := strint (scores (1)) 
    
    % Making the background colour BLACK
    colorback (black) 
    
    % Forking ending the music. 
    fork endMusic
    
    % Loop for the introduction 
    loop
        % Play the extra cool music 
        Music.PlayFileLoop ("Sound/introMusic.mp3")
        % Forking the buttons 
        fork introduction
        % Forking the introduction gif 
        fork introLoop
        
        delay (300)
        
        % Draw the title on the introduction 
        introTitleFrameNumber +=1
        introTitleFrame := Pic.FileNew ("Images/introScreen/titleScreen" + intstr (introTitleFrameNumber) + ".gif")
        Pic.Draw (introTitleFrame, 0, 340, picCopy)
        delay (25)
        loop
            exit when continue = true 
            % If statement: If it's not at 16, add 1 each time 
            if introTitleFrameNumber not= 16 then
                introTitleFrameNumber += 1
                % Else go back to pic 13 
            else
                introTitleFrameNumber := 13
            end if
            
            introTitleFrame := Pic.FileNew ("Images/introScreen/titleScreen" + intstr (introTitleFrameNumber) + ".gif")
            
            % Draw the image 
            Pic.Draw (introTitleFrame, 0, 340, picCopy)
            delay (30)
            % Free the image (just in case) 
            Pic.Free (introTitleFrame)
        end loop
        
        View.Update
        
        % Exit when true 
        exit when (continue = true)
    end loop    
    
    % If statement: Instructions 
    if continue = true and instructions = true then
        var anyKey : string (1)
        cls
        
        var stream : int
        % Going into a text file 
        open : stream, "files/text/instructions.txt", get
        
        Font.Draw ("Instructions", 12, 520, FONT, white)
        
        if stream > 0 then
            var format1 : int := 505 
            var Lines : string
            loop
                exit when eof (stream)
                format1 -= 30
                get : stream, Lines : *
                Font.Draw (Lines, 13, format1, FONT3, white)
                
            end loop
            close : stream
            Font.Draw ("Press any key to continue...", 13, 30, FONT3, brightred)
        else
            put "Unable to open file."
        end if
        
        View.Update
        
        getch (anyKey)
    end if
    
    % Intializing variables needed every new game 
    levelNumber := 0
    numberOfLives := 3
    gameScore := 0
    lifeScore := 0
    delayNum := 0
    death := false
    
    % Play the really cool intro music 
    fork IntroMusic
    
    % Looping for new levels 
    loop
        % Resetting the dots with a for loop. 
        open : fileName, "Files/Text/dotvalues.txt", get
        for decreasing i : 36 .. 1
            for j : 0 .. 31
                get : fileName, value
                dots (i) (j) := value
            end for
        end for
            close : fileName
        
        % Resetting the variables 
        dotsEaten := 0
        win := false
        levelNumber += 1
        
        % Setting the variables based on the level. Making it harder for the user every new level. 
        if levelNumber = 1 then
            ghostLeave := 240
            restrictingPacman := 0.8
            Pac.speedFright := 0.9
            restrictingGhost := 0.75
            restrictingPath := 0.4
            Ghost (3).dotsLimit := 30
            Ghost (4).dotsLimit := 60
            Ghost (1).chaseMode := 420
            Ghost (1).scatterMode := 1620
            Ghost (2).chaseMode := 2040
            Ghost (2).scatterMode := 3240
            Ghost (3).chaseMode := 3540
            Ghost (3).scatterMode := 4740
            Ghost (4).chaseMode := 5040
            Ghost (4).scatterMode := 4740
            for i : 1 .. 4
                Ghost (i).dots := 0
                Ghost (i).speedFright := 0.5
            end for
            elsif levelNumber >= 2 and levelNumber <= 4 then
            ghostLeave := 240
            restrictingPacman := 0.9
            Pac.speedFright := 0.95
            restrictingGhost := 0.85
            restrictingGhost := 0.85
            restrictingPath := .45
            Ghost (1).chaseMode := 420
            Ghost (1).scatterMode := 1620
            Ghost (2).chaseMode := 2040
            Ghost (2).scatterMode := 3240
            Ghost (3).chaseMode := 3540
            Ghost (3).scatterMode := 65520
            Ghost (4).chaseMode := 65521
            Ghost (4).scatterMode := 65520
            for i : 1 .. 4
                Ghost (i).dots := 0
                Ghost (i).speedFright := 0.55
            end for
            elsif levelNumber >= 5 and levelNumber <= 20 then
            ghostLeave := 180
            restrictingPacman := 1
            Pac.speedFright := 1
            restrictingGhost := 0.95
            restrictingPath := .5
            Ghost (1).chaseMode := 300
            Ghost (1).scatterMode := 1500
            Ghost (2).chaseMode := 1800
            Ghost (2).scatterMode := 3000
            Ghost (3).chaseMode := 3300
            Ghost (3).scatterMode := 65520
            Ghost (4).chaseMode := 65521
            Ghost (4).scatterMode := 65520
            for i : 1 .. 4
                Ghost (i).dots := 0
                Ghost (i).speedFright := 0.6
            end for
            elsif levelNumber > 20 then
            ghostLeave := 180
            restrictingPacman := 0.9
            Pac.speedFright := 0.9
            restrictingGhost := 0.95
            restrictingPath := .5
            Ghost (1).chaseMode := 300
            Ghost (1).scatterMode := 1500
            Ghost (2).chaseMode := 1800
            Ghost (2).scatterMode := 3000
            Ghost (3).chaseMode := 3300
            Ghost (3).scatterMode := 65520
            Ghost (4).chaseMode := 65521
            Ghost (4).scatterMode := 65520
            for i : 1 .. 4
                Ghost (i).dots := 0
                Ghost (i).speedFright := 0.95
            end for
        end if
        if levelNumber = 2 then
            Ghost (3).dotsLimit := 0
            Ghost (4).dotsLimit := 50
        elsif levelNumber >= 3 then
            Ghost (3).dotsLimit := 0
            Ghost (4).dotsLimit := 0
        end if
        if levelNumber = 1 then
            frightLimit := 360
        elsif levelNumber = 2 or levelNumber = 6 or levelNumber = 10 then
            frightLimit := 300
        elsif levelNumber = 3 then
            frightLimit := 240
        elsif levelNumber = 4 or levelNumber = 14 then
            frightLimit := 180
        elsif levelNumber = 5 or levelNumber = 7 or levelNumber = 8 or levelNumber = 11 then
            frightLimit := 120
        elsif levelNumber = 9 or levelNumber = 12 or levelNumber = 13 or levelNumber = 15 or levelNumber = 16 or levelNumber = 18 then
            frightLimit := 60
        else
            frightLimit := 1
        end if
        if (levelNumber >= 1 and levelNumber <= 8) or levelNumber = 10 or levelNumber = 11 or levelNumber = 14 then
            flash := 108
        elsif levelNumber = 9 or levelNumber = 12 or levelNumber = 13 or levelNumber = 15 or levelNumber = 16 or levelNumber = 18 then
            flash := 60
        else
            flash := 0
        end if
        
        % Looping after losing a life. 
        loop
            
            % Changing the settings for the ghost like moving them back to the ghost house 
            for i : 1 .. 4
                Ghost (i).pose := 1
                Ghost (i).leave := false
                Ghost (i).fright := false
                Ghost (i).turns := 0
            end for
                Ghost (1).direction := 2
            Ghost (1).radiusX := 224
            Ghost (1).xPosition := 224
            Ghost (1).radiusY := 345
            Ghost (1).yPosition := 345
            Ghost (1).mode := "scatter"
            Ghost (2).direction := 3
            Ghost (2).radiusX := 224
            Ghost (2).xPosition := 224
            Ghost (2).radiusY := 297
            Ghost (2).yPosition := 297
            Ghost (2).mode := "ghosthouse"
            Ghost (3).direction := 1
            Ghost (3).radiusX := 192
            Ghost (3).xPosition := 192
            Ghost (3).radiusY := 297
            Ghost (3).yPosition := 297
            Ghost (3).mode := "ghosthouse"
            Ghost (4).direction := 1
            Ghost (4).radiusX := 256
            Ghost (4).xPosition := 256
            Ghost (4).radiusY := 297
            Ghost (4).yPosition := 297
            Ghost (4).mode := "ghosthouse"
            ghostMode := "scatter"
            modeFrames := 0
            ghostFrames := 0
            frightFrames := 0
            lastDot := 0
            ghostEaten := 0
            
            % Changing the settings for pacman like moving him back to where he was at first. 
            Pac.turns := 0
            Pac.pauseCharacter := 0
            Pac.radiusX := 224
            Pac.xPosition := 224
            Pac.radiusY := 153
            Pac.yPosition := 153
            Pac.direction := 2
            Pac.pose := 1
            pacmanFrames := 0
            Pac.column := floor (Pac.xPosition / 16) + 1
            Pac.row := floor (Pac.yPosition / 16) + 1
            Pac.fright := false
            
            % If statement: Changing the settings based on level or death 
            if not death then
                Ghost (2).leave := true
                countingDots := -1
            else
                countingDots := 0
            end if
            
            % Making the death boolean back to false and frames to 0 
            death := false
            frames := 0
            
            % Drawing the background, dots, and scores/lives
            Pic.Draw (background, 0, 0, picCopy)
            Pic.Draw (pacmanPics (Pac.direction) (Pac.pose), round (Pac.xPosition - 12), round (Pac.yPosition - 13), picMerge)
            for i : 1 .. 4
                Pic.Draw (ghostPics (i) (Ghost (i).pose), Ghost (i).xPosition - 12, Ghost (i).yPosition - 15, picMerge)
                Pic.Draw (ghostEyePics (Ghost (i).direction), Ghost (i).xPosition - 12, Ghost (i).yPosition - 15, picMerge)
            end for
                Dots (frames)
            if dots (10) (2) = 2 then
                Pic.Draw (powerUpDot, 16, 145, picCopy)
            end if
            if dots (10) (27) = 2 then
                Pic.Draw (powerUpDot, 416, 145, picCopy)
            end if
            if dots (30) (2) = 2 then
                Pic.Draw (powerUpDot, 16, 465, picCopy)
            end if
            if dots (30) (27) = 2 then
                Pic.Draw (powerUpDot, 416, 465, picCopy)
            end if
            
            Font.Draw ("SCORE", 10, 565, FONT4, white)
            Font.Draw (intstr (gameScore), 10, 540, FONT5, white)
            Font.Draw ("LIVES", 160, 8, FONT, white) 
            Font.Draw (intstr (numberOfLives, 3), 250, 7, FONT, white)
            % If statement: if the gameScore is higher than the highscore, then change the highscore to gamescore. 
            if gameScore > highscore then
                Font.Draw ("HIGHSCORE", 330, 565, FONT4, white)
                Font.Draw (intstr (gameScore, 6), 303, 540, FONT5, white)
            else
                Font.Draw ("HIGHSCORE", 330, 565, FONT4, white)
                Font.Draw (intstr (highscore, 6), 303, 540, FONT5, white)
            end if
            View.Update
            
            
            % If statement: Just for the first level (for the really cool intro music) 
            if levelNumber = 1 and numberOfLives = 3 then
                delay (4700)
            else
                delay (1000)
            end if
            
            timeNow := Time.Elapsed
            
            % The actual game loop 
            loop
                
                % Setting variables based on pacman's location to edit the pictures of pacman 
                frames += 1
                Pac.column := floor (Pac.xPosition / 16) + 1
                Pac.row := floor (Pac.yPosition / 16) + 1
                Pac.xTilePosition := Pac.xPosition - ((Pac.column - 1) * 16)
                Pac.yTilePosition := Pac.yPosition - ((Pac.row - 1) * 16)
                
                % Calling the turning procedure to check if pacman is turning or not. 
                Turning
                
                % If statement: If he isn't turning, then check if he has bumped into a wall. 
                if Pac.turns = 0 then
                    Collisions
                else
                    Pac.turns -= 1
                end if
                
                % If statement: If pacman isn't stagnent, then move him. 
                if Pac.pauseCharacter = 0 then
                    Movement
                else
                    Pac.pauseCharacter -= 1
                end if
                
                % Resetting pacman's coordinates 
                Pac.xPosition := (round (Pac.radiusX / 2)) * 2
                Pac.yPosition := ((round ((Pac.radiusY - 1) / 2)) * 2) + 1
                
                % If statement: If in fright mode, then use different images. 
                if frightFrames > 0 then
                    frightFrames += 1
                else
                    modeFrames += 1
                end if
                
                % Else use the coloured images.
                ghostFrames += 1
                
                % Changing the modes from scatter (making pacman vulnerable to the ghosts), or chase (where pacman can eat the ghosts) (vice versa) 
                for j : 1 .. 4
                    if modeFrames = Ghost (j).chaseMode then
                        ghostMode := "chase"
                        for i : 1 .. 4
                            if Ghost (i).mode = "scatter" then
                                Ghost (i).mode := "chase"
                                Ghost (i).direction += 2
                                if Ghost (i).direction > 4 then
                                    Ghost (i).direction -= 2
                                end if
                            end if
                        end for
                        elsif modeFrames = Ghost (j).scatterMode then
                        ghostMode := "scatter"
                        for i : 1 .. 4
                            if Ghost (i).mode = "chase" then
                                Ghost (i).mode := "scatter"
                                Ghost (i).direction += 2
                                if Ghost (i).direction > 4 then
                                    Ghost (i).direction -= 2
                                end if
                            end if
                        end for
                    end if
                end for
                    
                % For loop: Solely for ghosts 
                for i : 1 .. 4
                    
                    % Setting variables based on pacman's location to edit the pictures of each individual ghost 
                    Ghost (i).column := floor (Ghost (i).xPosition / 16) + 1
                    Ghost (i).row := floor (Ghost (i).yPosition / 16) + 1
                    Ghost (i).xTilePosition := Ghost (i).xPosition - ((Ghost (i).column - 1) * 16)
                    Ghost (i).yTilePosition := Ghost (i).yPosition - ((Ghost (i).row - 1) * 16)
                    
                    % Determines whether or not the ghost can turn 
                    if Ghost (i).xTilePosition = 6 and Ghost (i).yTilePosition = 9 and wallValues (Ghost (i).row) (Ghost (i).column) = 2 then
                        
                        % This is a regular turn if not in fright mode. (Callng the ghostTarget procedure)
                        if not Ghost (i).fright then
                            GhostTarget (i)
                            
                            % Fright mode makes it so the ghosts go in any direction (with rand.int)
                        else
                            possibleDirection := Rand.Int (1, 4)
                            
                            % Loop for a possible direction that is allowed (without going through a wall) 
                            loop
                                if (possibleDirection = 2 and (Ghost (i).direction = 4 or wallValues (Ghost (i).row) (Ghost (i).column - 1) = 0)) or (possibleDirection = 4 and (Ghost (i).direction = 2 or wallValues (Ghost (i).row) (Ghost (i).column + 1) = 0)) or (possibleDirection = 1 and (Ghost (i).direction = 3 or wallValues (Ghost (i).row + 1) (Ghost (i).column) = 0)) or (possibleDirection = 3 and (Ghost (i).direction = 1 or wallValues (Ghost (i).row - 1) (Ghost (i).column) = 0)) then
                                    possibleDirection -= 1
                                    if possibleDirection = 0 then
                                        possibleDirection := 4
                                    end if
                                else
                                    Ghost (i).direction := -1
                                end if
                                exit when (Ghost (i).direction = -1)
                            end loop
                            Ghost (i).direction := possibleDirection
                            Ghost (i).turns := 1
                        end if
                        
                        % Determines whether or not the ghost is in the ghost house 
                    elsif Ghost (i).mode = "ghosthouse" then
                        GhostHouse (i, frames)
                    end if
                    
                    % Ghost movement (calling the function for the ghost)
                    GhostMovement (i)
                    
                    % Sets the ghost coordinates 
                    Ghost (i).xPosition := (round (Ghost (i).radiusX / 2)) * 2
                    Ghost (i).yPosition := ((round ((Ghost (i).radiusY - 1) / 2)) * 2) + 1
                    
                    % Coordinates to determine collision 
                    Ghost (i).column := floor (Ghost (i).xPosition / 16) + 1
                    Ghost (i).row := floor (Ghost (i).yPosition / 16) + 1
                    Pac.column := floor (Pac.xPosition / 16) + 1
                    Pac.row := floor (Pac.yPosition / 16) + 1
                    
                    % If statement: Determines whether or not there was a collision between pacman and a ghost 
                    if Ghost (i).column = Pac.column and Ghost (i).row = Pac.row then
                        
                        % If statement: If in fright mode, the ghost is eaten, else pacman loses a life. 
                        if Ghost (i).fright then
                            Ghost (i).fright := false
                            Ghost (i).mode := "eaten"
                            ghostEaten += 1
                            Ghost (i).radiusX := ((round ((Ghost (i).radiusX + 2) / 4)) * 4) - 2
                            Ghost (i).radiusY := ((round ((Ghost (i).radiusY - 1) / 4)) * 4) + 1
                            gameScore += (2 ** ghostEaten) * 100
                            lifeScore += (2 ** ghostEaten) * 100
                        elsif Ghost (i).mode not= "eaten" then
                            death := true
                        end if
                    end if
                end for
                    
                % Drawing the background and the dots. 
                Pic.Draw (background, 0, 0, picCopy)
                
                Dots (frames)
                
                Pic.Draw (pacmanPics (Pac.direction) (Pac.pose), round (Pac.xPosition - 12), round (Pac.yPosition - 13), picMerge)
                
                % Drawing of the ghosts based on mode 
                for i : 1 .. 4
                    if Ghost (i).fright then
                        if frightFrames >= (frightLimit - flash) and (ceil ((frightFrames - (frightLimit - flash)) / 12)) mod 2 = 1 then
                            Pic.Draw (ghostPics (6) (Ghost (i).pose), Ghost (i).xPosition - 12, Ghost (i).yPosition - 15, picMerge)
                        else
                            Pic.Draw (ghostPics (5) (Ghost (i).pose), Ghost (i).xPosition - 12, Ghost (i).yPosition - 15, picMerge)
                        end if
                    else
                        if Ghost (i).mode not= "eaten" then
                            Pic.Draw (ghostPics (i) (Ghost (i).pose), Ghost (i).xPosition - 12, Ghost (i).yPosition - 15, picMerge)
                        end if
                        Pic.Draw (ghostEyePics (Ghost (i).direction), Ghost (i).xPosition - 12, Ghost (i).yPosition - 15, picMerge)
                    end if
                end for
                    
                % Calling the timer procedure 
                timer
                
                %Exiting the game 
                exit when (win or death)
            end loop
            delay (1000)
            
            %Making Pac-man lose a life
            if death then
                numberOfLives -= 1
            end if
            
            %Exiting if user lost or if there's a new level. 
            exit when (win or numberOfLives = 0)
        end loop
        
        % Exiting when the game is over. 
        exit when (numberOfLives = 0)
    end loop
    
    
    % Game over screen. 
    
    Pic.Draw (background, 0, 0, picCopy)
    
    Dots (frames)
    if dots (10) (2) = 2 then
        Pic.Draw (powerUpDot, 16, 145, picCopy)
    end if
    if dots (10) (27) = 2 then
        Pic.Draw (powerUpDot, 416, 145, picCopy)
    end if
    if dots (30) (2) = 2 then
        Pic.Draw (powerUpDot, 16, 465, picCopy)
    end if
    if dots (30) (27) = 2 then
        Pic.Draw (powerUpDot, 416, 465, picCopy)
    end if
    Pic.Draw (pacmanPics (Pac.direction) (Pac.pose), round (Pac.xPosition - 12), round (Pac.yPosition - 13), picMerge)
    for i : 1 .. 4
        Pic.Draw (ghostPics (i) (Ghost (i).pose), Ghost (i).xPosition - 12, Ghost (i).yPosition - 15, picMerge)
        Pic.Draw (ghostEyePics (Ghost (i).direction), Ghost (i).xPosition - 12, Ghost (i).yPosition - 15, picMerge)
    end for
        
    
    View.Update 
    
    Font.Draw ("SCORE", 10, 565, FONT4, white)
    Font.Draw (intstr (gameScore), 10, 540, FONT5, white)
    Font.Draw ("LIVES", 160, 8, FONT, white) 
    Font.Draw (intstr (numberOfLives, 3), 250, 7, FONT, white)
    if gameScore > highscore then
        Font.Draw ("HIGHSCORE", 330, 565, FONT4, white)
        Font.Draw (intstr (gameScore, 6), 303, 540, FONT5, white)
    else
        Font.Draw ("HIGHSCORE", 330, 565, FONT4, white)
        Font.Draw (intstr (highscore, 6), 303, 540, FONT5, white)
    end if
    
    
    Font.Draw ("GAME OVER", 120, 239, FONT, brightred)
    
    View.Update
    
    delay (2000)
    cls
    
    Font.Draw ("GAME OVER", 44, 360, FONT1, red)        
    Font.Draw ("FINAL SCORE", 100, 310, FONT, yellow)
    
    if length (intstr (gameScore)) = 2 then 
        Font.Draw (intstr (gameScore), 166, 245, FONT6, white)
    elsif length (intstr (gameScore)) = 3 then 
        Font.Draw (intstr (gameScore), 139, 245, FONT6, white)
    elsif length (intstr (gameScore)) = 4 then 
        Font.Draw (intstr (gameScore), 112, 245, FONT6, white)
    elsif length (intstr (gameScore)) = 5 then 
        Font.Draw (intstr (gameScore), 84, 245, FONT6, white)
    elsif length (intstr (gameScore)) = 6 then 
        Font.Draw (intstr (gameScore), 60, 245, FONT6, white)
    end if 
    if gameScore >= highscore then 
        Font.Draw ("NEW HIGHSCORE", 120, 210, FONT7, brightred)
        Font.Draw ("TYPE YOUR NAME THEN PRESS ENTER", 60, 190, FONT3, yellow)
    end if 
    
    View.Update 
    get username 
    
    % Loop for sorting highscores 
    loop 
        for decreasing i : NUMBEROFSCORES .. 1 
            if gameScore > strint (scores (i)) then 
                for decreasing j : NUMBEROFSCORES .. i 
                    if j not = NUMBEROFSCORES then 
                        names (j+1) := namesTemp (j) 
                        scores (j+1) := scoresTemp (j) 
                    end if 
                end for 
                    names (i) := username  
                scores (i) := intstr (gameScore) 
            end if
        end for
            exit when (numberOfLives = 0)
    end loop
    
    % Writing in the highscores file 
    open : fileName, "Files/Text/highScores.txt", put 
    
    for i : 1.. NUMBEROFSCORES 
        put : fileName, names (i) 
        put : fileName, scores (i) 
        put ""
    end for 
        close : fileName
    
    
    % If statement: Highscore 
    if username not= "" then 
        var anyKey : string (1)
        cls
        
        var stream : int
        % Going into a text file 
        open : stream, "files/Text/highScores.txt", get
        
        Font.Draw ("HIGHSCORES", 12, 520, FONT1, white)
        
        if stream > 0 then
            var format1 : int := 505 
            var Lines : string
            loop
                exit when eof (stream)
                format1 -= 30
                get : stream, Lines : *
                Font.Draw (Lines, 13, format1, FONT, white)
                
            end loop
            close : stream
            Font.Draw ("Press any key to continue...", 13, 30, FONT3, brightred)
        else
            put "Unable to open file."
        end if
        
        View.Update
        
        getch (anyKey)
    end if
end loop
