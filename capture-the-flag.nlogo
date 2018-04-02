; Implementation of Capture the Flag
; Matthew Ottomano and Ammar Ahmed
; CS 390

; the blue team representing the team the user is a part of
breed [allies ally]
; the green team representing the enemy team.
breed [enemies enemy]
; bullets for the allies
breed [ ally-bullets ally-bullet ]
; bullets for the enemies
breed [ enemy-bullets enemy-bullet ]

ally-bullets-own [ ticks-traveled speed ]
enemy-bullets-own [ ticks-traveled ]
; a placeholder for the user
globals [ player deltax deltay bullet-speed bullet-life max-bullet-count previous went-up? went-down? goal]

patches-own[ wall? ]                  ; Gives a patch the ability to be a wall.


to setup
  ca
  set player nobody
  create_map
  init-player
  init-constants
  init-enemies
end

to init-constants
  set bullet-speed .0008
  ;set enemy-bullet-speed 0.0005
  set bullet-life world-width / ( bullet-speed * 2 )
  set max-bullet-count 10
  set goal nobody
  set previous nobody
end

to init-player
  if player = nobody [
    create-allies 1 [
      set shape "person"
      set heading -90
      set color blue
      set size 2
      move-to one-of patches with [ not any? turtles-here and wall? = false and pxcor < max-pxcor and pxcor > (max-pxcor / 2) ]
      set player self
    ]
  ]
end

to init-enemies
  create-enemies 1 [
    set shape "person"
    set heading 90
    set color green
    set size 2
    move-to one-of patches with [ not any? turtles-here and wall? = false and pxcor > min-pxcor and pxcor < (min-pxcor / 2) ]
  ]
end

to move
  if any? ally-bullets [
    ask ally-bullets [
      fd speed
      set ticks-traveled (ticks-traveled + 1)
      if ticks-traveled = bullet-life [
        die]
    ]
  ]
  ask enemies [
    wander
  ]
  
end

; == enemy movements ==
to wander
  let targets allies in-cone 10 60
  ifelse count targets = 0 [ 
    ifelse [wall?] of patch-at-heading-and-distance 90 1 = false [
      set heading 90
      fd .1
      show "right"
    ]
    [
      set heading 90
      if goal = nobody [
        set goal one-of patches with [ wall? = false and pycor != [ycor] of myself and pxcor = [xcor] of myself ]
        
      ]
      ;show goal
      ask goal [ set pcolor yellow ]
      ifelse goal != nobody [
        ifelse [pycor] of goal > ycor [ 
          set heading 0
          fd .1
          show "upwards"
        ]
        [
          set heading 180
          fd .1
          show "downwards"
        ]
      ]
      [
        ifelse previous != nobody [
          if previous = patch-at-heading-and-distance 0 1 [
            set previous patch-here
            set heading 180
            fd .1
          ]
          if previous = patch-at-heading-and-distance 180 1 [
            set previous patch-here
            set heading 0
            fd .1
          ]
        ]
        [
        set previous patch-here
        let options ( list(patch-at-heading-and-distance 0 1) )
        set options fput (patch-at-heading-and-distance 180 1) options
        face one-of options with [ pxcor != [pxcor] of previous and pycor != [pycor] of previous and wall? = false ]
        fd .1
        ]
      ]
    ]
  ]
  
  
  [
    set color black
  ]
end
; == player movements ==
to go-left [ agent ]
  if agent != nobody [
    ask agent [
      if [wall?] of patch-at-heading-and-distance -90 1 = false [
        set heading -90
        fd 1
      ]
    ]
  ]
end

to go-right [ agent ]
  if agent != nobody [
    ask agent [
      if [wall?] of patch-at-heading-and-distance 90 1 = false [
        set heading 90
        fd 1
      ]
    ]
  ]
end

to go-up [ agent ]
  if agent != nobody [
    ask agent [
      if [wall?] of patch-at-heading-and-distance 0 1 = false [
        set heading 0
        fd 1
      ]
    ]
  ]
end

to go-down [ agent ]
  if agent != nobody [
    ask agent [
      if [wall?] of patch-at-heading-and-distance 180 1 = false [
        set heading 180
        fd 1
      ]
    ]
  ]
end

to ally-shoot [ agent ]
  if agent != nobody [
    if count ally-bullets < max-bullet-count [
      ask agent [
        hatch-ally-bullets 1 [
          set shape "dot"
          set color blue
          set size 1
          set speed bullet-speed
          set ticks-traveled 0
        ]
      ]
    ]
  ]
end

