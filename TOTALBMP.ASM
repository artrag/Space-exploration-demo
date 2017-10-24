		output "TOTALBMP.ROM"

		defpage	 0,0x4000, 0x2000		; page 0 main code 
		defpage	 1,0x6000, 0x2000		; page 1 
		defpage	 2..31					; swapped data 
	
		;	konami scc
		
_kBank1:	equ 05000h ;- 57FFh (5000h used)
_kBank2: 	equ 07000h ;- 77FFh (7000h used)
_kBank3: 	equ 09000h ;- 97FFh (9000h used)
_kBank4: 	equ 0B000h ;- B7FFh (B000h used)

			MACRO   VDP_SetReg register        ;Set value A in the specified register
			di
			out	(#99),a
			ld	a,register+128
			out	(#99),a
			ei
			ENDM	

			page 0
		
			org 4000h
			dw  4241h,START,0,0,0,0,0,0
		
			; make happy the map guessers
			ld	(_kBank1),a
			ld	(_kBank2),a
			ld	(_kBank3),a
			ld	(_kBank4),a
			
screeninit:
			ld		a,8
			call	005fh		

			di                
			ld     a,#0A      
			out    (#99),a    
			ld     a,#88      
			out    (#99),a  	; no sprites

			ld		a,#1F           
			out    	(#99),a    
			ld		a,#82
			out    	(#99),a    ; set page 0			
			ei

			ld		hl,0h
			call	0053h		

			ld		de,256*:_opening+8+8

2:			ld	a,d
			ld	(_kBank2),a
			ld	hl,0x6000
			
			ld	bc,0x98
			ld	a,32
1:			otir
			dec	a
			jp	nz,1b
			inc	d
			dec	e
			jr	nz,2b
			ret
			

;
;	Wait until the VDP is done copying.
;
VDP_Ready:    
			ld      a,2
			di
			out     (#99),a          ;select s#2
			ld      a,15+128
			out     (#99),a
			in      a,(#99)
			rra
			ld      a,0              ;select s#0
			out     (#99),a
			ld      a,15+128
			ei
			out     (#99),a
			jp      c,VDP_Ready
			ret
			  

		
START:  
			call	screeninit
mode7YMMM:
			xor a
			VDP_SetReg 34 	;	R34 = 0		; source page for ground
			ld	a,1 
			VDP_SetReg 35 	;	R35 = 1		; source page for ground

			xor 	a
			VDP_SetReg 36 	;	R36 = 0
			xor		a
			VDP_SetReg 37	;	R37 = 0		; DX = 0


			ld a,1
			VDP_SetReg 42 	;	R42 = 1		; NYl = 1
			xor a 
			VDP_SetReg 43	;	R43 = 0		; NYh = 0

			xor a
			VDP_SetReg 45 	;	R45 = 0		; mode
			

			ld e,0
2:			halt
			ld 		a,106
			VDP_SetReg 38 	;	R38 = 106	; DY = 106		; first line on the screen
			xor     a 
			VDP_SetReg 39 	;	R39 = 0

			ld	a,1 
			VDP_SetReg 35 	;	R35 = 1		; source page for ground

			ld hl,raster_tab
			ld b,106
			
1:			call 	VDP_Ready
			ld a,1
			VDP_SetReg 42 	;	R42 = 1		; NYl = 1
			
			ld a,(hl)
			sub a,e
			cp 255
			jr nz,3f
			inc a
3:			VDP_SetReg 34 	;	R34 = source
			
			ld a,#E0
			VDP_SetReg 46 	;	R46 = #E0		; execute YMMM command
			
			inc hl

			djnz 1b
			inc e
			jp 2b
			
		
		
_START:  
		call	screeninit
		
		ld de,0
		
2:		halt              ; allow ISR
		di
		ld		a,d
		out    	(#99),a    
		ld		a,23 or 010000000b
		out    	(#99),a  	; scroll=0
				
        ld		a,#1F           
		out    	(#99),a    
		ld		a,#82
		out    	(#99),a    ; set page 0
		ei
		call   	raster_wave
		
		inc		de
		jp		2b    
;S#2		
;b6	VR: Vertical scanning line timing flag
;		During vertical retrace and while lower and upper bordersare drawn, this flag is set to 1.

;b5	HR: Horizontal scanning line timing flag
;		During horizontal retrace and while left and right borders are drawn, this flag is set to 1.
       
raster_wave:   
		di     
		
		ld     a,#97      
		out    (#99),a    
		ld     a,#91      
		out    (#99),a  	; write R#23 using port 0x9B and R#17
		
		ld		a,106
		add		a,d
		out    	(#99),a    
		ld		a,19 or 010000000b
		out    	(#99),a  	; Set FH at line 106

		ld     a,#01      
        out    (#99),a    
		ld     a,#8f      
		out    (#99),a		; read S#1

1:   						; wait for start of the line in R#19
		in a,(#99)
        rrca
        jp nc,1b		

        ld		a,#3F           
		out    	(#99),a    
		ld		a,#82
		out    	(#99),a    ; set page 1
		
		ld     a,#02      
        out    (#99),a    
		ld     a,#8f      
		out    (#99),a		; read S#2
		

		ld     	hl,raster_tab
		ld		b,103

.loop:
		ld	a,(hl)
		sub	a,e
		inc	hl
		ex af,af'
		
1:   	in     a,(#99)     ; wait for HR start  the line
		bit    5,a        
		jp     z,1b   
		
		ex af,af'
		out	(#9B),a
		djnz .loop        
		
		xor    a          
		out    (#99),a    
		ld     a,#8f      
		out    (#99),a    
		ei                
		ret
		
           
		code @ 4200h, # 256 
raster_tab:  
		repeat 256
		db (@#-256/(1+@#)) & 255
		endrepeat
end_raster_tab:

		page 1

_opening:
		incbin "galaxy.bin",0x0000,0x2000
		page 2
		incbin "galaxy.bin",0x2000,0x2000
		page 3
		incbin "galaxy.bin",0x4000,0x2000
		page 4
		incbin "galaxy.bin",0x6000,0x2000
		page 5
		incbin "galaxy.bin",0x8000,0x2000
		page 6
		incbin "galaxy.bin",0xA000,0x2000
		page 7
		incbin "galaxy.bin",0xC000,0x2000
		page 8
		incbin "galaxy.bin",0xE000,0x2000
		page 9
		incbin "PLASMA.bin",0x0000,0x2000
		page 10
		incbin "PLASMA.bin",0x2000,0x2000
		page 11
		incbin "PLASMA.bin",0x4000,0x2000
		page 12
		incbin "PLASMA.bin",0x6000,0x2000
		page 13
		incbin "PLASMA.bin",0x8000,0x2000
		page 14
		incbin "PLASMA.bin",0xA000,0x2000
		page 15
		incbin "PLASMA.bin",0xC000,0x2000
		page 16
		incbin "PLASMA.bin",0xE000,0x2000
		
