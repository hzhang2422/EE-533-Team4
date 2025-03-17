
bubble.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <main>:
   0:	fd010113          	addi	sp,sp,-48
   4:	02812623          	sw	s0,44(sp)
   8:	03010413          	addi	s0,sp,48
   c:	12400793          	li	a5,292     //addi
  10:	0007a583          	lw	a1,0(a5)
  14:	0047a603          	lw	a2,4(a5)
  18:	0087a683          	lw	a3,8(a5)
  1c:	00c7a703          	lw	a4,12(a5)
  20:	0107a783          	lw	a5,16(a5)
  24:	fcb42823          	sw	a1,-48(s0)
  28:	fcc42a23          	sw	a2,-44(s0)
  2c:	fcd42c23          	sw	a3,-40(s0)
  30:	fce42e23          	sw	a4,-36(s0)
  34:	fef42023          	sw	a5,-32(s0)
  38:	fe042623          	sw	zero,-20(s0)  // i=0
  3c:	0c80006f          	j	104 <main+0x104>
  40:	fe042423          	sw	zero,-24(s0)  // j=0
  44:	0a00006f          	j	e4 <main+0xe4>
  48:	fe842783          	lw	a5,-24(s0)
  4c:	00279793          	slli	a5,a5,0x2 //stall
  50:	ff078793          	addi	a5,a5,-16
  54:	008787b3          	add	a5,a5,s0
  58:	fe07a703          	lw	a4,-32(a5)
  5c:	fe842783          	lw	a5,-24(s0)
  60:	00178793          	addi	a5,a5,1
  64:	00279793          	slli	a5,a5,0x2
  68:	ff078793          	addi	a5,a5,-16
  6c:	008787b3          	add	a5,a5,s0
  70:	fe07a783          	lw	a5,-32(a5)
  74:	06e7d263          	bge	a5,a4,d8 <main+0xd8> //stall
  78:	fe842783          	lw	a5,-24(s0)
  7c:	00279793          	slli	a5,a5,0x2 stall
  80:	ff078793          	addi	a5,a5,-16
  84:	008787b3          	add	a5,a5,s0
  88:	fe07a783          	lw	a5,-32(a5)
  8c:	fef42223          	sw	a5,-28(s0) //stall
  90:	fe842783          	lw	a5,-24(s0)
  94:	00178793          	addi	a5,a5,1
  98:	00279793          	slli	a5,a5,0x2
  9c:	ff078793          	addi	a5,a5,-16
  a0:	008787b3          	add	a5,a5,s0
  a4:	fe07a703          	lw	a4,-32(a5)
  a8:	fe842783          	lw	a5,-24(s0)
  ac:	00279793          	slli	a5,a5,0x2
  b0:	ff078793          	addi	a5,a5,-16
  b4:	008787b3          	add	a5,a5,s0
  b8:	fee7a023          	sw	a4,-32(a5)
  bc:	fe842783          	lw	a5,-24(s0)
  c0:	00178793          	addi	a5,a5,1 //stall
  c4:	00279793          	slli	a5,a5,0x2
  c8:	ff078793          	addi	a5,a5,-16
  cc:	008787b3          	add	a5,a5,s0
  d0:	fe442703          	lw	a4,-28(s0)
  d4:	fee7a023          	sw	a4,-32(a5)
  d8:	fe842783          	lw	a5,-24(s0)
  dc:	00178793          	addi	a5,a5,1 //stall
  e0:	fef42423          	sw	a5,-24(s0) 
  e4:	00400713          	li	a4,4  
  e8:	fec42783          	lw	a5,-20(s0)
  ec:	40f707b3          	sub	a5,a4,a5 //stall 4-i
  f0:	fe842703          	lw	a4,-24(s0) //a4=j
  f4:	f4f74ae3          	blt	a4,a5,48 <main+0x48> //stall
  f8:	fec42783          	lw	a5,-20(s0)
  fc:	00178793          	addi	a5,a5,1
 100:	fef42623          	sw	a5,-20(s0)
 104:	fec42703          	lw	a4,-20(s0) //i=0
 108:	00300793          	li	a5,3
 10c:	f2e7dae3          	bge	a5,a4,40 <main+0x40>
 110:	00000793          	li	a5,0
 114:	00078513          	mv	a0,a5
 118:	02c12403          	lw	s0,44(sp)
 11c:	03010113          	addi	sp,sp,48
 120:	00008067          	ret
