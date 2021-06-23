;WUDSN IDE space invaders
;23/01/2020 got a bit annoyed with all the hassles
;involved with using hardware scrolling - not the hardware scrolling
;in itself as it is easy enough to do, but let's just say
;there are things about that approach that are a bit annoying
;and so I've decided to have a play at using software sprites
;using graphics 14 (antic knows this by bits 2 and 3, e.g the value 12)
;page flipping may be needed, but for now let's just see what we can do
;without it. For example, at present we're telling it to draw
;1 invader with up to 8 bombs per deferred vbi call
;so we won't have to mess about with multiplexed missiles.
;We also will know when an invader has reached the edge of the screen
;without messing about with a wasted edge boundary player stripe.
;Actually, this could be achieved in the hardware scrolling version
;by maintaining an array of invader positions like we're doing here
;and we would simply abandon the usual coarse scrolling
;and just redraw the invaders in their new character positions.
;It wouldn't use up too many compute cycles.
;Anyway, I'm more interested in this hires mode right now.
;It does feature multiplexed players, but these will be restricted to the
;same y positions, so it's obviously less of a hassle.
;Stratosleds are going to make use of the last 3 available hardware missiles
;and these missiles will be instructed to home in on the player's
;horizontal position. Sossplimfa will paralyse the player if the player
;shoots them - they won't be hurt, but the player will obviously be endangered
;and this is quite right because Olland loves sossplimfa.
;It was decided to multiplex 3 players because a straosled will need 24 pixels of width.
;Sossplimfa will have some nice animation going on.
;Needless to say, the main program is going to have to animate the multiplexed
;players because the poor ol' deferred vbi is taking on a fair bit already.   
;I have wondered about increasing the difficulty as each wave progresses
;but frankly I think the best thijng to do is to let the player
;select the difficulty from the title screen. In any case, all that would need to be done
;would be to a) check if the number of bombs was 8, if not increase.
;b) check if the number of flybys is 8, of not increase.
;c) check if g_dflag is 7, if not increase.
			org 	16384 ;Start of executable program
		
			m_ldelay	= 	1792
			m_hdelay	= 	1793
			g_sflag		= 	1794
			vbi_ppos	= 	1795
			dli_index 	= 	1796
			m_invx		=	1797
			m_invy		=	1798
			vbi_plmissy	= 	1799
			vbi_plmissx	= 	1800
			m_temp		= 	1801
			m_byte1		= 	1802
			m_byte2		= 	1803
			m_byte3		= 	1804
			temp3		=	1805
			temp4		= 	1806
			temp5		= 	1807
			temp6		=	1808
			m_an1fr		= 	1809
			v_temp1		=	1810
			v_temp2		=	1811
			m_an2fr		= 	1812
			v_temp3		=	1813
			m_an3fr		= 	1814
			bindex		=	1815
			v_temp4		=	1816
			m_invcnt	= 	1817
			vbi_invi	=	1818
			m_frame		=	1819
			v_temp5		=	1820
			dropfrom	=	1821
			m_bcnt		=	1822
			m_sc1		=	1823
			m_sc2		=	1824
			m_sc3		=	1825
			m_sc4		=	1826
			m_sc5		=	1827
			m_sc6		=	1828
			m_sc7		=	1829
			m_vertmax	=	1830
			v_vert		=	1831
			v_expdel	=	1832
			v_exppos	=	1833
			v_expy		=	1834
			g_sflag2	=	1835
			m_bswaitlo	=	1836
			m_bswaithi	=	1837
			m_poplo		=	1838
			m_pophi		=	1839
			dli_temp1	=	1840
			dli_temp2	=	1841
			oldmtype	=	1842
			splimfaf	=	1843
			splimfafi	=	1844	
			paralysis	=	1845
			v_tbdel		=	1846
			v_tbpos		=	1847
			v_tbstage	=	1848
			v_tbcolour	=	1849
			v_tbhoriz	=	1850
			v_tbindex	=	1851
			g_dflag		= 	1852
			m_sinput1	=	1853
			m_sinput2	=	1854
			m_samnt		=	1855
			m_sindex	=	1856
			m_digit1	=	1857
			m_digit2	=	1858
			m_lives		=	1859
			oldinvtype	=	1860
			go_colour	=	1861
			godli_index	=	1862
			v_temp6		=	1863
			dli_flag	=	1864
			gthoriz		=	1865
			multicnt	=	1866
			govert		=	1867
			invtone		=	1868
			misstone	=	1869
			missdel		=	1870
			invvol		=	1871
			lseldel		=	1872
			sellives	=	1873
			bsvol		=	1874
			bstone		=	1875
			lsel		=	1876
			tbtone		=	1877
			tbvol		=	1878
			missdec		=	1879
			wmissdec	=	1880
			v_temp7		=	1881
			v_temp8		=	1882
			v_temp9		=	1883
			v_temp10	=	1884
			snosspstage	=	1885
			snossptone	=	1886
			;missile base's dli based hardware x position
			m_mbhx		=	2323
			;bonus points ship hardware x position
			m_bpshx		=	2314
			;multiplex info
			m_mx		=	2314
			m_mcol1		=	2324
			m_mcol2		=	2334
			m_mcol3		=	2344
			m_mtype		=	2354
			m_mspeed	=	2364
			m_mwspeed	=	2374
			m_mslum		=	2384
			m_my		=	2394
			g_sossplimf	=	2404
			m_exppos	=	2414
			mb_exppos	=	2423
			mb_expdel	=	2335
			mb_expcnt	=	2336
			mb_shdel	=	2337
			;bomb + stratosled info
			g_bombx		= 	4096	;8 bytes
			g_bomby		=	4104	;8 bytes
			s_bombx		=	4128	;3 bytes
			s_bomby		=	4131	;3 bytes
			s_bombp		=	4134	;3 bytes
			s_bombhd	=	4137	;3 bytes
			g_mindex	=	4141	;192 bytes
			;look ups
			g_sclo		= 	36864	;192 bytes
			g_schi		=	37056	;192 bytes
			m_linvx		=	37248	;56 bytes
			m_linvy		= 	37304	;56 bytes
			m_linvtype	=	37360	;56 bytes
			m_linvby	=	37416	;56 bytes
			m_linvc		=	37472	;56 bytes
			m_linvr		=	37528	;56 bytes
			g_xchar		=	37584	;160 bytes
			g_pixel		=	37744	;160 bytes
			g_framelo	=	37904	;12 bytes
			g_framehi	=	37916	;12 bytes
			g_pixframe	=	37928	;160 bytes
			g_pixbits	=	38088	;160 bytes
			;copies of invader variables
			c_linvx		=	38248	;56 bytes
			c_linvy		=	38304	;56 bytes
			c_linvtype	=	38360	;56 bytes
			c_linvby	=	38416	;56 bytes
			c_linvc		=	38472	;56 bytes
			c_linvr		=	38528	;56 bytes
			;column / row info
			g_colrow	=	38584	;7 bytes
			;status line & character set (not many characters used)
			scoreline	=	38920	;20 bytes
			;other
			;DO NOT USE zero page addresses 208 & 209 - they are EVIL
			m_zerop1	=	206
			m_zerop2	=	207
			m_zerop3	=	204
			m_zerop4	=	205
			m_zerop5	=	82
			m_zerop6	=	83
			playery		=	31952
			;g_sflag information
			;bit 0 = invader direction
			;bit 1 = is player shooting missile
			;bit 2 = invader boundary hit
			;bit 3 = invaders descend
			;bit 4 = invaders landed (or game over)
			;bit 5 = snosspkronk has been shot
			;bit 6 = all invaders shot (new wave needed)
			;bit 7 = snosspkronk v formation in progress
			;g_sflag2 information
			;bit 0 = invader explosion
			;bit 1 = bonus points ship active
			;bit 2 = multiplex sprite exploding
			;bit 3 = paralysis caused by shot sossplimfa
			;bit 4 = timebomb activated - only 1 can happen at a time
			;bit 5 = missile base exploding
			;bit 6 = missile base shielded
			;bit 7 = clearing screen
			;dli_flag information
			;bit 0 = on title screen
			;bit 1 = in main game
			;bit 2 = in game over screen
start 		ldx		#0
			lda		#12
			sta		s_bombp,X
			inx
			lda		#48
			sta		s_bombp,X
			inx
			lda		#192
			sta		s_bombp,X
			lda		#3
			sta		sellives
			lda		#1
			sta		m_bcnt
			lda		#1
			sta		multicnt
			lda		#4
			sta		m_vertmax
			lda		#1
			sta		missdec
			;populate screen y lookups
			lda		#0
			sta		m_zerop1
			lda		#128
			sta		m_zerop2
			ldx		#0
fill1		lda		m_zerop1
			sta		g_sclo,X
			lda		m_zerop2
			sta		g_schi,X
			lda		m_zerop1
			clc
			adc		#20
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			inx
			cpx		#192
			bne		fill1
			;populate screen x character positions
			ldx		#0
			ldy		#0
			sty		temp5
			lda		#128
			sta		temp6
fill2		txa
			lsr
			lsr
			lsr
			clc
			sta		g_xchar,X
			tya
			sta		g_pixel,X
			lda		temp5
			sta		g_pixframe,X
			clc
			adc		#16
			sta		temp5		
			lda		temp6
			sta		g_pixbits,X
			clc
			lsr
			sta		temp6
			inx
			iny
			cpy		#8
			bne		br1
			ldy		#0
			sty		temp5
			lda		#128
			sta		temp6
br1			cpx		#160
			bne		fill2
			;compute frame lo and hi lookups
			lda		#0
			sta		m_zerop1
			lda		#112
			sta		m_zerop2
			ldx		#0
fill3		lda		m_zerop1
			sta		g_framelo,X
			lda		m_zerop2
			sta		g_framehi,X
			lda		m_zerop1
			clc
			adc		#128
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			inx
			cpx		#12
			bne		fill3		
			lda		#0
			sta		m_zerop3
			lda		#112
			sta		m_zerop4
			;copy digits into character set and so forth
			ldx		#0
fill7		lda		57472,X
			sta		39040,X
			inx
			cpx		#80
			bne		fill7
			ldx		#0
fill8		lda		57608,X
			sta		39176,X
			inx
			cpx		#208	
			bne		fill8
			ldx		#0
fill9		lda		2888,X
			sta		39120,X
			inx
			cpx		#8
			bne		fill9	
			;store frames
			lda		#0
			sta		temp4
storelp		jsr		store
			lda		temp4
			clc
			adc		#8
			sta		temp4
			lda		temp4
			cmp		#128
			bne		storelp
			ldx		#0
			;get mulitplex sprite indices
fill11		txa
			lsr
			lsr
			lsr
			lsr
			sta		g_mindex,X		
			inx
			cpx		#192
			bne		fill11
			lda		#0
			sta		g_dflag
			ldx		#0
gtloop		lda		28416,X
			clc
			adc		#64
			sta		28416,X
			inx
			cpx		#255
			bne		gtloop
			;init vbi
			jsr		gametitle
			lda		#7
			ldx		#32
			ldy		#0
			jsr		58460
loop		jsr		refresh
			jsr		popmulti
			jmp		loop

