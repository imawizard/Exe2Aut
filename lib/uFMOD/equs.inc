; STRUCTS.INC
; -----------
; uFMOD public source code release.

; Sample type - contains info on sample
uF_SAMP__length   EQU 0  ; sample length
uF_SAMP_loopstart EQU 4  ; loop start
uF_SAMP_looplen   EQU 8  ; loop length
uF_SAMP_defvol    EQU 12 ; default volume
uF_SAMP_finetune  EQU 13 ; finetune value from -128 to 127
uF_SAMP_bytes     EQU 14 ; type [b 0-1] : 0 - no loop
	                 ;                1 - forward loop
	                 ;                2 - bidirectional loop (aka ping-pong)
	                 ;      [b 4]   : 0 - 8-bit sample data
	                 ;                1 - 16-bit sample data
uF_SAMP_defpan    EQU 15 ; default pan value from 0 to 255
uF_SAMP_relative  EQU 16 ; relative note (signed value)
uF_SAMP_Resved    EQU 17 ; reserved, known values: 00h - regular delta packed sample data
	                ;                         ADh - ModPlug 4-bit ADPCM packed sample data
uF_SAMP_loopmode  EQU 18
uF_SAMP__align    EQU 19
uF_SAMP_buff      EQU 20 ; sound data
uF_SAMP_size      EQU 22

; Channel type - contains information on a mixing channel
FSOUND_CHANNEL_actualvolume     EQU 0  ; volume
FSOUND_CHANNEL_actualpan        EQU 4  ; panning value
FSOUND_CHANNEL_fsampleoffset    EQU 8  ; sample offset (sample starts playing from here)
FSOUND_CHANNEL_leftvolume       EQU 12 ; adjusted volume for left channel (panning involved)
FSOUND_CHANNEL_rightvolume      EQU 16 ; adjusted volume for right channel (panning involved)
FSOUND_CHANNEL_mixpos           EQU 20 ; high part of 32:32 fractional position in sample
FSOUND_CHANNEL_speedlo          EQU 24 ; playback rate - low part fractional
FSOUND_CHANNEL_speedhi          EQU 28 ; playback rate - high part fractional
FSOUND_CHANNEL_ramp_LR_target   EQU 32
FSOUND_CHANNEL_ramp_leftspeed   EQU 36
FSOUND_CHANNEL_ramp_rightspeed  EQU 40
FSOUND_CHANNEL_fsptr            EQU 44 ; pointer to FSOUND_SAMPLE currently playing sample
FSOUND_CHANNEL_mixposlo         EQU 48 ; low part of 32:32 fractional position in sample
FSOUND_CHANNEL_ramp_leftvolume  EQU 52
FSOUND_CHANNEL_ramp_rightvolume EQU 56
FSOUND_CHANNEL_ramp_count       EQU 60
FSOUND_CHANNEL_speeddir         EQU 62 ; playback direction - forwards or backwards
FSOUND_CHANNEL_size             EQU 64

; Single note type - contains info on 1 note in a pattern
uF_NOTE_unote   EQU 0 ; note to play at (0-97) 97=keyoff
uF_NOTE_number  EQU 1 ; sample being played (0-128)
uF_NOTE_uvolume EQU 2 ; volume column value (0-64)  255=no volume
uF_NOTE_effect  EQU 3 ; effect number (0-1Ah)
uF_NOTE_eparam  EQU 4 ; effect parameter (0-255)
uF_NOTE_size    EQU 5

uF_STATS_L_vol   EQU 0 ; L channel RMS volume
uF_STATS_R_vol   EQU 2 ; R channel RMS volume
uF_STATS_s_row   EQU 4
uF_STATS_s_order EQU 6
uF_STATS_size    EQU 8

; Pattern data type
uF_PAT_rows        EQU 0
uF_PAT_patternsize EQU 2
uF_PAT_data        EQU 4 ; pointer to FMUSIC_NOTE
uF_PAT_size        EQU 8

; Multi sample extended instrument
uF_INST_sample       EQU 0   ; 16 pointers to FSOUND_SAMPLE per instrument
uF_INST_keymap       EQU 64  ; sample keymap assignments
uF_INST_VOLPoints    EQU 160 ; volume envelope points
uF_INST_PANPoints    EQU 208 ; panning envelope points
uF_INST_VOLnumpoints EQU 256 ; number of volume envelope points
uF_INST_PANnumpoints EQU 257 ; number of panning envelope points
uF_INST_VOLsustain   EQU 258 ; volume sustain point
uF_INST_VOLLoopStart EQU 259 ; volume envelope loop start
uF_INST_VOLLoopEnd   EQU 260 ; volume envelope loop end
uF_INST_PANsustain   EQU 261 ; panning sustain point
uF_INST_PANLoopStart EQU 262 ; panning envelope loop start
uF_INST_PANLoopEnd   EQU 263 ; panning envelope loop end
uF_INST_VOLtype      EQU 264 ; type of envelope,bit 0:On 1:Sustain 2:Loop
uF_INST_PANtype      EQU 265 ; type of envelope,bit 0:On 1:Sustain 2:Loop
uF_INST_VIBtype      EQU 266 ; instrument vibrato type
uF_INST_VIBsweep     EQU 267 ; time it takes for vibrato to fully kick in
uF_INST_iVIBdepth    EQU 268 ; depth of vibrato
uF_INST_VIBrate      EQU 269 ; rate of vibrato
uF_INST_VOLfade      EQU 270 ; fade out value
uF_INST_size         EQU 272

