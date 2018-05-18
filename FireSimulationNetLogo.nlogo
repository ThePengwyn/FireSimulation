;; CONTENTS
;;
;; Contents :: (Recursion)
;;
;; Extensions
;;
;; Colours Glossary
;;;;;; Patch Colours
;;;;;; Turtle Colours
;;
;;Variables
;;;;;; Globals
;;;;;; Turtles
;;;;;; Patches
;;
;; Buttons
;;;;;; Set Scenario
;;;;;;;;;; Regions :: (Patch Set) - Outer Section, Inner Section, Field
;;;;;;;;;; Walls :: (Patch Set)
;;;;;;;;;;;;;; Outer Walls - North and South, East and West
;;;;;;;;;;;;;; Inner Walls - North, South, East, West
;;;;;;;;;; Exits :: (Patch Set)
;;;;;;;;;;;;;;Inner Exits - North, South, East, West
;;;;;;;;;;;;;;Outer Exits - North and South, East and West
;;;;;;;;;; Static Patch Variables :: (Patch Variable)
;;;;;;;;;;;;;; OriginalSections
;;;;;;;;;;;;;; PPNeighbours
;;;;;;;;;; People :: (Turtle Set)
;;;;;;;;;;;;;; Field
;;;;;;;;;;;;;; Lobby
;;;;;;;;;;;;;; Field

;; EXTENSIONS
;;
;; R
extensions [r]

;; COLOURS GLOSSARY
;;;;;; Patch Colours
;;;;;;;;;; 0 = Black = Walls
;;;;;;;;;; 6 = Light Grey = Outer Region
;;;;;;;;;; 9 = White = Inner Seating
;;;;;;;;;; 67 = Light Green = Field
;;;;;;;;;; 15 = Red = Fire
;;;;;;;;;; 37 = Light Brown = Light Smoke
;;;;;;;;;; 35 = Medium Brown = Medium Smoke
;;;;;;;;;; 33 = Dark Brown = Heavy Smoke "Dark Smoke" - lol
;;;;;;Turtle Colours
;;;;;;;;;;

;; VARIABLES
;;
;; Global Variables
;;
globals [
  DeathFireCount
  DeathSmokeCount
  DeathTrampleCount
  SafeCount
  WasRandomScenario?
  WasRandomFire?
  VisionMultiplier
  DeathsThisTick
]
;;
;; Turtle Variables
;;
turtles-own [
 TTneighbours
 TTneighbourMain
 TPexit
 TPexitsRange
 TPneighbours
 TPfires
 TPfireMain
 InnerExitDuration
 OuterExitDuration
 Walls
 Vision
 WallMain
 WallSub
 Section
 TPexitNew
 TPSmokeNeighbours
 Toxicity
 Fear
 TTneighbourMultiplier
 TPfireMultiplier
 SafestPatchMultiplier
 TPexitMultiplier
 subrandom
 SafestPatch
 SafeXcor
 SafeYcor
 MinDangerLevel
 DeathsWitnessed
 Speed
 ComfortSpace
]
;;
;;Patch Variables
;;
patches-own [
 PPneighbours
 OriginalSection
 PPFireDensity
 PPLightSmokeDensity
 PPMediumSmokeDensity
 PPHeavySmokeDensity
 DangerLevel
 ClosestInnerExit
]

;; BUTTONS
;;
;; Set Scenario
;;
to SetScenario
;;;;;; Reset
;;;;;;
;;;;;;;;;; Reset Patches and Ticks
  clear-all
  reset-ticks
;;;;;;;;;; Reset R Temp Data
  r:__evaldirect "rm(Fire, envir = nl.env)"
  r:__evaldirect "rm(Smoke, envir = nl.env)"
  r:__evaldirect "rm(Trample, envir = nl.env)"
  r:__evaldirect "rm(EvacuatedSafely, envir = nl.env)"
  r:__evaldirect "rm(Ticks, envir = nl.env)"
  r:__evaldirect "rm(Exits, envir = nl.env)"
  r:__evaldirect "rm(FirePosition, envir = nl.env)"
  r:__evaldirect "rm(FireDistanceToExit, envir = nl.env)"
  r:__evaldirect "rm(Turtles, envir = nl.env)"
  r:__evaldirect "rm(TempRow)"
  r:__evaldirect "rm(DeathFrame)"
  r:gc
;;;;;;;;;; Global Variable
  set DeathFireCount 0
  set DeathSmokeCount 0
  set DeathTrampleCount 0
  set SafeCount 0
;;
  set-current-plot "Death Plot"
  ifelse (Scenario = "Random Scenario") [set WasRandomScenario? TRUE set Scenario one-of ["Random Exits" "Scenario 1" "Scenario 2"]] [set WasRandomScenario? False]
  ifelse (FirePosition = "Random") [set WasRandomFire? TRUE set FirePosition one-of ["Inner" "Outer"]] [set WasRandomFire? False]
;;;;;; Set Regions :: (Patch Set)
;;;;;;;;;; Case 1
;;;;;;;;;;
;;;;;;;;;;;;;; Set Outer Section :: (Square Set)
  ask patches [
    if ((pxcor < max-pxcor) and  (pxcor > min-pxcor) and (pycor < max-pycor) and (pycor > min-pycor))
    [ set pcolor 9 ]
;;;;;;;;;;;;;; Set Inner Section :: (Square Set)
    if (pxcor < ((2 * min-pxcor + 12 * max-pxcor) / 14) and  pxcor > ((12 * min-pxcor + 2 * max-pxcor) / 14) and pycor < ((2 * min-pycor + 12 * max-pycor) / 14) and pycor > ((12 * min-pycor + 2 * max-pycor) / 14))
    [ set pcolor 6 ]
;;;;;;;;;;;;;; Set Field :: (Sqaure Set)
    if (pxcor < ((2 * min-pxcor + 5 * max-pxcor) / 7) and pxcor > ((5 * min-pxcor + 2 * max-pxcor) / 7) and pycor < ((2 * min-pycor + 5 * max-pxcor) / 7) and pycor > ((5 * min-pycor + 2 * max-pycor) / 7))
      [ set pcolor 67 ]
]
;;
;;;;;; Set Walls :: (Patch Set)
;;;;;;;;;; Case 1
;;;;;;;;;;;;;; Outer Walls :: (Line Set)
;;;;;;;;;;;;;;;;;; North and South
  ask patches with [pxcor = min-pxcor or pxcor = max-pxcor] [set pcolor 0]