initgamescr	lda		#128
			sta		g_sflag2
			lda		#64
			sta		54286
			lda		#235
			sta		invtone
			lda		#20
			sta		bstone
			lda		sellives
			sta		m_lives
			lda		#1
			sta		missdec
			;hit a strange condition
			;while play testing
			;basically, the missile base's mtype
			;had switched to zero - happened just before a new wave
			lda		#4
			sta		2363
			lda		#0
      		sta 	559
	  		lda		#0
			sta		560
			lda		#6
			sta		561
			lda		#3
			sta		53277
			lda		#15
			sta		711
			sta		708
			lda		#152
			sta		756
			lda		#120
			sta		54279
			sta		vbi_ppos
			jsr		clearspr
			lda		#1
			sta		g_sflag
			lda		#0
			sta		bindex
			sta		m_an1fr
			lda		#3
			sta		m_an2fr
			lda		#6
			sta		m_an3fr
			lda		#40
			sta		2333
			;note - 16 in 623 gives playfield priority over players
			;and gives the same colour to the missiles
			lda		#17
			sta		623
			lda		#0
			sta		dli_index
			sta		godli_index
			sta		53278
			lda		#15
			sta		706
			ldx		#10
			lda		#90
			sta		scoreline,X
			inx
			inx
			lda		m_lives
			clc
			adc		#80
			sta		scoreline,X
			lda		#62
			sta		559
			jsr		showscore
			lda		#56
			;lda		#8
			sta		m_invcnt	
			lda		#76
			;lda		#16
			sta		dropfrom
			jsr		initinvarr
			ldx		#0
			lda		#0
fill10		sta		g_bombx,X
			sta		g_bomby,X
			inx
			cpx		#8
			bne		fill10
			ldx		#0
			lda		#255
fill12		sta		g_colrow,X
			inx
			cpx		#7
			bne		fill12
			lda		#2
			sta		dli_flag
			lda		#62
			sta		559	
			lda		#207
			sta		invvol
			sta		53761
			lda		invtone
			sta		53760
			lda		#0
			sta		53768
			jsr		clrscr
			;init dli
			lda		#0
			sta		512
			lda 	#8
			sta		513
			lda		#192
			sta		54286
			rts

initinvarr	lda		#0
			sta		temp6
			sta		temp3
			lda		#16
			sta		temp5
			lda		#1
			sta		m_byte1
			jsr		popinvarr
			lda		#26
			sta		temp5
			lda		#1
			sta		temp3
			jsr		popinvarr
			lda		#36
			sta		temp5
			lda		#2
			sta		temp3
			jsr		popinvarr
			lda		#46
			sta		temp5
			lda		#2
			sta		m_byte1
			jsr		popinvarr
			lda		#3
			sta		temp3
			lda		#56
			sta		temp5
			lda		#4
			sta		temp3
			jsr		popinvarr
			lda		#66
			sta		temp5
			lda		#5
			sta		temp3
			jsr		popinvarr
			lda		#76
			sta		temp5
			lda		#3
			sta		m_byte1
			lda		#6
			sta		temp3
			jsr		popinvarr
			rts

;clear muliplex info
clrmulti	ldx		#0
clrmultilp	lda		#0
			sta		m_mtype,X
			sta		m_mx,X
			inx
			cpx		#9
			bne		clrmultilp
			ldx		#0
clrsbslp	lda		#0
			sta		s_bombx,X
			sta		s_bomby,X
			inx
			cpx		#3
			bne		clrsbslp
			rts
			
;draw bonus points ship
drtopsp		ldx		#0
			ldy		#4
drtopsplp	lda		2976,X
			sta		31776,Y
			lda		2984,X
			sta		32032,Y	
			lda		2992,X
			sta		32288,Y
			inx
			iny
			cpx		#8
			bne		drtopsplp
			rts
			
;populate mulitplex info

popmulti	lda		dli_flag
			and		#1
			cmp		#1
			bne		contpm1
			rts
contpm1		lda		g_sflag
			and		#16
			cmp		#16
			bne		contpm2
			rts
contpm2		dec		m_poplo
			lda		m_poplo
			beq		popm1
			rts
popm1		dec		m_pophi
			lda		m_pophi
			beq		popm2
			rts
popm2		lda		#3
			sta		m_pophi
			ldx		#1
			stx		m_byte1
			lda		#20
			sta		temp4
			lda		g_sflag
			and		#128
			cmp		#128
			bne		popm3
			lda		#0
			sta		temp3
			clc
			bcc		popm4
popm3		lda		#1
			sta		temp3
popm4		lda		#0
			sta		m_byte2
			sta		temp6
			sta		temp5
			ldx		#1
mcntlp		lda		m_mtype,X
			beq		nomcnt
			inc		temp6
			inc		temp5
nomcnt		inx
			cpx		#9
			bne		mcntlp
			lda		g_sflag
			and		#128
			cmp		#128
			bne		popmlp
			lda		snosspstage
			beq		popmlp
			lda		#2
			sta		snosspstage
popmlp		ldx		m_byte1
			lda		m_mtype,X
			beq		pop1
			jmp		ignorepopm
pop1		lda		g_sflag
			and		#128
			cmp		#128
			bne		ordpop
			lda		snosspstage
			cmp		#1
			beq		ordpop1
			lda		temp5
			beq		pop2
			jmp		ignorepopm
pop2		lda		snosspstage
			beq		pop3
			cmp		#2
			bne		ordpop1
			jmp		ignorepopm
pop3		lda		#1
			sta		snosspstage
			clc
			bcc		ordpop1
ordpop		lda		temp4
			sec
			sbc		53770
			bpl		ignorepop
			lda		multicnt
			cmp		temp6
			beq		ignorepop
			clc
			bcc		ordpop1
ignorepop	jmp		ignorepopm
			;random speeds not too helpful really
ordpop1		lda		g_sflag
			and		#128
			cmp		#128
			bne		ordpop2
			ldy		temp3
			lda		2424,Y
			sta		m_mwspeed,X
			sta		m_mspeed,X
			clc
			bcc		ordpop4
ordpop2		lda		temp3
			sta		m_mwspeed,X
			sta		m_mspeed,X
			;get pseudorandom hue
ordpop4		lda		53770
			lsr
			lsr
			lsr
			lsr
			clc
			asl
			asl
			asl
			asl
			sta		m_mcol1,X
			lda		g_sflag
			and		#128
			cmp		#128
			beq		ignorestrat
			lda		53770
			sec
			sbc		53770
			bpl		ignorestrat
			lda		#1
			sta		m_mtype,X
			lda		temp4
			sta		m_my,X
			ldx		#0
			ldy		temp4
			inc		temp6
dslatlp		lda		3000,X
			sta		31774,Y
			lda		3008,X
			sta		32030,Y	
			lda		3016,X
			sta		32286,Y
			inx
			iny
			cpx		#8
			bne		dslatlp
			clc
			bcc		ignorepopm
ignorestrat	ldx		m_byte1
			lda		#2
			sta		m_mtype,X
			inc		temp6
			lda		m_mcol1,X
			clc
			adc		#10
			sta		m_mcol1,X
			lda		temp4
			sta		m_my,X
ignorepopm	lda		temp4
			clc
			adc		#16
			sta		temp4
			inc		temp3
			lda		g_sflag
			and		#128
			cmp		#128
			bne		ordspcmp
			lda		temp3
			cmp		#8
			bne		contpoplp
			lda		#0
			sta		temp3
			clc
			bcc		contpoplp
ordspcmp	lda		temp3
			cmp		#4
			bne		contpoplp
			lda		#1
			sta		temp3
contpoplp	inc		m_byte1
			lda		m_byte1
			cmp		#9
			beq		popfin
			jmp		popmlp
popfin		lda		g_sflag
			and		#128
			cmp		#128
			bne		popfin1
			lda		snosspstage
			cmp		#2
			bne		popfin1
			lda		temp5
			bne		popfin1
			lda		g_sflag
			eor		#128
			sta		g_sflag
			lda		#0
			sta		53765
			sta		53767
			sta		53768
			lda		#1
			sta		missdec
			;multiplex sprite animations
popfin1		lda		#1
			sta		m_byte1
explodelp	ldx		m_byte1
			lda		m_mtype,X
			cmp		#3
			bne		otheranim
expr4		lda		#8
			sta		temp3
			ldy		m_my,X
			lda		m_exppos,X
			tax
drawexlp	lda		2928,X
			sta		31774,Y
			sta		32030,Y
			sta		32286,Y
			inx
			iny
			dec		temp3
			lda		temp3
			bne		drawexlp
			ldx		m_byte1
			lda		m_exppos,X
			clc
			adc		#8
			sta		m_exppos,X
			cmp		#48
			bne		otheranim
			lda		#0
			sta		m_mx,X
			lda		#0
			sta		m_mtype,X
			lda		#0
			sta		53763
chkmef		lda		g_sflag2
			and		#4
			cmp		#4
			bne		otheranim
			lda		g_sflag2
			eor		#4
			sta		g_sflag2
			lda		oldmtype
			cmp		#1
			bne		otheranim
			lda		#4
			sta		m_samnt
			sta		m_byte2
			lda		#4
			sta		m_sindex
			txa
			pha
			jsr		managepts
			pla
			tax
			;now deal with sossplimfa
otheranim	lda		m_mtype,X
			cmp		#2
			bne		noanim
			ldy		m_my,X
			ldx		splimfaf
			lda		#0
			sta		temp3
drawsosslp	lda		3024,X
			sta		31774,Y
			lda		3032,X
			sta		32030,Y
			lda		3040,X
			sta		32286,Y
			inx
			iny
			inc		temp3
			lda		temp3
			cmp		#8
			bne		drawsosslp
noanim		inc		m_byte1
			lda		m_byte1
			cmp		#9
			beq		sossfr
			jmp		explodelp
			;sossplimfa frame handling
sossfr		inc		splimfafi
			ldx		splimfafi
			lda		g_sossplimf,X
			sta		splimfaf
			lda		splimfafi
			cmp		#6
			bne		expbp
			lda		#0
			sta		splimfafi
			;now deal with the bonus points ship if that has been shot
expbp		lda		m_mtype
			cmp		#3
			beq		expbp1
			jmp		pmultex
expbp1		lda		#0
			sta		m_byte1
			ldx		#0
			ldy		#4
pointslp	inc		2324
			lda		m_digit1
			clc
			adc		m_byte1
			tax
			lda		57344,X
			sta		31776,Y
			lda		m_digit2
			clc
			adc		m_byte1
			tax
			lda		57344,X
			sta		32032,Y	
			lda		#128
			clc
			adc		m_byte1
			tax
			lda		57344,X
			sta		32288,Y
			inc		m_byte1
			iny
			lda		m_byte1
			cmp		#8
			bne		pointslp
			lda		bstone
			sta		53764
			clc
			adc		#20
			sta		bstone
			cmp		#100
			bne		noincbstone
			lda		#60
			sta		bstone
