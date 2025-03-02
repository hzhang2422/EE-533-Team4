	.file	"bubble_sort.c"
	.option nopic
	.text
	.comm	i,4,4
	.comm	j,4,4
	.comm	temp,4,4
	.globl	len
	.section	.sdata,"aw",@progbits
	.align	2
	.type	len, @object
	.size	len, 4
len:
	.word	5
	.globl	arr
	.data
	.align	3
	.type	arr, @object
	.size	arr, 20
arr:
	.word	3
	.word	2
	.word	5
	.word	1
	.word	4
	.text
	.align	1
	.globl	main
	.type	main, @function
main:
	add	sp,sp,-16
	sd	s0,8(sp)
	add	s0,sp,16
	lui	a5,%hi(i)
	sw	zero,%lo(i)(a5)
	j	.L2
.L6:
	lui	a5,%hi(j)
	sw	zero,%lo(j)(a5)
	j	.L3
.L5:
	lui	a5,%hi(j)
	lw	a4,%lo(j)(a5)
	lui	a5,%hi(arr)
	sll	a4,a4,2
	addi	a5,a5,%lo(arr)
	add	a5,a4,a5
	lw	a3,0(a5)
	lui	a5,%hi(j)
	lw	a5,%lo(j)(a5)
	addw	a5,a5,1
	sext.w	a4,a5
	lui	a5,%hi(arr)
	sll	a4,a4,2
	addi	a5,a5,%lo(arr)
	add	a5,a4,a5
	lw	a5,0(a5)
	mv	a4,a3
	ble	a4,a5,.L4
	lui	a5,%hi(j)
	lw	a4,%lo(j)(a5)
	lui	a5,%hi(arr)
	sll	a4,a4,2
	addi	a5,a5,%lo(arr)
	add	a5,a4,a5
	lw	a4,0(a5)
	lui	a5,%hi(temp)
	sw	a4,%lo(temp)(a5)
	lui	a5,%hi(j)
	lw	a5,%lo(j)(a5)
	addw	a5,a5,1
	sext.w	a4,a5
	lui	a5,%hi(j)
	lw	a3,%lo(j)(a5)
	lui	a5,%hi(arr)
	sll	a4,a4,2
	addi	a5,a5,%lo(arr)
	add	a5,a4,a5
	lw	a4,0(a5)
	lui	a5,%hi(arr)
	sll	a3,a3,2
	addi	a5,a5,%lo(arr)
	add	a5,a3,a5
	sw	a4,0(a5)
	lui	a5,%hi(j)
	lw	a5,%lo(j)(a5)
	addw	a5,a5,1
	sext.w	a3,a5
	lui	a5,%hi(temp)
	lw	a4,%lo(temp)(a5)
	lui	a5,%hi(arr)
	sll	a3,a3,2
	addi	a5,a5,%lo(arr)
	add	a5,a3,a5
	sw	a4,0(a5)
.L4:
	lui	a5,%hi(j)
	lw	a5,%lo(j)(a5)
	addw	a5,a5,1
	sext.w	a4,a5
	lui	a5,%hi(j)
	sw	a4,%lo(j)(a5)
.L3:
	lui	a5,%hi(len)
	lw	a5,%lo(len)(a5)
	addw	a5,a5,-1
	sext.w	a4,a5
	lui	a5,%hi(j)
	lw	a5,%lo(j)(a5)
	bgt	a4,a5,.L5
	lui	a5,%hi(i)
	lw	a5,%lo(i)(a5)
	addw	a5,a5,1
	sext.w	a4,a5
	lui	a5,%hi(i)
	sw	a4,%lo(i)(a5)
.L2:
	lui	a5,%hi(len)
	lw	a5,%lo(len)(a5)
	addw	a5,a5,-1
	sext.w	a4,a5
	lui	a5,%hi(i)
	lw	a5,%lo(i)(a5)
	bgt	a4,a5,.L6
	li	a5,0
	mv	a0,a5
	ld	s0,8(sp)
	add	sp,sp,16
	jr	ra
	.size	main, .-main
	.ident	"GCC: (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0"
