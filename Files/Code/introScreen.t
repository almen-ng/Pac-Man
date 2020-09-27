setscreen ("graphics:448,576,offscreenonly, nobuttonbar")
colorback (black)

type Main :
record
    rSpeedRestrict : real
    rFrightRestrict : real
    rX : real
    rY : real
    iX : int
    iY : int
    iTilePosX : int
    iTilePosY : int
    iDir : int
    iPause : int
    iPose : int
    iCol : int
    iRow : int
    iTurn : int
    iDots : int
    iDotsLimit : int
    iChase : int
    iScatter : int
    sMode : string
    bLeave : boolean
    bFright : boolean
end record

%Declaring Pac-man and Ghosts
var Pac : Main
var Ghost : array 1 .. 4 of Main

var raTargetDistance : array 1 .. 4 of real
var iaSprites : array 1 .. 4 of array 1 .. 4 of int
var iaGhostSprites : array 1 .. 6 of array 1 .. 2 of int
var iaGhostEyes : array 1 .. 4 of int
var bKeys : array char of boolean

var iDots : array 1 .. 36 of array 0 .. 31 of int
var iaBoardValues : array 1 .. 36 of array 0 .. 31 of int

var continue, instructions, death, win : boolean 
var ghostActionMode : string 
var restrictionGhostAction, restrictionOfTunnels, restrictionPacmanAction, closest, delayProgram : real
var ghostEaten, possibleDirections, ghostLeave, mouseX, mouseY, button, countingDots, lastDot, columnTarget, rowTarget, newDirection, timeNow, timePast, frames, pacmanFrames, modeFrames, ghostFrames, frightModeFrames, frightLimit, flash, dotsEaten, fileName, value, numberOfLives, levelNumber, gameScore, lifeScore : int 
var font := Font.New ("Emulogic:17")
var font2 := Font.New ("namco regular:6")
var introTitleFrameNumber, introTitleFrame, introLoopFrameNumber, introLoopFrame : int := 0

process endMusic 
    loop
        if continue = true and instructions = false then
            Music.PlayFileStop
        end if 
    end loop
end endMusic

process introLoop
    
    loop 
        exit when continue = true 
        if introLoopFrameNumber not= 586 then
            introLoopFrameNumber += 1
        else
            introLoopFrameNumber := 1
        end if
        introLoopFrame := Pic.FileNew ("Images/introScreen/introLoop (" + intstr (introLoopFrameNumber) + ").jpg")
        Pic.Draw (introLoopFrame, 25, 190, picCopy)
        delay (20)
        Pic.Free (introLoopFrame)
        
        View.Update         
        
    end loop
    
end introLoop

process help
    cls 
    Font.Draw ("created by almen ng", 130, 25, font2, red) 
    loop 
        Mouse.Where (mouseX, mouseY, button)
        if mouseX >= 120 and mouseX <= 330 and mouseY >= 170 and mouseY <= 190 then
            Font.Draw ("Play Game", 120, 170, font, 55)
            if button = 1 then
                continue := true
                instructions := false 
            end if
        else
            Font.Draw ("Play Game", 120, 170, font, white)
        end if
        
        if mouseX >= 85 and mouseX <= 363 and mouseY >= 120 and mouseY <= 140 then
            Font.Draw ("Instructions", 85, 120, font, 55)
            if button = 1 then
                continue := true
                instructions := true
            end if
        else
            Font.Draw ("Instructions", 85, 120, font, white)
        end if
        
        if mouseX >= 175 and mouseX <= 271 and mouseY >= 70 and mouseY <= 90 then
            Font.Draw ("Quit", 175, 70, font, 55)
            if button = 1 then
                continue := false 
                instructions := false 
            end if
        else
            Font.Draw ("Quit", 175, 70, font, white)
        end if
        
        exit when continue = true 
        
        View.Update 
        
    end loop 
end help

loop 
    continue:= false
    instructions := false 
    
    loop
        Music.PlayFileLoop ("introMusic.mp3")
        fork help
        fork endMusic
        fork introLoop
        
        
        delay (300)
        introTitleFrameNumber +=1
        introTitleFrame := Pic.FileNew ("Images/introScreen/titleScreen" + intstr (introTitleFrameNumber) + ".gif")
        Pic.Draw (introTitleFrame, 0, 340, picCopy)
        delay (25)
        loop 
            exit when continue = true 
            if introTitleFrameNumber not= 16 then
                introTitleFrameNumber += 1
            else
                introTitleFrameNumber := 13
            end if
            introTitleFrame := Pic.FileNew ("Images/introScreen/titleScreen" + intstr (introTitleFrameNumber) + ".gif")
            Pic.Draw (introTitleFrame, 0, 340, picCopy)
            delay (25)
            Pic.Free (introTitleFrame)
        end loop
        
        View.Update
        
        exit when (continue = true)
    end loop
    exit when (continue = true)
end loop