noincbstone	inc		m_exppos
			lda		m_exppos
			cmp		#32
			bne		pmultex
			lda		#0
			sta		m_mx
			sta		m_mtype
			lda		#224
			sta		53764
			lda		#20
			sta		bstone
			lda		g_sflag2
			eor		#6
			sta		g_sflag2
			lda		#0
			sta		53765
			lda		#10
			sta		2324
			jsr		drtopsp
			lda		m_sinput1
			sta		m_samnt
			sta		m_byte2
			lda		#4
			sta		m_sindex
			jsr		managepts
			lda		#5
			sta		m_samnt
			sta		m_sindex
			jsr		managepts
pmultex		lda		m_byte2
			beq		multnsc
			jsr		showscore
multnsc		rts
			
showscore	ldx		#0
showsloop	lda		m_sc1,X
			clc		
			adc		#80
			sta		scoreline,X
			inx
			cpx		#7
			bne		showsloop
			ldx		#12
			lda		m_lives
			clc
			adc		#80
			sta		scoreline,X
			rts
			
managepts	ldx		m_sindex
			lda		m_sc1,X
			clc
			adc		m_samnt
			sta		m_sc1,X
			sbc		#9
			bpl		mptslp
			lda		#0
			sta		m_samnt
			rts
mptslp		lda		m_sc1,X
			sec
			sbc		#10
			sta		m_sc1,X
			dex
			cpx		#255
			bne		mpts1
			lda		#0
			sta		m_samnt
			rts
mpts1		cpx		#2
			bne		notexl
			lda		m_lives
			cmp		#9
			beq		notexl
			inc		m_lives
notexl		lda		m_sc1,X
			clc
			adc		#1
			sta		m_sc1,X
			sbc		#9
			bpl		mptslp
			lda		#0
			sta		m_samnt
			rts
					
			
store		lda		#0
			sta		m_temp
rloop1		lda		#0
			sta		temp5
			lda		temp4
			sta		temp6
rloop2		ldx		temp6
			lda		2816,X
			sta		m_byte1
			lda		#0
			sta		m_byte2
			lda		m_temp
			beq		stfr
			ldy		#0
rotlp		lda		m_byte2
			lsr
			sta		m_byte2
			clc
			lda		m_byte1
			lsr
			sta		m_byte1
			bcc		nocar5
			lda		m_byte2
			ora		#128
			sta		m_byte2
nocar5		iny
			cpy		m_temp
			bne		rotlp
stfr		ldy		#0
			lda		m_byte1
			sta		(m_zerop3),Y
			iny
			lda		m_byte2
			sta		(m_zerop3),Y
			lda		m_zerop3
			clc
			adc		#2
			sta		m_zerop3
			lda		m_zerop4
			adc		#0
			sta		m_zerop4
			inc		temp5
			inc		temp6
			lda		temp5
			cmp		#8
			bne		rloop2
			inc		m_temp
			lda		m_temp
			cmp		#8
			beq		exst
			jmp		rloop1
exst		rts
			
;populate invader array
popinvarr	ldx		temp6
			lda		#0
			sta		temp4
			lda		#128
			sta		m_byte2
poplp1		lda		temp4
			sta		m_linvx,X
			lda		temp5
			sta		m_linvy,X
			lda		m_byte1
			sta		m_linvtype,X
			lda		dropfrom
			sta		m_linvby,X
			lda		m_byte2
			sta		m_linvc,X
			lda		temp3
			sta		m_linvr,X
			lda		m_byte2
			lsr	
			sta		m_byte2
			inx
			inc		temp6
			lda		temp4
			clc
			adc		#16
			sta		temp4
			lda		temp4
			cmp		#128
			bne		poplp1
			ldx		#0
			lda		#0
clrblp		sta		g_bombx,X
			sta		g_bomby,X
			inx
			cpx		m_bcnt
			bne		clrblp
			rts
			
			;are the invaders invisible?
render		lda		g_dflag
			and		#1
			cmp		#1
			bne		contrend
			rts
contrend	ldx		m_invy
			lda		g_sclo,X
			sta		m_zerop1
			lda		g_schi,X
			sta		m_zerop2
			ldx		m_invx
			lda		g_xchar,X
			clc
			adc		m_zerop1
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			ldx		m_frame
			lda		g_framelo,X
			sta		m_zerop3
			lda		g_framehi,X
			sta		m_zerop4
			ldx		m_invx
			lda		g_pixframe,X
			clc
			adc		m_zerop3
			sta		m_zerop3
			lda		m_zerop4
			adc		#0
			sta		m_zerop4
			ldx		#0
rendlp		ldy		#0
			lda		(m_zerop3),Y
			sta		(m_zerop1),Y
			iny
			lda		(m_zerop3),Y
			sta		(m_zerop1),Y
			lda		m_zerop3
			clc
			adc		#2
			sta		m_zerop3
			lda		m_zerop4
			adc		#0
			sta		m_zerop4
			lda		m_zerop1
			clc
			adc		#20
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			inx
			cpx		#8
			bne 	rendlp
			rts
			
unrender	ldx		m_invy
			lda		g_sclo,X
			sta		m_zerop1
			lda		g_schi,X
			sta		m_zerop2
			ldx		m_invx
			lda		g_xchar,X
			clc
			adc		m_zerop1
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			ldx		#0
unrendlp	ldy		#0
			lda		#0
			sta		(m_zerop1),Y
			iny
			sta		(m_zerop1),Y
			lda		m_zerop1
			clc
			adc		#20
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			inx
			cpx		#8
			bne 	unrendlp
			rts
			
;used when invaders are descending			
eraseline	ldx		m_invy
			lda		g_sclo,X
			sta		m_zerop1
			lda		g_schi,X
			sta		m_zerop2
			ldx		m_invx
			lda		g_xchar,X
			clc
			adc		m_zerop1
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			ldy		#0
			lda		#0
			sta		(m_zerop1),Y
			iny
			sta		(m_zerop1),Y
			rts
			
;find vacant bomb y positions and find out where they can go
;note: you might want to allow for some better bomb spacing
;in terms of the x positions
fbombslot	lda		g_sflag
			and		#128
			cmp		#128
			bne		fbomb1
			rts
fbomb1		lda		#0
			sta		v_temp1
floop		ldx		bindex
			lda		g_bomby,X
			beq		popslotlp
			jmp		slotok
popslotlp	ldy		vbi_invi
			lda		m_linvtype,Y
			bne		contb2
			jmp		slotok
			;check if bomb x char pos is taken
contb2		ldx		m_linvx,Y
			lda		g_xchar,X
			sta		v_temp3
			clc
			adc		#1
			sta		v_temp4
			ldy		#0
checkxlp	lda		g_bomby,Y
			beq		posdiff
			ldx		g_bombx,Y
			lda		g_xchar,X
			cmp		v_temp3
			bne		checkx2
			clc
			bcc		slotok
checkx2		cmp		v_temp4
			bne		posdiff
			clc
			bcc		slotok
posdiff		iny
			cpy		m_bcnt
			bne		checkxlp
fillslot	ldx		bindex
			ldy		vbi_invi
			lda		m_linvby,Y
			sec
			sbc		#148
			bpl		slotok
			lda		m_linvby,Y
			clc
			adc		#12
			sta		v_temp1
			lda		m_linvx,Y
			clc
			adc		#3
			sta		v_temp2
			;check if empty slot
			ldy		v_temp1
			lda		g_sclo,Y
			sta		m_zerop1
			lda		g_schi,Y
			sta		m_zerop2
			ldy		v_temp2
			lda		g_xchar,Y
			clc
			adc		m_zerop1
			sta		m_zerop1
			lda		m_zerop2
			adc		#0
			sta		m_zerop2
			ldy		#0
			lda		(m_zerop1),Y
			bne		slotok
			lda		v_temp1
			sta		g_bomby,X
			lda		v_temp2
			sta		g_bombx,X
			clc
			bcc		slotok
slotok		inc		bindex
			lda		bindex
			cmp		m_bcnt
			bne		slotexit
			lda		#0
			sta		bindex
			;decide if we are going to drop any stratosled bombs
slotexit	ldx		#1
			ldy		#0
stratbloop	lda		m_mtype,X
			cmp		#1
			bne		chksbomb5
			lda		s_bomby,Y
			bne		chksbomb5
			;check x boundary
			lda		m_mx,X
			sec
			sbc		#48
			bmi		chksbomb5
			lda		m_mx,X
			sec
			sbc		#200
			bpl		chksbomb5
			;check if feel like it
			lda		53770
			sec
			sbc		#200
			bmi		chksbomb5		
chksbomb4	cpy		#4
			beq		chksbomb5
			lda		m_mx,X
			sta		53253,Y
			sta		s_bombx,Y
			lda		m_my,X
			clc
			adc		#36
			sta		s_bomby,Y
			lda		#4
			sta		s_bombhd,Y
			iny
chksbomb5	inx
			cpx		#8
			bne		stratbloop				
			rts

;subroutine for decreasing m_invcnt & refreshing the invader variable list
refresh		lda		g_sflag
			and		#64
			cmp		#64
			beq		dorefresh
			rts
dorefresh	ldx		#0
refreshlp1	lda		m_linvtype,X
			sta		c_linvtype,X
			lda		m_linvby,X
			sta		c_linvby,X
			lda		m_linvx,X
			sta		c_linvx,X
			lda		m_linvy,X
			sta		c_linvy,X
			lda		m_linvc,X
			sta		c_linvc,X
			lda		m_linvr,X
			sta		c_linvr,X
			lda		#0
			sta		m_linvtype,X
			sta		m_linvx,X
			sta		m_linvy,X
			sta		m_linvby,X
			lda		#0
			sta		temp5
			lda		#6
			sta		m_byte2
			lda		dropfrom
			sta		m_byte1
			lda		c_linvtype,X
			bne		fclearlp
			lda		c_linvx,X
			sta		m_invx
			lda		c_linvy,X
			sta		m_invy
			txa
			pha
			jsr		unrender
			pla
			tax
			;here we need to update the global column / row array
			lda		c_linvr,X
			tay
			lda		g_colrow,Y
			eor		c_linvc,X
			sta		g_colrow,Y
			clc
			bcc		ignoreby
fclearlp	ldy		m_byte2
			lda		g_colrow,Y
			and		c_linvc,X
			cmp		c_linvc,X
			bne		notfilled
			lda		c_linvy,X
			clc
			adc		#10
			sta		m_byte1
			lda		#1
			sta		temp5
			clc
			bcc		fillbslot
notfilled	dec		m_byte2
			lda		m_byte2
			cmp		#255
			bne		fclearlp
fillbslot	lda		temp5
			bne		useypos
			lda		dropfrom
			sta		m_byte1
useypos		lda		m_byte1
			sta		c_linvby,X
ignoreby	inx
			cpx		m_invcnt
			beq		contrefr
			jmp		refreshlp1
contrefr	lda		m_invcnt
			cmp		#1
			bne		gotsome
			;no more invaders left!
			jsr		newwave
exitnoinv	rts
gotsome		ldx		#0
			ldy		#0
refreshlp2	lda		c_linvtype,X
			beq		invempty
			sta		m_linvtype,Y
			lda		c_linvby,X
			sta		m_linvby,Y
			lda		c_linvx,X
			sta		m_linvx,Y
			lda		c_linvy,X
			sta		m_linvy,Y
			lda		c_linvc,X
			sta		m_linvc,Y
			lda		c_linvr,X
			sta		m_linvr,Y
			iny
