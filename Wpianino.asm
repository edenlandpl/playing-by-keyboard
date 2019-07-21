format MZ
stack stk:256
entry text:main

macro delay time
{
local ext, iter
	push cx
	mov cx, time
ext:
	push cx
	mov cx, 0FFFFh
iter:
	loop iter
	pop cx
	loop ext
	pop cx
}
macro silence
{
    in al,61h ;cisza al z portu 61h
    and al,0fch ;ustawiamy 1 na najmlodyszm bajcie
    out 61h,al ;wysylamy do portu 61h (wyciszajac glosnik)
}

segment data_16 use16
_stare09 dw ?
	 dw ?

mark_09 dw 320
znakQ  db 01h
znakim dw 11D1h, 0FDFh, 0E24h, 0d59h, 0Be4h, 0a98h, 0970h, 08E9h
znaki2m dw 10D1h, 0EFBh, 0C99h, 0B39h, 0A00h

atryb db 71h
flaga db 0

segment text use16

moje09: push ax
	push bx
	push es
	in al,60h

	cmp al,42
	jne dalej3
	mov byte [flaga],1
	jmp dalej

dalej3: cmp al,170
	jne dalej1
	mov byte [flaga],0
	jmp dalej

dalej1: sub al,10h
	cmp al,0
	ja dalej6
	mov ah,0
	mov al, [flaga]
	test al,0FFh
	jz dalej
	mov bx, 0h
	mov [znakQ], bl
	jmp dalej

dalej5: jmp play

dalej6: sub al,0Fh; roznica miedzy q a h w scancodach
	cmp al,5; sprawdzenie czy nasz scancode jest w zadanym przedziale
	ja dalej7
		cmp al, 2
		je  dalej
		cmp al, 2
		jl  not_add
		dec al
not_add:	
		mov ah,0
	mov bx, znaki2m ;wskazanie gdzie sa litery
		shl ax, 1
	add bx,ax
	mov al, [flaga]
	test al,0FFh ;sprawdzenie czy mamy shift
	jz dalej5    ;skok do wyswietlenia jesli nie   
	jmp dalej   ;skok do wyswietlania
		
dalej7: sub al,0Dh; roznica miedzy q a h w scancodach
	cmp al,7; sprawdzenie czy nasz scancode jest w zadanym przedziale
	ja dalej
	mov ah,0
	mov bx, znakim ;wskazanie gdzie sa litery
	shl ax, 1
	add bx,ax
	mov al, [flaga]
	test al,0FFh ;sprawdzenie czy mamy shift
	jz dalej5    ;skok do wyswietlenia jesli nie   
	jmp dalej   ;skok do wyswietlania
		

dalej:
	in al,61h
	or al,80h
	out 61h,al
	and al,7Fh
	out 61h,al
	mov al,20h
	out 20h,al

	pop es
	pop bx
	pop ax

	iret

play:
	mov al,0B6h	    ;slowo stanu 10110110b (0B6h)-wybor 2-ego kanalu portu (glosnik)
	out 43h,al	    ;do portu 43h
	in al,61h
	or al,3
	out 61h,al
	mov si, bx
	mov ax, [si]

	out 42h,al
	mov al,ah
	out 42h,al
	delay 10
	silence
	jmp dalej
	
main:	mov ax,data_16
	mov ds,ax
	mov ax,stk
	mov ss,ax
	mov sp,256

	cli
	xor ax,ax
	mov es,ax
	les bx,[es:(9 shl 2)]
	mov [_stare09+2],es
	mov [_stare09],bx
	mov es,ax
	mov word [es:(9 shl 2)],moje09
	mov word [es:(9 shl 2)+2],text
	sti

loop_g:
	mov bl, 0FFh
	and bl, [znakQ]
	jnz loop_g

	cli
	xor ax,ax
	
	mov ax,data_16
	mov ds,ax
	les cx,dword [ds:_stare09]
	xor ax,ax
	mov ds,ax
	mov [ds:(9 shl 2)],cx
	mov [ds:(9 shl 2)+2],es
	
	mov ax,data_16
	mov ds,ax
	sti

	mov ax,4C00h
	int 21h

	ret

segment stk use16
	db 256 dup (?)
	
	