;;;;;;;;;;;;;;;;;; East and West
  ask patches with [ pxcor = max-pxcor or  pycor = max-pycor] [set pcolor 0]
;;;;;;;;;;;;;; Inner Walls :: (Line Set)
  ask patches [
;;;;;;;;;;;;;;;;;; North Wall
    if ((pycor = round(((12 * max-pxcor + 2 * min-pxcor) / 14))) and (pxcor < ((2 * min-pycor + 12 * max-pycor) / 14)) and (pxcor > ((12 * min-pycor + 2 * max-pycor) / 14)))
    [ set pcolor 0]
;;;;;;;;;;;;;;;;;; South Wall
    if ((pycor = round(((12 * min-pycor + 2 * max-pycor) / 14))) and (pxcor < ((2 * min-pxcor + 12 * max-pxcor) / 14)) and (pxcor > ((12 * min-pxcor + 2 * max-pxcor) / 14)))
    [ set pcolor 0]
;;;;;;;;;;;;;;;;;; East Wall
    if ((pxcor = round(((2 * min-pxcor + 12 * max-pxcor) / 14))) and (pycor < ((2 * min-pycor + 12 * max-pycor) / 14)) and (pycor > ((12 * min-pycor + 2 * max-pycor) / 14)))
    [ set pcolor 0]
;;;;;;;;;;;;;;;;;; West Wall
    if ((pxcor = round(((12 * min-pxcor + 2 * max-pxcor) / 14))) and (pycor < ((2 * min-pycor + 12 * max-pycor) / 14)) and (pycor > ((12 * min-pycor + 2 * max-pycor) / 14) ))
    [ set pcolor 0]
  ]
;;
;;;;;; Set Exits :: (Patch Set)
;;;;;;;;;;;;;; Random
  ask patches [
;;;;;;;;;;;;;;;;;; Inner Exits
    if (Scenario = "Random Exits") [
;;;;;;;;;;;;;;;;;;;;;; East Exits
      if ((pxcor = round(((12 * max-pxcor + 2 * min-pxcor) / 14))) and (pycor < ((2 * min-pycor + 12 * max-pycor) / 14)) and (pycor > ((12 * min-pycor + 2 * max-pycor) / 14)) and (random 100) < 7)
      [ set pcolor 25]
;;;;;;;;;;;;;;;;;;;;;; West Exits
      if ((pxcor = round(((12 * min-pxcor + 2 * max-pxcor) / 14))) and (pycor < ((2 * min-pycor + 12 * max-pycor) / 14)) and (pycor > ((12 * min-pycor + 2 * max-pycor) / 14)) and (random 100) < 7)
      [ set pcolor 25]
;;;;;;;;;;;;;;;;;;;;;; North Exits
      if ((pycor = round(((12 * max-pycor + 2 * min-pycor) / 14))) and (pxcor < ((2 * min-pxcor + 12 * max-pxcor) / 14)) and (pxcor > ((12 * min-pxcor + 2 * max-pxcor) / 14)) and (random 100) < 7)
      [ set pcolor 25]
;;;;;;;;;;;;;;;;;;;;;; South Exits
      if ((pycor = round(((12 * min-pycor + 2 * max-pycor) / 14))) and (pxcor < ((2 * min-pxcor + 12 * max-pxcor) / 14)) and (pxcor > ((12 * min-pxcor + 2 * max-pxcor) / 14)) and (random 100) < 7)
      [ set pcolor 25]

;;;;;;;;;;;;;; Outer Exits
;;;;;;;;;;;;;;;;;; North and South Exits
      if (pycor = min-pycor or  pycor = max-pycor and (random 100) < 15) [set pcolor 45]
;;;;;;;;;;;;;;;;;; East and West Exits
      if (pxcor = min-pxcor or pxcor = max-pxcor and (random 100) < 15) [set pcolor 45]
    ]
;;;;;;;;;;;;;; Scenario 1
  if (Scenario = "Scenario 1") [
;;;;;;;;;;;;;;;;;; Inner Exits
;;;;;;;;;;;;;;;;;;;;;; North-East Exits
      if ((pxcor = round(((12 * max-pxcor + 2 * min-pxcor) / 14))) and (pycor = round(((12 * max-pycor + 2 * min-pycor) / 14)))) [set pcolor 25]
      if ((pxcor = round(((12 * max-pxcor + 2 * min-pxcor) / 14))) and (pycor = round(((12 * max-pycor + 2 * min-pycor) / 14)) - 1)) [set pcolor 25]
      if ((pxcor = round(((12 * max-pxcor + 2 * min-pxcor) / 14)) - 1) and (pycor = round(((12 * max-pycor + 2 * min-pycor) / 14)))) [set pcolor 25]
;;;;;;;;;;;;;;;;;;;;;; North-West Exits
      if ((pycor = round(((12 * max-pycor + 2 * min-pycor) / 14))) and (pxcor = round(((2 * max-pxcor + 12 * min-pxcor) / 14)))) [set pcolor 25]
      if ((pycor = round(((12 * max-pycor + 2 * min-pycor) / 14))) and (pxcor = round(((2 * max-pxcor + 12 * min-pxcor) / 14)) + 1)) [set pcolor 25]
      if ((pycor = round(((12 * max-pycor + 2 * min-pycor) / 14) - 1)) and (pxcor = round(((2 * max-pxcor + 12 * min-pxcor) / 14)))) [set pcolor 25]
;;;;;;;;;;;;;;;;;;;;;; South-East Exits
      if ((pycor = round(((12 * min-pycor + 2 * max-pycor) / 14))) and (pxcor = round(((2 * min-pxcor + 12 * max-pxcor) / 14)))) [set pcolor 25]
      if ((pycor = round(((12 * min-pycor + 2 * max-pycor) / 14))) and (pxcor = round(((2 * min-pxcor + 12 * max-pxcor) / 14)) - 1)) [set pcolor 25]
      if ((pycor = round(((12 * min-pycor + 2 * max-pycor) / 14) + 1)) and (pxcor = round(((2 * min-pxcor + 12 * max-pxcor) / 14)))) [set pcolor 25]
;;;;;;;;;;;;;;;;;;;;;; South-West Exits
      if ((pxcor = round(((12 * min-pxcor + 2 * max-pxcor) / 14))) and (pycor = round(((12 * min-pycor + 2 * max-pycor) / 14)))) [set pcolor 25]
      if ((pxcor = round(((12 * min-pxcor + 2 * max-pxcor) / 14))) and (pycor = round(((12 * min-pycor + 2 * max-pycor) / 14)) + 1)) [set pcolor 25]
      if ((pxcor = round(((12 * min-pxcor + 2 * max-pxcor) / 14)) + 1) and (pycor = round(((12 * min-pycor + 2 * max-pycor) / 14)))) [set pcolor 25]
;;;;;;;;;;;;;;;;;; Outer Exits
;;;;;;;;;;;;;;;;;;;;;; North-East Exits
      if (pxcor = max-pxcor and pycor = max-pycor) [set pcolor 45]
      if (pxcor = max-pxcor - 1 and pycor = max-pycor) [set pcolor 45]
      if (pxcor = max-pxcor and pycor = max-pycor - 1) [set pcolor 45]
;;;;;;;;;;;;;;;;;;;;;; North-West Exits
      if (pycor = max-pycor and pxcor = min-pxcor) [set pcolor 45]
      if (pycor = max-pycor and pxcor = min-pxcor + 1) [set pcolor 45]
      if (pycor = max-pycor - 1 and pxcor = min-pxcor) [set pcolor 45]
;;;;;;;;;;;;;;;;;;;;;; South-East Exits
      if (pycor = min-pycor and pxcor = max-pxcor) [set pcolor 45]
      if (pycor = min-pycor and pxcor = max-pxcor - 1) [set pcolor 45]
      if (pycor = min-pycor + 1 and pxcor = max-pxcor) [set pcolor 45]
;;;;;;;;;;;;;;;;;;;;;; South-West Exits
      if (pxcor = min-pxcor and pycor = min-pycor) [set pcolor 45]
      if (pxcor = min-pxcor + 1 and pycor = min-pycor) [set pcolor 45]
      if (pxcor = min-pxcor and pycor = min-pycor + 1) [set pcolor 45]
    ]
;;;;;;;;;; Scenario 2
  if (Scenario = "Scenario 2") [
;;;;;;;;;;;;;; Inner Exits
;;;;;;;;;;;;;;;;;; North Exits
      if ((pycor = round(((12 * max-pycor + 2 * min-pycor) / 14))) and pxcor = 0) [set pcolor 25]
;;;;;;;;;;;;;;;;;; South Exits
      if ((pycor = round(((12 * min-pycor + 2 * max-pycor) / 14))) and pxcor = 0) [set pcolor 25]
;;;;;;;;;;;;;;;;;; East Exits
      if ((pxcor = round(((12 * max-pxcor + 2 * min-pxcor) / 14))) and pycor = 0) [set pcolor 25]
;;;;;;;;;;;;;;;;;; West Exits
      if ((pxcor = round(((12 * min-pxcor + 2 * max-pxcor) / 14))) and pycor = 0) [set pcolor 25]
;;;;;;;;;;;;;; Outer Exits
;;;;;;;;;;;;;;;;;; North Exits
      if (pycor = max-pycor and pxcor = round (0.5 * min-pxcor)) [set pcolor 45]
      if (pycor = max-pycor and pxcor = round ( 0.5 * max-pxcor)) [set pcolor 45]
;;;;;;;;;;;;;;;;;; South Exits
      if (pycor = min-pycor and pxcor = round (0.5 * min-pxcor)) [set pcolor 45]
      if (pycor = min-pycor and pxcor = round ( 0.5 * max-pxcor)) [set pcolor 45]
;;;;;;;;;;;;;;;;;; East Exits
      if (pxcor = max-pxcor and pycor = round (0.5 * min-pycor)) [set pcolor 45]
      if (pxcor = max-pxcor and pycor = round ( 0.5 * max-pycor)) [set pcolor 45]
;;;;;;;;;;;;;;;;;; West Exits
      if (pxcor = min-pxcor and pycor = round (0.5 * min-pycor)) [set pcolor 45]
      if (pxcor = min-pxcor and pycor = round ( 0.5 * max-pycor)) [set pcolor 45]
    ]
  ]