invempty	inx
			cpx		m_invcnt
			bne		refreshlp2
			dec		m_invcnt
			lda		g_sflag
			and		#64
			cmp		#64
			bne		exitref
			lda		g_sflag
			eor		#64
			sta		g_sflag
exitref		lda		oldinvtype
			cmp		#3
			bne		invpts1
			lda		#5
			sta		m_samnt
			lda		#5
			sta		m_sindex
			jsr		managepts
			lda		#3
			sta		m_samnt
			lda		#4
			sta		m_sindex
			jsr		managepts
			jsr		showscore
			rts
invpts1		cmp		#2
			bne		invpts2
			lda		#5
			sta		m_samnt
			lda		#5
			sta		m_sindex
			jsr		managepts
			lda		#2
			sta		m_samnt
			lda		#4
			sta		m_sindex
			jsr		managepts
			jsr		showscore
			rts
invpts2		lda		#5
			sta		m_samnt
			lda		#5
			sta		m_sindex
			jsr		managepts
			lda		#1
			sta		m_samnt
			lda		#4
			sta		m_sindex
			jsr		managepts
			jsr		showscore
			rts
				
gameover	lda		g_sflag
			and		#16
			cmp		#16
			beq		ingo1
			rts
ingo1		lda		dli_flag
			and		#4
			cmp		#4
			bne		ingo2
			rts
ingo2		lda		g_sflag
			eor		#16
			sta		g_sflag
			lda		#64
			sta		54286
			lda		#0
			sta		559
			sta		560
			lda		#25
			sta		561
			lda		#62
			sta		559
			lda		#17
			sta		623
			lda		#0
			sta		53277
			sta		govert
			lda		dli_flag
			ora		#4
			sta		dli_flag
			ldx		#0
clrsplp		lda		#0
			sta		2314,X
			inx
			cpx		#10
			bne		clrsplp
			sta		53252
			sta		53253
			sta		53254
			sta		53255
			lda		#0
			sta		512
			lda		#26
			sta		513
			lda		#192
			sta		54286
			lda		#62
			sta		559
			jsr		clearspr
			lda		#0
			sta		53768
			lda		#229
			sta		53761
			sta		53763
			lda		#255
			sta		53760
			lda		#254
			sta		53762
			lda		#0
			sta		712
			rts
			
gametitle	lda		dli_flag
			and		#1
			cmp		#1
			bne		gt2
			rts
gt2			lda		#119
			sta		m_zerop5
			lda		#107
			sta		m_zerop6
			ldy		#0
			lda		#84
			sta		(m_zerop5),Y
			lda		#0
			ldy		#40
			sta		(m_zerop5),Y
			ldy		#80
			sta		(m_zerop5),Y
			ldy		#120
			sta		(m_zerop5),Y
			ldy		#160
			sta		(m_zerop5),Y	
			lda		#8
			sta		lseldel
			sta		gthoriz
			lda		#0
			sta		m_sc1
			sta		m_sc2
			sta		m_sc3
			sta		m_sc4
			sta		m_sc5
			sta		m_sc6
			sta		m_sc7
			lda		#64
			sta		54286
			lda		#0
			sta		560
			sta		559
			lda		#27
			sta		561
			lda		#17
			sta		623
			lda		#0
			sta		708
			sta		710
			lda		#224
			sta		756
			lda		#120
			sta		54279
			lda		#3
			sta		53277
			lda		#10
			sta		704
			sta		705
			sta		706
			lda		#60
			sta		53248
			clc
			adc		#8
			sta		53249
			adc		#8
			sta		53250
			jsr		clearspr
			ldx		#0
			ldy		#116
sprlp1		lda		2976,X
			sta		31776,Y
			lda		2984,X
			sta		32032,Y	
			lda		2992,X
			sta		32288,Y
			inx
			iny
			cpx		#8
			bne		sprlp1
			ldx		#0
			ldy		#132
sprlp2		lda		2816,X
			sta		31776,Y
			inx
			iny
			cpx		#8
			bne		sprlp2
			ldx		#0
			ldy		#148
sprlp3		lda		2840,X
			sta		31776,Y
			inx
			iny
			cpx		#8
			bne		sprlp3
			ldx		#0
			ldy		#164
sprlp4		lda		2864,X
			sta		31776,Y
			inx
			iny
			cpx		#8
			bne		sprlp4
			ldx		#0
			ldy		#180
sprlp5		lda		3000,X
			sta		31774,Y
			lda		3008,X
			sta		32030,Y	
			lda		3016,X
			sta		32286,Y
			inx
			iny
			cpx		#8
			bne		sprlp5
			lda		#223
			sta		709
			lda		#0
			sta		lsel
			lda		#62
			sta		559
			lda		dli_flag
			ora		#1
			sta		dli_flag	
			lda		#0
			sta		v_temp1
			sta		512
			lda		#28
			sta		513
			lda		#192
			sta		54286
			rts			
			
clearspr	ldy		#0
			lda		#0
			sta		53761
			sta		53763
			sta		53765
			sta		53767
clearsplp	sta		31744,Y
			sta		32000,Y
			sta		32256,Y
			sta		32512,Y
			iny
			cpy		#255
			bne		clearsplp
			rts
			
drawbar		lda		#5
			sta		m_pophi
			lda		#10
			sta		m_hdelay
			lda		#255
			sta		m_poplo
			sta		m_bswaitlo
			lda		#8
			sta		m_bswaithi
			ldx		#148
			lda		g_sclo,X
			sta		m_zerop5
			lda		g_schi,X
			sta		m_zerop6
			ldx		#0
			lda		#0
fill4		sta		31488,X
			inx
			cpx		#255
			bne		fill4
			ldx		#0
			lda		g_dflag
			and		#4
			cmp		#4
			bne		fill5
			rts
fill5		lda		#255
			ldy		#1
			sta		(m_zerop5),Y
			iny
			sta		(m_zerop5),Y
			iny
			sta		(m_zerop5),Y
			ldy		#8
			sta		(m_zerop5),Y
			iny
			sta		(m_zerop5),Y
			iny
			sta		(m_zerop5),Y
			ldy		#15
			sta		(m_zerop5),Y
			iny
			sta		(m_zerop5),Y
			iny
			sta		(m_zerop5),Y
			lda		m_zerop5
			clc
			adc		#20
			sta		m_zerop5
			lda		m_zerop6
			adc		#0
			sta		m_zerop6
			inx
			cpx		#16
			bne		fill5
			rts
			
clrscr		ldx		#0
clrscrlp	lda		g_sclo,X
			sta		m_zerop1
			lda		g_schi,X
			sta		m_zerop2
			ldy		#0
			lda		#0
clrllp		sta		(m_zerop1),Y
			iny
			cpy		#20
			bne		clrllp
			inx
			cpx		#192
			bne		clrscrlp
			jsr		drawbar
			jsr		clrmulti
			ldx		#0
			;draw player's missile base
fill6		lda		2888,X
			sta		playery,X
			lda		#0
			sta		53765
			inx
			cpx		#8
			bne		fill6
			lda		#40
			sta		2333
			jsr	 	drtopsp
			lda		#0
			sta		vbi_invi
			sta		g_sflag2
			lda		#1
			sta		g_sflag
			rts
			
newwave		lda		#128
			sta		g_sflag2
			lda		#56
			;lda		#8
			sta		m_invcnt	
			lda		#76
			;lda		#16
			sta		dropfrom
			ldx		#0
			lda		#255
colrowlp	sta		g_colrow,X
			inx
			cpx		#7
			bne		colrowlp
			jsr		initinvarr
			lda		#40
			sta		2333
			lda		#0
			sta		53768
			sta		53765
			sta		53767
			lda		#1
			sta		missdec
			jsr		clearspr
			jsr		clrscr
			lda		#4
			sta		2363
			rts
			
;this subroutine is used to decide when a snosspkronka v-formation
;is ready to appear. It will not set the v-formation in progress bit
;if a player has shot a snosspkronk on the current wave
vform		lda		g_sflag
			and		#32
			cmp		#32
			bne		vform1
			rts
vform1		lda		g_sflag
			and		#128
			cmp		#128
			bne		vform2
			lda		snosspstage
			beq		toneok
			lda		#32
			sta		53768
			lda		#47
			sta		53765
			lda		#239
			sta		53767
			lda		snossptone
			sta		53764
			clc
			adc		#5
			sta		53766
			inc		snossptone
			lda		snossptone
			cmp		#250
			bne		toneok
			lda		#200
			sta		snossptone
toneok		rts
vform2		dec		m_ldelay
			lda		m_ldelay
			beq		vform3
			rts
vform3		dec		m_hdelay
			lda		m_hdelay
			beq		vform4
			rts
vform4		lda		#10
			sta		m_hdelay
			lda		g_sflag
			ora		#128
			sta		g_sflag
			lda		#0
			sta		snosspstage
			lda		#200
			sta		snossptone
			lda		#2
			sta		missdec
			rts		
				
			org 1536
;game display list

.byte		112,112,112
.byte		204,0,128,12,12,12,12,12,12,12
.byte		12,12,12,12,12,12,12,12
.byte		140,12,12,12,12,12,12,12
.byte		12,12,12,12,12,12,12,12
.byte		140,12,12,12,12,12,12,12
.byte		12,12,12,12,12,12,12,12
.byte		140,12,12,12,12,12,12,12
.byte		12,12,12,12,12,12,12,12
.byte		140,12,12,12,12,12,12,12
.byte		12,12,12,12,12,12,12,12
.byte		140,12,12,12,12,12,12,12
.byte		12,12,12,12,12,12,12,12
.byte		140,12,12,12,12,12,12,12
.byte		12,12,12,12,12,12,12,12
.byte		140,12,12,12,12,12,12,12
.byte		12,12,12,12,12,12,12,12
.byte		140,12,12,12,12,12,12,12
.byte		12,12,12,12,12,12,12,12
.byte		140,12,12,12,12,12,12,12
.byte		12,12,12,12,12,12,12,12
.byte		12,12,12,12,12,12,12,12
.byte		12,12,12,12,12,12,12,12
.byte		12,12,12,12,12,12,12,12
.byte		70,8,152
.byte		65,0,6		

			org 6400
;game over display list
			
.byte		112,112,240
.byte		103,44,152
.byte		103,44,152
.byte		103,44,152
.byte		103,44,152
.byte		103,44,152
.byte		103,44,152
.byte		103,44,152
.byte		103,44,152
.byte		103,44,152
.byte		103,44,152
.byte		103,44,152
.byte		112
.byte		70,8,152
.byte		65,0,25
			
			org 38940
;game over message

.byte		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte		39,33,45,37,0,47,54,37,50

			org	6912
;title screen display list
			
.byte		112,112,240
.byte		71,0,107
.byte		71,20,107
.byte		86,0,111
.byte		66,40,107
.byte		66,80,107
.byte		66,120,107
.byte		66,160,107
.byte		66,200,107
.byte		66,240,107
.byte		112
.byte		66,24,108
.byte		112
.byte		66,64,108
.byte		112
.byte		66,104,108
.byte		112
.byte		66,144,108
.byte		112
.byte		66,184,108
.byte		112
.byte		66,224,108
.byte		112
.byte		66,8,109
.byte		65,0,27

			org	27392
