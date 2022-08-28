[Variables]
;--------------
; DEFAULT SIZING OPTIONS
SkinSize=200
ClockBezelExists=1

;--------------
; CUSTOMIZED SIZING OPTIONS
@Include=#@#Settings.inc

;--------------
; DEFAULT COLOR OPTIONS
ClockBackgroundColor=0,0,0,255
ClockElementsColor=255,255,255,255
BevelColor=128,128,128,255

SecondHandColor=205,29,29,255

;--------------
; TIME CONTROLS
; Make time run fast for first 58.5 seconds, then sit until the top of the minute.
; (Set to zero to turn off Stop2Go.)
GainRatio=0.025641
; ( = 60 / 58.5 - 1)

; How many seconds it takes the minute hand to 'tick' to its next position each minute
MinuteHandMotionDuration = 0.1

;--------------
; CONSTANTS (don't need to edit these)
NumberOfHourMarkers=12
NumberOfMinuteMarkers=60

; Ensure whole-numbers (sometimes even) to address antialiasing woes
HandWidth=(floor(#ClockDiameter#*0.038))
HourHandLength=(floor(#ClockDiameter#*0.27))
MinuteHandLength=(floor(#ClockDiameter#*0.43))
HandBacksideLength=(floor(-#ClockDiameter#*0.14))

;--------------
; AUTO-COMPUTED VARIABLES (please don't edit)
ClockBezelWidth=(floor(#ClockBezelExists#?#SkinSize#*0.025:0))
ClockPadding=(#ClockBezelWidth#)
ClockDiameter=(#SkinSize#-#ClockPadding#*2)

ClockRadius=(#ClockDiameter#/2)
ClockEdgeWidth=(#ClockDiameter#*0.025)

SCRIPT=#@#scripts/
INC=#@#includes/

[Rainmeter]
Update=20

ContextTitle=Bigger size
ContextTitle2=Smaller size
ContextTitle3=Toggle bezel
ContextAction=[!WriteKeyValue Variables SkinSize "(#SkinSize#=120?200:640)" #@#Settings.inc][!Refresh]
ContextAction2=[!WriteKeyValue Variables SkinSize "(#SkinSize#=640?200:120)" #@#Settings.inc][!Refresh]
ContextAction3=[!WriteKeyValue Variables ClockBezelExists "(#ClockBezelExists#?0:1)" #@#Settings.inc][!Refresh]

; MEASURES
[MeasureTime]
Measure=Time

[MeasureSmoothTime]
Measure=SCRIPT
ScriptFile=#SCRIPT#Progress.lua

; STYLES

[styleCircle]
H=(#SkinSize#)
W=(#SkinSize#)
UpdateDivider=-1
Solid=1
AntiAlias=1

[styleMarker]
LineColor=#ClockElementsColor#
H=(#ClockDiameter#)
W=(#ClockDiameter#)
X=(-#ClockRadius#)
LineLength=(#ClockRadius#-#ClockEdgeWidth#)
StartAngle=(3/2*PI)
Solid=0
AntiAlias=1
UpdateDivider=-1

[styleMarkerMinute]
LineStart=(#MinuteHandLength#-1)
LineWidth=(#ClockDiameter#*0.010417)

[styleMarkerHour]
LineStart=(#ClockDiameter#*0.366667)
LineWidth=#HandWidth#

[styleHand]
LineColor=#ClockElementsColor#
H=(#ClockDiameter#)
W=(#ClockDiameter#)
X=#ClockPadding#
Y=#ClockPadding#
LineLength=(#ClockRadius#-#ClockEdgeWidth#)
StartAngle=(3/2*PI)
Solid=0
AntiAlias=1

[styleHourHand]
LineLength=#HourHandLength#
LineStart=#HandBacksideLength#
LineWidth=#HandWidth#

[styleMinuteHand]
LineLength=#MinuteHandLength#
LineStart=#HandBacksideLength#
LineWidth=#HandWidth#

[styleSecondHand]
LineLength=(#ClockDiameter#*0.35)
LineStart=(-#ClockDiameter#*0.125)
LineWidth=(#ClockDiameter#*0.013)
LineColor=#SecondHandColor#

[styleSecondHandBall]
Solid=1
LineLength=(#ClockDiameter#*0.037)
LineColor=#SecondHandColor#

;----------------------------------------------
; METERS
;
; Drawn in z-order to ensure that everything looks great!

;-----------------------
; CLOCK background

[MeterClockBackground]
Meter=Shape
Shape=Ellipse (#SkinSize#/2),(#SkinSize#/2),(#SkinSize#/2) | Fill Color #BevelColor# | StrokeWidth 0; bevel
Shape2=Ellipse (#SkinSize#/2),(#SkinSize#/2),(#ClockRadius#) | Fill Color #ClockBackgroundColor# | StrokeWidth 0; bezel


[MinuteMarkers]
Measure=Script
ScriptFile=#SCRIPT#Factory.lua
IncFile=#INC#MinuteMarkers.inc
Number=(#NumberOfMinuteMarkers#)
SectionName=MinuteMarker%%
Option0=Meter
Value0=Roundline
Option1=MeterStyle
Value1=styleMarker|styleMarkerMinute
Option2=TransformationMatrix
Value2={cos(2*PI/#NumberOfMinuteMarkers#*%%)};{-sin(2*PI/#NumberOfMinuteMarkers#*%%)};{sin(2*PI/#NumberOfMinuteMarkers#*%%)};{cos(2*PI/#NumberOfMinuteMarkers#*%%)};{(1-sin(2*PI/#NumberOfMinuteMarkers#*%%))*#ClockRadius#+#ClockPadding#};{(1-cos(2*PI/#NumberOfMinuteMarkers#*%%))*#ClockRadius#+#ClockPadding#}
UpdateDivider=-1
@Include=#INC#MinuteMarkers.inc

[HourMarkers]
Measure=Script
ScriptFile=#SCRIPT#Factory.lua
IncFile=#INC#HourMarkers.inc
Number=(#NumberOfHourMarkers#)
SectionName=HourMarker%%
Option0=Meter
Value0=Roundline
Option1=MeterStyle
Value1=styleMarker|styleMarkerHour
Option2=TransformationMatrix
Value2={cos(2*PI/#NumberOfHourMarkers#*%%)};{-sin(2*PI/#NumberOfHourMarkers#*%%)};{sin(2*PI/#NumberOfHourMarkers#*%%)};{cos(2*PI/#NumberOfHourMarkers#*%%)};{(1-sin(2*PI/#NumberOfHourMarkers#*%%))*#ClockRadius#+#ClockPadding#};{(1-cos(2*PI/#NumberOfHourMarkers#*%%))*#ClockRadius#+#ClockPadding#}
UpdateDivider=-1
@Include=#INC#HourMarkers.inc

[MeasureMinutesAndHours]
Measure=Calc
Formula=(floor(MeasureSmoothTime/60)+min((MeasureSmoothTime%60)/#MinuteHandMotionDuration#-1,0))
OnChangeAction=[!UpdateMeasureGroup MeasuresThatUpdateOncePerMinute][!UpdateMeterGroup HandsThatUpdateOncePerMinute]

[MeasureMinutes]
Measure=Calc
Formula=MeasureMinutesAndHours%60/60
Group=MeasuresThatUpdateOncePerMinute
UpdateDivider=-1

[MeasureHours]
Measure=Calc
Formula=MeasureMinutesAndHours%720/720
Group=MeasuresThatUpdateOncePerMinute
UpdateDivider=-1

[MeasureSeconds]
Measure=Calc
Formula=((MeasureSmoothTime%60)+min((MeasureSmoothTime%60)*#GainRatio#,60-(MeasureSmoothTime%60)))/60

[MeterHourHand]
Meter=Roundline
MeterStyle=styleHand|styleHourHand
Group=HandsThatUpdateOncePerMinute
MeasureName=MeasureHours
UpdateDivider=-1

[MeterMinuteHand]
Meter=Roundline
MeterStyle=styleHand|styleMinuteHand
Group=HandsThatUpdateOncePerMinute
MeasureName=MeasureMinutes
UpdateDivider=-1

[MeterSecondHand]
Meter=Roundline
MeterStyle=styleHand|styleSecondHand
MeasureName=MeasureSeconds

[MeterSecondHandBall]
Meter=Roundline
MeterStyle=styleHand|styleSecondHandBall
TransformationMatrix=1;0;0;1;(sin(2*PI*[MeasureSeconds])*#ClockDiameter#*0.313492);(-cos(2*PI*[MeasureSeconds])*#ClockDiameter#*0.313492)
DynamicVariables=1

[MeterSecondHandHub]
Meter=Roundline
MeterStyle=styleHand|styleSecondHandBall
LineLength=(#ClockDiameter#*0.017)
DynamicVariables=1
UpdateDivider=-1

[MeterSpindle]
Meter=Roundline
MeterStyle=styleHand|styleSecondHandBall
LineLength=(#ClockDiameter#*0.0048)
LineColor=128,128,128,255
DynamicVariables=1
UpdateDivider=-1

; Helper script to always refresh skin twice instead of once
; This is so that it loads the updated .inc files
[sRefresher]
Measure=Script
ScriptFile=#SCRIPT#Refresher.lua
UpdateDivider=-1
Refreshed=0