; Channel type - contains information on a mod channel
uF_CHAN_note          EQU 0   ; last note set in channel
uF_CHAN_samp          EQU 1   ; last sample set in channel
uF_CHAN_notectrl      EQU 2   ; flags for DoFlags proc
uF_CHAN_inst          EQU 3   ; last instrument set in channel
uF_CHAN_cptr          EQU 4   ; pointer to FSOUND_CHANNEL system mixing channel
uF_CHAN_freq          EQU 8   ; current mod frequency period for this channel
uF_CHAN_volume        EQU 12  ; current mod volume for this channel
uF_CHAN_voldelta      EQU 16  ; delta for volume commands: tremolo/tremor, etc
uF_CHAN_freqdelta     EQU 20  ; delta for frequency commands: vibrato/arpeggio, etc
uF_CHAN_pan           EQU 24  ; current mod pan for this channel
uF_CHAN_envvoltick    EQU 28  ; tick counter for envelope position
uF_CHAN_envvolpos     EQU 32  ; envelope position
uF_CHAN_envvoldelta   EQU 36  ; delta step between points
uF_CHAN_envpantick    EQU 40  ; tick counter for envelope position
uF_CHAN_envpanpos     EQU 44  ; envelope position
uF_CHAN_envpandelta   EQU 48  ; delta step between points
uF_CHAN_ivibsweeppos  EQU 52  ; instrument vibrato sweep position
uF_CHAN_ivibpos       EQU 56  ; instrument vibrato position
uF_CHAN_keyoff        EQU 60  ; flag whether keyoff has been hit or not
uF_CHAN_envvolstopped EQU 62  ; flag to say whether envelope has finished or not
uF_CHAN_envpanstopped EQU 63  ; flag to say whether envelope has finished or not
uF_CHAN_envvolfrac    EQU 64  ; fractional interpolated envelope volume
uF_CHAN_envvol        EQU 68  ; final interpolated envelope volume
uF_CHAN_fadeoutvol    EQU 72  ; volume fade out
uF_CHAN_envpanfrac    EQU 76  ; fractional interpolated envelope pan
uF_CHAN_envpan        EQU 80  ; final interpolated envelope pan
uF_CHAN_period        EQU 84  ; last period set in channel
uF_CHAN_sampleoffset  EQU 88  ; sample offset for this channel in SAMPLES
uF_CHAN_portatarget   EQU 92  ; note to porta to
uF_CHAN_patloopno     EQU 96  ; pattern loop variables for effect E6x
uF_CHAN_patlooprow    EQU 100
uF_CHAN_realnote      EQU 104 ; last realnote set in channel
uF_CHAN_recenteffect  EQU 105 ; previous row's effect. used to correct tremolo volume
uF_CHAN_portaupdown   EQU 106 ; last porta up/down value
;uF_CHAN_unused       EQU 107
uF_CHAN_xtraportadown EQU 108 ; last porta down value
uF_CHAN_xtraportaup   EQU 109 ; last porta up value
uF_CHAN_volslide      EQU 110 ; last volume slide value
uF_CHAN_panslide      EQU 111 ; pan slide parameter
uF_CHAN_retrigx       EQU 112 ; last retrig volume slide used
uF_CHAN_retrigy       EQU 113 ; last retrig tick count used
uF_CHAN_portaspeed    EQU 114 ; porta speed
uF_CHAN_vibpos        EQU 115 ; vibrato position
uF_CHAN_vibspeed      EQU 116 ; vibrato speed
uF_CHAN_vibdepth      EQU 117 ; vibrato depth
uF_CHAN_tremolopos    EQU 118 ; tremolo position
uF_CHAN_tremolospeed  EQU 119 ; tremolo speed
uF_CHAN_tremolodepth  EQU 120 ; tremolo depth
uF_CHAN_tremorpos     EQU 121 ; tremor position
uF_CHAN_tremoron      EQU 122 ; remembered parameters for tremor
uF_CHAN_tremoroff     EQU 123 ; remembered parameters for tremor
uF_CHAN_wavecontrol   EQU 124 ; waveform type for vibrato and tremolo (4bits each)
uF_CHAN_finevslup     EQU 125 ; parameter for fine volume slide down
uF_CHAN_fineportaup   EQU 126 ; parameter for fine porta slide up
uF_CHAN_fineportadown EQU 127 ; parameter for fine porta slide down
uF_CHAN_size          EQU 128