;title screen non scrolling text

;title
.byte	57,37,0,35,44,47,53,52,40,37,0,37,52,0,0,0,0,0,0,0
.byte	38,47,51,51,37,0,37,52,0,43,46,57,39,40,52,37,0,0,0,0
;difficuty levels
.byte	36,41,38,38,41,35,53,44,52,57,0,44,37,54,37,44,51,26,0,0
.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;number of invader bombs
.byte	46,53,45,34,37,50,0,47,38,0,41,46,54,33,36,37,50,0,34,47
.byte	45,34,51,26,17,0,0,0,0,0,0,0,0,0,0,0,0,0,0,84
;number of flybys:
.byte	46,53,45,34,37,50,0,47,38,0,38,44,57,34,57,51,26,17,0,0
.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;invader vertical creep
.byte	41,46,54,33,36,37,50,0,54,37,50,52,41,35,33,44,0,35,50,37
.byte	37,48,26,20,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;extra difficulty levels
.byte	37,56,52,50,33,0,36,41,38,38,41,35,53,44,52,57,0,44,37
.byte	54,37,44,51,26,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;number of lives
.byte	46,53,45,34,37,50,0,47,38,0,44,41,54,37,51,26,19,0,0,0
.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte	48,47,41,46,52,51,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,45,57,51,52,37,50,57
.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,19,21,16
.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,18,21,16
.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,17,21,16
.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,20,16,16
.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.byte	48,50,37,51,51,0,38,41,50,37,0,52,47,0,51,52,33,50,52,0
.byte	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

		
		org 28416	
;title screen scrolling text
.byte	52,40,41,51,0,41,51,0,2,41,46,54,33,36 
.byte	37,50,51,2,0,55,41,52,40,0,51,47,45,37,0 
.byte	36,41,38,38,37,50,37,46,35,37,51,14,0,51
.byte	40,47,47,52,0,46,47,52,0,51,46,47,51,51
.byte	48,43,50,47,46,43,33,0,44,37,51,52,0,57
.byte	47,53,0,39,37,52,0,51,46,47,51,51,48,43
.byte	50,47,46,43,37,36,14,0,45,41,46,36,0,47
.byte	53,52,0,38,47,50,0,52,40,37,0,52,41,45
.byte	37,34,47,45,34,51,14
.byte	0,41,38,0,57,47,53,0,36,47,0,46,47,52,0
.byte	51,40,47,47,52,0,52,40,37,0,51,46,47,51
.byte	51,48,43,50,47,46,43,33,0,52,40,37,46,0
.byte	33,38,52,37,50,0,33,0,55,40,41,44,37,0,57
.byte	47,53,0,55,41,44,44,0,34,37,0,39,41,38
.byte	52,37,36,0,34,57,0,52,40,37,45,14,0,51
.byte	52,50,33,52,47,51,44,37,36,51,0,55,41,44
.byte	44,0,36,50,47,48,0,40,47,45,41,46,39,0
.byte	45,41,51,51,41,44
.byte	37,51,0,47,46,0,57,47,53,14,0			

		
			org	2816 
;invader type 1 animation frames
.byte	24,60,126,219,255,195,129,195
.byte	24,60,126,219,255,195,66,102
.byte	24,60,126,219,255,102,102,66
;invader type 2 animation frames
.byte	66,36,24,126,219,255,129,129
.byte	0,102,24,126,219,255,129,66
.byte	0,36,90,126,219,255,195,0
;invader type 3 animation frames
.byte	24,60,126,219,219,126,60,24
.byte	24,60,255,219,219,255,60,24
.byte	24,189,255,219,219,255,189,24
;player's missile base and explosions thereof
.byte	24,24,24,60,126,255,255,255
.byte	24,24,24,60,94,255,253,191
.byte	24,16,24,52,94,237,237,191
.byte	8,16,24,52,90,109,173,182
.byte	8,0,8,20,10,36,169,146
;invader explosion frames
.byte	24,60,126,255,255,126,60,24
.byte	0,60,126,255,255,126,60,0
.byte	0,24,60,126,126,60,24,0
.byte	0,0,24,60,60,24,0,0
.byte	0,0,0,24,24,0,0,0
.byte	0,0,0,0,0,0,0,0
;bonus points ship
.byte	0,1,15,121,249,255,49,96
.byte	56,255,255,153,153,255,255,0
.byte	0,0,240,158,159,255,140,6
;stratosled
.byte	0,0,7,6,31,127,255,63
.byte	0,1,255,171,255,255,192,255
.byte	128,64,230,254,254,252,120,192
;sossplimfa frame 1
.byte	240,120,60,30,63,127,63,15
.byte	15,30,60,121,255,255,255,254
.byte	0,28,111,248,240,128,0,0
;sossplimfa frame 2
.byte	0,120,60,30,48,127,63,15
.byte	0,30,60,121,255,255,255,254
.byte	0,28,111,248,240,128,0,0
;sossplimfa frame 3
.byte	0,0,120,60,35,112,63,15
.byte	0,0,30,61,255,255,255,254
.byte	0,28,111,248,240,128,0,0
;sossplimfa frame 4
.byte	0,0,0,120,63,97,48,15
.byte	0,0,0,31,255,255,255,254
.byte	0,28,111,248,240,128,0,0
;display list interrupt lookups
		org	2304
;hardware register 53266
.byte	15,15,15,15,15,15,15,15,15,170
;hardware register 53248 (2314)
.byte	0,0,0,0,0,0,0,0,0,0
;hardware register 53266 (2324)
.byte	10,0,0,0,0,0,0,0,0,40
;generic area (2334)
.byte	2,0,0,0,0,0,0,0,0,0
;generic area (2344)
.byte	0,0,0,0,0,0,0,0,0,0
;multiplex types 2354
.byte	0,0,0,0,0,0,0,0,0,4
;multiplex speeds 2364
.byte	2,8,8,8,8,8,8,8,8,8
;multiplex working speeds 2374
.byte	2,8,8,8,8,8,8,8,8,8
;stratosled luminance lookup 2384
.byte	8,10,12,14,14,12,10,8,0,0
;multiplex y pos 2394
.byte	0,0,0,0,0,0,0,0,0,0
;sossplimfa frame lookup 2404
.byte	0,24,48,72,48,24,0,0,0,0	
;other generic area 2414
.byte	0,0,0,0,0,0,0,0,0,0
;other generic area 2424
.byte	8,7,6,5,5,6,7,8

;display list interrupt for game over
			org 6656
			pha
			txa
			pha		
			;kernel
			lda		54283
			sec
			sbc		#16
			bpl		exdligo
			ldx		#0
			stx		godli_index
			dec		go_colour
gokl		lda		go_colour
			clc
			adc		godli_index
			sta		54282
			sta		53270
			inx
			inc		godli_index
			cpx		#176
			bne		gokl
exdligo		pla
			tax
			pla
			rti
	
;display list interrupt for game title
			org 7168
			pha
			txa
			pha
			ldx		#0
			stx		godli_index	
			dec		go_colour
			;kernel
tskl		lda		go_colour
			clc
			adc		godli_index
			sta		54282
			sta		53270
			inx
			inc		godli_index
			cpx		#32
			bne		tskl
exdlits		pla
			tax
			pla
			rti	

;display list interrupt for game
			org	2048
			;just a note here for dealing with dlis
			;you only want to look the colour/horiz offset/whatever
			;per 8 scan lines. Otherwise you will get wscan weirdness
			pha
			txa
			pha
			ldx		dli_index
			lda		#0
			sta		dli_temp1
			lda		m_mtype,X
			cmp		#1
			beq		kernellp
			cmp		#4
			beq		nokernel2
nokernel1	lda		2304,X
			sta		54282
			sta		53270
			lda		2314,X
			sta		53248
			clc
			adc		#8
			sta		53249
			clc
			adc		#8
			sta		53250
			lda		2324,X
			sta		53266	
			sta		53267
			sta		53268
			clc
			bcc		dlifin
nokernel2	lda		2304,X
			sta		54282
			sta		53270
			lda		2314,X
			sta		53248
			lda		2324,X
			sta		53266
			lda		v_tbhoriz
			sta		53250
			lda		v_tbcolour
			sta		53268
			clc
			bcc		dlifin
kernellp	lda		2304,X
			sta		54282
			sta		53270
			lda		2314,X
			sta		53248
			clc
			adc		#8
			sta		53249
			clc
			adc		#8
			sta		53250
			ldx		dli_temp1
			lda		2384,X
			sta		dli_temp2
			ldx		dli_index
			lda		2324,X
			clc
			adc		dli_temp2
			sta		53266	
			sta		53267
			sta		53268
			inc		dli_temp1
			lda		dli_temp1
			cmp		#8
			bne		kernellp
dlifin		inc 	dli_index
			lda		dli_index
			cmp		#10
			bne		exit3
			lda		#0
			sta		dli_index
exit3		pla
			tax
			pla
			rti
		
			org	8192
			;here is our deferred vertical blank interrupt which
			;will likely be doing a lot of things
			;the first check is to see if we have
			;finished clearing the screen.
			;Can't do anything while this is going on
mainvbi		lda		#0
			sta		77
			;above is to disable the attract mode
			lda		g_sflag2
			and		#128
			cmp		#128
			bne		contvbi
			jmp		58466
contvbi		lda		dli_flag
			and		#1
			cmp		#1
			bne		mainvbi1
			jsr		levels
			dec		2334
			lda		2334
			beq		scrol1
			jmp		58466
scrol1		lda		#2
			sta		2334
			dec		gthoriz
			lda		gthoriz
			sta		54276
			bne		gtexscrol
			inc		6922
			lda		#8
			sta		gthoriz
			sta		54276
gtexscrol	jmp		58466
mainvbi1	lda		dli_flag
			and		#4
			cmp		#4
			bne		mainvbi2
			lda		646
			bne		contgo
			jsr		gametitle
			jmp		58466		
contgo		inc		govert
			lda		govert
			sta		54277
			cmp		#8
			bne		noresetvp
			lda		#0
			sta		54277
noresetvp	jmp		58466
mainvbi2	lda		g_sflag
			and		#16
			cmp		#16
			bne		mainvbi3
			jsr		gameover
			jmp		58466
mainvbi3	jsr		mbexplode
			jsr		mbshield
			jsr		chkstk
			jsr		chkf
			jsr 	fbombslot
			jsr		dropbombs
			jsr		stratbombs
			jsr		topship
			jsr		movemulti
			jsr		hitmulti
			jsr		vform
			dec		711
			;are we waiting for the main program
			;to reset invader variables?
			lda		g_sflag
			and		#64
			cmp		#64
			bne		drawinvs
			jmp		final3
drawinvs	ldx		vbi_invi
invok		lda		m_linvx,X
			sta		m_invx
			lda		m_linvy,X
			sta		m_invy
			lda		m_linvtype,X
			cmp		#1
			bne		frame2
			lda		m_an1fr
			sta		m_frame
frame2		lda		m_linvtype,X
			cmp		#2
			bne		frame3
			lda		m_an2fr
			sta		m_frame
frame3		lda		m_linvtype,X
			cmp		#3
			bne		frame4
			lda		m_an3fr
			sta		m_frame