to enemy-shoot [ agent ]
  if agent != nobody [
    if count enemy-bullets < max-bullet-count [
      ask agent [
        hatch-enemy-bullets 1 [
          set shape "dot"
          set color green
          set size 1
          set speed bullet-speed
          set ticks-traveled 0
        ]
      ]
    ]
  ]
end

;to acc
;  if player != nobody [
;     ask player [
;      let angle ( 90 - heading )
;      set deltay deltay + ( .00005 * sin(angle) ) ; first component of the velocity vector
;      set deltax deltax + ( .00005 * cos(angle) ) ; second component of the velocity vector
;    ]
;  ]
;end


; creates the map
to create_map
  ask patches [set pcolor white set wall? false]
  map1
end


















;===========
; Map number 1
to map1
  
  ask patch 25 20 [set wall? true set pcolor red]
  ask patch 25 19 [set wall? true set pcolor red]
  ask patch 25 18 [set wall? true set pcolor red]
  ask patch 25 17 [set wall? true set pcolor red]
  ask patch 25 16 [set wall? true set pcolor red]
  ask patch 24 20 [set wall? true set pcolor red]
  ask patch 23 20 [set wall? true set pcolor red]
  ask patch 22 20 [set wall? true set pcolor red]
  ask patch 21 20 [set wall? true set pcolor red]
  ask patch 20 20 [set wall? true set pcolor red]
  
  ask patch 25 -12 [set wall? true set pcolor red]
  ask patch 25 -11 [set wall? true set pcolor red]
  ask patch 25 -10 [set wall? true set pcolor red]
  ask patch 25 -9 [set wall? true set pcolor red]
  ask patch 25 -8 [set wall? true set pcolor red]
  ask patch 24 -12 [set wall? true set pcolor red]
  ask patch 23 -12 [set wall? true set pcolor red]
  ask patch 22 -12 [set wall? true set pcolor red]
  ask patch 21 -12 [set wall? true set pcolor red]
  ask patch 20 -12 [set wall? true set pcolor red]
  
  ask patch -25 20 [set wall? true set pcolor red]
  ask patch -25 19 [set wall? true set pcolor red]
  ask patch -25 18 [set wall? true set pcolor red]
  ask patch -25 17 [set wall? true set pcolor red]
  ask patch -25 16 [set wall? true set pcolor red]
  ask patch -24 20 [set wall? true set pcolor red]
  ask patch -23 20 [set wall? true set pcolor red]
  ask patch -22 20 [set wall? true set pcolor red]
  ask patch -21 20 [set wall? true set pcolor red]
  ask patch -20 20 [set wall? true set pcolor red]
  
  ask patch -25 -12 [set wall? true set pcolor red]
  ask patch -25 -11 [set wall? true set pcolor red]
  ask patch -25 -10 [set wall? true set pcolor red]
  ask patch -25 -9 [set wall? true set pcolor red]
  ask patch -25 -8 [set wall? true set pcolor red]
  ask patch -24 -12 [set wall? true set pcolor red]
  ask patch -23 -12 [set wall? true set pcolor red]
  ask patch -22 -12 [set wall? true set pcolor red]
  ask patch -21 -12 [set wall? true set pcolor red]
  ask patch -20 -12 [set wall? true set pcolor red]
  
  ask patch 0 -32 [set wall? true set pcolor red]
  ask patch 0 -31 [set wall? true set pcolor red]
  ask patch 0 -30 [set wall? true set pcolor red]
  ask patch 0 -29 [set wall? true set pcolor red]
  ask patch 0 -28 [set wall? true set pcolor red]
  ask patch 0 -27 [set wall? true set pcolor red]
  ask patch 0 -26 [set wall? true set pcolor red]
  ask patch 0 -25 [set wall? true set pcolor red]
  ask patch 0 -24 [set wall? true set pcolor red]
  ask patch 0 -23 [set wall? true set pcolor red]
  ask patch 0 -22 [set wall? true set pcolor red]
  ask patch 0 -21 [set wall? true set pcolor red]
  ask patch 0 -20 [set wall? true set pcolor red]
  ask patch 0 -19 [set wall? true set pcolor red]
  ask patch 0 -18 [set wall? true set pcolor red]
  ask patch 0 -17 [set wall? true set pcolor red]
  ask patch 0 -16 [set wall? true set pcolor red]
  ask patch 0 -15 [set wall? true set pcolor red]
  ask patch 0 -14 [set wall? true set pcolor red]
  ask patch 0 -13 [set wall? true set pcolor red]
  
  ask patch 0 32 [set wall? true set pcolor red]
  ask patch 0 31 [set wall? true set pcolor red]
  ask patch 0 30 [set wall? true set pcolor red]
  ask patch 0 29 [set wall? true set pcolor red]
  ask patch 0 28 [set wall? true set pcolor red]
  ask patch 0 27 [set wall? true set pcolor red]
  ask patch 0 26 [set wall? true set pcolor red]
  ask patch 0 25 [set wall? true set pcolor red]
  ask patch 1 25 [set wall? true set pcolor red]
  ask patch 2 25 [set wall? true set pcolor red]
  ask patch 3 25 [set wall? true set pcolor red]
  ask patch 4 25 [set wall? true set pcolor red]
  ask patch 5 25 [set wall? true set pcolor red]
  ask patch -1 25 [set wall? true set pcolor red]
  ask patch -2 25 [set wall? true set pcolor red]
  ask patch -3 25 [set wall? true set pcolor red]
  ask patch -4 25 [set wall? true set pcolor red]
  ask patch -5 25 [set wall? true set pcolor red]
  
  ask patch 0 15 [set wall? true set pcolor red]
  ask patch 1 15 [set wall? true set pcolor red]
  ask patch 2 15 [set wall? true set pcolor red]
  ask patch 3 15 [set wall? true set pcolor red]
  ask patch 4 15 [set wall? true set pcolor red]
  ask patch 5 15 [set wall? true set pcolor red]
  ask patch -1 15 [set wall? true set pcolor red]
  ask patch -2 15 [set wall? true set pcolor red]
  ask patch -3 15 [set wall? true set pcolor red]
  ask patch -4 15 [set wall? true set pcolor red]
  ask patch -5 15 [set wall? true set pcolor red]
  ask patch -5 14 [set wall? true set pcolor red]
  ask patch -5 13 [set wall? true set pcolor red]
  ask patch -5 12 [set wall? true set pcolor red]
  ask patch -5 11 [set wall? true set pcolor red]
  ask patch -5 10 [set wall? true set pcolor red]
  ask patch -5 9 [set wall? true set pcolor red]
  ask patch -5 4 [set wall? true set pcolor red]
  ask patch -5 3 [set wall? true set pcolor red]
  ask patch -5 2 [set wall? true set pcolor red]
  ask patch -5 1 [set wall? true set pcolor red]
  ask patch -5 0 [set wall? true set pcolor red]
  ask patch -5 -1 [set wall? true set pcolor red]
  ask patch -5 -2 [set wall? true set pcolor red]
  ask patch -4 -2 [set wall? true set pcolor red]
  ask patch -3 -2 [set wall? true set pcolor red]
  ask patch -2 -2 [set wall? true set pcolor red]
  ask patch -1 -2 [set wall? true set pcolor red]
  ask patch 0 -2 [set wall? true set pcolor red]
  ask patch 1 -2 [set wall? true set pcolor red]
  ask patch 2 -2 [set wall? true set pcolor red]
  ask patch 3 -2 [set wall? true set pcolor red]
  ask patch 4 -2 [set wall? true set pcolor red]
  ask patch 5 -2 [set wall? true set pcolor red]
  ask patch 5 -1 [set wall? true set pcolor red]
  ask patch 5 0 [set wall? true set pcolor red]
  ask patch 5 1 [set wall? true set pcolor red]
  ask patch 5 2 [set wall? true set pcolor red]
  ask patch 5 3 [set wall? true set pcolor red]
  ask patch 5 4 [set wall? true set pcolor red]
  ask patch 5 9 [set wall? true set pcolor red]
  ask patch 5 10 [set wall? true set pcolor red]
  ask patch 5 11 [set wall? true set pcolor red]
  ask patch 5 12 [set wall? true set pcolor red]
  ask patch 5 13 [set wall? true set pcolor red]
  ask patch 5 14 [set wall? true set pcolor red]
  
  ask patch 15 0 [set wall? true set pcolor red]
  ask patch 15 1 [set wall? true set pcolor red]
  ask patch 15 2 [set wall? true set pcolor red]
  ask patch 15 3 [set wall? true set pcolor red]
  ask patch 15 4 [set wall? true set pcolor red]
  ask patch 15 9 [set wall? true set pcolor red]
  ask patch 15 10 [set wall? true set pcolor red]
  ask patch 15 11 [set wall? true set pcolor red]
  ask patch 15 12 [set wall? true set pcolor red]
  ask patch 15 13 [set wall? true set pcolor red]
  ask patch 16 0 [set wall? true set pcolor red]
  ask patch 17 0 [set wall? true set pcolor red]
  ask patch 18 0 [set wall? true set pcolor red]
  ask patch 19 0 [set wall? true set pcolor red]
  ask patch 20 0 [set wall? true set pcolor red]
  ask patch 21 0 [set wall? true set pcolor red]
  ask patch 16 13 [set wall? true set pcolor red]
  ask patch 17 13 [set wall? true set pcolor red]
  ask patch 18 13 [set wall? true set pcolor red]
  ask patch 19 13 [set wall? true set pcolor red]
  ask patch 20 13 [set wall? true set pcolor red]
  ask patch 21 13 [set wall? true set pcolor red]
  ask patch 21 12 [set wall? true set pcolor red]
  ask patch 21 11 [set wall? true set pcolor red]
  ask patch 21 10 [set wall? true set pcolor red]
  ask patch 21 9 [set wall? true set pcolor red]
  ask patch 21 8 [set wall? true set pcolor red]
  ask patch 21 7 [set wall? true set pcolor red]
  ask patch 21 6 [set wall? true set pcolor red]
  ask patch 21 5 [set wall? true set pcolor red]
  ask patch 21 4 [set wall? true set pcolor red]
  ask patch 21 3 [set wall? true set pcolor red]
  ask patch 21 2 [set wall? true set pcolor red]
  ask patch 21 1 [set wall? true set pcolor red]
  
  ask patch -15 0 [set wall? true set pcolor red]
  ask patch -15 1 [set wall? true set pcolor red]
  ask patch -15 2 [set wall? true set pcolor red]
  ask patch -15 3 [set wall? true set pcolor red]
  ask patch -15 4 [set wall? true set pcolor red]
  ask patch -15 9 [set wall? true set pcolor red]
  ask patch -15 10 [set wall? true set pcolor red]
  ask patch -15 11 [set wall? true set pcolor red]
  ask patch -15 12 [set wall? true set pcolor red]
  ask patch -15 13 [set wall? true set pcolor red]
  ask patch -16 0 [set wall? true set pcolor red]
  ask patch -17 0 [set wall? true set pcolor red]
  ask patch -18 0 [set wall? true set pcolor red]
  ask patch -19 0 [set wall? true set pcolor red]
  ask patch -20 0 [set wall? true set pcolor red]
  ask patch -21 0 [set wall? true set pcolor red]
  ask patch -16 13 [set wall? true set pcolor red]
  ask patch -17 13 [set wall? true set pcolor red]
  ask patch -18 13 [set wall? true set pcolor red]
  ask patch -19 13 [set wall? true set pcolor red]
  ask patch -20 13 [set wall? true set pcolor red]
  ask patch -21 13 [set wall? true set pcolor red]
  ask patch -21 12 [set wall? true set pcolor red]
  ask patch -21 11 [set wall? true set pcolor red]
  ask patch -21 10 [set wall? true set pcolor red]
  ask patch -21 9 [set wall? true set pcolor red]
  ask patch -21 8 [set wall? true set pcolor red]
  ask patch -21 7 [set wall? true set pcolor red]
  ask patch -21 6 [set wall? true set pcolor red]
  ask patch -21 5 [set wall? true set pcolor red]
  ask patch -21 4 [set wall? true set pcolor red]
  ask patch -21 3 [set wall? true set pcolor red]
  ask patch -21 2 [set wall? true set pcolor red]
  ask patch -21 1 [set wall? true set pcolor red]
  
  ask patch -45 -25 [set wall? true set pcolor red]
  ask patch -44 -25 [set wall? true set pcolor red]
  ask patch -43 -25 [set wall? true set pcolor red]
  ask patch -42 -25 [set wall? true set pcolor red]
  ask patch -41 -25 [set wall? true set pcolor red]
  ask patch -40 -25 [set wall? true set pcolor red]
  ask patch -39 -25 [set wall? true set pcolor red]
  ask patch -39 -26 [set wall? true set pcolor red]
  ask patch -39 -27 [set wall? true set pcolor red]
  ask patch -39 -28 [set wall? true set pcolor red]
  ask patch -39 -29 [set wall? true set pcolor red]
  
  ask patch 45 25 [set wall? true set pcolor red]
  ask patch 44 25 [set wall? true set pcolor red]
  ask patch 43 25 [set wall? true set pcolor red]
  ask patch 42 25 [set wall? true set pcolor red]
  ask patch 41 25 [set wall? true set pcolor red]
  ask patch 40 25 [set wall? true set pcolor red]
  ask patch 39 25 [set wall? true set pcolor red]
  ask patch 39 26 [set wall? true set pcolor red]
  ask patch 39 27 [set wall? true set pcolor red]
  ask patch 39 28 [set wall? true set pcolor red]
  ask patch 39 29 [set wall? true set pcolor red]
  
  
  
end