; Song type - contains info on song
uF_MOD_pattern              EQU 0  ; pointer to FMUSIC_PATTERN array for this song
uF_MOD_instrument           EQU 4  ; pointer to FMUSIC_INSTRUMENT array for this song
uF_MOD_mixer_samplesleft    EQU 8
uF_MOD_globalvolume         EQU 12 ; global mod volume
uF_MOD_tick                 EQU 16 ; current mod tick
uF_MOD_speed                EQU 20 ; speed of song in ticks per row
uF_MOD_order                EQU 24 ; current song order position
uF_MOD_row                  EQU 28 ; current row in pattern
uF_MOD_patterndelay         EQU 32 ; pattern delay counter
uF_MOD_nextorder            EQU 36 ; current song order position
uF_MOD_nextrow              EQU 40 ; current row in pattern
uF_MOD_unused1              EQU 44
uF_MOD_numchannels          EQU 48 ; number of channels
uF_MOD_Channels             EQU 52 ; channel pool
uF_MOD_uFMOD_Ch             EQU 56 ; channel array for this song
uF_MOD_mixer_samplespertick EQU 60
uF_MOD_numorders            EQU 64 ; number of orders (song length)
uF_MOD_restart              EQU 66 ; restart position
uF_MOD_numchannels_xm       EQU 68
uF_MOD_globalvsl            EQU 69 ; global mod volume
uF_MOD_numpatternsmem       EQU 70 ; number of allocated patterns
uF_MOD_numinsts             EQU 72 ; number of instruments
uF_MOD_flags                EQU 74 ; flags such as linear frequency, format specific quirks, etc
uF_MOD_defaultspeed         EQU 76
uF_MOD_defaultbpm           EQU 78
uF_MOD_orderlist            EQU 80 ; pattern playing order list
uF_MOD_size                 EQU 336

XM_MEMORY                 EQU 1
XM_FILE                   EQU 2
XM_NOLOOP                 EQU 8
XM_SUSPENDED              EQU 16
FMUSIC_ENVELOPE_SUSTAIN   EQU 2
FMUSIC_ENVELOPE_LOOP      EQU 4
FMUSIC_FREQ               EQU 1
FMUSIC_VOLUME             EQU 2
FMUSIC_PAN                EQU 4
FMUSIC_TRIGGER            EQU 8
FMUSIC_VOLUME_OR_FREQ     EQU 3
FMUSIC_VOLUME_OR_PAN      EQU 6
FMUSIC_VOL_OR_FREQ_OR_TR  EQU 11
FMUSIC_FREQ_OR_TRIGGER    EQU 9
NOT_FMUSIC_TRIGGER        EQU 0F7h
NOT_FMUSIC_TRIGGER_OR_FRQ EQU 0F6h

; FMUSIC_XMCOMMANDS enum:
FMUSIC_XM_PORTAUP         EQU 1
FMUSIC_XM_PORTADOWN       EQU 2
FMUSIC_XM_PORTATO         EQU 3
FMUSIC_XM_VIBRATO         EQU 4
FMUSIC_XM_PORTATOVOLSLIDE EQU 5
FMUSIC_XM_VIBRATOVOLSLIDE EQU 6
FMUSIC_XM_TREMOLO         EQU 7
FMUSIC_XM_SETPANPOSITION  EQU 8
FMUSIC_XM_SETSAMPLEOFFSET EQU 9
FMUSIC_XM_VOLUMESLIDE     EQU 10
FMUSIC_XM_PATTERNJUMP     EQU 11
FMUSIC_XM_SETVOLUME       EQU 12
FMUSIC_XM_PATTERNBREAK    EQU 13
FMUSIC_XM_SPECIAL         EQU 14
FMUSIC_XM_SETSPEED        EQU 15
FMUSIC_XM_SETGLOBALVOLUME EQU 16
FMUSIC_XM_GLOBALVOLSLIDE  EQU 17
FMUSIC_XM_KEYOFF          EQU 20
FMUSIC_XM_PANSLIDE        EQU 25
FMUSIC_XM_MULTIRETRIG     EQU 27
FMUSIC_XM_TREMOR          EQU 29
FMUSIC_XM_EXTRAFINEPORTA  EQU 33

; FMUSIC_XMCOMMANDSSPECIAL enum:
FMUSIC_XM_FINEPORTAUP      EQU 1
FMUSIC_XM_FINEPORTADOWN    EQU 2
FMUSIC_XM_SETGLISSANDO     EQU 3
FMUSIC_XM_SETVIBRATOWAVE   EQU 4
FMUSIC_XM_SETFINETUNE      EQU 5
FMUSIC_XM_PATTERNLOOP      EQU 6
FMUSIC_XM_SETTREMOLOWAVE   EQU 7
FMUSIC_XM_SETPANPOSITION16 EQU 8
FMUSIC_XM_RETRIG           EQU 9
FMUSIC_XM_NOTECUT          EQU 12
FMUSIC_XM_NOTEDELAY        EQU 13
FMUSIC_XM_PATTERNDELAY     EQU 14

FSOUND_Block      EQU 10
fragmentsmask     EQU 0Fh
FSOUND_BlockSize  EQU 1024 ; 1 << FSOUND_Block
totalblocks       EQU (fragmentsmask+1)
FSOUND_BufferSize EQU (FSOUND_BlockSize)*totalblocks