frame4		lda		g_sflag
			and		#8
			cmp		#8
			bne		invhoriz
			jsr		eraseline
			ldx		vbi_invi
			lda		m_linvy,X
			clc
			adc		#1
			sta		m_linvy,X
			sta		m_invy
			lda		m_linvby,X
			clc
			adc		#1
			sta		m_linvby,X
			lda		m_invy
			cmp		#172
			bne		notlanded
			lda		g_sflag
			ora		#16
			sta		g_sflag
			lda		#64
			sta		712
notlanded	lda		m_linvtype,X
			beq		notlanded1
			jsr		render
notlanded1	jmp		final1
invhoriz	lda		g_sflag
			and		#1
			cmp		#1
			bne		minvleft
			lda		m_invx
			beq		skipler1
			dec		m_invx
			jsr		unrender
skipler1	ldx		vbi_invi
			lda		m_linvx,X
			sta		m_invx
			lda		m_linvtype,X
			beq		norender1
			jsr		render
norender1	ldx		vbi_invi
			lda		m_linvx,X
			clc
			adc		#1
			sta		m_linvx,X
			cmp		#143
			bne		final1
			lda		g_sflag
			ora		#4
			sta		g_sflag
			lda		m_vertmax
			sta		v_vert
			clc
			bcc		final1
minvleft	lda		m_invx
			cmp		#142
			beq		skipler2
			inc		m_invx
			jsr		unrender
skipler2	ldx		vbi_invi
			lda		m_linvx,X
			sta		m_invx
			lda		m_linvtype,X
			beq		norender2
			jsr		render
norender2	ldx		vbi_invi
			lda		m_linvx,X
			sec
			sbc		#1
			sta		m_linvx,X
			lda		m_linvx,X
			bne		final1
			lda		g_sflag
			ora		#4
			sta		g_sflag
			lda		m_vertmax
			sta		v_vert
final1		inc		vbi_invi
			lda		vbi_invi
			cmp		m_invcnt
			bne		final3
			lda		g_sflag
			and		#4
			cmp		#4
			bne		final2
			lda		g_sflag
			ora		#8
			sta		g_sflag
			dec		v_vert
			inc		dropfrom
			lda		v_vert
			bne		final2
			lda		g_sflag
			eor		#13
			sta		g_sflag
final2		lda		#0
			sta		vbi_invi
			jsr		anim
final3		;check player shot at anything
			lda		g_dflag
			and		#1
			cmp		#1
			beq		invisible
			lda		53248
			and		#1
			cmp		#1
			bne		nbarhit
invisible	jsr		clrbat
nbarhit		lda		invvol
			sta		53761
			lda		invvol
			cmp		#192
			beq		faded
			dec		invvol
faded		jsr		invexplode
			jmp		58466		

anim		lda		#207
			sta		invvol
			lda		invtone
			clc
			adc		#3
			sta		invtone
			cmp		#244
			bne		anim1
			lda		#235
			sta		invtone
anim1		lda		invtone
			sta		53760
			inc		m_an1fr
			lda		m_an1fr
			cmp		#3
			bne		anim2
			lda		#0
			sta		m_an1fr
anim2		inc		m_an2fr
			lda		m_an2fr
			cmp		#6
			bne		anim3
			lda		#3
			sta		m_an2fr
anim3		inc		m_an3fr
			lda		m_an3fr
			cmp		#9
			bne		anim4
			lda		#6
			sta		m_an3fr
anim4		rts

;init missile base explode
mbexpinit	lda		g_sflag2
			ora		#32
			sta		g_sflag2
			lda		g_sflag2
			and		#8
			cmp		#8
			bne		mexpin1
			lda		g_sflag2
			eor		#8
			sta		g_sflag2
mexpin1		lda		#47
			sta		2333
			lda		#0
			sta		mb_exppos
			lda		#8
			sta		mb_expdel
			lda		#4
			sta		mb_expcnt
			rts

;missile base explode
mbexplode	lda		g_sflag2
			and		#32
			cmp		#32
			beq		mbexp1
			rts
mbexp1		lda		53770
			sta		53762
			lda		#15
			sta		53763
			dec		mb_expdel
			lda		mb_expdel
			beq		mbexp2
			rts
mbexp2		lda		#8
			sta		mb_expdel		
			ldx		mb_exppos
			ldy		#0
mbexplp		lda		2896,X
			sta		playery,Y
			inx
			iny
			cpy		#8
			bne		mbexplp
			lda		mb_exppos
			clc
			adc		#8
			sta		mb_exppos
			cmp		#32
			beq		mbexp3
			rts
mbexp3		lda		#0
			sta		mb_exppos
			dec		mb_expcnt
			lda		mb_expcnt
			beq		mbexp4
			rts
mbexp4		lda		g_sflag2
			eor		#32
			sta		g_sflag2
			ldx		#0
drawmblp	lda		2888,X
			sta		playery,X
			inx
			cpx		#8
			bne		drawmblp
			lda		#143
			sta		2333
			lda		g_sflag2
			ora		#64
			sta		g_sflag2
			dec		m_lives
			ldx		#12
			lda		m_lives
			clc
			adc		#80
			sta		scoreline,X
			lda		#0
			sta		712
			sta		53763
			lda		m_lives
			bne		mbexp5
			lda		g_sflag
			ora		#16
			sta		g_sflag
			lda		#255
			sta		mb_shdel
mbexp5		rts		

;missile base shield
mbshield	lda		g_sflag2
			and		#64
			cmp		#64
			beq		mbsh1
			rts
mbsh1		dec		2333
			lda		2333
			cmp		#128
			bne		mbsh2
			lda		#143
			sta		2333
mbsh2		dec		mb_shdel
			lda		mb_shdel
			beq		mbsh3
			rts
mbsh3		lda		g_sflag2
			eor		#64
			sta		g_sflag2
			lda		#40
			sta		2333
			rts

;difficulty selection
levels		dec		lseldel
			lda		lseldel
			beq		lev1
			rts
lev1		lda		#8
			sta		lseldel
			ldy		#0
			lda		632
			cmp		#14
			bne		chkdwn
			lda		lsel
			beq		firstlev
			dec		lsel
			lda		#0
			sta		(m_zerop5),Y
			lda		m_zerop5
			sec
			sbc		#40
			sta		m_zerop5
			bcs		firstlev
			dec		m_zerop6
firstlev	lda		#84
			sta		(m_zerop5),Y
			lda		#15
			sta		632
			rts
chkdwn		lda		632
			cmp		#13
			bne		chkleft
			lda		lsel
			cmp		#4
			beq		lastlev
			inc		lsel
			lda		#0
			sta		(m_zerop5),Y
			lda		m_zerop5
			clc
			adc		#40
			sta		m_zerop5
			lda		m_zerop6
			adc		#0
			sta		m_zerop6
lastlev		lda		#84
			sta		(m_zerop5),Y
			rts
chkleft		lda		632
			cmp		#11
			beq		chkleft1
			jmp		chkright
chkleft1	lda		lsel
			bne		nodec1
			lda		m_bcnt
			cmp		#1
			beq		nodec1
			dec		m_bcnt
			lda		m_bcnt
			clc
			adc		#16
			sta		27496
			rts
nodec1		lda		lsel
			cmp		#1
			bne		nodec2
			lda		multicnt
			cmp		#1
			beq		nodec2
			dec		multicnt
			lda		multicnt
			clc
			adc		#16
			sta		27529
			rts
nodec2		lda		lsel
			cmp		#2
			bne		nodec3
			lda		m_vertmax
			cmp		#4
			beq		nodec3
			dec		m_vertmax
			lda		m_vertmax
			clc
			adc		#16
			sta		27575
			rts
nodec3		lda		lsel
			cmp		#3
			bne		nodec4
			lda		g_dflag
			beq		nodec4
			dec		g_dflag
			lda		g_dflag
			clc
			adc		#16
			sta		27616
			rts
nodec4		lda		lsel
			cmp		#4
			bne		nodec5
			lda		sellives
			cmp		#1
			beq		nodec5
			dec		sellives
			lda		sellives
			clc
			adc		#16
			sta		27648
nodec5		rts
chkright	lda		632
			cmp		#7
			beq		chkright1
			jmp		noinc5
chkright1	lda		lsel
			bne		noinc1
			lda		m_bcnt
			cmp		#8
			beq		noinc1
			inc		m_bcnt
			lda		m_bcnt
			clc
			adc		#16
			sta		27496
			rts
noinc1		lda		lsel
			cmp		#1
			bne		noinc2
			lda		multicnt
			cmp		#8
			beq		noinc2
			inc		multicnt
			lda		multicnt
			clc
			adc		#16
			sta		27529
			rts
noinc2		lda		lsel
			cmp		#2
			bne		noinc3
			lda		m_vertmax
			cmp		#8
			beq		noinc3
			inc		m_vertmax
			lda		m_vertmax
			clc
			adc		#16
			sta		27575
			rts
noinc3		lda		lsel
			cmp		#3
			bne		noinc4
			lda		g_dflag
			cmp		#7
			beq		noinc4
			inc		g_dflag
			lda		g_dflag
			clc
			adc		#16
			sta		27616
			rts
noinc4		lda		lsel
			cmp		#4
			bne		noinc5
			lda		sellives
			cmp		#9
			beq		noinc5
			inc		sellives
			lda		sellives
			clc
			adc		#16
			sta		27648
			rts
noinc5		lda		646
			bne		noinc6
			jsr		initgamescr
noinc6		rts

			;check fire button
chkf		lda		g_sflag
			and		#2
			cmp		#2
			beq		dmiss0
			lda		#0
			sta		v_temp1
			;invader exploding?
			lda		g_sflag2
			and		#1
			cmp		#1
			bne		exptest2
			inc		v_temp1
			;multiplex sprite exploding?
exptest2	lda		g_sflag2
			and		#4
			cmp		#4
			bne		exptest3
			inc		v_temp1
exptest3	;missile base exploding
			lda		g_sflag2
			and		#32
			cmp		#32
			bne		exptest4
			inc		v_temp1
exptest4	lda		v_temp1
			beq		chkpressed
			rts
chkpressed	lda		646
			beq		m0init
			beq		m0init
			rts
m0init		lda		g_sflag
			eor		#2
			sta		g_sflag
			lda		missdec
			sta		wmissdec
			lda		vbi_ppos
			adc		#2
			sta		vbi_plmissx
			sta		53252
			lda		#200
			sta		vbi_plmissy
			lda		#15
			sta		misstone
			sta		53762
			lda		#16
			sta		missdel
			lda		#5
			sta		53763
			rts
dmiss0		ldx		vbi_plmissy
			lda		31488,X
			eor		#3
			sta		31488,X
			txa
			clc
			adc		wmissdec
			tax
			lda		31488,X
			and		#3
			cmp		#3
			bne		mmiss0
			lda		31488,X
			eor		#3
			sta		31488,X
mmiss0		lda		misstone
			sta		53762
			beq		mmiss1
			dec		missdel
			lda		missdel
			bne		mmiss1
			lda		#16
			sta		missdel
			dec		misstone