;;
;;;;;; Patch Variables :: (Patch Variable)
;;;;;;
;;;;;;;;;; Section :: (Integer)
  ask patches [
;;;;;;;;;;;;;; Field)
    if (pcolor = 67) [set OriginalSection 0]
;;;;;;;;;;;;;; Stands
    if (pcolor = 6) [set OriginalSection 0]
;;;;;;;;;;;;;; Lobby
    if (pcolor = 9) [set OriginalSection 1]
;;;;;;;;;;;;;; Walls
    if (pcolor = 0) [set OriginalSection 4]
;;;;;;;;;;;;;; Inner Exits
    if (pcolor = 25) [set OriginalSection 2]
;;;;;;;;;;;;;; Outer Exits
    if (pcolor = 45) [set OriginalSection 3]
  ]
;;;;;;;;;; PPneighbours :: (Patch Set)
  ask patches [
    set PPneighbours (other patches) in-radius 1
  ]
;;
;;;;;; Set Fire
;;;;;;
;;;;;;;;;; Inner Fire
  if (FirePosition = "Inner") [
    ask one-of patches with [OriginalSection = 0 or OriginalSection = 2] [
      set ClosestInnerExit min-one-of patches with [OriginalSection = 2] [distance self]
      set pcolor 15
      r:put "FireDistanceToExit" distance ClosestInnerExit
    ]
  ]
;;;;;;;;;; Outer Fire
  if (FirePosition = "Outer") [
    ask one-of patches with [OriginalSection = 1 or OriginalSection = 3] [
      set ClosestInnerExit min-one-of patches with [OriginalSection = 2] [distance self]
      set pcolor 15
      r:put "FireDistanceToExit" distance ClosestInnerExit
    ]
  ]
;;
;;;;;; Set People :: (Turtle Set)
;;;;;;
;;;;;;;;;; 10:Field, 80:Stands, 20:Lobby
;;;;;;;;;;;;;; Stands
  create-turtles round(TurtleMultiplier * 80) [set Fear 0 set Toxicity 0 set Vision 32 set shape "person" move-to one-of (patches with [pcolor = 6])]
