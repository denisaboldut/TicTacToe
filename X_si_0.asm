.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc


includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Proiect asamblare",0
area_width EQU 700
area_height EQU 600
area DD 0

counter DD 0 ; numara evenimentele de tip timer

culoare DD 0



ocupat  db 9 dup (0)  ;pentru a verifica daca este ocupat sau nu patratelul




;dimensiuni simbol x sau 0
Xsau0_width EQU 70  
Xsau0_height EQU 70  

doi dd 2

miscari dd 0;numar maxim de miscari in cadran =9
castigat dd 0  ;va avea valoarea 1 daca a castigat careva

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16 
arg4 EQU 20   

symbol_width EQU 10
symbol_height EQU 20

include digits.inc
include letters.inc
include Xsi0.inc

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0ff1414h
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi],0ffffh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

desenam_X_0 proc
  push ebp
  mov ebp,esp
  pusha
     desenam_X:
       mov eax, [ebp+arg1]
       cmp eax,'X'
       jne desenam_0
       sub eax,'X'
       lea esi,Xsi0 
       mov culoare, 0ff9434h
      jmp desenam
	 desenam_0:
	   mov eax,1
	   mov culoare, 0B338B3h
	   lea esi,Xsi0
	 desenam:
         mov ebx, Xsau0_width	
         mul ebx
         mov ebx, Xsau0_width
		 mul ebx 
		 
		 add esi,eax
		 mov ecx,Xsau0_width
		 
		 
	buclalinii:
	mov edi, [ebp+arg2] ; matricea de pixeli
	mov eax, [ebp+arg4] ;y
	add eax, Xsau0_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ;  x
	shl eax, 2 ; inmultim cu 4
	add edi, eax
	push ecx
	mov ecx, Xsau0_height
buclacoloane:
	cmp byte ptr [esi], 0
	je next
	mov edx, culoare
	mov dword ptr [edi], edx

next:
	inc esi
	add edi, 4
	loop buclacoloane
	pop ecx
	loop buclalinii
	popa
	mov esp, ebp
	pop ebp
	ret
desenam_X_0 endp

desenam_X_0macro macro simbol,aria, x, y
	push y
	push x
	push area
	push simbol
	call desenam_X_0
	add esp, 16
endm



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;jocul	   
punemX proc
   push ebp
   mov ebp,esp
   pusha
   
	mov ebx,[ebp+arg1];x esi
	mov edx,[ebp+arg2];y edi
	cmp edx,250
	jl PrimulRand
	
		
	jmp gata1	
	PrimulRand:
		cmp ebx,300
		jl primul_patratel_1
		cmp ebx,400
		jg alTreilea_patratel_1
		cmp ocupat[1],0
		jne esteOcupat
	    desenam_X_0macro 'X',area,310,160
	    mov ocupat[1],1
	jmp gata
	
	primul_patratel_1:
	    cmp ocupat[0],0
		jne esteOcupat
		desenam_X_0macro 'X',area,210,160
		mov ocupat[0],1
		jmp gata
	alTreilea_patratel_1:
	   cmp ocupat[2],0
		jne esteOcupat
	    desenam_X_0macro 'X',area,410,160
   mov	ocupat[2],1
	    jmp gata
		
	gata1: 
	cmp edx, 350
	jg AlTreileaRand
	
	cmp ebx,300
	jl primul_patratel_3
	cmp ebx,400
	jg alTreilea_patratel_3
	cmp ocupat[4],0
	jne esteOcupat
	desenam_X_0macro 'X',area,310,260
    mov ocupat[4],1	
	jmp gata
	primul_patratel_3:
	cmp ocupat[3],0
	jne esteOcupat
		desenam_X_0macro 'X',area,210,260
		mov ocupat[3],1
		jmp gata
	alTreilea_patratel_3:
	cmp ocupat[5],0
	jne esteOcupat
	    desenam_X_0macro 'X',area,410,260
		mov ocupat[5],1
	    jmp gata
		

	
	AlTreileaRand:
	cmp ebx,300
	jl primul_patratel_2
	cmp ebx,400
	jg alTreilea_patratel_2
	cmp ocupat[7],0
	jne esteOcupat
	desenam_X_0macro 'X',area,310,360
	mov ocupat[7],1
	jmp gata
	primul_patratel_2:
	  cmp ocupat[6],0
	  jne esteOcupat
		desenam_X_0macro 'X',area,210,360
		mov ocupat[6],1
		jmp gata
	alTreilea_patratel_2:
	cmp ocupat[8],0
	jne esteOcupat
	    desenam_X_0macro 'X',area,410,360
		mov ocupat[8],1
	
	    jmp gata
		
   esteOcupat:
	dec miscari
	
	
	gata:
   popa
   mov esp, ebp
   pop ebp
   ret 8
