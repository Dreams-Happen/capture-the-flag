; Implementation of Capture the Flag
; Matthew Ottomano and Ammar Ahmed
; CS 390

; the flags that will be captured by players from each team
breed [enemy-flags enemy-flag]
breed [ ally-flags ally-flag]
; the blue team representing the team the user is a part of
breed [allies ally]
; the green team representing the enemy team.
breed [enemies enemy]
; bullets for the allies
breed [ ally-bullets ally-bullet ]
; bullets for the enemies
breed [ enemy-bullets enemy-bullet ]

ally-bullets-own [ ticks-traveled speed parent ]
enemy-bullets-own [ ticks-traveled speed parent ]
; a placeholder for the user
globals [ wall-life player deltax deltay bullet-speed bullet-life max-bullet-count previous went-up? went-down? goal green-flag blue-flag ]

patches-own[ wall? life ]                  ; Gives a patch the ability to be a wall.
enemy-flags-own [ carried? carrier ]
ally-flags-own [ carried? carrier ]
allies-own [ strategy facing carrying bullet-count ]
enemies-own [ strategy facing carrying bullet-count ]


to setup
  ca
  set player nobody
  create_map
  init-allies
  init-constants
  init-enemies
  init-flags
  ask patches with [ wall? = true ] [
    set life wall-life
  ]
  ask allies with [strategy = "shooter" ] [
    set facing one-of enemies
    face facing
  ]
  ask enemies with [strategy = "shooter" ] [
    set facing one-of allies
    face facing
  ]
   ask allies [
    set bullet-count 8
  ]
  ask enemies [
    set bullet-count 8
  ]
end

to init-flags
  set blue-flag nobody
  set green-flag nobody
  create-ally-flags 1 [
    set shape "flag"
    set color blue
    set size 3
    move-to patch (max-pxcor - 1) (max-pycor - 5)
    set carried? false
    set carrier nobody
    set blue-flag self
  ]

  create-enemy-flags 1 [
    set shape "flag"
    set color green
    set size 3
    move-to patch (min-pxcor + 3 ) (min-pycor + 5 )
    set carried? false
    set carrier nobody
    set green-flag self
  ]
end

to init-constants
  set bullet-speed .009
  ;set enemy-bullet-speed 0.0005
  set bullet-life world-width / ( bullet-speed * 2 )
  set max-bullet-count 4
  set goal nobody
  set previous nobody
  set wall-life 5

end

to init-allies
  if player = nobody [
    create-allies 1 [
      ;set shape "person"
      set strategy "player"
      set heading -90
      set color blue + 3
      set size 2
      move-to one-of patches with [ not any? turtles-here and wall? = false and pxcor < max-pxcor and pxcor > (max-pxcor / 2) ]
      set player self
    ]
  ]
  create-allies NUMBER-OF-ALLIES - 2 [
    ;set shape "person"

    set heading -90
    set color blue
    set size 2
    set strategy "shooter"
    move-to one-of patches with [ not any? turtles-here and wall? = false and pxcor < max-pxcor and pxcor > (max-pxcor / 2) ]
    ]

   create-allies 1 [
    ;set shape "person"

    set heading -90
    set color blue
    set size 2
    set strategy "flag-carrier"
    move-to one-of patches with [ not any? turtles-here and wall? = false and pxcor < max-pxcor and pxcor > (max-pxcor / 2) ]
    ]


   create-allies 1 [
    ;set shape "person"

    set heading -90
    set color blue
    set size 2
    set strategy "flag-defender"
    move-to patch (max-pxcor - 1.5) (min-pycor + 1.5)
  ]
end

to init-enemies
  create-enemies NUMBER-OF-ENEMIES - 2 [
    ;set shape "person"
    set heading 90
    set color green
    set size 2
    set strategy "shooter"
    move-to one-of patches with [ not any? turtles-here and wall? = false and pxcor > min-pxcor and pxcor < (min-pxcor / 2) ]
  ]


  create-enemies 1 [
    ;set shape "person"
    set heading 90
    set color green
    set size 2
    set strategy "flag-carrier"
    move-to one-of patches with [ not any? turtles-here and wall? = false and pxcor > min-pxcor and pxcor < (min-pxcor / 2) ]
  ]

  create-enemies 1 [
    ;set shape "person"
    set heading 90
    set color green
    set size 2
    set strategy "flag-defender"
    move-to patch (min-pxcor + 1.5) ( max-pycor - 1.5)
  ]
end