;;;;;;;;;;;;;; Lobby
  create-turtles round(TurtleMultiplier * 20) [set Fear 0 set Toxicity 0 set Vision 32 set shape "person" move-to one-of (patches with [pcolor = 9])]
;;;;;;;;;;;;;; Field
  create-turtles round(TurtleMultiplier * 10) [set Fear 0 set Toxicity 0 set Vision 32 set shape "person" move-to one-of (patches with [pcolor = 67])]
;;;;;; Set TTneighbours
  ask turtles [
    if ([Section] of self = 0) [set TTneighbours (other turtles with [Section = 0]) in-radius Vision]
    if ([Section] of self = 1) [set TTneighbours (other turtles with [Section = 1]) in-radius Vision]
    if ([Section] of self = 2) [set TTneighbours (other turtles with [Section = 2]) in-radius Vision]
    if ([Section] of self = 3) [set TTneighbours (other turtles with [Section = 3]) in-radius Vision]
    if ([Section] of self = 4) [set TTneighbours (other turtles with [Section = 4]) in-radius Vision]
  ]
;;;;;; Set TPneighbours
  ask turtles [
    if ([Section] of self = 0) [set TPneighbours (patches in-radius ([Vision] of self) with [OriginalSection = 0])]
    if ([Section] of self = 1) [set TPneighbours (patches in-radius ([Vision] of self) with [OriginalSection = 1])]
    if ([Section] of self = 2) [set TPneighbours (patches in-radius ([Vision] of self) with [OriginalSection = 2])]
    if ([Section] of self = 3) [set TPneighbours (patches in-radius ([Vision] of self) with [OriginalSection = 3])]
    if ([Section] of self = 4) [set TPneighbours (patches in-radius ([Vision] of self) with [OriginalSection = 4])]
  ]

  r:put "Exits" Scenario
  r:put "FirePosition" FirePosition
  r:put "Turtles" count Turtles
  r:__evaldirect "DeathFrame <- as.data.frame(matrix(ncol = 4, nrow = nl.env$Turtles))"
  ;;r:__evaldirect "TempRow <- c(nl.env$Exits, nl.env$FirePosition, nl.env$FireDistanceToExit, nl.env$Turtles)"
  if (WasRandomScenario?) [set Scenario "Random Scenario"]
  if (WasRandomFire?) [set FirePosition "Random"]
end
;;
;;Go
;;
to go
;;;;;;
  set DeathsThisTick 0
;;;;;; Stop
  if (count turtles = 0) [
   r:put "Fire" DeathFireCount
   r:put "Smoke" DeathSmokeCount
   r:put "Trample" DeathTrampleCount
   r:put "EvacuatedSafely" SafeCount
   r:put "Ticks" ticks
   ;;r:__evaldirect "TempRow <- c(TempRow, mean(DeathFrame[[1]], na.rm = TRUE), mean(DeathFrame[[2]], na.rm = TRUE), mean(DeathFrame[[3]], na.rm = TRUE), mean(DeathFrame[[4]], na.rm = TRUE))"
   ;;r:__evaldirect "TempRow <- c(nl.env$Fire, nl.env$Smoke, nl.env$Trample, nl.env$EvacuatedSafely, nl.env$Ticks, TempRow)"
   ;;r:__evaldirect "TempRow <- c(nl.env$Fire, nl.env$Smoke, nl.env$Trample, nl.env$EvacuatedSafely, nl.env$Ticks,nl.env$Exits, nl.env$FirePosition, nl.env$FireDistanceToExit, nl.env$Turtles, mean(DeathFrame[[1]], na.rm = TRUE), mean(DeathFrame[[2]], na.rm = TRUE), mean(DeathFrame[[3]], na.rm = TRUE), mean(DeathFrame[[4]], na.rm = TRUE))"
   r:__evaldirect "TempRow <- c(as.integer(nl.env$Fire))"
   r:__evaldirect "TempRow <- c(TempRow, as.integer(nl.env$Smoke))"
   r:__evaldirect "TempRow <- c(TempRow, as.integer(nl.env$Trample))"
   r:__evaldirect "TempRow <- c(TempRow, as.integer(nl.env$EvacuatedSafely))"
   r:__evaldirect "TempRow <- c(TempRow, as.integer(nl.env$Ticks))"
   r:__evaldirect "TempRow <- c(TempRow, toString(nl.env$Exits))"
   r:__evaldirect "TempRow <- c(TempRow, toString(nl.env$FirePosition))"
   r:__evaldirect "TempRow <- c(TempRow, as.numeric(nl.env$FireDistanceToExit))"
   r:__evaldirect "TempRow <- c(TempRow, as.integer(nl.env$Turtles))"
   r:__evaldirect "TempRow <- c(TempRow, as.numeric(mean(DeathFrame[[1]], na.rm = TRUE)))"
   r:__evaldirect "TempRow <- c(TempRow, as.numeric(mean(DeathFrame[[2]], na.rm = TRUE)))"
   r:__evaldirect "TempRow <- c(TempRow, as.numeric(mean(DeathFrame[[3]], na.rm = TRUE)))"
   r:__evaldirect "TempRow <- c(TempRow, as.numeric(mean(DeathFrame[[4]], na.rm = TRUE)))"
   r:__evaldirect "DataFrame <- rbind.data.frame(DataFrame, TempRow, stringsAsFactors = FALSE)"
   r:__evaldirect "if (nrow(DataFrame) == 1){colnames(DataFrame)[1] <- 'Fire'}"
   r:__evaldirect "if (nrow(DataFrame) == 1){colnames(DataFrame)[2] <- 'Smoke'}"
   r:__evaldirect "if (nrow(DataFrame) == 1){colnames(DataFrame)[3] <- 'Trample'}"
   r:__evaldirect "if (nrow(DataFrame) == 1){colnames(DataFrame)[4] <- 'Evacuated'}"
   r:__evaldirect "if (nrow(DataFrame) == 1){colnames(DataFrame)[5] <- 'Ticks'}"
   r:__evaldirect "if (nrow(DataFrame) == 1){colnames(DataFrame)[6] <- 'Exits'}"
   r:__evaldirect "if (nrow(DataFrame) == 1){colnames(DataFrame)[7] <- 'FirePosition'}"
   r:__evaldirect "if (nrow(DataFrame) == 1){colnames(DataFrame)[8] <- 'FireDistanceToExit'}"
   r:__evaldirect "if (nrow(DataFrame) == 1){colnames(DataFrame)[9] <- 'Turtles'}"
   r:__evaldirect "if (nrow(DataFrame) == 1){colnames(DataFrame)[10] <- 'FireDeathAverageTicks'}"
   r:__evaldirect "if (nrow(DataFrame) == 1){colnames(DataFrame)[11] <- 'SmokeDeathAverageTicks'}"
   r:__evaldirect "if (nrow(DataFrame) == 1){colnames(DataFrame)[12] <- 'TrampleDeathAverageTicks'}"
   r:__evaldirect "if (nrow(DataFrame) == 1){colnames(DataFrame)[13] <- 'EvacuatedAverageTicks'}"
   ifelse ReRun? [SetScenario] [Stop]
  ]
  set VisionMultiplier 2 / (1 + exp(count turtles / 220))
