[mZero]
Measure=Calc
Formula=0
UpdateDivider=-1

[mOne]
Measure=Calc
Formula=1
UpdateDivider=-1

[mPlayer]
Measure=Plugin
Plugin=NowPlaying.dll
PlayerName=#player#
PlayerType=TITLE
PlayerPath=
; Substitute="":"Unknown"
TrackChangeAction=[!UpdateMeasureGroup UpdateOnTrackChange]

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

[mProgress]
Measure=Plugin
Plugin=NowPlaying.dll
PlayerName=[mPlayer]
PlayerType=PROGRESS

[mStateButton]
Measure=Plugin
Plugin=NowPlaying.dll
PlayerName=[mPlayer]
PlayerType=STATE

[mProgressInterpolated]
Measure=Script
ScriptFile=#SCRIPT#SmoothProgress.lua