punemX endp 
   
   
   punem0 proc
   push ebp
   mov ebp,esp
   pusha
   
	mov ebx,[ebp+arg1];x esi
	mov edx,[ebp+arg2];y edi
	cmp edx,250
	jl PrimulRand          ;trecem pe prima linie
	
		
	jmp gata1	            ;altfel trecem pe linia 3  
	PrimulRand:
		cmp ebx,300
		jl primul_patratel_1
		cmp ebx,400
		jg alTreilea_patratel_1
		
		cmp ocupat[1],0                    ;;;;;;;;;;
		jne esteOcupat                       ;;;;;;;;;;
	    desenam_X_0macro 'O',area,310,160   ;;;;;;;;;;
	    mov ocupat[1], 2                     ;;;;;;;;;;
		
	jmp gata
	
	primul_patratel_1:

	    cmp ocupat[0],0
		jne esteOcupat
		desenam_X_0macro 'O',area,210,160
		mov ocupat[0],2
		
		jmp gata
	alTreilea_patratel_1:
	
	   cmp ocupat[2],0
		jne esteOcupat
	    desenam_X_0macro 'O',area,410,160
		mov ocupat[2],2
		
	    jmp gata
		
	gata1: 
	cmp edx, 350
	jg AlTreileaRand        ;trecem pe a 3-a linie
	                        ;altfel ramanem pe linia 2
	cmp ebx,300
	jl primul_patratel_3
	cmp ebx,400
	jg alTreilea_patratel_3
	
	cmp ocupat[4],0
	jne esteOcupat
	desenam_X_0macro 'O',area,310,260
    mov ocupat[4],2
	
	jmp gata
	primul_patratel_3:
	
	cmp ocupat[3],0
	jne esteOcupat
		desenam_X_0macro 'O',area,210,260
		mov ocupat[3],2
		
		jmp gata
	alTreilea_patratel_3:
	
	cmp ocupat[5],0
	jne esteOcupat
	    desenam_X_0macro 'O',area,410,260
		mov ocupat[5],2
		
	    jmp gata
	

	AlTreileaRand:         ;suntem pe a treia linie
	cmp ebx,300
	jl primul_patratel_2
	cmp ebx,400
	jg alTreilea_patratel_2
	
	cmp ocupat[7],0
	jne esteOcupat
	desenam_X_0macro 'O',area,310,360
	mov ocupat[7],2
	
	jmp gata
	primul_patratel_2:
	
	  cmp ocupat[6],0
	  jne esteOcupat
		desenam_X_0macro 'O',area,210,360
		mov ocupat[6],2
		
		jmp gata
	alTreilea_patratel_2:
	
	cmp ocupat[8],0
	jne esteOcupat
	    desenam_X_0macro 'O',area,410,360
		mov ocupat[8],2
	
	    jmp gata

 	 esteOcupat:
	dec miscari
gata:

   popa
   mov esp, ebp
   pop ebp
   ret 8
punem0 endp 

  
 schimbare_jucator proc 
  push ebp
  mov ebp,esp
  pusha
  

  inc miscari
  cmp miscari, 9 
  jg sfarsit
  cmp castigat,1
  je sfarsit
  mov eax,miscari
  xor edx,edx
  div doi
  cmp edx,0
  je trebuieX
  push [ebp+12]
  push [ebp+8]
  call punem0
  jmp sfarsit
  trebuieX:
	  push [ebp+12]
	  push [ebp+8]
	  call punemX
	
  sfarsit:
  popa
  mov esp,ebp
  pop ebp
  ret 8
 schimbare_jucator endp
 
;macro pentru a desena o linie verticala
	linieVerticala macro x,y
	local bucla,final
	pusha
	mov edi, area
	mov esi, area_width
	shl ESI, 2
	
	mov EAX, y ; coordonata y 
	mov EBX, area_width
	mul EBX
	
	add EAX, x ; coordonata x
	shl EAX, 2

    mov ecx,300  ;lungimea
	
	bucla:
		mov ebx, eax
		add ebx, edi
		mov dword ptr[EbX], 0 ; facem negru

		add EAX, ESI; area_width, inaintam pe verticala in jos
		
		sub ECX,1 
		cmp ecx,1
		jg bucla
		je final
	final:
		popa
		endm
	
     ;macro pentru a desena o linie orizontala	
		linieOrizontala macro x,y
		local bucla,final
		pusha
	      mov edi, area
	      mov esi, area_width
	      shl ESI, 2
	
	      mov EAX, y ;
	      mov EBX, area_width
	      mul EBX
	
	     add EAX, x ; 
	     shl EAX, 2
	
	     mov ecx,1200
	
	bucla:
		mov ebx, eax
		add ebx, edi
		mov dword ptr[EbX], 0 ; facem negru
	
	     add EAX, 1  ;inaintam pe orizontala la dreapta
		
		sub ECX,1 
		cmp ecx,1
		jg bucla
		je final
	final:
		popa
		endm
	

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra 