;;;;;; Patches
;;;;;;
  ask patches [
;;;;;;;;;; Patch Variables :: (Patch Variables)
;;;;;;;;;;
;;;;;;;;;;;;;; Counters :: (Integer)
;;;;;;;;;;;;;;;;;; Fire Density Counter
    set PPFireDensity count PPneighbours with [pcolor = 15]
;;;;;;;;;;;;;;;;;; Smoke Density Counters
;;;;;;;;;;;;;;;;;;;;;; Light
    set PPLightSmokeDensity (count PPneighbours with [pcolor = 37 or pcolor = 15])
;;;;;;;;;;;;;;;;;;;;;; Medium
    set PPMediumSmokeDensity (count PPneighbours with [pcolor = 35 or pcolor = 15]) * (count PPneighbours with [pcolor = 37] + 1) / 4.669201 ;;Feigenbaum Constant
;;;;;;;;;;;;;;;;;;;;;; Heavy
    set PPHeavySmokeDensity (count PPneighbours with [pcolor = 33 or pcolor = 15]) * (count PPneighbours with [pcolor = 35] + 1) / (pi ^ 2)
;;;;;;;;;;;;;; Danger Level :: (Integer)
;;;;;;;;;;;;;;;;;; Exits
    if (pcolor = 25 or pcolor = 45) [set DangerLevel 0]
;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;; Clear Space
    if (pcolor = 6 or pcolor = 67 or pcolor = 9) [set DangerLevel 1]
;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;; Smoke
;;;;;;;;;;;;;;;;;;;;;; Light
    if (pcolor = 37) [set DangerLevel 2]
;;;;;;;;;;;;;;;;;;;;;; Medium
    if (pcolor = 35) [set DangerLevel 3]
;;;;;;;;;;;;;;;;;;;;;; Heavy
    if (pcolor = 33) [set DangerLevel 4]
;;;;;;;;;;;;;;;;;; Walls and Fire
    if (pcolor = 0 or pcolor = 15) [set DangerLevel 5]
;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Patch Changes
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;; Spread Fire
    if (pcolor != 0 and (random 1000)  < FireSpreadRate * PPFireDensity) [set pcolor 15]
;;;;;;;;;;;;;;;;;; Spread Smoke
;;;;;;;;;;;;;;;;;;;;;; Light Smoke
    if (pcolor = 6 or pcolor = 9 or pcolor = 25 or pcolor = 45 or pcolor = 67 and (random 1000)  < SmokeSpreadRate * PPLightSmokeDensity) [set pcolor 37]
;;;;;;;;;;;;;;;;;;;;;; Medium Smoke
    if (pcolor = 6 or pcolor = 9 or pcolor = 25 or pcolor = 45 or pcolor = 67 or pcolor = 37  and (random 1000)  < SmokeSpreadRate * PPMediumSmokeDensity) [set pcolor 35]
;;;;;;;;;;;;;;;;;;;;;; Heavy Smoke
    if (pcolor = 6 or pcolor = 9 or pcolor = 25 or pcolor = 45 or pcolor = 67 or pcolor = 37 or pcolor = 35 and (random 1000)  < SmokeSpreadRate * PPHeavySmokeDensity) [set pcolor 33]
  ]
