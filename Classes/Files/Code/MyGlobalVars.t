%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Programmer:
%Date:
%Course:  ICS3CU1
%Teacher:
%Program Name:
%Descriptions:  Final Program Name Here and a brief description of the game
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   MyGlobalVars.t
%   All global variables are coded in this file.
%   These will have FILE scope.
%   These must be document thoroughly - Descriptive name,
%   where used and for what purpose

% Main program variables
var YesToInstructions : string (1)
var isPacManDead, isPacWomanDead : boolean := false
var livesCounter : int := 3
var foodCounter : int := 0

%Introduction Window
var isIntroWindowOpen : boolean % Flag for Introduction Window state open or closed
var isFontWindowOpen : boolean


proc setInitialGameValues

    isIntroWindowOpen := false
    isFontWindowOpen := false

end setInitialGameValues