mmiss1		lda		vbi_plmissy
			sec
			sbc		wmissdec
			sta		vbi_plmissy
			lda		vbi_plmissy
			cmp		#32
			bne		missexit
			lda		#32
			clc
			adc		wmissdec
			tax
			lda		31488,X
			eor		#3
			sta		31488,X
			lda		#0
			sta		53763
			lda		g_sflag
			eor		#2
			sta		g_sflag
missexit	rts

;move multiplexed sprites
movemulti	ldx		#1
movemlp		lda		m_mtype,X
			beq		movem2
			cmp		#1
			beq		movem1
			cmp		#2
			beq		movem1
			cmp		#3
			bne		movem1
			dec		m_mcol1,X
			lda		m_mcol1,X
			cmp		#208
			bne		movem2
			lda		#223
			sta		m_mcol1,X
			clc
			bcc		movem2
movem1		dec		m_mwspeed,X
			lda		m_mwspeed,X
			bne		movem2
			lda		m_mspeed,X
			sta		m_mwspeed,X
			lda		m_mtype,X
			cmp		#1
			bne		mgoright
			dec		m_mx,X
			clc
			bcc		checkmx
mgoright	inc		m_mx,X
checkmx		lda		m_mx,X
			bne		movem2
			lda		#0
			sta		m_mtype,X
movem2		inx
			cpx		#9
			bne		movemlp
			rts

;move bonus points ship
topship		lda		g_sflag2
			and		#2
			cmp		#2
			beq		topship4
topship1	dec		m_bswaitlo
			lda		m_bswaitlo
			beq		topship2
			rts
topship2	lda		#255
			sta		m_bswaitlo
			dec		m_bswaithi
			lda		m_bswaithi
			beq		topship3
			rts
topship3	lda		#8
			sta		m_bswaithi
			lda		g_sflag2
			ora		#2
			sta		g_sflag2
			rts
topship4	dec		m_mwspeed
			lda		m_mwspeed
			beq		movets1
			rts
movets1		lda		m_mspeed
			sta		m_mwspeed
			lda		m_mtype
			cmp		#3
			bne		movets2
			rts
movets2		dec		bsvol
			lda		bsvol
			sta		53765
			cmp		#224
			bne		tone1
			lda		#239
			sta		bsvol
tone1		lda		bstone
			sta		53764
			clc
			adc		#20
			sta		bstone
			cmp		#60
			bne		tone2
			lda		#20
			sta		bstone
tone2		dec		m_bpshx
			lda		m_bpshx
			beq		topship5
			rts
topship5	lda		g_sflag2
			eor		#2
			sta		g_sflag2
			lda		#224
			sta		53765
			rts		

;invader explosion - no point using the software sprites
;to do this, as the rendering is too slow.
;While the explosion is running, the player can't shoot
;because there is only 1 non-multiplexed player to show
;the explosion
invexplode	lda		g_sflag2
			and		#1
			cmp		#1
			beq		invexp1
			rts
invexp1		lda		v_exppos
			cmp		#48
			beq		invexp5
invexp2		lda		#64
			sta		53762
			lda		#15
			sta		53763	
			dec		707
			lda		707
			cmp		#208
			bne		invexp3
			lda		#223
			sta		707
invexp3		dec		v_expdel
			lda		v_expdel
			beq		invexp4
			rts
invexp4		lda		#8
			sta		v_expdel
			sta		v_temp1
			ldy		v_expy
			ldx		v_exppos
invexplp	lda		2928,X
			sta		32512,Y
			inx
			iny
			dec		v_temp1
			lda		v_temp1
			bne		invexplp
			lda		v_exppos
			clc
			adc		#8
			sta		v_exppos
			cmp		#48
			beq		invexp5
			rts
invexp5		lda		vbi_invi
			bne		invexp6
			lda		#0
			sta		53763
			lda		g_sflag
			and		#64
			cmp		#64
			beq		invexp6
			lda		g_sflag
			eor		#64
			sta		g_sflag
			lda		g_sflag2
			and		#1
			cmp		#1
			bne		invexp6
			lda		g_sflag2
			eor		#1
			sta		g_sflag2
invexp6		rts

;check joystick
chkstk		lda		g_sflag2
			and		#32
			cmp		#32
			beq		retstk
			lda		g_sflag2
			and		#8
			cmp		#8
			bne		chkstk1
			dec		2333
			dec		paralysis
			lda		paralysis
			bne		retstk
			lda		#40
			sta		2333
			lda		g_sflag2
			eor		#8
			sta		g_sflag2
retstk		rts
chkstk1		lda		vbi_ppos
			sta		m_mbhx
			lda		632
			cmp		#11
			beq		left
			lda		632
			cmp		#7
			beq 	right
			rts
left		lda		vbi_ppos
			cmp		#48
			beq		exit1
			dec		vbi_ppos
			rts
right		lda		vbi_ppos
			cmp		#200
			beq		exit1
			inc		vbi_ppos
exit1		rts

;subroutine for handling barrier hits

clrbat		lda		g_sflag
			and		#2
			cmp		#2
			beq		contclrbat
			rts
contclrbat	lda		m_invcnt
			sec
			sbc		#1
			tax
			lda		vbi_plmissx
			sec
			sbc		#48
			tay
			lda		g_xchar,Y
			sta		v_temp3
			lda		vbi_plmissy
			sec
			sbc		#30
			sta		v_temp4
			;better to compare character offsets
			;than pixel offsets for x positions
invdetlp	lda		#0
			sta		v_temp2
			lda		m_linvtype,X
			bne		invdet1
			jmp		notfound
invdet1		lda		v_temp4
			sec
			sbc		m_linvy,X
			sta		v_temp5
			;note: branch if minus - USEFUL!
			;the overflow flag is not relevant here
			;what it is used for is something we can worry about some
			;other time
			bpl		invdet2
			jmp		notfound
invdet2		inc		v_temp2
			lda		#7
			sec
			sbc		v_temp5
			bmi		notfound
			inc		v_temp2
			lda		m_linvx,X
			tay
			lda		g_xchar,Y
			cmp		v_temp3
			bne		chkchar2
			inc		v_temp2
chkchar2	lda		m_linvx,X
			tay
			lda		g_xchar,Y
			clc
			adc		#1
			cmp		v_temp3
			bne		invdet3
			inc		v_temp2
invdet3		lda		v_temp2
			cmp		#3
			bne		notfound
			lda		m_linvtype,X
			bne		shotinv
			clc
			bcc		stopmiss
shotinv		lda		g_sflag2
			and		#1
			cmp		#1
			beq		stopmiss
			lda		m_linvtype,X
			sta		oldinvtype
			lda		#0
			sta		m_linvtype,X
			lda		m_linvx,X
			sta		m_invx
			clc
			adc		#48
			sta		53251
			lda		m_linvy,X
			sta		m_invy
			clc
			adc		#32
			sta		v_expy
			jsr		unrender
			lda		#223
			sta		707
			lda		#8
			sta		v_expdel
			lda		#0
			sta		v_exppos
			sta		53765
			lda		g_sflag2
			eor		#1
			sta		g_sflag2	
			clc
			bcc		stopmiss
notfound	dex
			cpx		#255
			beq		stopmiss
			jmp		invdetlp
			;note: bit #1 of d_flag
			;causes the invaders' bombs to stop your missile
stopmiss	lda		g_sflag2
			and		#1
			cmp		#1
			beq		notbomb
			lda		vbi_plmissy
			sec
			sbc		#30
			sta		v_temp4
			lda		g_dflag
			and		#2
			cmp		#2
			beq		notbomb
			lda		v_temp4
			sec
			sbc		#148
			bpl		notbomb
			lda		#0
			sta		53278
			rts
notbomb		lda		53248
			bne		isbarrier
			lda		g_sflag2
			and		#1
			cmp		#1
			beq		isbarrier
			rts
isbarrier	ldy		vbi_plmissy
			tya
			clc
			adc		wmissdec
			tay
			lda		31488,Y
			eor		#3
			sta		31488,Y
			lda		g_sflag
			and		#2
			cmp		#2
			bne		notset
			lda		g_sflag
			eor		#2
			sta		g_sflag
notset		lda 	#0
			sta		53278
			sta		53763
			lda		vbi_plmissy
			sec
			sbc		#33
			tay
			lda		g_sclo,Y
			sta		m_zerop5
			lda		g_schi,Y
			sta		m_zerop6
			lda		vbi_plmissx
			sec
			sbc		#48
			tay
			lda		g_pixbits,Y
			sta		v_temp1
			lda		g_xchar,Y
			clc
			adc		#60
			adc		m_zerop5
			sta		m_zerop5
			lda		m_zerop6
			adc		#0
			sta		m_zerop6
			ldy		#0
			lda		(m_zerop5),Y
			and		v_temp1
			cmp		v_temp1
			bne		noclr
			lda		(m_zerop5),Y
			eor		v_temp1
			sta		(m_zerop5),Y		
noclr		rts

dropbombs	lda		#0
			sta		v_temp2
			sta		v_temp4
droploop	ldx		v_temp2
			lda		g_bomby,X
			bne		contbomb
			jmp		nobomb
contbomb	tay
			lda		g_sflag2
			and		#16
			cmp		#16
			beq		tbomb1
			jmp		ordbomb
			;deal with timebomb stage 1
tbomb1		cpx		v_tbindex
			beq		tbomb2
			jmp		ordbomb
tbomb2		lda		v_tbstage
			cmp		#1
			bne		tbstage2
			lda		tbtone
			sta		53766
			lda		tbvol
			sta		53767
			dec		tbvol
			lda		tbvol
			cmp		#192
			bne		norstvol
			lda		#207
			sta		tbvol
norstvol	lda		g_bomby,X
			clc
			adc		#24
			tay
			ldx		v_tbpos
			lda		#0
			sta		v_temp3
tb1lp		lda		57472,X
			sta		32256,Y
			iny
			inx
			inc		v_temp3
			lda		v_temp3
			cmp		#8
			bne		tb1lp
			dec		v_tbdel
			lda		v_tbdel
			bne		tbomb3
			lda		#15
			sta		v_tbdel
			lda		v_tbpos
			sec
			sbc		#8
			sta		v_tbpos
			lda		v_tbpos
			bne		tbomb3
			inc		v_tbstage
			lda		#0
			sta		53278
			lda		#8
			sta		v_tbdel
			lda		#0
			sta		v_tbpos
			lda		#223
			sta		v_tbcolour
			lda		#15
			sta		53767
tbomb3		jmp		nobomb
tbstage2	dec		v_tbcolour
			lda		53770
			sta		53766
			lda		v_tbcolour
			cmp		#208
			bne		tbexplode
			lda		#223
			sta		v_tbcolour
tbexplode	lda		g_bomby,X
			clc
			adc		#24
			tay
			lda		#0
			sta		v_temp3
			ldx		v_tbpos
tb2lp		lda		2928,X
			sta		32256,Y
			inx
			iny
			inc		v_temp3
			lda		v_temp3
			cmp		#8
			bne		tb2lp
			;check if hit missile base
			lda		53260
			and		#4
			cmp		#4
			bne		nothittb
			lda		#0
			sta		53278
			lda		g_sflag2
			and		#32
			cmp		#32
			beq		nothittb
			lda		g_sflag2
			and		#64
			cmp		#64
			beq		nothittb
			lda		#32
			sta		712
			jsr		mbexpinit	