;;
;;;;;; Turtles
;;;;;;
	ask turtles [
;;;;;;;;;; Set Patch-Here Related Variables
;;;;;;;;;;;;;; Set Section
    if ([OriginalSection] of patch-here = 0) [set Section 0]
    if ([OriginalSection] of patch-here = 1) [set Section 1]
    if ([OriginalSection] of patch-here = 2) [set Section 2]
    if ([OriginalSection] of patch-here = 3) [set Section 3]
    if ([OriginalSection] of patch-here = 4) [set Section 4]
;;;;;;;;;;;;;; No Smoke
    if ([pcolor] of patch-here = 6 or [pcolor] of patch-here = 67 or [pcolor] of patch-here = 9) [set Vision 25 * VisionMultiplier]
;;;;;;;;;;;;;; Light Smoke
    if ([pcolor] of patch-here = 37) [Set Vision 20 * VisionMultiplier set Toxicity Toxicity + 0.261497] ;; Meissel-Mertenz Constant
;;;;;;;;;;;;;; Medium Smoke
    if ([pcolor] of patch-here = 35) [Set Vision 15 * VisionMultiplier set Toxicity Toxicity + 0.577215] ;; Euler-Mascheroni Constant
;;;;;;;;;;;;;; Heavy Smoke
    if ([pcolor] of patch-here = 33) [Set Vision 10 * VisionMultiplier set Toxicity Toxicity + 1.353077] ;; Conways Constant
;;;;;;;;;; Kill Turtles
;;;;;;;;;;;;;; Death By Fire
    if ([pcolor] of patch-here = 15) [set DeathFireCount (DeathFireCount + 1) ask TTneighbours [set DeathsWitnessed DeathsWitnessed + 1] set DeathsThisTick DeathsThisTick + 1 die]
;;;;;;;;;;;;;; Death By Trample
    if (any? TTneighbours and (count TTneighbours in-radius 0.567143 >= 3)) [set DeathTrampleCount DeathTrampleCount + 1 ask TTneighbours [set DeathsWitnessed DeathsWitnessed + 1] set DeathsThisTick DeathsThisTick + 1 die] ;; Omega Constant
;;;;;;;;;;;;;; Death By Asphyxiation
    if ([Toxicity] of self > pi * 137) [set DeathSmokeCount DeathSmokeCount + 1 ask TTneighbours [set DeathsWitnessed DeathsWitnessed + 1] set DeathsThisTick DeathsThisTick + 1 die]
;;;;;;;;;; Set Nearby Patch Variables :: (Patch Set)
    if ([Section] of self = 0) [set TPneighbours (patches in-radius ([Vision] of self) with [OriginalSection = 0])]
    if ([Section] of self = 1) [set TPneighbours (patches in-radius ([Vision] of self) with [OriginalSection = 1])]
    if ([Section] of self = 2) [set TPneighbours (patches in-radius ([Vision] of self) with [OriginalSection = 2])]
    if ([Section] of self = 3) [set TPneighbours (patches in-radius ([Vision] of self) with [OriginalSection = 3])]
    if ([Section] of self = 4) [set TPneighbours (patches in-radius ([Vision] of self) with [OriginalSection = 4])]
;;;;;;;;;;; Set Nearby Turtle Variables :: (Turtle Set)
    if ([Section] of self = 0) [set TTneighbours (other turtles with [Section = 0]) in-radius Vision]
    if ([Section] of self = 1) [set TTneighbours (other turtles with [Section = 1]) in-radius Vision]
    if ([Section] of self = 2) [set TTneighbours (other turtles with [Section = 2]) in-radius Vision]
    if ([Section] of self = 3) [set TTneighbours (other turtles with [Section = 3]) in-radius Vision]
    if (any? TTneighbours) [set TTneighbourMain min-one-of TTneighbours [distance myself]]
;;;;;;;;;; Set Nearby Fires
    if ([Section] of self = 0) [set TPfires TPneighbours with [OriginalSection = 0 and pcolor = 15] in-radius ([Vision] of self)]
    if ([Section] of self = 1) [set TPfires TPneighbours with [OriginalSection = 1 and pcolor = 15] in-radius ([Vision] of self)]
    if ([Section] of self = 2) [set TPfires TPneighbours with [OriginalSection = 2 and pcolor = 15] in-radius ([Vision] of self)]
    if ([Section] of self = 3) [set TPfires TPneighbours with [OriginalSection = 3 and pcolor = 15] in-radius ([Vision] of self)]
    if ([Section] of self = 4) [set TPfires TPneighbours with [OriginalSection = 4 and pcolor = 15] in-radius ([Vision] of self)]
    if (any? TPfires) [set TPfireMain min-one-of TPfires [distance self]]
;;;;;;;;;; Set Nearby Walls
    set Walls (patches) in-radius 0.75 with [pcolor = 0]
    if (any? Walls) [set WallMain min-one-of Walls [distance self]]
;;;;;;;;;; Set Nearby Smoke
    set TPSmokeNeighbours TPneighbours with ([pcolor = 33 or pcolor = 35 or pcolor = 37 or pcolor = 15])
;;;;;;;;;; Set Nearby Exits
    if ([Section] of self = 0) [set TPexitsRange (patches in-radius Vision) with [OriginalSection = 2 and pcolor != 15]]
    if ([Section] of self = 1) [set TPexitsRange (patches in-radius Vision) with [OriginalSection = 3 and pcolor != 15]]
    if (any? TPexitsRange) [set TPexit min-one-of TPexitsRange [distance myself]]
;;;;;;;;;; Set Other Variables
;;;;;;;;;;;;;; Fear
    if (any? TPneighbours with [pcolor = 33 or pcolor = 35 or pcolor = 37] and any? TPfires) [set Fear (137 + 2 * Toxicity + ((e ^ pi) * ln (DeathsWitnessed + 1)) + 10 * (count TTneighbours in-radius 1)) + (1000 / (0.01 + distance [self] of TPfireMain))]
    if (any? TPneighbours with [pcolor = 33 or pcolor = 35 or pcolor = 37] and not any? TPfires) [set Fear (137 + 2 * Toxicity + ((e ^ pi) * ln (DeathsWitnessed + 1)) + 10 * (count TTneighbours in-radius 1))]
;;;;;;;;;;;;;; Speed
    set Speed exp (-1 * pi) * (1 / (1 + (log (Toxicity + 1) (e ^ pi))))
    ;;set speed (30000 - (Toxicity ^ 2)) / 1000000
;;;;;;;;;;;;;; ComfortSpace
    set ComfortSpace exp (-0.001 * Fear)

    if ([Section] of self = 2) [set TPexitNew min-one-of (patches with [OriginalSection = 1]) [distance myself]]
    ;;If turtle is in an exit, sets the patch it will exit towards


    ;;CODE IN WORKS
    ;;set MinDangerLevel min [DangerLevel] of TPneighbours
    ;;set SafestPatch TPneighbours with [DangerLevel = [MinDangerLevel] of myself]
    ;;Sets the safest neighbouring patch
    set SafestPatchMultiplier 0
    ;;set SafeXcor sum ([pxcor] of SafestPatch / distance SafestPatch)


    if (any? TPfires) [set TPfireMultiplier ((1 / (distance [self] of TPfireMain + 0.000001)) + exp (-0.567 * distance [self] of TPfireMain + pi))]
    if (any? TTneighbours and distance [self] of TTneighbourMain > ComfortSpace) [set TTneighbourMultiplier (0.5) * (distance [myself] of TTneighbourMain) * (exp ((1 / Vision) * (distance [myself] of TTneighbourMain)))]
    if (any? TTneighbours and distance [self] of TTneighbourMain <= ComfortSpace) [set TTneighbourMultiplier 1 / (distance [myself] of TTneighbourMain + 0.0001)]
    ;;set TTneighbourMultiplier 1
    ;;set TTneighbourMultiplier 0
    if (any? TPexitsRange) [set TPexitMultiplier (3 / (distance [self] of TPexit + 0.001)) * (exp (exp (-1 * ((distance [self] of TPexit) ^ (1))) + 1))]

		;;SETTING COLOURS
    if (not any? TPneighbours with [pcolor = 33 or pcolor = 35 or pcolor = 37 or pcolor = 15] and not any? Walls) [set color 95 if ([Fear] of self < 100) [set Fear 100]]
		;;if there is no smoke
    if (any? TPSmokeNeighbours and any? TPexitsRange and any? TTneighbours and not any? Walls) [set color 115]
		;; if there is smoke and exits in range turtles in range
		if (any? TPSmokeNeighbours and any? TPexitsRange and not any? TTneighbours and not any? Walls) [set color 65]
		;; if there is smoke and exits but no neighbours
		if (any? TPSmokeNeighbours and not any? TPexitsRange and any? TTneighbours and not any? Walls) [set color 85]
		;;if there is smoke and neighbours but no exits
		if (any? TPSmokeNeighbours and any? TPFires and not any? TPexitsRange and not any? TTneighbours and not any? Walls) [set color 125]
		;;if there is smoke with no neighbours and no exits

    ;;ACTIONING
    if ([Section] of self = 2) [act-InnerExit]
    if ([Section] of self = 3) [act-OuterExit]
    ;;If turtle is in an exit
    if any? Walls [set color 12]
    ;;if ( [pcolor] of myself = 45) [act-OuterExit]
    if (color = 95 and [Section] of self != 2 and [Section] of self != 3) [act-Calm]
    if (color = 85 and [Section] of self != 2 and [Section] of self != 3) [act-Flock]
    if (color = 65 and [Section] of self != 2 and [Section] of self != 3) [act-Escape]
    if (color = 115 and [Section] of self != 2 and [Section] of self != 3) [act-Hybrid]
    if (color = 125 and [Section] of self != 2 and [Section] of self != 3) [act-RunFire]
    if (color = 12) [act-Wall]
		;; colours 95,85,65,115,125 are blue, teal, green, purple and fuschia respectively
	]
  if (DeathsThisTick > 0) [
    r:put "DeathTickCount" ticks
    r:put "TempFireCount" DeathFireCount
    r:put "TempSmokeCount" DeathSmokeCount
    r:put "TempTrampleCount" DeathTrampleCount
    r:put "TempSafeCount" SafeCount
    r:__evaldirect "if(match(NA,DeathFrame[[1]]) <= nl.env$TempFireCount){DeathFrame[[1]][match(NA,DeathFrame[[1]]):nl.env$TempFireCount] <- nl.env$DeathTickCount}"
    r:__evaldirect "if(match(NA,DeathFrame[[2]]) <= nl.env$TempSmokeCount){DeathFrame[[2]][match(NA,DeathFrame[[2]]):nl.env$TempSmokeCount] <- nl.env$DeathTickCount}"
    r:__evaldirect "if(match(NA,DeathFrame[[3]]) <= nl.env$TempTrampleCount){DeathFrame[[3]][match(NA,DeathFrame[[3]]):nl.env$TempTrampleCount] <- nl.env$DeathTickCount}"
    r:__evaldirect "if(match(NA,DeathFrame[[4]]) <= nl.env$TempSafeCount){DeathFrame[[4]][match(NA,DeathFrame[[4]]):nl.env$TempSafeCount] <- nl.env$DeathTickCount}"
    r:__evaldirect "rm(DeathTickCount, TempFireCount, TempSmokeCount, TempTrampleCount, TempSafeCount, envir = nl.env)"
    r:gc
  ]
	tick