initializare:
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 0b2abc2h    ;culoare fundal
	push area
	call memset
	add esp, 12
	linieVerticala 200,150
	linieVerticala 300,150
	linieVerticala 400,150
    linieVerticala 500,150
	linieOrizontala 200,150
	linieOrizontala 200,250
	linieOrizontala 200,350
    linieOrizontala 200,450
	jmp evt_timer
			
 
	evt_click:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov edx,[ebp+arg3];y
	mov ebx,[ebp+arg2];x
	
	cmp edx,150
	jl esteAfara
    ; desenam_X_0macro 'O',area,ebx,eax
	cmp edx,450
	jge esteAfara
	cmp ebx,200
	jl esteAfara
	cmp ebx,500
	jg esteAfara
	
	;push [ebp+arg3];y
	;push [ebp+arg2];x
   ; call punemX
	push [ebp+arg3];y
	push [ebp+arg2];x
	;call punem0

	
	call schimbare_jucator 
	
	cmp ocupat[1],1
	je  verificLinieInJos
	jmp next
	
	verificLinieInJos:
	cmp ocupat[4],1
	je verificLinieSImaiJos
	jmp next
	
	verificLinieSImaiJos:
	cmp ocupat[7],1
	je castigatorX
	jmp next
	
	next:
	cmp ocupat[0],1
	je  verificLinieInJos1
	jmp next1
	
	verificLinieInJos1:
	cmp ocupat[3],1
	je verificLinieSImaiJos1
	jmp next1
	
	verificLinieSImaiJos1:
	cmp ocupat[6],1
	je castigatorX
	jmp next1
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	next1:
	cmp ocupat[2],1
	je  verificLinieInJos2
	jmp next2
	
	verificLinieInJos2:
	cmp ocupat[5],1
	je verificLinieSImaiJos2
	jmp next2
	
	verificLinieSImaiJos2:
	cmp ocupat[8],1
	je castigatorX
	jmp next2
	
	next2:
	cmp ocupat[0],1
	je  verificLinieInJos3
	jmp next3
	
	verificLinieInJos3:
	cmp ocupat[1],1
	je verificLinieSImaiJos3
	jmp next3
	
	verificLinieSImaiJos3:
	cmp ocupat[2],1
	je castigatorX
	jmp next3
	
	next3:
	cmp ocupat[3],1
	je  verificLinieInJos4
	jmp next4
	
	verificLinieInJos4:
	cmp ocupat[4],1
	je verificLinieSImaiJos4
	jmp next4
	
	verificLinieSImaiJos4:
	cmp ocupat[5],1
	je castigatorX
	jmp next4
	
	next4:
	cmp ocupat[6],1
	je  verificLinieInJos5
	jmp next5
	
	verificLinieInJos5:
	cmp ocupat[7],1
	je verificLinieSImaiJos5
	jmp next5
	
	verificLinieSImaiJos5:
	cmp ocupat[8],1
	je castigatorX
	jmp next5
	
	next5:
	cmp ocupat[2],1
	je  verificLinieInJos6
	jmp next6
	
	verificLinieInJos6:
	cmp ocupat[4],1
	je verificLinieSImaiJos6
	jmp next6
	
	verificLinieSImaiJos6:
	cmp ocupat[6],1
	je castigatorX
	jmp next6
	
	next6:
	cmp ocupat[0],1
	je  verificLinieInJos7
	jmp next7
	
	verificLinieInJos7:
	cmp ocupat[4],1
	je verificLinieSImaiJos7
	jmp next7
	
	verificLinieSImaiJos7:
	cmp ocupat[8],1
	je castigatorX
	jmp next7
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;pentru 0
	next7:
	cmp ocupat[1],2
	je  verificLinieInJos0
	jmp next0
	
	verificLinieInJos0:
	cmp ocupat[4],2
	je verificLinieSImaiJos0
	jmp next0
	
	verificLinieSImaiJos0:
	cmp ocupat[7],2
	je castigator0
	jmp next0
	
	next0:
	cmp ocupat[0],2
	je  verificLinieInJos10
	jmp next10
	
	verificLinieInJos10:
	cmp ocupat[3],2
	je verificLinieSImaiJos10
	jmp next10
	
	verificLinieSImaiJos10:
	cmp ocupat[6],2
	je castigator0
	jmp next10
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	next10:
	cmp ocupat[2],2
	je  verificLinieInJos20
	jmp next20
	
	verificLinieInJos20:
	cmp ocupat[5],2
	je verificLinieSImaiJos20
	jmp next20
	
	verificLinieSImaiJos20:
	cmp ocupat[8],2
	je castigator0
	jmp next20
	
	next20:
	cmp ocupat[0],2
	je  verificLinieInJos30
	jmp next30
	
	verificLinieInJos30:
	cmp ocupat[1],2
	je verificLinieSImaiJos30
	jmp next30
	
	verificLinieSImaiJos30:
	cmp ocupat[2],2
	je castigator0
	jmp next30
	
	next30:
	cmp ocupat[3],2
	je  verificLinieInJos40
	jmp next40
	
	verificLinieInJos40:
	cmp ocupat[4],2
	je verificLinieSImaiJos40
	jmp next40
	
	verificLinieSImaiJos40:
	cmp ocupat[5],2
	je castigator0
	jmp next40
	
	next40:
	cmp ocupat[6],2
	je  verificLinieInJos50
	jmp next50
	
	verificLinieInJos50:
	cmp ocupat[7],2
	je verificLinieSImaiJos50
	jmp next50
	
	verificLinieSImaiJos50:
	cmp ocupat[8],2
	je castigator0
	jmp next50
	
	next50:
	cmp ocupat[2],2
	je  verificLinieInJos60
	jmp next60
	
	verificLinieInJos60:
	cmp ocupat[4],2
	je verificLinieSImaiJos60
	jmp next60
	
	verificLinieSImaiJos60:
	cmp ocupat[6],2
	je castigator0
	jmp next60
	
	next60:
	cmp ocupat[0],2
	je  verificLinieInJos70
	jmp next70
	
	verificLinieInJos70:
	cmp ocupat[4],2
	je verificLinieSImaiJos70
	jmp next70
	
	verificLinieSImaiJos70:
	cmp ocupat[8],2
	je castigator0
	jmp next70
	

	jmp esteAfara
	
	next70:
	cmp miscari,9
	je remiza
	
	jmp esteAfara
	
	castigatorX: 
	    make_text_macro 'A', area, 260, 100
		make_text_macro ' ', area, 270, 100
		make_text_macro 'C', area, 280, 100
		make_text_macro 'A', area, 290, 100
		make_text_macro 'S', area, 300, 100
		make_text_macro 'T', area, 310, 100
		make_text_macro 'I', area, 320, 100
		make_text_macro 'G', area, 330, 100
		make_text_macro 'A', area, 340, 100
		make_text_macro 'T', area, 350, 100
		make_text_macro 'X', area, 380, 100
		mov castigat,1
		jmp gataJOC
		
  castigator0:
		make_text_macro 'A', area, 260, 100
		make_text_macro ' ', area, 270, 100
		make_text_macro 'C', area, 280, 100
		make_text_macro 'A', area, 290, 100
		make_text_macro 'S', area, 300, 100
		make_text_macro 'T', area, 310, 100
		make_text_macro 'I', area, 320, 100
		make_text_macro 'G', area, 330, 100
		make_text_macro 'A', area, 340, 100
		make_text_macro 'T', area, 350, 100
		make_text_macro '0', area, 380, 100
		mov castigat,1
	jmp gataJOC
	
			   remiza:
	    make_text_macro 'R', area, 320, 100
		make_text_macro 'E', area, 330, 100
		make_text_macro 'M', area, 340, 100
		make_text_macro 'I', area, 350, 100
		make_text_macro 'Z', area, 360, 100
		make_text_macro 'A', area, 370, 100
		mov castigat,1
		jmp gataJOC
	
	
	;desenam_X_0macro 'X',area,ebx,edx
	esteAfara:

   
   evt_timer:
 
  
final_draw:
        ;mesaj
		;make_text_macro 'P', area, 110, 100
			make_text_macro 'X', area, 30, 10
			make_text_macro ' ', area, 40, 10
			make_text_macro 'S', area, 50, 10
			make_text_macro 'I', area, 60, 10
			make_text_macro ' ', area, 70, 10
			make_text_macro '0', area, 80, 10
			
				
	gataJOC:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp


start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	
	;terminarea programului
	push 0
	call exit
end start