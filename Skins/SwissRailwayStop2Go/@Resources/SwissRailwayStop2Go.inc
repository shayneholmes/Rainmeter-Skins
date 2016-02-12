[Rainmeter]
Update=20

[Variables]
;--------------
; SIZING OPTIONS
ClockDiameter=200

;--------------
; COLOR OPTIONS
ClockBackgroundColor=0,0,0,255
ClockElementsColor=255,255,255,255

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

;--------------
; AUTO-COMPUTED VARIABLES (please don't edit)
ClockRadius=(#ClockDiameter#/2)
ClockEdgeWidth=(#ClockDiameter#*0.020635)

SCRIPT=#@#scripts/
INC=#@#includes/

; MEASURES
[MeasureTime]
Measure=Time

[MeasureSmoothTime]
Measure=SCRIPT
ScriptFile=#SCRIPT#Progress.lua

[MeasureOne]
Measure=Calc
Formula=1
UpdateDivider=-1

; STYLES

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
LineStart=(#ClockRadius#-#ClockEdgeWidth#-#ClockDiameter#*0.047619)
LineWidth=(0.009524*#ClockDiameter#)

[styleMarkerHour]
LineStart=(#ClockRadius#-#ClockEdgeWidth#-#ClockDiameter#*0.111111)
LineWidth=(0.039683*#ClockDiameter#)

[styleHand]
LineColor=#ClockElementsColor#
H=(#ClockDiameter#)
W=(#ClockDiameter#)
X=0
LineLength=(#ClockRadius#-#ClockEdgeWidth#)
StartAngle=(3/2*PI)
Solid=0
AntiAlias=1

[styleHourHand]
LineLength=(#ClockDiameter#*0.271429)
LineStart=(-#ClockDiameter#*0.138095)
LineWidth=(#ClockDiameter#*0.038095)

[styleMinuteHand]
LineLength=(#ClockDiameter#*0.436508)
LineStart=(-#ClockDiameter#*0.139683)
LineWidth=(#ClockDiameter#*0.038095)

[styleSecondHand]
LineLength=(#ClockDiameter#*0.350794)
LineStart=(-#ClockDiameter#*0.125397)
LineWidth=(#ClockDiameter#*0.013651)
LineColor=#SecondHandColor#

[styleSecondHandBall]
Solid=1
LineLength=(#ClockDiameter#*0.037302)
LineColor=#SecondHandColor#

;----------------------------------------------
; METERS
;
; Drawn in z-order to ensure that everything looks great!

;-----------------------
; CLOCK background

[MeterClockBackground]
Meter=Roundline
LineColor=#ClockBackgroundColor#
H=(#ClockDiameter#)
W=(#ClockDiameter#)
UpdateDivider=-1
LineStart=0
LineLength=(#ClockRadius#)
Solid=1
AntiAlias=1

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
Value2={cos(2*PI/#NumberOfMinuteMarkers#*%%)};{-sin(2*PI/#NumberOfMinuteMarkers#*%%)};{sin(2*PI/#NumberOfMinuteMarkers#*%%)};{cos(2*PI/#NumberOfMinuteMarkers#*%%)};{(1-sin(2*PI/#NumberOfMinuteMarkers#*%%))*#ClockRadius#};{(1-cos(2*PI/#NumberOfMinuteMarkers#*%%))*#ClockRadius#}
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
Value2={cos(2*PI/#NumberOfHourMarkers#*%%)};{-sin(2*PI/#NumberOfHourMarkers#*%%)};{sin(2*PI/#NumberOfHourMarkers#*%%)};{cos(2*PI/#NumberOfHourMarkers#*%%)};{(1-sin(2*PI/#NumberOfHourMarkers#*%%))*#ClockRadius#};{(1-cos(2*PI/#NumberOfHourMarkers#*%%))*#ClockRadius#}
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
MeasureName=MeasureOne
TransformationMatrix=1;0;0;1;(sin(2*PI*[MeasureSeconds])*#ClockDiameter#*0.313492);(-cos(2*PI*[MeasureSeconds])*#ClockDiameter#*0.313492)
DynamicVariables=1

[MeterSecondHandHub]
Meter=Roundline
MeterStyle=styleHand|styleSecondHandBall
MeasureName=MeasureOne
LineLength=(#ClockDiameter#*0.017460)
DynamicVariables=1
UpdateDivider=-1

[MeterSpindle]
Meter=Roundline
MeterStyle=styleHand|styleSecondHandBall
MeasureName=MeasureOne
LineLength=(#ClockDiameter#*0.004762)
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