end

to act-Calm
  	left random 180
	right random 180
  if (any? TTneighbours and distance [self] of TTneighbourMain <= ComfortSpace)[
    facexy (2 * [xcor] of self - [xcor] of TTneighbourMain)
    (2 * [ycor] of self - [ycor] of TTneighbourMain)
  ]
	fd Speed
end

to act-Flock
  if (is-turtle? TTneighbourMain)[
    if (any? TPfires and distance [self] of TTneighbourMain > ComfortSpace)[
      	facexy  ((TTneighbourMultiplier) * [xcor] of TTneighbourMain + [heading] of TTneighbourMain + (TPFireMultiplier) * ([xcor] of self - [pxcor] of TPfireMain) + [xcor] of self ) / (TPFireMultiplier + TTneighbourMultiplier)
      	 ((TTneighbourMultiplier) * [ycor] of TTneighbourMain + [heading] of TTneighbourMain + (TPfireMultiplier) * ([ycor] of self - [pycor] of TPfireMain) + [ycor] of self) / (TPFireMultiplier + TTneighbourMultiplier)
	fd Speed
  ]
    if (not any? TPfires and distance [self] of TTneighbourMain > ComfortSpace)[
    	facexy  (((TTneighbourMultiplier) * [xcor] of TTneighbourMain + 2 * (random max-pxcor) - 16) / (1 + TTneighbourMultiplier))
  	 ((TTneighbourMultiplier) * [ycor] of TTneighbourMain + 2 * (random max-pycor) - 16) / (1 + TTneighbourMultiplier)
	fd Speed
  ]
        if (any? TPfires and distance [self] of TTneighbourMain <= ComfortSpace)[
      	facexy  ((TTneighbourMultiplier) * ([xcor] of self - [xcor] of TTneighbourMain) + [xcor] of self + 2 * (random max-pxcor) - 16 + (TPFireMultiplier) * ([xcor] of self - [pxcor] of TPfireMain) + [xcor] of self) / (3)
      	 ((TTneighbourMultiplier) * ([ycor] of self - [ycor] of TTneighbourMain) + [ycor] of self + 2 * (random max-pxcor) - 16 + (TPfireMultiplier) * ([ycor] of self - [pycor] of TPfireMain) + [xcor] of self) / (3)
	fd Speed
  ]
    if (not any? TPfires and distance [self] of TTneighbourMain <= ComfortSpace)[
    	facexy  ((TTneighbourMultiplier) * ([xcor] of self - [xcor] of TTneighbourMain) + [ycor] of self) / (1)
    	 ((TTneighbourMultiplier) * ([ycor] of self - [ycor] of TTneighbourMain) + [ycor] of self) / (1)
	fd Speed
  ]
  ]
end

to act-Escape
  	facexy  ([pxcor] of TPexit)
  		([pycor] of TPexit)
	fd Speed
end


