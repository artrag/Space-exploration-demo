		output "TOTALRAS.rom"

		defpage	 0,0x4000, 0x2000		; page 0 main code 
		defpage	 1,0x6000, 0x2000		; page 1 
		defpage	 2..31					; swapped data 
	
		;	konami scc
		
_kBank1:	equ 05000h ;- 57FFh (5000h used)
_kBank2: 	equ 07000h ;- 77FFh (7000h used)
_kBank3: 	equ 09000h ;- 97FFh (9000h used)
_kBank4: 	equ 0B000h ;- B7FFh (B000h used)
	
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

		ei

		ld		hl,0h
		call	0053h		

		ld		de,256*:_opening+8+8
		
outvram:
2:		ld	a,d
		ld	(_kBank2),a
		ld	hl,0x6000
		
		ld	bc,0x98
		ld	a,32
1:		otir
		dec	a
		jp	nz,1b
		inc	d
		dec	e
		jr	nz,2b
		ret
		
		
		
		
START:  
		call	screeninit
		
		ld de,0
		
2:		halt              ; allow ISR
		di
		ld		a,d
		out    	(#99),a    
		ld		a,23 or 010000000b
		out    	(#99),a  	; scroll=0
				
        ld		a,#3F           
		out    	(#99),a    
		ld		a,#82
		out    	(#99),a    ; set page 1
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

        ld		a,#1F           
		out    	(#99),a    
		ld		a,#82
		out    	(#99),a    ; set page 0
		
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
		
           

raster_tab:  
		repeat 256
		db (@#-256/(1+@#)) & 255
		endrepeat
  
		; include rast_mode8.txt		; include rast.txt
end_raster_tab:

		page 1
_opening:
		incbin "PLASMA.bin",0x0000,0x2000
		page 2
		incbin "PLASMA.bin",0x2000,0x2000
		page 3
		incbin "PLASMA.bin",0x4000,0x2000
		page 4
		incbin "PLASMA.bin",0x6000,0x2000
		page 5
		incbin "PLASMA.bin",0x8000,0x2000
		page 6
		incbin "PLASMA.bin",0xA000,0x2000
		page 7
		incbin "PLASMA.bin",0xC000,0x2000
		page 8
		incbin "PLASMA.bin",0xE000,0x2000

		page 9
		incbin "galaxy.bin",0x0000,0x2000
		page 10
		incbin "galaxy.bin",0x2000,0x2000
		page 11
		incbin "galaxy.bin",0x4000,0x2000
		page 12
		incbin "galaxy.bin",0x6000,0x2000
		page 13
		incbin "galaxy.bin",0x8000,0x2000
		page 14
		incbin "galaxy.bin",0xA000,0x2000
		page 15
		incbin "galaxy.bin",0xC000,0x2000
		page 16
		incbin "galaxy.bin",0xE000,0x2000
		