nothittb	dec		v_tbdel
			lda		v_tbdel
			bne		tbomb4
			lda		#8
			sta		v_tbdel
			lda		v_tbpos
			clc
			adc		#8
			sta		v_tbpos
			cmp		#48
			beq		tbomb5
tbomb4		jmp		nobomb
tbomb5		lda		#0
			sta		v_tbhoriz
			lda		#1
			sta		v_temp4
			lda		g_sflag2
			and		#16
			cmp		#16
			bne		ordbomb
			lda		g_sflag2
			eor		#16
			sta		g_sflag2
			lda		#0
			sta		53767
ordbomb		ldx		v_temp2
			lda		g_bomby,X
			tay
			lda		g_sclo,Y
			sta		m_zerop5
			lda		g_schi,Y
			sta		m_zerop6
			lda		g_bombx,X
			tay
			lda		g_xchar,Y
			sta		v_temp6
			clc
			adc		m_zerop5
			sta		m_zerop5
			lda		m_zerop6
			adc		#0
			sta		m_zerop6
			lda		g_bombx,X
			tay
			lda		g_pixbits,Y
			sta		v_temp1
			lda		v_temp4
			beq		notimebomb
			cpx		v_tbindex
			bne		notimebomb
			jmp		clearbomb
			;check if there's anything to erase
notimebomb	ldy		#0
			lda		(m_zerop5),Y
			and		v_temp1
			cmp		v_temp1
			bne		noeraseb
			lda		(m_zerop5),Y
			eor		v_temp1
			sta		(m_zerop5),Y
noeraseb	lda		g_bomby,X
			clc
			adc		#1
			sta		g_bomby,X
			lda		m_zerop5
			clc
			adc		#20
			sta		m_zerop5
			lda		m_zerop6
			adc		#0
			sta		m_zerop6
			;check if hit anything
			lda		(m_zerop5),Y
			and		v_temp1
			cmp		v_temp1
			bne		nobbar
			jmp		clearbomb
nobbar		lda		(m_zerop5),Y
			ora		v_temp1
			sta		(m_zerop5),Y
			;check if hit missile base
			;can't use hardware collision
			;because of player #0 multiplexing
			lda		g_bomby,X
			sec
			sbc		#176
			bcc		nothitmb
			lda		g_bomby,X
			clc
			adc		#32
			sta		v_temp7
			lda		g_bombx,X
			clc
			adc		#48
			sta		v_temp8
			jsr		swbombcol
			ldx		v_temp2
			lda		v_temp9
			beq		nothitmb
			lda		g_sflag2
			and		#32
			cmp		#32
			beq		nothitmb
			lda		g_sflag2
			and		#64
			cmp		#64
			beq		nothitmb
			lda		#208
			sta		712
			jsr		mbexpinit		
nothitmb	lda		g_bomby,X
			cmp		#183
			bne		nobomb
			;decide if we can have a timebomb
			lda		v_temp4
			bne		clearbomb
			lda		53770
			sec
			sbc		53770
			bpl		clearbomb
			lda		g_sflag2
			and		#16
			cmp		#16
			beq		clearbomb
			lda		g_sflag2
			ora		#16
			sta		g_sflag2
			lda		#1
			sta		v_tbstage
			lda		#72
			sta		v_tbpos
			lda		#15
			sta		v_tbdel
			lda		#175
			sta		v_tbcolour
			lda		#10
			sta		tbtone
			lda		#207
			sta		tbvol
			lda		g_bombx,X
			clc
			adc		#48
			sta		v_tbhoriz
			stx		v_tbindex
			clc
			bcc		nobomb
clearbomb	lda		#0
			ldy		#0
			sta		g_bomby,X
			sta		g_bombx,X
			lda		(m_zerop5),Y
			and		v_temp1
			cmp		v_temp1
			bne		nobomb
			lda		(m_zerop5),Y
			eor		v_temp1
			sta		(m_zerop5),Y
nobomb		inc		v_temp2
			lda		v_temp2
			cmp		m_bcnt
			beq		bombdone
			jmp		droploop
bombdone	rts	

swbombcol	lda		#0
			sta		v_temp9
			lda		v_temp8
			sec
			sbc		vbi_ppos
			bcc		nobombcol
			sta		v_temp10
			lda		#8
			sec		
			sbc		v_temp10
			bcc		nobombcol
			ldx		v_temp10
			lda		g_pixbits,X
			sta		v_temp10
			ldy		v_temp7
			lda		31744,Y
			and		v_temp10
			cmp		v_temp10
			bne		nobombcol
			lda		#1
			sta		v_temp9
nobombcol	rts

;hardware missiles dropped from stratosleds
stratbombs	lda		#0
			sta		v_temp2
sdroploop	ldx		v_temp2
			lda		s_bomby,X
			bne		contsbomb
			jmp		nosbomb
contsbomb	dec		s_bombhd,X
			lda		s_bombhd,X
			bne		drawsbomb
			lda		#4
			sta		s_bombhd,X
			;do homing in after pause
			lda		s_bombx,X
			sec
			sbc		#4
			cmp		vbi_ppos
			beq		drawsbomb
			sec
			sbc		vbi_ppos
			bmi		movesbr
			dec		s_bombx,X
			clc
			bcc		drawsbomb
movesbr		inc		s_bombx,X
drawsbomb	lda		s_bombx,X
			sta		53253,X		
			ldy		s_bomby,X
			lda		31488,Y
			and		s_bombp,X
			cmp		s_bombp,X
			bne		snoeraseb
			lda		31488,Y
			eor		s_bombp,X
			sta		31488,Y
snoeraseb	lda		s_bomby,X
			clc
			adc		#1
			sta		s_bomby,X
			tay
			lda		31488,Y
			eor		s_bombp,X
			sta		31488,Y
			lda		s_bomby,X
			sec
			sbc		#32
			tay
			lda		g_sclo,Y
			sta		m_zerop5
			lda		g_schi,Y
			sta		m_zerop6
			lda		s_bombx,X
			sec
			sbc		#48
			tay
			lda		g_xchar,Y
			clc
			adc		#0
			adc		m_zerop5
			sta		m_zerop5
			lda		m_zerop6
			adc		#0
			sta		m_zerop6
			lda		s_bombx,X
			sec
			sbc		#48
			tay
			lda		g_pixbits,Y
			sta		v_temp1
			;check if hit anything
			;can't use hardware collision
			;because of player#0 being multiplexed
			;we have to call swbombcol twice (second time with increased x pos)
			;because there two pixels are being used
			;for the hardware missiles
			lda		s_bomby,X
			sec
			sbc		#196
			bcc		nohc
			lda		s_bombx,X
			sta		v_temp8
			lda		s_bomby,X
			sta		v_temp7
			jsr		swbombcol
			ldx		v_temp2
			lda		v_temp9
			beq		nohc
			inc		v_temp8
			jsr		swbombcol
			ldx		v_temp2
			lda		v_temp9
			beq		nohc
			;hit missile base
hc			lda		g_sflag2
			and		#32
			cmp		#32
			beq		nohc
			lda		g_sflag2
			and		#64
			cmp		#64
			beq		nohc
			lda		#64
			sta		712
			jsr		mbexpinit
nohc		ldy		#0
			lda		(m_zerop5),Y
			and		v_temp1
			cmp		v_temp1
			bne		nosbbar
			lda		s_bomby,X
			sec
			sbc		#180
			bmi		nosbbar
			clc
			bcc		clearsbomb
nosbbar		lda		s_bomby,X
			cmp		#212
			bne		nosbomb
clearsbomb	ldy		s_bomby,X
			lda		31488,Y
			eor		s_bombp,X
			sta		31488,Y
			lda		#0
			sta		s_bomby,X
			sta		s_bombx,X
			ldy		#0
			lda		(m_zerop5),Y
			and		v_temp1
			cmp		v_temp1
			bne		nosbomb
			lda		(m_zerop5),Y
			eor		v_temp1
			sta		(m_zerop5),Y
nosbomb		inc		v_temp2
			lda		v_temp2
			cmp		#3
			beq		sbombdone
			jmp		sdroploop
sbombdone	rts	

;player has shot at multiplexed sprite
hitmulti	lda		g_sflag2
			and		#4
			cmp		#4
			bne		hm1
			lda		#0
			sta		53278
			rts
hm1			lda		53256
			bne		hm2
			rts
			;detect which multiplex sprite we hit
hm2			lda		vbi_plmissy
			sec
			sbc		#32
			tay
			lda		g_mindex,Y
			tay
			cpy		#0
			beq		hitbs
			jmp		notbs
			;we hit the bonus points ship
			;need to find out how many points
hitbs		lda		#60
			sta		bstone
			lda		#239
			sta		53765
			lda		#136
			sta		m_digit1
			lda		#1
			sta		m_sinput1
			lda		#5
			sta		m_sinput2
			lda		#168
			sta		m_digit2
			lda		53770
			sec
			sbc		53770
			bpl		rscore2
			lda		m_digit1
			clc
			adc		#8
			sta		m_digit1
			inc		m_sinput1
rscore2		lda		53770
			sec
			sbc		53770
			bmi		rscore3
			lda		m_digit1
			clc
			adc		#8
			sta		m_digit1
			inc		m_sinput1
rscore3		lda		53770
			sec
			sbc		53770
			bpl		rscore4
			lda		m_digit1
			clc
			adc		#8
			sta		m_digit1
			inc		m_sinput1
rscore4		lda		#0
			sta		oldmtype
			sta		m_exppos
			lda		#3
			sta		m_mtype
			ldy		vbi_plmissy
			tya
			clc
			adc		missdec
			tay
			lda		31488,Y
			eor		#3
			sta		31488,Y
			lda		g_sflag
			and		#2
			cmp		#2
			bne		rscore5
			lda		g_sflag
			eor		#2
			sta		g_sflag
rscore5		lda		g_sflag2
			ora		#4
			sta		g_sflag2
			lda		#0
			sta		53278
			lda		#0
			sta		53763
			rts
notbs		lda		g_sflag
			and		#128
			cmp		#128
			beq		hm4
			lda		m_mtype,Y
			sta		oldmtype
			cmp		#2
			bne		notsnossp
			lda		g_sflag
			ora		#32
			sta		g_sflag
notsnossp	lda		#3
			sta		m_mtype,Y
			lda		#223
			sta		m_mcol1,Y
			lda		#0
			sta		m_exppos,Y
			ldy		vbi_plmissy
			tya
			clc
			adc		wmissdec
			tay
			lda		31488,Y
			eor		#3
			sta		31488,Y
			lda		g_sflag
			and		#2
			cmp		#2
			bne		hm3
			lda		g_sflag
			eor		#2
			sta		g_sflag
			lda		#48
			sta		53762
			lda		#15
			sta		53763
hm3			lda		g_sflag2
			ora		#4
			sta		g_sflag2
			lda		oldmtype
			cmp		#2
			bne		hm4
			lda		g_sflag2
			ora		#8
			sta		g_sflag2
			lda		#128
			sta		paralysis
hm4			lda		#0
			sta		53278
			rts
		
			run start ;Define run address