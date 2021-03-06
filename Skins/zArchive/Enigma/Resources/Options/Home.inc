[Variables]
PanelHeight=500

;---------------------------------------------------------------------
; MEASURES

;---------------------------------------------------------------------
; METERS

[AboutName]
Meter=STRING
MeterStyle=StyleName | StyleNameFirst
Text="A  B  O  U  T"

[VersionName]
Meter=STRING
MeterStyle=StyleName | StyleNameFirstSub
Text="Version"

[VersionText]
Meter=STRING
MeterStyle=StyleHome
Text="#EnigmaVersion#"

[DateName]
Meter=STRING
MeterStyle=StyleName | StyleNameFirstSub
Text="Date"

[DateText]
Meter=STRING
MeterStyle=StyleHome
Text="#EnigmaDate#"

[RevName]
Meter=STRING
MeterStyle=StyleName | StyleNameFirstSub
Text="Platform"

[RevText]
Meter=STRING
MeterStyle=StyleHome
Text="Rainmeter #EnigmaRev#"

[LicenseName]
Meter=STRING
MeterStyle=StyleName | StyleNameFirstSub
Text="License"

[LicenseText]
Meter=STRING
MeterStyle=StyleHome
Text="Creative Commons BY-NC-SA 3.0"

[AuthorName]
Meter=STRING
MeterStyle=StyleName | StyleNameFirstSub
Text="Author"

[AuthorText]
Meter=STRING
MeterStyle=StyleHome
Text="Kaelri"

;-----------------------

[ContactName]
Meter=STRING
MeterStyle=StyleName
Text="Contact"

[ContactText]
Meter=STRING
MeterStyle=StyleHome | StyleHomeLink
Text="Email"
LeftMouseUpAction=!Execute ["mailto:Kaelri@gmail.com"]
ToolTipTitle=Kaelri@gmail.com
ToolTipText=Email address.

[ContactText2]
Meter=STRING
MeterStyle=StyleHome | StyleHomeSub | StyleHomeLink
Text="Google+"
LeftMouseUpAction=!Execute ["https://plus.google.com/105475850290146211472/"]
ToolTipTitle=Michael Engard
ToolTipText=Google+ profile.

[ContactText3]
Meter=STRING
MeterStyle=StyleHome | StyleHomeSub | StyleHomeLink
Text="Twitter"
LeftMouseUpAction=!Execute ["http://twitter.com/Kaelri"]
ToolTipTitle=@Kaelri
ToolTipText=Twitter account.

;-----------------------

[WebsiteName]
Meter=STRING
MeterStyle=StyleName
Text="Website"

[WebsiteText]
Meter=STRING
MeterStyle=StyleText
Text="Home"
LeftMouseUpAction=!Execute ["http://enigma.kaelri.com"]

[WebsiteCaption]
Meter=STRING
MeterStyle=StyleHome | StyleHomeSub | StyleHomeCaption
Text="Design, history and features."

[WebsiteText2]
Meter=STRING
MeterStyle=StyleText | StyleTextSub
Text="Downloads"
LeftMouseUpAction=!Execute ["http://enigma.kaelri.com/index.php?p=downloads"]

[WebsiteCaption2]
Meter=STRING
MeterStyle=StyleHome | StyleHomeSub | StyleHomeCaption
Text="Complementary skins and addons."

[WebsiteText3]
Meter=STRING
MeterStyle=StyleText | StyleTextSub
Text="F.A.Q."
LeftMouseUpAction=!Execute ["http://enigma.kaelri.com/index.php?p=faq"]

[WebsiteCaption3]
Meter=STRING
MeterStyle=StyleHome | StyleHomeSub | StyleHomeCaption
Text="Common questions and issues."

[WebsiteText4]
Meter=STRING
MeterStyle=StyleText | StyleTextSub
Text="Support"
LeftMouseUpAction=!Execute ["http://enigma.kaelri.com/index.php?p=support"]

[WebsiteCaption4]
Meter=STRING
MeterStyle=StyleHome | StyleHomeSub | StyleHomeCaption
Text="Tech support and development threads."