to act-Hybrid
  if (is-turtle? TTneighbourMain)[
    if (not any? TPfires and distance [self] of TTneighbourMain > ComfortSpace)[
  	facexy  (TPexitMultiplier * [pxcor] of TPexit + TTneighbourMultiplier * [xcor] of TTneighbourMain) / (TTneighbourMultiplier + TPexitMultiplier)
		((TPexitMultiplier) * [pycor] of TPexit + TTneighbourMultiplier * [ycor] of TTneighbourMain) / (TTneighbourMultiplier + TPexitMultiplier)
  ]
    if (any? TPfires and distance [self] of TTneighbourMain > ComfortSpace)[
      	facexy  ((TPexitMultiplier) * [pxcor] of TPexit + TTneighbourMultiplier * [xcor] of TTneighbourMain + (TPfireMultiplier) * ([xcor] of self - [pxcor] of TPfireMain) + [xcor] of self) / (1 + TTneighbourMultiplier + TPexitMultiplier + SafestPatchMultiplier)
      		((TPexitMultiplier) * [pycor] of TPexit + TTneighbourMultiplier * [ycor] of TTneighbourMain + (TPfireMultiplier) * ([ycor] of self - [pycor] of TPfireMain) + [ycor] of self) / (1 + TTneighbourMultiplier + TPexitMultiplier + SafestPatchMultiplier)
  ]
    if (not any? TPfires and distance [self] of TTneighbourMain <= ComfortSpace)[
      	facexy  (TPexitMultiplier * [pxcor] of TPexit + TTneighbourMultiplier * ([xcor] of self - [xcor] of TTneighbourMain) + [xcor] of self) / (1 + TPexitMultiplier)
      		((TPexitMultiplier) * [pycor] of TPexit + TTneighbourMultiplier * ([ycor] of self - [ycor] of TTneighbourMain) + [ycor] of self) / (1 + TPexitMultiplier)
  ]
    if (any? TPfires and distance [self] of TTneighbourMain <= ComfortSpace)[
      	facexy  ((TPexitMultiplier) * [pxcor] of TPexit + TTneighbourMultiplier * ([xcor] of self - [xcor] of TTneighbourMain) + [xcor] of self + (TPfireMultiplier) * ([xcor] of self - [pxcor] of TPfireMain) + [xcor] of self) / (2 + TPexitMultiplier + SafestPatchMultiplier)
      		((TPexitMultiplier) * [pycor] of TPexit + TTneighbourMultiplier * ([ycor] of self - [ycor] of TTneighbourMain) + [ycor] of self + (TPfireMultiplier) * ([ycor] of self - [pycor] of TPfireMain) + [ycor] of self) / (2 + TPexitMultiplier + SafestPatchMultiplier)
  ]
	fd Speed
  ]
end

to act-RunFire
  facexy  ((TPfireMultiplier) * ([xcor] of self - [pxcor] of TPfireMain) + [xcor] of self) / (SafestPatchMultiplier + 1)
  ((TPfireMultiplier) * ([ycor] of self - [pycor] of TPfireMain) + [ycor] of self) / (SafestPatchMultiplier + 1)
	
  fd Speed
end



to act-Wall
  ;;bk 0.1
  	facexy (2 * [xcor] of self - [pxcor] of WallMain)
  		(2 * [ycor] of self - [pycor] of WallMain)
  set subrandom (random 2)
  if (subrandom = 1)[
  rt 30
  ]
  if (subrandom = 2)[
    lt 30
  ]
	fd Speed
end



to act-InnerExit
	set InnerExitDuration InnerExitDuration + 1
	if (InnerExitDuration >= ExitTime) [
    		facexy  ([pxcor] of TPexitNew)
    			([pycor] of TPexitNew)
   move-to TPexitNew
   set Section 1
	]
end

to act-OuterExit
	set OuterExitDuration OuterExitDuration + 1
  if (OuterExitDuration >= ExitTime) [
    set SafeCount SafeCount + 1
    die
  ]
end

to-report FireDeaths
  report DeathFireCount
end

to-report SmokeDeaths
  report DeathSmokeCount
end

to-report TrampleDeaths
  report DeathTrampleCount
end

to-report Safe
  report SafeCount
end

to ResetData
  r:__evaldirect "rm()"
  r:gc
  r:__evaldirect "DataFrame <- as.data.frame(matrix(ncol = 13, nrow = 0))"
  ;;r:__evaldirect "colnames(DataFrame)[1] <- 'Fire'"
  ;;r:__evaldirect "colnames(DataFrame)[2] <- 'Smoke'"
  ;;r:__evaldirect "colnames(DataFrame)[3] <- 'Trample'"
  ;;r:__evaldirect "colnames(DataFrame)[4] <- 'Evacuated'"
  ;;r:__evaldirect "colnames(DataFrame)[5] <- 'Ticks'"
end

to ExportData
  r:__evaldirect "write.csv(DataFrame, file = 'C:/Users/Peng/Desktop/Assignment4DATA.csv')"
  ;;r:__evaldirect "write.csv(DataFrame, file = '/home/think/Desktop/DATA.csv')"
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
8
25
71
58
NIL
Go
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
84
27
181
60
NIL
SetScenario
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
16
71
191
116
Scenario
Scenario
"Random Scenario" "Random Exits" "Scenario 1" "Scenario 2" "Scenario 3"
0

SLIDER
4
124
176
157
FireSpreadRate
FireSpreadRate
0
1000
7.0
1
1
NIL
HORIZONTAL

SLIDER
6
161
178
194
SmokeSpreadRate
SmokeSpreadRate
0
1000
25.0
1
1
NIL
HORIZONTAL

SLIDER
5
200
177
233
ExitTime
ExitTime
0
100
5.0
1
1
NIL
HORIZONTAL

MONITOR
679
19
884
64
NIL
FireDeaths
4
1
11

MONITOR
683
83
817
128
NIL
SmokeDeaths
1
1
11

MONITOR
689
147
832
192
NIL
TrampleDeaths
4
1
11

MONITOR
686
213
767
258
NIL
Safe
4
1
11

MONITOR
889
36
1005
81
turtles left alive
count turtles
4
1
11

SWITCH
10
249
121
282
ReRun?
ReRun?
0
1
-1000

SLIDER
11
294
183
327
TurtleMultiplier
TurtleMultiplier
0
10
1.7
0.1
1
NIL
HORIZONTAL

PLOT
670
271
1001
421
Death Plot
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Fire" 1.0 0 -2674135 true "" "plot DeathFireCount"
"Smoke" 1.0 0 -10402772 true "" "plot DeathSmokeCount"
"Trample" 1.0 0 -13791810 true "" "plot DeathTrampleCount"
"Safe" 1.0 0 -13840069 true "" "plot SafeCount"

CHOOSER
18
344
156
389
FirePosition
FirePosition
"Random" "Inner" "Outer"
0

BUTTON
19
408
109
441
NIL
ResetData
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
29
454
124
487
NIL
ExportData
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

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
NetLogo 6.0.1
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
