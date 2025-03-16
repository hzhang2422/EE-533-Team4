
sort.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <main>:
   0:	fb010113          	addi	sp,sp,-80
   4:	04812623          	sw	s0,76(sp)
   8:	05010413          	addi	s0,sp,80
   c:	00000793          	li	a5,0
  10:	0007a303          	lw	t1,0(a5)         
  14:	0047a883          	lw	a7,4(a5)         
  18:	0087a803          	lw	a6,8(a5) 
  1c:	00c7a503          	lw	a0,12(a5)     
  20:	0107a583          	lw	a1,16(a5)     
  24:	0147a603          	lw	a2,20(a5)      
  28:	0187a683          	lw	a3,24(a5)       
  2c:	01c7a703          	lw	a4,28(a5)      
  30:	0207a783          	lw	a5,32(a5)      
  34:	0247ae03          	lw	t3,36(a5)
  38:	fa642023          	sw	t1,-96(s0)    
  3c:	fb142223          	sw	a7,-92(s0) 
  40:	fb042423          	sw	a6,-88(s0)  
  44:	faa42623          	sw	a0,-84(s0)  
  48:	fab42823          	sw	a1,-80(s0)  
  4c:	fac42a23          	sw	a2,-76(s0)
  50:	fad42c23          	sw	a3,-72(s0)
  54:	fae42e23          	sw	a4,-68(s0)
  58:	fcf42023          	sw	a5,-64(s0)
  5c:	fdc42223          	sw	t3,-60(s0)
  60:	fe042623          	sw	zero,-20(s0)
  64:	0bc0006f          	j	120 <main+0x120>
  68:	fec42783          	lw	a5,-20(s0)  
  6c:	00178793          	addi	a5,a5,1 
  70:	fef42423          	sw	a5,-24(s0)
  74:	0940006f          	j	108 <main+0x108> 
  78:	fe842783          	lw	a5,-24(s0)     
  7c:	00279793          	slli	a5,a5,0x2    
  80:	fa040713          	addi	a4,s0,-96    
  84:	00f707b3          	add	a5,a4,a5       
  88:	0007a703          	lw	a4,0(a5)
  8c:	fec42783          	lw	a5,-20(s0)
  90:	00279793          	slli	a5,a5,0x2
  94:	fa040693          	addi	a3,s0,-96 
  98:	00f687b3          	add	a5,a3,a5 
  9c:	0007a783          	lw	a5,0(a5)
  a0:	04f75e63          	bge	a4,a5,fc <main+0xfc> 
  a4:	fe842783          	lw	a5,-24(s0) 
  a8:	00279793          	slli	a5,a5,0x2   
  ac:	fa040713          	addi	a4,s0,-96   
  b0:	00f707b3          	add	a5,a4,a5 
  b4:	0007a783          	lw	a5,0(a5)    
  b8:	fef42223          	sw	a5,-28(s0)    
  bc:	fec42783          	lw	a5,-20(s0)    
  c0:	00279793          	slli	a5,a5,0x2   
  c4:	fa040713          	addi	a4,s0,-96 
  c8:	00f707b3          	add	a5,a4,a5 
  cc:	0007a703          	lw	a4,0(a5)
  d0:	fe842783          	lw	a5,-24(s0)  
  d4:	00279793          	slli	a5,a5,0x2  
  d8:	fa040693          	addi	a3,s0,-96  
  dc:	00f687b3          	add	a5,a3,a5 
  e0:	00e7a023          	sw	a4,0(a5) 
  e4:	fec42783          	lw	a5,-20(s0) 
  e8:	00279793          	slli	a5,a5,0x2 
  ec:	fa040713          	addi	a4,s0,-96 
  f0:	00f707b3          	add	a5,a4,a5 
  f4:	fe442703          	lw	a4,-28(s0)
  f8:	00e7a023          	sw	a4,0(a5) 
  fc:	fe842783          	lw	a5,-24(s0) 
 100:	00178793          	addi	a5,a5,1 
 104:	fef42423          	sw	a5,-24(s0) 
 108:	fe842703          	lw	a4,-24(s0) 
 10c:	00900793          	li	a5,9 
 110:	f6e7d4e3          	bge	a5,a4,78 <main+0x78>
 114:	fec42783          	lw	a5,-20(s0)  
 118:	00178793          	addi	a5,a5,1 
 11c:	fef42623          	sw	a5,-20(s0)
 120:	fec42703          	lw	a4,-20(s0) 
 124:	00800793          	li	a5,8   
 128:	f4e7d0e3          	bge	a5,a4,68 <main+0x68>
 12c:	00000793          	li	a5,0 
 130:	fa042303          	lw	t1,-96(s0)
 134:	0067a023          	sw	t1,0(a5)
 138:	fa442883          	lw	a7,-92(s0)
 13c:	0117a223          	sw	a7,4(a5)
 140:	fa842803          	lw	a6,-88(s0)
 144:	0107a423          	sw	a6,8(a5)
 148:	fac42503          	lw	a0,-84(s0)
 14c:	00a7a623          	sw	a0,12(a5)
 150:	fb042583          	lw	a1,-80(s0) 
 154:	00b7a823          	sw	a1,16(a5)
 158:	fb442603          	lw	a2,-76(s0)
 15c:	00c7aa23          	sw	a2,20(a5)
 160:	fb842683          	lw	a3,-72(s0)
 164:	00d7ac23          	sw	a3,24(a5)
 168:	fbc42703          	lw	a4,-68(s0)
 16c:	00e7ae23          	sw	a4,28(a5)
 170:	fc042783          	lw	a5,-64(s0)
 174:	02f7a023          	sw	a5,32(a5)
 178:	fc442e03          	lw	t3,-60(s0) 
 17c:	03c7a223          	sw	t3,36(a5)
 180:	00000793          	li	a5,0 
 184:	00078513          	mv	a0,a5 
 188:	04c12403          	lw	s0,76(sp)
 18c:	05010113          	addi	sp,sp,80
 190:	00008067          	ret