[WebsiteText5]
Meter=STRING
MeterStyle=StyleText | StyleTextSub
Text="Legal"
LeftMouseUpAction=!Execute ["http://enigma.kaelri.com/index.php?p=legal"]

[WebsiteCaption5]
Meter=STRING
MeterStyle=StyleHome | StyleHomeSub | StyleHomeCaption
Text="Credits and legal information."

;-----------------------

[ChangelogName]
Meter=STRING
MeterStyle=StyleName
Text="Changelog"

[ChangelogText]
Meter=STRING
MeterStyle=StyleText
Text="View..."
LeftMouseUpAction=!Execute ["#SKINSPATH#Enigma\About.txt"]

;-----------------------

[NotesName]
Meter=STRING
MeterStyle=StyleName
Text="Notes"

[NotesText1]
Meter=STRING
MeterStyle=StyleHome
Text=This suite would not exist without the

[NotesText2]
Meter=STRING
MeterStyle=StyleHome | StyleHomeSub
Text=support and contributions of members

[NotesText3]
Meter=STRING
MeterStyle=StyleHome | StyleHomeSub
Text=of the community and the Rainmeter

[NotesText4]
Meter=STRING
MeterStyle=StyleHome | StyleHomeSub
Text=development team.

[NotesText5]
Meter=STRING
MeterStyle=StyleHome | StyleHomeSub
Text=

[NotesText6]
Meter=STRING
MeterStyle=StyleHome | StyleHomeSub
Text=Thank you for your hard work and your

[NotesText7]
Meter=STRING
MeterStyle=StyleHome | StyleHomeSub
Text=continuing belief in the Rainmeter

[NotesText8]
Meter=STRING
MeterStyle=StyleHome | StyleHomeSub
Text=project.

;----------------------------------------------
; STATUS

[MeasureVersion]
Measure=Plugin
Plugin=Plugins\WebParser.dll
Url=http://enigma.kaelri.com/version.txt
RegExp=(?siU)<version>(.*)</version>
UpdateRate=3600
StringIndex=1
FinishAction=!EnableMeasure "MeasureCheck"

[MeasureCheck]
Measure=CALC
Formula=10*(MeasureVersion-3.1)
IfAboveValue=0
IfAboveAction=!Execute [!SetOption "Update" "MeterStyle" "StyleUpdateYes"][!Redraw]
IfEqualValue=0
IfEqualAction=!Execute [!SetOption "Update" "MeterStyle" "StyleUpdateNo"][!Redraw]
IfBelowValue=0
IfBelowAction=!Execute [!SetOption "Update" "MeterStyle" "StyleUpdateBeta"][!Redraw]
Disabled=1

;-----------------------

[StyleUpdateConnecting]
Text="Connecting to enigma.kaelri.com..."
TooltipTitle="Trying to Connect"
TooltipText="If this message is not changing, there may be a problem with your Internet connection. Rainmeter may also have been blocked by a firewall application. Refresh this config when the issue has been resolved."
FontColor=255,255,255

[StyleUpdateNo]
Text="Your version of Enigma is up to date."
FontColor=255,255,255,160

[StyleUpdateYes]
Text="Upgrade to Enigma [MeasureVersion]"
FontColor=128,192,255,217
StringStyle=BOLD
LeftMouseUpAction=!Execute ["http://enigma.kaelri.com/files/Enigma.rmskin"]
TooltipTitle="Upgrade to Enigma [MeasureVersion]"
TooltipText="An update is available! Click here to download the latest Enigma installer in your browser."
TooltipWidth=300

[StyleUpdateBeta]
Text="Thanks for helping us test Enigma #EnigmaVersion#!"
FontColor=255,255,255,160

;-----------------------



[UpdateConnecting]
Meter=STRING
X=10
Y=(#PanelHeight#-23)
FontFace=Trebuchet MS
FontSize=7
AntiAlias=1

[Update]
Meter=STRING
MeterStyle=StyleUpdateConnecting
X=10
Y=(#PanelHeight#-23)
FontFace=Trebuchet MS
FontSize=7
AntiAlias=1
TooltipWidth=300