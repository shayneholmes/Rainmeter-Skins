[variables]
; Player (= AIMP, CAD, iTunes, MediaMonkey, Winamp, WMP, Spotify, WLM)
; see http://docs.rainmeter.net/manual/plugins/nowplaying/
Player=CAD

[mZero]
Measure=Calc
Formula=0
UpdateDivider=-1

[mOne]
Measure=Calc
Formula=1
UpdateDivider=-1

[mRunOnStart]
Measure=Calc
Formula=1
IfEqualValue=1
IfEqualAction=[!CommandMeasure MeasureAhkWindowMessaging "SendMessage 16687 2 0"][!DisableMeasure mRunOnStart]

[MeasureAhkWindowMessaging]
Measure=Plugin
Plugin=WindowMessagePlugin
WindowClass=AutoHotkey
UpdateDivider=-1

[mPlayer]
Measure=Plugin
Plugin=NowPlaying.dll
PlayerName=#player#
PlayerType=TITLE
PlayerPath=
TrackChangeAction=[!UpdateMeasureGroup SporadicUpdate][!UpdateMeterGroup SporadicUpdate][!CommandMeasure MeasureAhkWindowMessaging "SendMessage 16687 2 0"][!Redraw]

[mArtist]
Measure=Plugin
Plugin=NowPlaying.dll
PlayerName=[mPlayer]
PlayerType=ARTIST
Group=SporadicUpdate
UpdateDivider=-1

[mAlbum]
Measure=Plugin
Plugin=NowPlaying.dll
PlayerName=[mPlayer]
PlayerType=ALBUM
; Substitute="":"Unknown"
Group=SporadicUpdate
UpdateDivider=-1

[mPosition]
Measure=Plugin
Plugin=NowPlaying.dll
PlayerName=[mPlayer]
PlayerType=POSITION

[mDuration]
Measure=Plugin
Plugin=NowPlaying.dll
PlayerName=[mPlayer]
PlayerType=DURATION
Group=SporadicUpdate
UpdateDivider=-1

[mRating]
Measure=Plugin
Plugin=NowPlaying.dll
PlayerName=[mPlayer]
PlayerType=RATING
Substitute="0":"","1":" *","2":" **","3":" ***","4":" ****","5":" *****"
Group=SporadicUpdate
UpdateDivider=-1

[mPlayCount]
Measure=Calc
Formula=#NowPlayingPlayCount#
DynamicVariables=1
UpdateDivider=-1
OnChangeAction=[!UpdateMeasure mPlayCountPercent]

[mSkipCount]
Measure=Calc
Formula=#NowPlayingSkipCount#
DynamicVariables=1
UpdateDivider=-1
OnChangeAction=[!UpdateMeasure mSkipCountPercent]

;From Muziko
[mProgress]
Measure=Script
ScriptFile=Progress.lua