to move
  ask blue-flag [
    if carrier = nobody [
      set carried? false
    ]
    if carried? = false and any? allies in-radius 1 [
      move-to patch (max-pxcor - 1 ) (max-pycor - 5 )
    ]
  ]
  ask green-flag [
    if carrier = nobody [
      set carried? false
    ]
    if carried? = false and any? enemies in-radius 1 [
      move-to patch (min-pxcor + 3 ) (min-pycor + 5 )
    ]
  ]

  if any? ally-bullets [
    ask ally-bullets [
      fd speed
      set ticks-traveled (ticks-traveled + 1)
      if ticks-traveled >= bullet-life [
        if parent != nobody [
          ask parent [ set bullet-count bullet-count + 1 ]
        ]
        die
      ]
    ]
  ]
  if any? enemy-bullets [
    ask enemy-bullets [
      fd speed
      set ticks-traveled (ticks-traveled + 1)
      if ticks-traveled >= bullet-life [
        if parent != nobody [
          ask parent [ set bullet-count bullet-count + 1 ]
        ]
        die
      ]
    ]
  ]

  if any? allies   [
    ask allies with [ (strategy = "flag-carrier" or strategy = "player") and any? enemy-flags in-radius 1] [
        ask green-flag  [
          set carried? true
          set carrier myself
          create-link-with myself [ tie ]
        ]
      ]
  ]

    if any? enemies   [
    ask enemies with [ (strategy = "flag-carrier") and any? ally-flags in-radius 1] [
        ask blue-flag  [
          set carried? true
          set carrier myself
          create-link-with myself [ tie ]
        ]
      ]
  ]

  ask enemy-flags with [any? ally-flags in-radius 1 and not [carried?] of one-of ally-flags and xcor = (max-pxcor - 1) and ycor = (max-pycor - 5) ] [
    ask links [die]
    move-to patch (min-pxcor + 3 ) (min-pycor + 5 )
    set carried? false
    set carrier nobody
  ]

  ask ally-flags with [any? enemy-flags in-radius 1 and not [carried?] of one-of enemy-flags and xcor = (min-pxcor + 3) and ycor = (min-pycor + 5) ] [
    ask links [die]
    move-to patch (max-pxcor - 1 ) (max-pycor - 5 )
    set carried? false
    set carrier nobody
  ]

  handle-collisions
  run-strategies

  ask enemies [
    if any? patches in-cone 8 40 with [wall? = true] [
      enemy-shoot self
    ]
  ]

  ask allies [
    if any? patches in-cone 8 40 with [wall? = true] [
      ally-shoot self
    ]
  ]

end

to handle-collisions

  if any? ally-bullets [
    ask ally-bullets with [ [wall?] of patch-ahead 0 ] [
      ask patch-ahead 0 [
        set pcolor pcolor - 1
        set life life - 1
        if life = 0 [
          set wall? false
          set pcolor white
        ]
      ]
      if parent != nobody [
      ask parent [ set bullet-count bullet-count + 1 ]
      ]
      die]
    ask ally-bullets with [any? enemies in-radius 1][
      ask enemies in-radius 1 [
        hatch-enemies 1 [
          move-to one-of patches with [ not any? turtles-here and wall? = false and pxcor > min-pxcor and pxcor < (min-pxcor / 2) ]
        ]
        die]
      die]
  ]

  if any? enemy-bullets [
    ask enemy-bullets with [ [wall?] of patch-ahead 0 ] [
      ask patch-ahead 0 [
        set pcolor pcolor - 1
        set life life - 1
        if life = 0 [
          set wall? false
          set pcolor white
        ]
      ]
      if parent != nobody [
        ask parent [ set bullet-count bullet-count + 1 ]
      ]
      die]
    ask enemy-bullets with [any? allies in-radius 1][
      ask allies in-radius 1 [
        hatch-allies 1 [
          if [strategy] of myself = "player" [
            set player self
          ]
          move-to one-of patches with [ not any? turtles-here and wall? = false and pxcor < max-pxcor and pxcor > (max-pxcor / 2) ]
        ]
        die]
      die]
  ]

end

; == enemy movements ==

to wander

end


; == player movements ==
to rotate-left

  lt 5

end

to rotate-right

  rt 5

end

to fwd
  if xcor < (max-pxcor) and ycor < ( max-pycor) [
    if not [wall?] of patch-ahead 1 [
      fd 1
    ]
  ]
end

to auto-fwd
  if xcor < (max-pxcor) and ycor < ( max-pycor ) [
    if not [wall?] of patch-ahead 1 [
      fd .005
    ]
  ]
end

to faster-fwd
  if xcor < (max-pxcor) and ycor < ( max-pycor) [
    if not [wall?] of patch-ahead 1 [
      fd .008
    ]
  ]
end

to backs
  if xcor > min-pxcor and ycor > min-pycor [
    if not [wall?] of patch-ahead -1 [
      bk 1
    ]
  ]
end

