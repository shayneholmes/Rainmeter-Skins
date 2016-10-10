[Rainmeter]
AccurateText=1

[Variables]
; Sizing
FullHeight=600
FullWidth=600
FontPadding=-2
Padding=20

; Font
Font=Segoe UI Light
FontSize=20

; Colors
BrightColor=255,255,255,255
NormalColor=255,255,255,128

;Internal
ColorTransparent=0,0,0,1

QuoteWidth=Max([DummyQuote:W]/(trunc([DummyQuote:W]/(#FullWidth#-#Padding#-50))+1)+50,0)

;------------------------
; Styles

[TextStyle]
FontSize=#FontSize#
X=5R
FontFace=#Font#
AntiAlias=1
UpdateDivider=-1
DynamicVariables=1

[TopTextStyle]
FontColor=#BrightColor#
X=(#FullWidth#-#Padding#-(#QuoteWidth#))
StringAlign=LeftBottom
ClipString=2
ClipStringW=(#QuoteWidth#)
Y=(#FullHeight#-[DummyQuote:H]-#Padding#)

[BottomTextStyle]
FontColor=#NormalColor#
StringAlign=RightBottom
X=-10R
Y=(#FullHeight#-#Padding#)

[DetailedInfoStyle]
Hidden=1

;------------------------
; Meters

[DummyQuote]
; Just exists to give us the height and width of the quote so we can use it for positioning elsewhere
MeterStyle=TextStyle|TopTextStyle
Meter=String
MeasureName=MeasureQuote
X=-100
StringAlign=RightBottom
Group=SporadicUpdate
ClipString=0

[ClearBG]
Meter=Image
SolidColor=#ColorTransparent#
X=([Quote:X]-#Padding#)
Y=([Quote:Y]-#Padding#)
W=(max([Quote:X]+[Quote:W],[Author:X]+[Author:W])-[Quote:X]+2*#Padding#)
H=([Author:Y]+[Author:H]-[Quote:Y]+2*#Padding#)
Group=UpdateAfterQuotes
DynamicVariables=1

[Quote]
MeterStyle=TextStyle|TopTextStyle
Meter=STRING
MeasureName=MeasureQuote
Group=SporadicUpdate

[Author]
MeterStyle=TextStyle|BottomTextStyle
Meter=STRING
MeasureName=MeasureAuthor
Group=SporadicUpdate