to ally-shoot [ agent ]
  if agent != nobody [
      ask agent [
      if bullet-count > 0 [
        hatch-ally-bullets 1 [
          set shape "dot"
          set color blue
          set size 1
          set speed bullet-speed
          set ticks-traveled 0
          set parent myself
        ]
        set bullet-count bullet-count - 1
      ]
    ]
  ]
end

to enemy-shoot [ agent ]
  if agent != nobody [
      ask agent [
      if bullet-count > 0 [
        hatch-enemy-bullets 1 [
          set shape "dot"
          set color green
          set size 1
          set speed bullet-speed
          set ticks-traveled 0
          set parent myself
        ]
        set bullet-count bullet-count - 1
      ]
    ]
  ]
end

to run-strategies

  ;======= SHOOTERS ========
  ask enemies with [strategy = "shooter"] [
    if facing = nobody [
      if any? allies [
        set facing one-of allies

      ]
    ]
    if any? allies [
      face facing
    ]
    if any? allies in-cone 8 40 [
      enemy-shoot self
    ]
    auto-fwd
  ]

  ask allies with [strategy = "shooter"] [

    if facing = nobody [
      if any? enemies [
        set facing one-of enemies
        face facing
      ]
    ]
    if any? enemies [
      face facing
    ]
    if any? enemies in-cone 8 40 [
      ally-shoot self
    ]
    auto-fwd
  ]

  ; ======== SHOOTERS ===========

  ; ===== Flag-Carrier ==========
  ask allies with [strategy = "flag-carrier"] [
    ifelse not [carried?] of green-flag [
      face green-flag
      faster-fwd
    ]
    [
      face patch (max-pxcor - 1 ) (max-pycor - 5 )
      faster-fwd
    ]
  ]
   ask enemies with [strategy = "flag-carrier"] [
    ifelse not [carried?] of blue-flag [
      face blue-flag
      faster-fwd
    ]
    [
      face patch (min-pxcor + 3 ) (min-pycor + 5 )
      faster-fwd
    ]
  ]
  ; ====== Flag-Carrier ===========


  ; ======= FLAG-DEFENDER ==========

  ask allies with [strategy = "flag-defender" ] [
    ifelse [xcor] of blue-flag != (max-pxcor - 1 ) or [ycor] of blue-flag != (max-pycor - 5 ) [
      face blue-flag
      auto-fwd
    ]
    [
      if xcor != (max-pxcor - 1) and ycor != (min-pycor + 1) [
        face patch (max-pxcor - 1)  (min-pycor + 1)
        auto-fwd
      ]
    ]
  ]

  ask enemies with [strategy = "flag-defender" ] [
    ifelse [xcor] of green-flag != (min-pxcor + 3 ) or [ycor] of green-flag != (min-pycor + 5 ) [
      face green-flag
      auto-fwd
    ]
    [
      if xcor != (min-pxcor + 1) and ycor != (max-pycor - 1) [
        face patch (min-pxcor + 1) (max-pycor - 1)
        auto-fwd
      ]
    ]
  ]


end


; creates the map
to create_map
  ask patches [set pcolor white set wall? false]
  map1
end



;===========
; Map number 1
to map1

  ask patch min-pxcor max-pycor [ set pcolor black ]
  ask patch max-pxcor min-pycor [ set pcolor black ]

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

;  ask patches with [min-pycor = pycor] [set wall? true]
;  ask patches with [min-pxcor = pxcor] [set wall? true]
;  ask patches with [max-pycor = pycor] [set wall? true]
;  ask patches with [max-pxcor = pxcor] [set wall? true]


end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
946
539
-1
-1
8.0
1
10
1
1
1
0
0
0
1
-45
45
-32
32
0
0
1
ticks
30.0

BUTTON
85
75
151
108
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1153
200
1216
233
NIL
move
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1245
193
1317
226
SHOOT
ally-shoot player\n\n
NIL
1
T
OBSERVER
NIL
K
NIL
NIL
1

BUTTON
1104
286
1284
319
NIL
ask player [rotate-right]
NIL
1
T
OBSERVER
NIL
D
NIL
NIL
1

BUTTON
1071
112
1199
145
NIL
ask player [fwd]
NIL
1
T
OBSERVER
NIL
W
NIL
NIL
1

BUTTON
1095
41
1237
74
NIL
ask player [backs]
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
1106
326
1276
359
NIL
ask player [rotate-left]
NIL
1
T
OBSERVER
NIL
A
NIL
NIL
1

SLIDER
1119
495
1291
528
NUMBER-OF-ALLIES
NUMBER-OF-ALLIES
0
5
5.0
1
1
NIL
HORIZONTAL

SLIDER
1119
449
1291
482
NUMBER-OF-ENEMIES
NUMBER-OF-ENEMIES
0
6
6.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
