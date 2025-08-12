
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	91010113          	addi	sp,sp,-1776 # 80007910 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04a000ef          	jal	ra,80000060 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	0x14d,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffddbbf>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	d8878793          	addi	a5,a5,-632 # 80000e08 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a2:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	ra,8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	715d                	addi	sp,sp,-80
    800000d2:	e486                	sd	ra,72(sp)
    800000d4:	e0a2                	sd	s0,64(sp)
    800000d6:	fc26                	sd	s1,56(sp)
    800000d8:	f84a                	sd	s2,48(sp)
    800000da:	f44e                	sd	s3,40(sp)
    800000dc:	f052                	sd	s4,32(sp)
    800000de:	ec56                	sd	s5,24(sp)
    800000e0:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800000e2:	04c05263          	blez	a2,80000126 <consolewrite+0x56>
    800000e6:	8a2a                	mv	s4,a0
    800000e8:	84ae                	mv	s1,a1
    800000ea:	89b2                	mv	s3,a2
    800000ec:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800000ee:	5afd                	li	s5,-1
    800000f0:	4685                	li	a3,1
    800000f2:	8626                	mv	a2,s1
    800000f4:	85d2                	mv	a1,s4
    800000f6:	fbf40513          	addi	a0,s0,-65
    800000fa:	09a020ef          	jal	ra,80002194 <either_copyin>
    800000fe:	01550a63          	beq	a0,s5,80000112 <consolewrite+0x42>
      break;
    uartputc(c);
    80000102:	fbf44503          	lbu	a0,-65(s0)
    80000106:	7ca000ef          	jal	ra,800008d0 <uartputc>
  for(i = 0; i < n; i++){
    8000010a:	2905                	addiw	s2,s2,1
    8000010c:	0485                	addi	s1,s1,1
    8000010e:	ff2991e3          	bne	s3,s2,800000f0 <consolewrite+0x20>
  }

  return i;
}
    80000112:	854a                	mv	a0,s2
    80000114:	60a6                	ld	ra,72(sp)
    80000116:	6406                	ld	s0,64(sp)
    80000118:	74e2                	ld	s1,56(sp)
    8000011a:	7942                	ld	s2,48(sp)
    8000011c:	79a2                	ld	s3,40(sp)
    8000011e:	7a02                	ld	s4,32(sp)
    80000120:	6ae2                	ld	s5,24(sp)
    80000122:	6161                	addi	sp,sp,80
    80000124:	8082                	ret
  for(i = 0; i < n; i++){
    80000126:	4901                	li	s2,0
    80000128:	b7ed                	j	80000112 <consolewrite+0x42>

000000008000012a <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000012a:	7159                	addi	sp,sp,-112
    8000012c:	f486                	sd	ra,104(sp)
    8000012e:	f0a2                	sd	s0,96(sp)
    80000130:	eca6                	sd	s1,88(sp)
    80000132:	e8ca                	sd	s2,80(sp)
    80000134:	e4ce                	sd	s3,72(sp)
    80000136:	e0d2                	sd	s4,64(sp)
    80000138:	fc56                	sd	s5,56(sp)
    8000013a:	f85a                	sd	s6,48(sp)
    8000013c:	f45e                	sd	s7,40(sp)
    8000013e:	f062                	sd	s8,32(sp)
    80000140:	ec66                	sd	s9,24(sp)
    80000142:	e86a                	sd	s10,16(sp)
    80000144:	1880                	addi	s0,sp,112
    80000146:	8aaa                	mv	s5,a0
    80000148:	8a2e                	mv	s4,a1
    8000014a:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000014c:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000150:	0000f517          	auipc	a0,0xf
    80000154:	7c050513          	addi	a0,a0,1984 # 8000f910 <cons>
    80000158:	23b000ef          	jal	ra,80000b92 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000015c:	0000f497          	auipc	s1,0xf
    80000160:	7b448493          	addi	s1,s1,1972 # 8000f910 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000164:	00010917          	auipc	s2,0x10
    80000168:	84490913          	addi	s2,s2,-1980 # 8000f9a8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    8000016c:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000016e:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    80000170:	4ca9                	li	s9,10
  while(n > 0){
    80000172:	07305363          	blez	s3,800001d8 <consoleread+0xae>
    while(cons.r == cons.w){
    80000176:	0984a783          	lw	a5,152(s1)
    8000017a:	09c4a703          	lw	a4,156(s1)
    8000017e:	02f71163          	bne	a4,a5,800001a0 <consoleread+0x76>
      if(killed(myproc())){
    80000182:	6a2010ef          	jal	ra,80001824 <myproc>
    80000186:	6a1010ef          	jal	ra,80002026 <killed>
    8000018a:	e125                	bnez	a0,800001ea <consoleread+0xc0>
      sleep(&cons.r, &cons.lock);
    8000018c:	85a6                	mv	a1,s1
    8000018e:	854a                	mv	a0,s2
    80000190:	45f010ef          	jal	ra,80001dee <sleep>
    while(cons.r == cons.w){
    80000194:	0984a783          	lw	a5,152(s1)
    80000198:	09c4a703          	lw	a4,156(s1)
    8000019c:	fef703e3          	beq	a4,a5,80000182 <consoleread+0x58>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001a0:	0017871b          	addiw	a4,a5,1
    800001a4:	08e4ac23          	sw	a4,152(s1)
    800001a8:	07f7f713          	andi	a4,a5,127
    800001ac:	9726                	add	a4,a4,s1
    800001ae:	01874703          	lbu	a4,24(a4)
    800001b2:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001b6:	057d0f63          	beq	s10,s7,80000214 <consoleread+0xea>
    cbuf = c;
    800001ba:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001be:	4685                	li	a3,1
    800001c0:	f9f40613          	addi	a2,s0,-97
    800001c4:	85d2                	mv	a1,s4
    800001c6:	8556                	mv	a0,s5
    800001c8:	783010ef          	jal	ra,8000214a <either_copyout>
    800001cc:	01850663          	beq	a0,s8,800001d8 <consoleread+0xae>
    dst++;
    800001d0:	0a05                	addi	s4,s4,1
    --n;
    800001d2:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    800001d4:	f99d1fe3          	bne	s10,s9,80000172 <consoleread+0x48>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    800001d8:	0000f517          	auipc	a0,0xf
    800001dc:	73850513          	addi	a0,a0,1848 # 8000f910 <cons>
    800001e0:	24b000ef          	jal	ra,80000c2a <release>

  return target - n;
    800001e4:	413b053b          	subw	a0,s6,s3
    800001e8:	a801                	j	800001f8 <consoleread+0xce>
        release(&cons.lock);
    800001ea:	0000f517          	auipc	a0,0xf
    800001ee:	72650513          	addi	a0,a0,1830 # 8000f910 <cons>
    800001f2:	239000ef          	jal	ra,80000c2a <release>
        return -1;
    800001f6:	557d                	li	a0,-1
}
    800001f8:	70a6                	ld	ra,104(sp)
    800001fa:	7406                	ld	s0,96(sp)
    800001fc:	64e6                	ld	s1,88(sp)
    800001fe:	6946                	ld	s2,80(sp)
    80000200:	69a6                	ld	s3,72(sp)
    80000202:	6a06                	ld	s4,64(sp)
    80000204:	7ae2                	ld	s5,56(sp)
    80000206:	7b42                	ld	s6,48(sp)
    80000208:	7ba2                	ld	s7,40(sp)
    8000020a:	7c02                	ld	s8,32(sp)
    8000020c:	6ce2                	ld	s9,24(sp)
    8000020e:	6d42                	ld	s10,16(sp)
    80000210:	6165                	addi	sp,sp,112
    80000212:	8082                	ret
      if(n < target){
    80000214:	0009871b          	sext.w	a4,s3
    80000218:	fd6770e3          	bgeu	a4,s6,800001d8 <consoleread+0xae>
        cons.r--;
    8000021c:	0000f717          	auipc	a4,0xf
    80000220:	78f72623          	sw	a5,1932(a4) # 8000f9a8 <cons+0x98>
    80000224:	bf55                	j	800001d8 <consoleread+0xae>

0000000080000226 <consputc>:
{
    80000226:	1141                	addi	sp,sp,-16
    80000228:	e406                	sd	ra,8(sp)
    8000022a:	e022                	sd	s0,0(sp)
    8000022c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000022e:	10000793          	li	a5,256
    80000232:	00f50863          	beq	a0,a5,80000242 <consputc+0x1c>
    uartputc_sync(c);
    80000236:	5d4000ef          	jal	ra,8000080a <uartputc_sync>
}
    8000023a:	60a2                	ld	ra,8(sp)
    8000023c:	6402                	ld	s0,0(sp)
    8000023e:	0141                	addi	sp,sp,16
    80000240:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000242:	4521                	li	a0,8
    80000244:	5c6000ef          	jal	ra,8000080a <uartputc_sync>
    80000248:	02000513          	li	a0,32
    8000024c:	5be000ef          	jal	ra,8000080a <uartputc_sync>
    80000250:	4521                	li	a0,8
    80000252:	5b8000ef          	jal	ra,8000080a <uartputc_sync>
    80000256:	b7d5                	j	8000023a <consputc+0x14>

0000000080000258 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80000258:	1101                	addi	sp,sp,-32
    8000025a:	ec06                	sd	ra,24(sp)
    8000025c:	e822                	sd	s0,16(sp)
    8000025e:	e426                	sd	s1,8(sp)
    80000260:	e04a                	sd	s2,0(sp)
    80000262:	1000                	addi	s0,sp,32
    80000264:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80000266:	0000f517          	auipc	a0,0xf
    8000026a:	6aa50513          	addi	a0,a0,1706 # 8000f910 <cons>
    8000026e:	125000ef          	jal	ra,80000b92 <acquire>

  switch(c){
    80000272:	47d5                	li	a5,21
    80000274:	0af48063          	beq	s1,a5,80000314 <consoleintr+0xbc>
    80000278:	0297c663          	blt	a5,s1,800002a4 <consoleintr+0x4c>
    8000027c:	47a1                	li	a5,8
    8000027e:	0cf48f63          	beq	s1,a5,8000035c <consoleintr+0x104>
    80000282:	47c1                	li	a5,16
    80000284:	10f49063          	bne	s1,a5,80000384 <consoleintr+0x12c>
  case C('P'):  // Print process list.
    procdump();
    80000288:	757010ef          	jal	ra,800021de <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000028c:	0000f517          	auipc	a0,0xf
    80000290:	68450513          	addi	a0,a0,1668 # 8000f910 <cons>
    80000294:	197000ef          	jal	ra,80000c2a <release>
}
    80000298:	60e2                	ld	ra,24(sp)
    8000029a:	6442                	ld	s0,16(sp)
    8000029c:	64a2                	ld	s1,8(sp)
    8000029e:	6902                	ld	s2,0(sp)
    800002a0:	6105                	addi	sp,sp,32
    800002a2:	8082                	ret
  switch(c){
    800002a4:	07f00793          	li	a5,127
    800002a8:	0af48a63          	beq	s1,a5,8000035c <consoleintr+0x104>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002ac:	0000f717          	auipc	a4,0xf
    800002b0:	66470713          	addi	a4,a4,1636 # 8000f910 <cons>
    800002b4:	0a072783          	lw	a5,160(a4)
    800002b8:	09872703          	lw	a4,152(a4)
    800002bc:	9f99                	subw	a5,a5,a4
    800002be:	07f00713          	li	a4,127
    800002c2:	fcf765e3          	bltu	a4,a5,8000028c <consoleintr+0x34>
      c = (c == '\r') ? '\n' : c;
    800002c6:	47b5                	li	a5,13
    800002c8:	0cf48163          	beq	s1,a5,8000038a <consoleintr+0x132>
      consputc(c);
    800002cc:	8526                	mv	a0,s1
    800002ce:	f59ff0ef          	jal	ra,80000226 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002d2:	0000f797          	auipc	a5,0xf
    800002d6:	63e78793          	addi	a5,a5,1598 # 8000f910 <cons>
    800002da:	0a07a683          	lw	a3,160(a5)
    800002de:	0016871b          	addiw	a4,a3,1
    800002e2:	0007061b          	sext.w	a2,a4
    800002e6:	0ae7a023          	sw	a4,160(a5)
    800002ea:	07f6f693          	andi	a3,a3,127
    800002ee:	97b6                	add	a5,a5,a3
    800002f0:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    800002f4:	47a9                	li	a5,10
    800002f6:	0af48f63          	beq	s1,a5,800003b4 <consoleintr+0x15c>
    800002fa:	4791                	li	a5,4
    800002fc:	0af48c63          	beq	s1,a5,800003b4 <consoleintr+0x15c>
    80000300:	0000f797          	auipc	a5,0xf
    80000304:	6a87a783          	lw	a5,1704(a5) # 8000f9a8 <cons+0x98>
    80000308:	9f1d                	subw	a4,a4,a5
    8000030a:	08000793          	li	a5,128
    8000030e:	f6f71fe3          	bne	a4,a5,8000028c <consoleintr+0x34>
    80000312:	a04d                	j	800003b4 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80000314:	0000f717          	auipc	a4,0xf
    80000318:	5fc70713          	addi	a4,a4,1532 # 8000f910 <cons>
    8000031c:	0a072783          	lw	a5,160(a4)
    80000320:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000324:	0000f497          	auipc	s1,0xf
    80000328:	5ec48493          	addi	s1,s1,1516 # 8000f910 <cons>
    while(cons.e != cons.w &&
    8000032c:	4929                	li	s2,10
    8000032e:	f4f70fe3          	beq	a4,a5,8000028c <consoleintr+0x34>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000332:	37fd                	addiw	a5,a5,-1
    80000334:	07f7f713          	andi	a4,a5,127
    80000338:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000033a:	01874703          	lbu	a4,24(a4)
    8000033e:	f52707e3          	beq	a4,s2,8000028c <consoleintr+0x34>
      cons.e--;
    80000342:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000346:	10000513          	li	a0,256
    8000034a:	eddff0ef          	jal	ra,80000226 <consputc>
    while(cons.e != cons.w &&
    8000034e:	0a04a783          	lw	a5,160(s1)
    80000352:	09c4a703          	lw	a4,156(s1)
    80000356:	fcf71ee3          	bne	a4,a5,80000332 <consoleintr+0xda>
    8000035a:	bf0d                	j	8000028c <consoleintr+0x34>
    if(cons.e != cons.w){
    8000035c:	0000f717          	auipc	a4,0xf
    80000360:	5b470713          	addi	a4,a4,1460 # 8000f910 <cons>
    80000364:	0a072783          	lw	a5,160(a4)
    80000368:	09c72703          	lw	a4,156(a4)
    8000036c:	f2f700e3          	beq	a4,a5,8000028c <consoleintr+0x34>
      cons.e--;
    80000370:	37fd                	addiw	a5,a5,-1
    80000372:	0000f717          	auipc	a4,0xf
    80000376:	62f72f23          	sw	a5,1598(a4) # 8000f9b0 <cons+0xa0>
      consputc(BACKSPACE);
    8000037a:	10000513          	li	a0,256
    8000037e:	ea9ff0ef          	jal	ra,80000226 <consputc>
    80000382:	b729                	j	8000028c <consoleintr+0x34>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000384:	f00484e3          	beqz	s1,8000028c <consoleintr+0x34>
    80000388:	b715                	j	800002ac <consoleintr+0x54>
      consputc(c);
    8000038a:	4529                	li	a0,10
    8000038c:	e9bff0ef          	jal	ra,80000226 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000390:	0000f797          	auipc	a5,0xf
    80000394:	58078793          	addi	a5,a5,1408 # 8000f910 <cons>
    80000398:	0a07a703          	lw	a4,160(a5)
    8000039c:	0017069b          	addiw	a3,a4,1
    800003a0:	0006861b          	sext.w	a2,a3
    800003a4:	0ad7a023          	sw	a3,160(a5)
    800003a8:	07f77713          	andi	a4,a4,127
    800003ac:	97ba                	add	a5,a5,a4
    800003ae:	4729                	li	a4,10
    800003b0:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003b4:	0000f797          	auipc	a5,0xf
    800003b8:	5ec7ac23          	sw	a2,1528(a5) # 8000f9ac <cons+0x9c>
        wakeup(&cons.r);
    800003bc:	0000f517          	auipc	a0,0xf
    800003c0:	5ec50513          	addi	a0,a0,1516 # 8000f9a8 <cons+0x98>
    800003c4:	277010ef          	jal	ra,80001e3a <wakeup>
    800003c8:	b5d1                	j	8000028c <consoleintr+0x34>

00000000800003ca <consoleinit>:

void
consoleinit(void)
{
    800003ca:	1141                	addi	sp,sp,-16
    800003cc:	e406                	sd	ra,8(sp)
    800003ce:	e022                	sd	s0,0(sp)
    800003d0:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800003d2:	00007597          	auipc	a1,0x7
    800003d6:	c3e58593          	addi	a1,a1,-962 # 80007010 <etext+0x10>
    800003da:	0000f517          	auipc	a0,0xf
    800003de:	53650513          	addi	a0,a0,1334 # 8000f910 <cons>
    800003e2:	730000ef          	jal	ra,80000b12 <initlock>

  uartinit();
    800003e6:	3d8000ef          	jal	ra,800007be <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800003ea:	0001f797          	auipc	a5,0x1f
    800003ee:	6be78793          	addi	a5,a5,1726 # 8001faa8 <devsw>
    800003f2:	00000717          	auipc	a4,0x0
    800003f6:	d3870713          	addi	a4,a4,-712 # 8000012a <consoleread>
    800003fa:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800003fc:	00000717          	auipc	a4,0x0
    80000400:	cd470713          	addi	a4,a4,-812 # 800000d0 <consolewrite>
    80000404:	ef98                	sd	a4,24(a5)
}
    80000406:	60a2                	ld	ra,8(sp)
    80000408:	6402                	ld	s0,0(sp)
    8000040a:	0141                	addi	sp,sp,16
    8000040c:	8082                	ret

000000008000040e <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    8000040e:	7139                	addi	sp,sp,-64
    80000410:	fc06                	sd	ra,56(sp)
    80000412:	f822                	sd	s0,48(sp)
    80000414:	f426                	sd	s1,40(sp)
    80000416:	f04a                	sd	s2,32(sp)
    80000418:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    8000041a:	c219                	beqz	a2,80000420 <printint+0x12>
    8000041c:	06054f63          	bltz	a0,8000049a <printint+0x8c>
    x = -xx;
  else
    x = xx;
    80000420:	4881                	li	a7,0
    80000422:	fc840693          	addi	a3,s0,-56

  i = 0;
    80000426:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000428:	00007617          	auipc	a2,0x7
    8000042c:	c1060613          	addi	a2,a2,-1008 # 80007038 <digits>
    80000430:	883e                	mv	a6,a5
    80000432:	2785                	addiw	a5,a5,1
    80000434:	02b57733          	remu	a4,a0,a1
    80000438:	9732                	add	a4,a4,a2
    8000043a:	00074703          	lbu	a4,0(a4)
    8000043e:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000442:	872a                	mv	a4,a0
    80000444:	02b55533          	divu	a0,a0,a1
    80000448:	0685                	addi	a3,a3,1
    8000044a:	feb773e3          	bgeu	a4,a1,80000430 <printint+0x22>

  if(sign)
    8000044e:	00088b63          	beqz	a7,80000464 <printint+0x56>
    buf[i++] = '-';
    80000452:	fe040713          	addi	a4,s0,-32
    80000456:	97ba                	add	a5,a5,a4
    80000458:	02d00713          	li	a4,45
    8000045c:	fee78423          	sb	a4,-24(a5)
    80000460:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80000464:	02f05563          	blez	a5,8000048e <printint+0x80>
    80000468:	fc840713          	addi	a4,s0,-56
    8000046c:	00f704b3          	add	s1,a4,a5
    80000470:	fff70913          	addi	s2,a4,-1
    80000474:	993e                	add	s2,s2,a5
    80000476:	37fd                	addiw	a5,a5,-1
    80000478:	1782                	slli	a5,a5,0x20
    8000047a:	9381                	srli	a5,a5,0x20
    8000047c:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    80000480:	fff4c503          	lbu	a0,-1(s1)
    80000484:	da3ff0ef          	jal	ra,80000226 <consputc>
  while(--i >= 0)
    80000488:	14fd                	addi	s1,s1,-1
    8000048a:	ff249be3          	bne	s1,s2,80000480 <printint+0x72>
}
    8000048e:	70e2                	ld	ra,56(sp)
    80000490:	7442                	ld	s0,48(sp)
    80000492:	74a2                	ld	s1,40(sp)
    80000494:	7902                	ld	s2,32(sp)
    80000496:	6121                	addi	sp,sp,64
    80000498:	8082                	ret
    x = -xx;
    8000049a:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    8000049e:	4885                	li	a7,1
    x = -xx;
    800004a0:	b749                	j	80000422 <printint+0x14>

00000000800004a2 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004a2:	7155                	addi	sp,sp,-208
    800004a4:	e506                	sd	ra,136(sp)
    800004a6:	e122                	sd	s0,128(sp)
    800004a8:	fca6                	sd	s1,120(sp)
    800004aa:	f8ca                	sd	s2,112(sp)
    800004ac:	f4ce                	sd	s3,104(sp)
    800004ae:	f0d2                	sd	s4,96(sp)
    800004b0:	ecd6                	sd	s5,88(sp)
    800004b2:	e8da                	sd	s6,80(sp)
    800004b4:	e4de                	sd	s7,72(sp)
    800004b6:	e0e2                	sd	s8,64(sp)
    800004b8:	fc66                	sd	s9,56(sp)
    800004ba:	f86a                	sd	s10,48(sp)
    800004bc:	f46e                	sd	s11,40(sp)
    800004be:	0900                	addi	s0,sp,144
    800004c0:	8a2a                	mv	s4,a0
    800004c2:	e40c                	sd	a1,8(s0)
    800004c4:	e810                	sd	a2,16(s0)
    800004c6:	ec14                	sd	a3,24(s0)
    800004c8:	f018                	sd	a4,32(s0)
    800004ca:	f41c                	sd	a5,40(s0)
    800004cc:	03043823          	sd	a6,48(s0)
    800004d0:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800004d4:	0000f797          	auipc	a5,0xf
    800004d8:	4fc7a783          	lw	a5,1276(a5) # 8000f9d0 <pr+0x18>
    800004dc:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800004e0:	eb9d                	bnez	a5,80000516 <printf+0x74>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800004e2:	00840793          	addi	a5,s0,8
    800004e6:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800004ea:	00054503          	lbu	a0,0(a0)
    800004ee:	24050463          	beqz	a0,80000736 <printf+0x294>
    800004f2:	4981                	li	s3,0
    if(cx != '%'){
    800004f4:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    800004f8:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    800004fc:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80000500:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000504:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000508:	07000d93          	li	s11,112
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000050c:	00007b97          	auipc	s7,0x7
    80000510:	b2cb8b93          	addi	s7,s7,-1236 # 80007038 <digits>
    80000514:	a081                	j	80000554 <printf+0xb2>
    acquire(&pr.lock);
    80000516:	0000f517          	auipc	a0,0xf
    8000051a:	4a250513          	addi	a0,a0,1186 # 8000f9b8 <pr>
    8000051e:	674000ef          	jal	ra,80000b92 <acquire>
  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	000a4503          	lbu	a0,0(s4)
    8000052e:	f171                	bnez	a0,800004f2 <printf+0x50>
#endif
  }
  va_end(ap);

  if(locking)
    release(&pr.lock);
    80000530:	0000f517          	auipc	a0,0xf
    80000534:	48850513          	addi	a0,a0,1160 # 8000f9b8 <pr>
    80000538:	6f2000ef          	jal	ra,80000c2a <release>
    8000053c:	aaed                	j	80000736 <printf+0x294>
      consputc(cx);
    8000053e:	ce9ff0ef          	jal	ra,80000226 <consputc>
      continue;
    80000542:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000544:	0014899b          	addiw	s3,s1,1
    80000548:	013a07b3          	add	a5,s4,s3
    8000054c:	0007c503          	lbu	a0,0(a5)
    80000550:	1c050f63          	beqz	a0,8000072e <printf+0x28c>
    if(cx != '%'){
    80000554:	ff5515e3          	bne	a0,s5,8000053e <printf+0x9c>
    i++;
    80000558:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    8000055c:	009a07b3          	add	a5,s4,s1
    80000560:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000564:	1c090563          	beqz	s2,8000072e <printf+0x28c>
    80000568:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    8000056c:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000056e:	c789                	beqz	a5,80000578 <printf+0xd6>
    80000570:	009a0733          	add	a4,s4,s1
    80000574:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80000578:	03690463          	beq	s2,s6,800005a0 <printf+0xfe>
    } else if(c0 == 'l' && c1 == 'd'){
    8000057c:	03890e63          	beq	s2,s8,800005b8 <printf+0x116>
    } else if(c0 == 'u'){
    80000580:	0b990d63          	beq	s2,s9,8000063a <printf+0x198>
    } else if(c0 == 'x'){
    80000584:	11a90363          	beq	s2,s10,8000068a <printf+0x1e8>
    } else if(c0 == 'p'){
    80000588:	13b90b63          	beq	s2,s11,800006be <printf+0x21c>
    } else if(c0 == 's'){
    8000058c:	07300793          	li	a5,115
    80000590:	16f90363          	beq	s2,a5,800006f6 <printf+0x254>
    } else if(c0 == '%'){
    80000594:	03591c63          	bne	s2,s5,800005cc <printf+0x12a>
      consputc('%');
    80000598:	8556                	mv	a0,s5
    8000059a:	c8dff0ef          	jal	ra,80000226 <consputc>
    8000059e:	b75d                	j	80000544 <printf+0xa2>
      printint(va_arg(ap, int), 10, 1);
    800005a0:	f8843783          	ld	a5,-120(s0)
    800005a4:	00878713          	addi	a4,a5,8
    800005a8:	f8e43423          	sd	a4,-120(s0)
    800005ac:	4605                	li	a2,1
    800005ae:	45a9                	li	a1,10
    800005b0:	4388                	lw	a0,0(a5)
    800005b2:	e5dff0ef          	jal	ra,8000040e <printint>
    800005b6:	b779                	j	80000544 <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'd'){
    800005b8:	03678163          	beq	a5,s6,800005da <printf+0x138>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005bc:	03878d63          	beq	a5,s8,800005f6 <printf+0x154>
    } else if(c0 == 'l' && c1 == 'u'){
    800005c0:	09978963          	beq	a5,s9,80000652 <printf+0x1b0>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800005c4:	03878b63          	beq	a5,s8,800005fa <printf+0x158>
    } else if(c0 == 'l' && c1 == 'x'){
    800005c8:	0da78d63          	beq	a5,s10,800006a2 <printf+0x200>
      consputc('%');
    800005cc:	8556                	mv	a0,s5
    800005ce:	c59ff0ef          	jal	ra,80000226 <consputc>
      consputc(c0);
    800005d2:	854a                	mv	a0,s2
    800005d4:	c53ff0ef          	jal	ra,80000226 <consputc>
    800005d8:	b7b5                	j	80000544 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    800005da:	f8843783          	ld	a5,-120(s0)
    800005de:	00878713          	addi	a4,a5,8
    800005e2:	f8e43423          	sd	a4,-120(s0)
    800005e6:	4605                	li	a2,1
    800005e8:	45a9                	li	a1,10
    800005ea:	6388                	ld	a0,0(a5)
    800005ec:	e23ff0ef          	jal	ra,8000040e <printint>
      i += 1;
    800005f0:	0029849b          	addiw	s1,s3,2
    800005f4:	bf81                	j	80000544 <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005f6:	03668463          	beq	a3,s6,8000061e <printf+0x17c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800005fa:	07968a63          	beq	a3,s9,8000066e <printf+0x1cc>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    800005fe:	fda697e3          	bne	a3,s10,800005cc <printf+0x12a>
      printint(va_arg(ap, uint64), 16, 0);
    80000602:	f8843783          	ld	a5,-120(s0)
    80000606:	00878713          	addi	a4,a5,8
    8000060a:	f8e43423          	sd	a4,-120(s0)
    8000060e:	4601                	li	a2,0
    80000610:	45c1                	li	a1,16
    80000612:	6388                	ld	a0,0(a5)
    80000614:	dfbff0ef          	jal	ra,8000040e <printint>
      i += 2;
    80000618:	0039849b          	addiw	s1,s3,3
    8000061c:	b725                	j	80000544 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    8000061e:	f8843783          	ld	a5,-120(s0)
    80000622:	00878713          	addi	a4,a5,8
    80000626:	f8e43423          	sd	a4,-120(s0)
    8000062a:	4605                	li	a2,1
    8000062c:	45a9                	li	a1,10
    8000062e:	6388                	ld	a0,0(a5)
    80000630:	ddfff0ef          	jal	ra,8000040e <printint>
      i += 2;
    80000634:	0039849b          	addiw	s1,s3,3
    80000638:	b731                	j	80000544 <printf+0xa2>
      printint(va_arg(ap, int), 10, 0);
    8000063a:	f8843783          	ld	a5,-120(s0)
    8000063e:	00878713          	addi	a4,a5,8
    80000642:	f8e43423          	sd	a4,-120(s0)
    80000646:	4601                	li	a2,0
    80000648:	45a9                	li	a1,10
    8000064a:	4388                	lw	a0,0(a5)
    8000064c:	dc3ff0ef          	jal	ra,8000040e <printint>
    80000650:	bdd5                	j	80000544 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    80000652:	f8843783          	ld	a5,-120(s0)
    80000656:	00878713          	addi	a4,a5,8
    8000065a:	f8e43423          	sd	a4,-120(s0)
    8000065e:	4601                	li	a2,0
    80000660:	45a9                	li	a1,10
    80000662:	6388                	ld	a0,0(a5)
    80000664:	dabff0ef          	jal	ra,8000040e <printint>
      i += 1;
    80000668:	0029849b          	addiw	s1,s3,2
    8000066c:	bde1                	j	80000544 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    8000066e:	f8843783          	ld	a5,-120(s0)
    80000672:	00878713          	addi	a4,a5,8
    80000676:	f8e43423          	sd	a4,-120(s0)
    8000067a:	4601                	li	a2,0
    8000067c:	45a9                	li	a1,10
    8000067e:	6388                	ld	a0,0(a5)
    80000680:	d8fff0ef          	jal	ra,8000040e <printint>
      i += 2;
    80000684:	0039849b          	addiw	s1,s3,3
    80000688:	bd75                	j	80000544 <printf+0xa2>
      printint(va_arg(ap, int), 16, 0);
    8000068a:	f8843783          	ld	a5,-120(s0)
    8000068e:	00878713          	addi	a4,a5,8
    80000692:	f8e43423          	sd	a4,-120(s0)
    80000696:	4601                	li	a2,0
    80000698:	45c1                	li	a1,16
    8000069a:	4388                	lw	a0,0(a5)
    8000069c:	d73ff0ef          	jal	ra,8000040e <printint>
    800006a0:	b555                	j	80000544 <printf+0xa2>
      printint(va_arg(ap, uint64), 16, 0);
    800006a2:	f8843783          	ld	a5,-120(s0)
    800006a6:	00878713          	addi	a4,a5,8
    800006aa:	f8e43423          	sd	a4,-120(s0)
    800006ae:	4601                	li	a2,0
    800006b0:	45c1                	li	a1,16
    800006b2:	6388                	ld	a0,0(a5)
    800006b4:	d5bff0ef          	jal	ra,8000040e <printint>
      i += 1;
    800006b8:	0029849b          	addiw	s1,s3,2
    800006bc:	b561                	j	80000544 <printf+0xa2>
      printptr(va_arg(ap, uint64));
    800006be:	f8843783          	ld	a5,-120(s0)
    800006c2:	00878713          	addi	a4,a5,8
    800006c6:	f8e43423          	sd	a4,-120(s0)
    800006ca:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006ce:	03000513          	li	a0,48
    800006d2:	b55ff0ef          	jal	ra,80000226 <consputc>
  consputc('x');
    800006d6:	856a                	mv	a0,s10
    800006d8:	b4fff0ef          	jal	ra,80000226 <consputc>
    800006dc:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006de:	03c9d793          	srli	a5,s3,0x3c
    800006e2:	97de                	add	a5,a5,s7
    800006e4:	0007c503          	lbu	a0,0(a5)
    800006e8:	b3fff0ef          	jal	ra,80000226 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006ec:	0992                	slli	s3,s3,0x4
    800006ee:	397d                	addiw	s2,s2,-1
    800006f0:	fe0917e3          	bnez	s2,800006de <printf+0x23c>
    800006f4:	bd81                	j	80000544 <printf+0xa2>
      if((s = va_arg(ap, char*)) == 0)
    800006f6:	f8843783          	ld	a5,-120(s0)
    800006fa:	00878713          	addi	a4,a5,8
    800006fe:	f8e43423          	sd	a4,-120(s0)
    80000702:	0007b903          	ld	s2,0(a5)
    80000706:	00090d63          	beqz	s2,80000720 <printf+0x27e>
      for(; *s; s++)
    8000070a:	00094503          	lbu	a0,0(s2)
    8000070e:	e2050be3          	beqz	a0,80000544 <printf+0xa2>
        consputc(*s);
    80000712:	b15ff0ef          	jal	ra,80000226 <consputc>
      for(; *s; s++)
    80000716:	0905                	addi	s2,s2,1
    80000718:	00094503          	lbu	a0,0(s2)
    8000071c:	f97d                	bnez	a0,80000712 <printf+0x270>
    8000071e:	b51d                	j	80000544 <printf+0xa2>
        s = "(null)";
    80000720:	00007917          	auipc	s2,0x7
    80000724:	8f890913          	addi	s2,s2,-1800 # 80007018 <etext+0x18>
      for(; *s; s++)
    80000728:	02800513          	li	a0,40
    8000072c:	b7dd                	j	80000712 <printf+0x270>
  if(locking)
    8000072e:	f7843783          	ld	a5,-136(s0)
    80000732:	de079fe3          	bnez	a5,80000530 <printf+0x8e>

  return 0;
}
    80000736:	4501                	li	a0,0
    80000738:	60aa                	ld	ra,136(sp)
    8000073a:	640a                	ld	s0,128(sp)
    8000073c:	74e6                	ld	s1,120(sp)
    8000073e:	7946                	ld	s2,112(sp)
    80000740:	79a6                	ld	s3,104(sp)
    80000742:	7a06                	ld	s4,96(sp)
    80000744:	6ae6                	ld	s5,88(sp)
    80000746:	6b46                	ld	s6,80(sp)
    80000748:	6ba6                	ld	s7,72(sp)
    8000074a:	6c06                	ld	s8,64(sp)
    8000074c:	7ce2                	ld	s9,56(sp)
    8000074e:	7d42                	ld	s10,48(sp)
    80000750:	7da2                	ld	s11,40(sp)
    80000752:	6169                	addi	sp,sp,208
    80000754:	8082                	ret

0000000080000756 <panic>:

void
panic(char *s)
{
    80000756:	1101                	addi	sp,sp,-32
    80000758:	ec06                	sd	ra,24(sp)
    8000075a:	e822                	sd	s0,16(sp)
    8000075c:	e426                	sd	s1,8(sp)
    8000075e:	1000                	addi	s0,sp,32
    80000760:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000762:	0000f797          	auipc	a5,0xf
    80000766:	2607a723          	sw	zero,622(a5) # 8000f9d0 <pr+0x18>
  printf("panic: ");
    8000076a:	00007517          	auipc	a0,0x7
    8000076e:	8b650513          	addi	a0,a0,-1866 # 80007020 <etext+0x20>
    80000772:	d31ff0ef          	jal	ra,800004a2 <printf>
  printf("%s\n", s);
    80000776:	85a6                	mv	a1,s1
    80000778:	00007517          	auipc	a0,0x7
    8000077c:	8b050513          	addi	a0,a0,-1872 # 80007028 <etext+0x28>
    80000780:	d23ff0ef          	jal	ra,800004a2 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000784:	4785                	li	a5,1
    80000786:	00007717          	auipc	a4,0x7
    8000078a:	14f72523          	sw	a5,330(a4) # 800078d0 <panicked>
  for(;;)
    8000078e:	a001                	j	8000078e <panic+0x38>

0000000080000790 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000790:	1101                	addi	sp,sp,-32
    80000792:	ec06                	sd	ra,24(sp)
    80000794:	e822                	sd	s0,16(sp)
    80000796:	e426                	sd	s1,8(sp)
    80000798:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000079a:	0000f497          	auipc	s1,0xf
    8000079e:	21e48493          	addi	s1,s1,542 # 8000f9b8 <pr>
    800007a2:	00007597          	auipc	a1,0x7
    800007a6:	88e58593          	addi	a1,a1,-1906 # 80007030 <etext+0x30>
    800007aa:	8526                	mv	a0,s1
    800007ac:	366000ef          	jal	ra,80000b12 <initlock>
  pr.locking = 1;
    800007b0:	4785                	li	a5,1
    800007b2:	cc9c                	sw	a5,24(s1)
}
    800007b4:	60e2                	ld	ra,24(sp)
    800007b6:	6442                	ld	s0,16(sp)
    800007b8:	64a2                	ld	s1,8(sp)
    800007ba:	6105                	addi	sp,sp,32
    800007bc:	8082                	ret

00000000800007be <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007be:	1141                	addi	sp,sp,-16
    800007c0:	e406                	sd	ra,8(sp)
    800007c2:	e022                	sd	s0,0(sp)
    800007c4:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007c6:	100007b7          	lui	a5,0x10000
    800007ca:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ce:	f8000713          	li	a4,-128
    800007d2:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007d6:	470d                	li	a4,3
    800007d8:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007dc:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007e0:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007e4:	469d                	li	a3,7
    800007e6:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007ea:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007ee:	00007597          	auipc	a1,0x7
    800007f2:	86258593          	addi	a1,a1,-1950 # 80007050 <digits+0x18>
    800007f6:	0000f517          	auipc	a0,0xf
    800007fa:	1e250513          	addi	a0,a0,482 # 8000f9d8 <uart_tx_lock>
    800007fe:	314000ef          	jal	ra,80000b12 <initlock>
}
    80000802:	60a2                	ld	ra,8(sp)
    80000804:	6402                	ld	s0,0(sp)
    80000806:	0141                	addi	sp,sp,16
    80000808:	8082                	ret

000000008000080a <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000080a:	1101                	addi	sp,sp,-32
    8000080c:	ec06                	sd	ra,24(sp)
    8000080e:	e822                	sd	s0,16(sp)
    80000810:	e426                	sd	s1,8(sp)
    80000812:	1000                	addi	s0,sp,32
    80000814:	84aa                	mv	s1,a0
  push_off();
    80000816:	33c000ef          	jal	ra,80000b52 <push_off>

  if(panicked){
    8000081a:	00007797          	auipc	a5,0x7
    8000081e:	0b67a783          	lw	a5,182(a5) # 800078d0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000822:	10000737          	lui	a4,0x10000
  if(panicked){
    80000826:	c391                	beqz	a5,8000082a <uartputc_sync+0x20>
    for(;;)
    80000828:	a001                	j	80000828 <uartputc_sync+0x1e>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000082a:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000082e:	0207f793          	andi	a5,a5,32
    80000832:	dfe5                	beqz	a5,8000082a <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    80000834:	0ff4f513          	zext.b	a0,s1
    80000838:	100007b7          	lui	a5,0x10000
    8000083c:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000840:	396000ef          	jal	ra,80000bd6 <pop_off>
}
    80000844:	60e2                	ld	ra,24(sp)
    80000846:	6442                	ld	s0,16(sp)
    80000848:	64a2                	ld	s1,8(sp)
    8000084a:	6105                	addi	sp,sp,32
    8000084c:	8082                	ret

000000008000084e <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000084e:	00007797          	auipc	a5,0x7
    80000852:	08a7b783          	ld	a5,138(a5) # 800078d8 <uart_tx_r>
    80000856:	00007717          	auipc	a4,0x7
    8000085a:	08a73703          	ld	a4,138(a4) # 800078e0 <uart_tx_w>
    8000085e:	06f70863          	beq	a4,a5,800008ce <uartstart+0x80>
{
    80000862:	7139                	addi	sp,sp,-64
    80000864:	fc06                	sd	ra,56(sp)
    80000866:	f822                	sd	s0,48(sp)
    80000868:	f426                	sd	s1,40(sp)
    8000086a:	f04a                	sd	s2,32(sp)
    8000086c:	ec4e                	sd	s3,24(sp)
    8000086e:	e852                	sd	s4,16(sp)
    80000870:	e456                	sd	s5,8(sp)
    80000872:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000874:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000878:	0000fa17          	auipc	s4,0xf
    8000087c:	160a0a13          	addi	s4,s4,352 # 8000f9d8 <uart_tx_lock>
    uart_tx_r += 1;
    80000880:	00007497          	auipc	s1,0x7
    80000884:	05848493          	addi	s1,s1,88 # 800078d8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000888:	00007997          	auipc	s3,0x7
    8000088c:	05898993          	addi	s3,s3,88 # 800078e0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000890:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000894:	02077713          	andi	a4,a4,32
    80000898:	c315                	beqz	a4,800008bc <uartstart+0x6e>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000089a:	01f7f713          	andi	a4,a5,31
    8000089e:	9752                	add	a4,a4,s4
    800008a0:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    800008a4:	0785                	addi	a5,a5,1
    800008a6:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008a8:	8526                	mv	a0,s1
    800008aa:	590010ef          	jal	ra,80001e3a <wakeup>
    
    WriteReg(THR, c);
    800008ae:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008b2:	609c                	ld	a5,0(s1)
    800008b4:	0009b703          	ld	a4,0(s3)
    800008b8:	fcf71ce3          	bne	a4,a5,80000890 <uartstart+0x42>
  }
}
    800008bc:	70e2                	ld	ra,56(sp)
    800008be:	7442                	ld	s0,48(sp)
    800008c0:	74a2                	ld	s1,40(sp)
    800008c2:	7902                	ld	s2,32(sp)
    800008c4:	69e2                	ld	s3,24(sp)
    800008c6:	6a42                	ld	s4,16(sp)
    800008c8:	6aa2                	ld	s5,8(sp)
    800008ca:	6121                	addi	sp,sp,64
    800008cc:	8082                	ret
    800008ce:	8082                	ret

00000000800008d0 <uartputc>:
{
    800008d0:	7179                	addi	sp,sp,-48
    800008d2:	f406                	sd	ra,40(sp)
    800008d4:	f022                	sd	s0,32(sp)
    800008d6:	ec26                	sd	s1,24(sp)
    800008d8:	e84a                	sd	s2,16(sp)
    800008da:	e44e                	sd	s3,8(sp)
    800008dc:	e052                	sd	s4,0(sp)
    800008de:	1800                	addi	s0,sp,48
    800008e0:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008e2:	0000f517          	auipc	a0,0xf
    800008e6:	0f650513          	addi	a0,a0,246 # 8000f9d8 <uart_tx_lock>
    800008ea:	2a8000ef          	jal	ra,80000b92 <acquire>
  if(panicked){
    800008ee:	00007797          	auipc	a5,0x7
    800008f2:	fe27a783          	lw	a5,-30(a5) # 800078d0 <panicked>
    800008f6:	efbd                	bnez	a5,80000974 <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008f8:	00007717          	auipc	a4,0x7
    800008fc:	fe873703          	ld	a4,-24(a4) # 800078e0 <uart_tx_w>
    80000900:	00007797          	auipc	a5,0x7
    80000904:	fd87b783          	ld	a5,-40(a5) # 800078d8 <uart_tx_r>
    80000908:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000090c:	0000f997          	auipc	s3,0xf
    80000910:	0cc98993          	addi	s3,s3,204 # 8000f9d8 <uart_tx_lock>
    80000914:	00007497          	auipc	s1,0x7
    80000918:	fc448493          	addi	s1,s1,-60 # 800078d8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000091c:	00007917          	auipc	s2,0x7
    80000920:	fc490913          	addi	s2,s2,-60 # 800078e0 <uart_tx_w>
    80000924:	00e79d63          	bne	a5,a4,8000093e <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000928:	85ce                	mv	a1,s3
    8000092a:	8526                	mv	a0,s1
    8000092c:	4c2010ef          	jal	ra,80001dee <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000930:	00093703          	ld	a4,0(s2)
    80000934:	609c                	ld	a5,0(s1)
    80000936:	02078793          	addi	a5,a5,32
    8000093a:	fee787e3          	beq	a5,a4,80000928 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    8000093e:	0000f497          	auipc	s1,0xf
    80000942:	09a48493          	addi	s1,s1,154 # 8000f9d8 <uart_tx_lock>
    80000946:	01f77793          	andi	a5,a4,31
    8000094a:	97a6                	add	a5,a5,s1
    8000094c:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000950:	0705                	addi	a4,a4,1
    80000952:	00007797          	auipc	a5,0x7
    80000956:	f8e7b723          	sd	a4,-114(a5) # 800078e0 <uart_tx_w>
  uartstart();
    8000095a:	ef5ff0ef          	jal	ra,8000084e <uartstart>
  release(&uart_tx_lock);
    8000095e:	8526                	mv	a0,s1
    80000960:	2ca000ef          	jal	ra,80000c2a <release>
}
    80000964:	70a2                	ld	ra,40(sp)
    80000966:	7402                	ld	s0,32(sp)
    80000968:	64e2                	ld	s1,24(sp)
    8000096a:	6942                	ld	s2,16(sp)
    8000096c:	69a2                	ld	s3,8(sp)
    8000096e:	6a02                	ld	s4,0(sp)
    80000970:	6145                	addi	sp,sp,48
    80000972:	8082                	ret
    for(;;)
    80000974:	a001                	j	80000974 <uartputc+0xa4>

0000000080000976 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000976:	1141                	addi	sp,sp,-16
    80000978:	e422                	sd	s0,8(sp)
    8000097a:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000097c:	100007b7          	lui	a5,0x10000
    80000980:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000984:	8b85                	andi	a5,a5,1
    80000986:	cb91                	beqz	a5,8000099a <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000988:	100007b7          	lui	a5,0x10000
    8000098c:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000990:	0ff57513          	zext.b	a0,a0
  } else {
    return -1;
  }
}
    80000994:	6422                	ld	s0,8(sp)
    80000996:	0141                	addi	sp,sp,16
    80000998:	8082                	ret
    return -1;
    8000099a:	557d                	li	a0,-1
    8000099c:	bfe5                	j	80000994 <uartgetc+0x1e>

000000008000099e <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000099e:	1101                	addi	sp,sp,-32
    800009a0:	ec06                	sd	ra,24(sp)
    800009a2:	e822                	sd	s0,16(sp)
    800009a4:	e426                	sd	s1,8(sp)
    800009a6:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009a8:	100007b7          	lui	a5,0x10000
    800009ac:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>

  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009b0:	54fd                	li	s1,-1
    800009b2:	a019                	j	800009b8 <uartintr+0x1a>
      break;
    consoleintr(c);
    800009b4:	8a5ff0ef          	jal	ra,80000258 <consoleintr>
    int c = uartgetc();
    800009b8:	fbfff0ef          	jal	ra,80000976 <uartgetc>
    if(c == -1)
    800009bc:	fe951ce3          	bne	a0,s1,800009b4 <uartintr+0x16>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009c0:	0000f497          	auipc	s1,0xf
    800009c4:	01848493          	addi	s1,s1,24 # 8000f9d8 <uart_tx_lock>
    800009c8:	8526                	mv	a0,s1
    800009ca:	1c8000ef          	jal	ra,80000b92 <acquire>
  uartstart();
    800009ce:	e81ff0ef          	jal	ra,8000084e <uartstart>
  release(&uart_tx_lock);
    800009d2:	8526                	mv	a0,s1
    800009d4:	256000ef          	jal	ra,80000c2a <release>
}
    800009d8:	60e2                	ld	ra,24(sp)
    800009da:	6442                	ld	s0,16(sp)
    800009dc:	64a2                	ld	s1,8(sp)
    800009de:	6105                	addi	sp,sp,32
    800009e0:	8082                	ret

00000000800009e2 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e2:	1101                	addi	sp,sp,-32
    800009e4:	ec06                	sd	ra,24(sp)
    800009e6:	e822                	sd	s0,16(sp)
    800009e8:	e426                	sd	s1,8(sp)
    800009ea:	e04a                	sd	s2,0(sp)
    800009ec:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009ee:	03451793          	slli	a5,a0,0x34
    800009f2:	e7a9                	bnez	a5,80000a3c <kfree+0x5a>
    800009f4:	84aa                	mv	s1,a0
    800009f6:	00020797          	auipc	a5,0x20
    800009fa:	24a78793          	addi	a5,a5,586 # 80020c40 <end>
    800009fe:	02f56f63          	bltu	a0,a5,80000a3c <kfree+0x5a>
    80000a02:	47c5                	li	a5,17
    80000a04:	07ee                	slli	a5,a5,0x1b
    80000a06:	02f57b63          	bgeu	a0,a5,80000a3c <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a0a:	6605                	lui	a2,0x1
    80000a0c:	4585                	li	a1,1
    80000a0e:	258000ef          	jal	ra,80000c66 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a12:	0000f917          	auipc	s2,0xf
    80000a16:	ffe90913          	addi	s2,s2,-2 # 8000fa10 <kmem>
    80000a1a:	854a                	mv	a0,s2
    80000a1c:	176000ef          	jal	ra,80000b92 <acquire>
  r->next = kmem.freelist;
    80000a20:	01893783          	ld	a5,24(s2)
    80000a24:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a26:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a2a:	854a                	mv	a0,s2
    80000a2c:	1fe000ef          	jal	ra,80000c2a <release>
}
    80000a30:	60e2                	ld	ra,24(sp)
    80000a32:	6442                	ld	s0,16(sp)
    80000a34:	64a2                	ld	s1,8(sp)
    80000a36:	6902                	ld	s2,0(sp)
    80000a38:	6105                	addi	sp,sp,32
    80000a3a:	8082                	ret
    panic("kfree");
    80000a3c:	00006517          	auipc	a0,0x6
    80000a40:	61c50513          	addi	a0,a0,1564 # 80007058 <digits+0x20>
    80000a44:	d13ff0ef          	jal	ra,80000756 <panic>

0000000080000a48 <freerange>:
{
    80000a48:	7179                	addi	sp,sp,-48
    80000a4a:	f406                	sd	ra,40(sp)
    80000a4c:	f022                	sd	s0,32(sp)
    80000a4e:	ec26                	sd	s1,24(sp)
    80000a50:	e84a                	sd	s2,16(sp)
    80000a52:	e44e                	sd	s3,8(sp)
    80000a54:	e052                	sd	s4,0(sp)
    80000a56:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a58:	6785                	lui	a5,0x1
    80000a5a:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a5e:	94aa                	add	s1,s1,a0
    80000a60:	757d                	lui	a0,0xfffff
    80000a62:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a64:	94be                	add	s1,s1,a5
    80000a66:	0095ec63          	bltu	a1,s1,80000a7e <freerange+0x36>
    80000a6a:	892e                	mv	s2,a1
    kfree(p);
    80000a6c:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a6e:	6985                	lui	s3,0x1
    kfree(p);
    80000a70:	01448533          	add	a0,s1,s4
    80000a74:	f6fff0ef          	jal	ra,800009e2 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a78:	94ce                	add	s1,s1,s3
    80000a7a:	fe997be3          	bgeu	s2,s1,80000a70 <freerange+0x28>
}
    80000a7e:	70a2                	ld	ra,40(sp)
    80000a80:	7402                	ld	s0,32(sp)
    80000a82:	64e2                	ld	s1,24(sp)
    80000a84:	6942                	ld	s2,16(sp)
    80000a86:	69a2                	ld	s3,8(sp)
    80000a88:	6a02                	ld	s4,0(sp)
    80000a8a:	6145                	addi	sp,sp,48
    80000a8c:	8082                	ret

0000000080000a8e <kinit>:
{
    80000a8e:	1141                	addi	sp,sp,-16
    80000a90:	e406                	sd	ra,8(sp)
    80000a92:	e022                	sd	s0,0(sp)
    80000a94:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a96:	00006597          	auipc	a1,0x6
    80000a9a:	5ca58593          	addi	a1,a1,1482 # 80007060 <digits+0x28>
    80000a9e:	0000f517          	auipc	a0,0xf
    80000aa2:	f7250513          	addi	a0,a0,-142 # 8000fa10 <kmem>
    80000aa6:	06c000ef          	jal	ra,80000b12 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aaa:	45c5                	li	a1,17
    80000aac:	05ee                	slli	a1,a1,0x1b
    80000aae:	00020517          	auipc	a0,0x20
    80000ab2:	19250513          	addi	a0,a0,402 # 80020c40 <end>
    80000ab6:	f93ff0ef          	jal	ra,80000a48 <freerange>
}
    80000aba:	60a2                	ld	ra,8(sp)
    80000abc:	6402                	ld	s0,0(sp)
    80000abe:	0141                	addi	sp,sp,16
    80000ac0:	8082                	ret

0000000080000ac2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ac2:	1101                	addi	sp,sp,-32
    80000ac4:	ec06                	sd	ra,24(sp)
    80000ac6:	e822                	sd	s0,16(sp)
    80000ac8:	e426                	sd	s1,8(sp)
    80000aca:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000acc:	0000f497          	auipc	s1,0xf
    80000ad0:	f4448493          	addi	s1,s1,-188 # 8000fa10 <kmem>
    80000ad4:	8526                	mv	a0,s1
    80000ad6:	0bc000ef          	jal	ra,80000b92 <acquire>
  r = kmem.freelist;
    80000ada:	6c84                	ld	s1,24(s1)
  if(r)
    80000adc:	c485                	beqz	s1,80000b04 <kalloc+0x42>
    kmem.freelist = r->next;
    80000ade:	609c                	ld	a5,0(s1)
    80000ae0:	0000f517          	auipc	a0,0xf
    80000ae4:	f3050513          	addi	a0,a0,-208 # 8000fa10 <kmem>
    80000ae8:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000aea:	140000ef          	jal	ra,80000c2a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000aee:	6605                	lui	a2,0x1
    80000af0:	4595                	li	a1,5
    80000af2:	8526                	mv	a0,s1
    80000af4:	172000ef          	jal	ra,80000c66 <memset>
  return (void*)r;
}
    80000af8:	8526                	mv	a0,s1
    80000afa:	60e2                	ld	ra,24(sp)
    80000afc:	6442                	ld	s0,16(sp)
    80000afe:	64a2                	ld	s1,8(sp)
    80000b00:	6105                	addi	sp,sp,32
    80000b02:	8082                	ret
  release(&kmem.lock);
    80000b04:	0000f517          	auipc	a0,0xf
    80000b08:	f0c50513          	addi	a0,a0,-244 # 8000fa10 <kmem>
    80000b0c:	11e000ef          	jal	ra,80000c2a <release>
  if(r)
    80000b10:	b7e5                	j	80000af8 <kalloc+0x36>

0000000080000b12 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b12:	1141                	addi	sp,sp,-16
    80000b14:	e422                	sd	s0,8(sp)
    80000b16:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b18:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b1a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b1e:	00053823          	sd	zero,16(a0)
}
    80000b22:	6422                	ld	s0,8(sp)
    80000b24:	0141                	addi	sp,sp,16
    80000b26:	8082                	ret

0000000080000b28 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b28:	411c                	lw	a5,0(a0)
    80000b2a:	e399                	bnez	a5,80000b30 <holding+0x8>
    80000b2c:	4501                	li	a0,0
  return r;
}
    80000b2e:	8082                	ret
{
    80000b30:	1101                	addi	sp,sp,-32
    80000b32:	ec06                	sd	ra,24(sp)
    80000b34:	e822                	sd	s0,16(sp)
    80000b36:	e426                	sd	s1,8(sp)
    80000b38:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b3a:	6904                	ld	s1,16(a0)
    80000b3c:	4cd000ef          	jal	ra,80001808 <mycpu>
    80000b40:	40a48533          	sub	a0,s1,a0
    80000b44:	00153513          	seqz	a0,a0
}
    80000b48:	60e2                	ld	ra,24(sp)
    80000b4a:	6442                	ld	s0,16(sp)
    80000b4c:	64a2                	ld	s1,8(sp)
    80000b4e:	6105                	addi	sp,sp,32
    80000b50:	8082                	ret

0000000080000b52 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b52:	1101                	addi	sp,sp,-32
    80000b54:	ec06                	sd	ra,24(sp)
    80000b56:	e822                	sd	s0,16(sp)
    80000b58:	e426                	sd	s1,8(sp)
    80000b5a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b5c:	100024f3          	csrr	s1,sstatus
  int old = intr_get();

  if(mycpu()->noff == 0){
    80000b60:	4a9000ef          	jal	ra,80001808 <mycpu>
    80000b64:	5d3c                	lw	a5,120(a0)
    80000b66:	cb99                	beqz	a5,80000b7c <push_off+0x2a>
    intr_off();
    mycpu()->intena = old;
  }
  mycpu()->noff += 1;
    80000b68:	4a1000ef          	jal	ra,80001808 <mycpu>
    80000b6c:	5d3c                	lw	a5,120(a0)
    80000b6e:	2785                	addiw	a5,a5,1
    80000b70:	dd3c                	sw	a5,120(a0)
}
    80000b72:	60e2                	ld	ra,24(sp)
    80000b74:	6442                	ld	s0,16(sp)
    80000b76:	64a2                	ld	s1,8(sp)
    80000b78:	6105                	addi	sp,sp,32
    80000b7a:	8082                	ret
    80000b7c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b80:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b82:	10079073          	csrw	sstatus,a5
    mycpu()->intena = old;
    80000b86:	483000ef          	jal	ra,80001808 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000b8a:	8085                	srli	s1,s1,0x1
    80000b8c:	8885                	andi	s1,s1,1
    80000b8e:	dd64                	sw	s1,124(a0)
    80000b90:	bfe1                	j	80000b68 <push_off+0x16>

0000000080000b92 <acquire>:
{
    80000b92:	1101                	addi	sp,sp,-32
    80000b94:	ec06                	sd	ra,24(sp)
    80000b96:	e822                	sd	s0,16(sp)
    80000b98:	e426                	sd	s1,8(sp)
    80000b9a:	1000                	addi	s0,sp,32
    80000b9c:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000b9e:	fb5ff0ef          	jal	ra,80000b52 <push_off>
  if(holding(lk))
    80000ba2:	8526                	mv	a0,s1
    80000ba4:	f85ff0ef          	jal	ra,80000b28 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000ba8:	4705                	li	a4,1
  if(holding(lk))
    80000baa:	e105                	bnez	a0,80000bca <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bac:	87ba                	mv	a5,a4
    80000bae:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bb2:	2781                	sext.w	a5,a5
    80000bb4:	ffe5                	bnez	a5,80000bac <acquire+0x1a>
  __sync_synchronize();
    80000bb6:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000bba:	44f000ef          	jal	ra,80001808 <mycpu>
    80000bbe:	e888                	sd	a0,16(s1)
}
    80000bc0:	60e2                	ld	ra,24(sp)
    80000bc2:	6442                	ld	s0,16(sp)
    80000bc4:	64a2                	ld	s1,8(sp)
    80000bc6:	6105                	addi	sp,sp,32
    80000bc8:	8082                	ret
    panic("acquire");
    80000bca:	00006517          	auipc	a0,0x6
    80000bce:	49e50513          	addi	a0,a0,1182 # 80007068 <digits+0x30>
    80000bd2:	b85ff0ef          	jal	ra,80000756 <panic>

0000000080000bd6 <pop_off>:

void
pop_off(void)
{
    80000bd6:	1141                	addi	sp,sp,-16
    80000bd8:	e406                	sd	ra,8(sp)
    80000bda:	e022                	sd	s0,0(sp)
    80000bdc:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000bde:	42b000ef          	jal	ra,80001808 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000be2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000be6:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000be8:	e78d                	bnez	a5,80000c12 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000bea:	5d3c                	lw	a5,120(a0)
    80000bec:	02f05963          	blez	a5,80000c1e <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000bf0:	37fd                	addiw	a5,a5,-1
    80000bf2:	0007871b          	sext.w	a4,a5
    80000bf6:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000bf8:	eb09                	bnez	a4,80000c0a <pop_off+0x34>
    80000bfa:	5d7c                	lw	a5,124(a0)
    80000bfc:	c799                	beqz	a5,80000c0a <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bfe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c02:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c06:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c0a:	60a2                	ld	ra,8(sp)
    80000c0c:	6402                	ld	s0,0(sp)
    80000c0e:	0141                	addi	sp,sp,16
    80000c10:	8082                	ret
    panic("pop_off - interruptible");
    80000c12:	00006517          	auipc	a0,0x6
    80000c16:	45e50513          	addi	a0,a0,1118 # 80007070 <digits+0x38>
    80000c1a:	b3dff0ef          	jal	ra,80000756 <panic>
    panic("pop_off");
    80000c1e:	00006517          	auipc	a0,0x6
    80000c22:	46a50513          	addi	a0,a0,1130 # 80007088 <digits+0x50>
    80000c26:	b31ff0ef          	jal	ra,80000756 <panic>

0000000080000c2a <release>:
{
    80000c2a:	1101                	addi	sp,sp,-32
    80000c2c:	ec06                	sd	ra,24(sp)
    80000c2e:	e822                	sd	s0,16(sp)
    80000c30:	e426                	sd	s1,8(sp)
    80000c32:	1000                	addi	s0,sp,32
    80000c34:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c36:	ef3ff0ef          	jal	ra,80000b28 <holding>
    80000c3a:	c105                	beqz	a0,80000c5a <release+0x30>
  lk->cpu = 0;
    80000c3c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c40:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000c44:	0f50000f          	fence	iorw,ow
    80000c48:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c4c:	f8bff0ef          	jal	ra,80000bd6 <pop_off>
}
    80000c50:	60e2                	ld	ra,24(sp)
    80000c52:	6442                	ld	s0,16(sp)
    80000c54:	64a2                	ld	s1,8(sp)
    80000c56:	6105                	addi	sp,sp,32
    80000c58:	8082                	ret
    panic("release");
    80000c5a:	00006517          	auipc	a0,0x6
    80000c5e:	43650513          	addi	a0,a0,1078 # 80007090 <digits+0x58>
    80000c62:	af5ff0ef          	jal	ra,80000756 <panic>

0000000080000c66 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000c66:	1141                	addi	sp,sp,-16
    80000c68:	e422                	sd	s0,8(sp)
    80000c6a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000c6c:	ca19                	beqz	a2,80000c82 <memset+0x1c>
    80000c6e:	87aa                	mv	a5,a0
    80000c70:	1602                	slli	a2,a2,0x20
    80000c72:	9201                	srli	a2,a2,0x20
    80000c74:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000c78:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000c7c:	0785                	addi	a5,a5,1
    80000c7e:	fee79de3          	bne	a5,a4,80000c78 <memset+0x12>
  }
  return dst;
}
    80000c82:	6422                	ld	s0,8(sp)
    80000c84:	0141                	addi	sp,sp,16
    80000c86:	8082                	ret

0000000080000c88 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000c88:	1141                	addi	sp,sp,-16
    80000c8a:	e422                	sd	s0,8(sp)
    80000c8c:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000c8e:	ca05                	beqz	a2,80000cbe <memcmp+0x36>
    80000c90:	fff6069b          	addiw	a3,a2,-1
    80000c94:	1682                	slli	a3,a3,0x20
    80000c96:	9281                	srli	a3,a3,0x20
    80000c98:	0685                	addi	a3,a3,1
    80000c9a:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000c9c:	00054783          	lbu	a5,0(a0)
    80000ca0:	0005c703          	lbu	a4,0(a1)
    80000ca4:	00e79863          	bne	a5,a4,80000cb4 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000ca8:	0505                	addi	a0,a0,1
    80000caa:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000cac:	fed518e3          	bne	a0,a3,80000c9c <memcmp+0x14>
  }

  return 0;
    80000cb0:	4501                	li	a0,0
    80000cb2:	a019                	j	80000cb8 <memcmp+0x30>
      return *s1 - *s2;
    80000cb4:	40e7853b          	subw	a0,a5,a4
}
    80000cb8:	6422                	ld	s0,8(sp)
    80000cba:	0141                	addi	sp,sp,16
    80000cbc:	8082                	ret
  return 0;
    80000cbe:	4501                	li	a0,0
    80000cc0:	bfe5                	j	80000cb8 <memcmp+0x30>

0000000080000cc2 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000cc2:	1141                	addi	sp,sp,-16
    80000cc4:	e422                	sd	s0,8(sp)
    80000cc6:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000cc8:	c205                	beqz	a2,80000ce8 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000cca:	02a5e263          	bltu	a1,a0,80000cee <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000cce:	1602                	slli	a2,a2,0x20
    80000cd0:	9201                	srli	a2,a2,0x20
    80000cd2:	00c587b3          	add	a5,a1,a2
{
    80000cd6:	872a                	mv	a4,a0
      *d++ = *s++;
    80000cd8:	0585                	addi	a1,a1,1
    80000cda:	0705                	addi	a4,a4,1
    80000cdc:	fff5c683          	lbu	a3,-1(a1)
    80000ce0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000ce4:	fef59ae3          	bne	a1,a5,80000cd8 <memmove+0x16>

  return dst;
}
    80000ce8:	6422                	ld	s0,8(sp)
    80000cea:	0141                	addi	sp,sp,16
    80000cec:	8082                	ret
  if(s < d && s + n > d){
    80000cee:	02061693          	slli	a3,a2,0x20
    80000cf2:	9281                	srli	a3,a3,0x20
    80000cf4:	00d58733          	add	a4,a1,a3
    80000cf8:	fce57be3          	bgeu	a0,a4,80000cce <memmove+0xc>
    d += n;
    80000cfc:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000cfe:	fff6079b          	addiw	a5,a2,-1
    80000d02:	1782                	slli	a5,a5,0x20
    80000d04:	9381                	srli	a5,a5,0x20
    80000d06:	fff7c793          	not	a5,a5
    80000d0a:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d0c:	177d                	addi	a4,a4,-1
    80000d0e:	16fd                	addi	a3,a3,-1
    80000d10:	00074603          	lbu	a2,0(a4)
    80000d14:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d18:	fee79ae3          	bne	a5,a4,80000d0c <memmove+0x4a>
    80000d1c:	b7f1                	j	80000ce8 <memmove+0x26>

0000000080000d1e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d1e:	1141                	addi	sp,sp,-16
    80000d20:	e406                	sd	ra,8(sp)
    80000d22:	e022                	sd	s0,0(sp)
    80000d24:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d26:	f9dff0ef          	jal	ra,80000cc2 <memmove>
}
    80000d2a:	60a2                	ld	ra,8(sp)
    80000d2c:	6402                	ld	s0,0(sp)
    80000d2e:	0141                	addi	sp,sp,16
    80000d30:	8082                	ret

0000000080000d32 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d32:	1141                	addi	sp,sp,-16
    80000d34:	e422                	sd	s0,8(sp)
    80000d36:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d38:	ce11                	beqz	a2,80000d54 <strncmp+0x22>
    80000d3a:	00054783          	lbu	a5,0(a0)
    80000d3e:	cf89                	beqz	a5,80000d58 <strncmp+0x26>
    80000d40:	0005c703          	lbu	a4,0(a1)
    80000d44:	00f71a63          	bne	a4,a5,80000d58 <strncmp+0x26>
    n--, p++, q++;
    80000d48:	367d                	addiw	a2,a2,-1
    80000d4a:	0505                	addi	a0,a0,1
    80000d4c:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000d4e:	f675                	bnez	a2,80000d3a <strncmp+0x8>
  if(n == 0)
    return 0;
    80000d50:	4501                	li	a0,0
    80000d52:	a809                	j	80000d64 <strncmp+0x32>
    80000d54:	4501                	li	a0,0
    80000d56:	a039                	j	80000d64 <strncmp+0x32>
  if(n == 0)
    80000d58:	ca09                	beqz	a2,80000d6a <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000d5a:	00054503          	lbu	a0,0(a0)
    80000d5e:	0005c783          	lbu	a5,0(a1)
    80000d62:	9d1d                	subw	a0,a0,a5
}
    80000d64:	6422                	ld	s0,8(sp)
    80000d66:	0141                	addi	sp,sp,16
    80000d68:	8082                	ret
    return 0;
    80000d6a:	4501                	li	a0,0
    80000d6c:	bfe5                	j	80000d64 <strncmp+0x32>

0000000080000d6e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000d6e:	1141                	addi	sp,sp,-16
    80000d70:	e422                	sd	s0,8(sp)
    80000d72:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000d74:	872a                	mv	a4,a0
    80000d76:	8832                	mv	a6,a2
    80000d78:	367d                	addiw	a2,a2,-1
    80000d7a:	01005963          	blez	a6,80000d8c <strncpy+0x1e>
    80000d7e:	0705                	addi	a4,a4,1
    80000d80:	0005c783          	lbu	a5,0(a1)
    80000d84:	fef70fa3          	sb	a5,-1(a4)
    80000d88:	0585                	addi	a1,a1,1
    80000d8a:	f7f5                	bnez	a5,80000d76 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000d8c:	86ba                	mv	a3,a4
    80000d8e:	00c05c63          	blez	a2,80000da6 <strncpy+0x38>
    *s++ = 0;
    80000d92:	0685                	addi	a3,a3,1
    80000d94:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000d98:	fff6c793          	not	a5,a3
    80000d9c:	9fb9                	addw	a5,a5,a4
    80000d9e:	010787bb          	addw	a5,a5,a6
    80000da2:	fef048e3          	bgtz	a5,80000d92 <strncpy+0x24>
  return os;
}
    80000da6:	6422                	ld	s0,8(sp)
    80000da8:	0141                	addi	sp,sp,16
    80000daa:	8082                	ret

0000000080000dac <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000dac:	1141                	addi	sp,sp,-16
    80000dae:	e422                	sd	s0,8(sp)
    80000db0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000db2:	02c05363          	blez	a2,80000dd8 <safestrcpy+0x2c>
    80000db6:	fff6069b          	addiw	a3,a2,-1
    80000dba:	1682                	slli	a3,a3,0x20
    80000dbc:	9281                	srli	a3,a3,0x20
    80000dbe:	96ae                	add	a3,a3,a1
    80000dc0:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000dc2:	00d58963          	beq	a1,a3,80000dd4 <safestrcpy+0x28>
    80000dc6:	0585                	addi	a1,a1,1
    80000dc8:	0785                	addi	a5,a5,1
    80000dca:	fff5c703          	lbu	a4,-1(a1)
    80000dce:	fee78fa3          	sb	a4,-1(a5)
    80000dd2:	fb65                	bnez	a4,80000dc2 <safestrcpy+0x16>
    ;
  *s = 0;
    80000dd4:	00078023          	sb	zero,0(a5)
  return os;
}
    80000dd8:	6422                	ld	s0,8(sp)
    80000dda:	0141                	addi	sp,sp,16
    80000ddc:	8082                	ret

0000000080000dde <strlen>:

int
strlen(const char *s)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000de4:	00054783          	lbu	a5,0(a0)
    80000de8:	cf91                	beqz	a5,80000e04 <strlen+0x26>
    80000dea:	0505                	addi	a0,a0,1
    80000dec:	87aa                	mv	a5,a0
    80000dee:	4685                	li	a3,1
    80000df0:	9e89                	subw	a3,a3,a0
    80000df2:	00f6853b          	addw	a0,a3,a5
    80000df6:	0785                	addi	a5,a5,1
    80000df8:	fff7c703          	lbu	a4,-1(a5)
    80000dfc:	fb7d                	bnez	a4,80000df2 <strlen+0x14>
    ;
  return n;
}
    80000dfe:	6422                	ld	s0,8(sp)
    80000e00:	0141                	addi	sp,sp,16
    80000e02:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e04:	4501                	li	a0,0
    80000e06:	bfe5                	j	80000dfe <strlen+0x20>

0000000080000e08 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e08:	1141                	addi	sp,sp,-16
    80000e0a:	e406                	sd	ra,8(sp)
    80000e0c:	e022                	sd	s0,0(sp)
    80000e0e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e10:	1e9000ef          	jal	ra,800017f8 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e14:	00007717          	auipc	a4,0x7
    80000e18:	ad470713          	addi	a4,a4,-1324 # 800078e8 <started>
  if(cpuid() == 0){
    80000e1c:	c51d                	beqz	a0,80000e4a <main+0x42>
    while(started == 0)
    80000e1e:	431c                	lw	a5,0(a4)
    80000e20:	2781                	sext.w	a5,a5
    80000e22:	dff5                	beqz	a5,80000e1e <main+0x16>
      ;
    __sync_synchronize();
    80000e24:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e28:	1d1000ef          	jal	ra,800017f8 <cpuid>
    80000e2c:	85aa                	mv	a1,a0
    80000e2e:	00006517          	auipc	a0,0x6
    80000e32:	28250513          	addi	a0,a0,642 # 800070b0 <digits+0x78>
    80000e36:	e6cff0ef          	jal	ra,800004a2 <printf>
    kvminithart();    // turn on paging
    80000e3a:	080000ef          	jal	ra,80000eba <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e3e:	4d2010ef          	jal	ra,80002310 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e42:	272040ef          	jal	ra,800050b4 <plicinithart>
  }

  scheduler();        
    80000e46:	611000ef          	jal	ra,80001c56 <scheduler>
    consoleinit();
    80000e4a:	d80ff0ef          	jal	ra,800003ca <consoleinit>
    printfinit();
    80000e4e:	943ff0ef          	jal	ra,80000790 <printfinit>
    printf("\n");
    80000e52:	00006517          	auipc	a0,0x6
    80000e56:	26e50513          	addi	a0,a0,622 # 800070c0 <digits+0x88>
    80000e5a:	e48ff0ef          	jal	ra,800004a2 <printf>
    printf("xv6 kernel is booting\n");
    80000e5e:	00006517          	auipc	a0,0x6
    80000e62:	23a50513          	addi	a0,a0,570 # 80007098 <digits+0x60>
    80000e66:	e3cff0ef          	jal	ra,800004a2 <printf>
    printf("\n");
    80000e6a:	00006517          	auipc	a0,0x6
    80000e6e:	25650513          	addi	a0,a0,598 # 800070c0 <digits+0x88>
    80000e72:	e30ff0ef          	jal	ra,800004a2 <printf>
    kinit();         // physical page allocator
    80000e76:	c19ff0ef          	jal	ra,80000a8e <kinit>
    kvminit();       // create kernel page table
    80000e7a:	2ca000ef          	jal	ra,80001144 <kvminit>
    kvminithart();   // turn on paging
    80000e7e:	03c000ef          	jal	ra,80000eba <kvminithart>
    procinit();      // process table
    80000e82:	0cf000ef          	jal	ra,80001750 <procinit>
    trapinit();      // trap vectors
    80000e86:	466010ef          	jal	ra,800022ec <trapinit>
    trapinithart();  // install kernel trap vector
    80000e8a:	486010ef          	jal	ra,80002310 <trapinithart>
    plicinit();      // set up interrupt controller
    80000e8e:	210040ef          	jal	ra,8000509e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000e92:	222040ef          	jal	ra,800050b4 <plicinithart>
    binit();         // buffer cache
    80000e96:	2a5010ef          	jal	ra,8000293a <binit>
    iinit();         // inode table
    80000e9a:	086020ef          	jal	ra,80002f20 <iinit>
    fileinit();      // file table
    80000e9e:	625020ef          	jal	ra,80003cc2 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ea2:	302040ef          	jal	ra,800051a4 <virtio_disk_init>
    userinit();      // first user process
    80000ea6:	3e7000ef          	jal	ra,80001a8c <userinit>
    __sync_synchronize();
    80000eaa:	0ff0000f          	fence
    started = 1;
    80000eae:	4785                	li	a5,1
    80000eb0:	00007717          	auipc	a4,0x7
    80000eb4:	a2f72c23          	sw	a5,-1480(a4) # 800078e8 <started>
    80000eb8:	b779                	j	80000e46 <main+0x3e>

0000000080000eba <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000eba:	1141                	addi	sp,sp,-16
    80000ebc:	e422                	sd	s0,8(sp)
    80000ebe:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000ec0:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000ec4:	00007797          	auipc	a5,0x7
    80000ec8:	a2c7b783          	ld	a5,-1492(a5) # 800078f0 <kernel_pagetable>
    80000ecc:	83b1                	srli	a5,a5,0xc
    80000ece:	577d                	li	a4,-1
    80000ed0:	177e                	slli	a4,a4,0x3f
    80000ed2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000ed4:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000ed8:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000edc:	6422                	ld	s0,8(sp)
    80000ede:	0141                	addi	sp,sp,16
    80000ee0:	8082                	ret

0000000080000ee2 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000ee2:	7139                	addi	sp,sp,-64
    80000ee4:	fc06                	sd	ra,56(sp)
    80000ee6:	f822                	sd	s0,48(sp)
    80000ee8:	f426                	sd	s1,40(sp)
    80000eea:	f04a                	sd	s2,32(sp)
    80000eec:	ec4e                	sd	s3,24(sp)
    80000eee:	e852                	sd	s4,16(sp)
    80000ef0:	e456                	sd	s5,8(sp)
    80000ef2:	e05a                	sd	s6,0(sp)
    80000ef4:	0080                	addi	s0,sp,64
    80000ef6:	84aa                	mv	s1,a0
    80000ef8:	89ae                	mv	s3,a1
    80000efa:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000efc:	57fd                	li	a5,-1
    80000efe:	83e9                	srli	a5,a5,0x1a
    80000f00:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f02:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f04:	02b7fc63          	bgeu	a5,a1,80000f3c <walk+0x5a>
    panic("walk");
    80000f08:	00006517          	auipc	a0,0x6
    80000f0c:	1c050513          	addi	a0,a0,448 # 800070c8 <digits+0x90>
    80000f10:	847ff0ef          	jal	ra,80000756 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f14:	060a8263          	beqz	s5,80000f78 <walk+0x96>
    80000f18:	babff0ef          	jal	ra,80000ac2 <kalloc>
    80000f1c:	84aa                	mv	s1,a0
    80000f1e:	c139                	beqz	a0,80000f64 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f20:	6605                	lui	a2,0x1
    80000f22:	4581                	li	a1,0
    80000f24:	d43ff0ef          	jal	ra,80000c66 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f28:	00c4d793          	srli	a5,s1,0xc
    80000f2c:	07aa                	slli	a5,a5,0xa
    80000f2e:	0017e793          	ori	a5,a5,1
    80000f32:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f36:	3a5d                	addiw	s4,s4,-9
    80000f38:	036a0063          	beq	s4,s6,80000f58 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f3c:	0149d933          	srl	s2,s3,s4
    80000f40:	1ff97913          	andi	s2,s2,511
    80000f44:	090e                	slli	s2,s2,0x3
    80000f46:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000f48:	00093483          	ld	s1,0(s2)
    80000f4c:	0014f793          	andi	a5,s1,1
    80000f50:	d3f1                	beqz	a5,80000f14 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f52:	80a9                	srli	s1,s1,0xa
    80000f54:	04b2                	slli	s1,s1,0xc
    80000f56:	b7c5                	j	80000f36 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000f58:	00c9d513          	srli	a0,s3,0xc
    80000f5c:	1ff57513          	andi	a0,a0,511
    80000f60:	050e                	slli	a0,a0,0x3
    80000f62:	9526                	add	a0,a0,s1
}
    80000f64:	70e2                	ld	ra,56(sp)
    80000f66:	7442                	ld	s0,48(sp)
    80000f68:	74a2                	ld	s1,40(sp)
    80000f6a:	7902                	ld	s2,32(sp)
    80000f6c:	69e2                	ld	s3,24(sp)
    80000f6e:	6a42                	ld	s4,16(sp)
    80000f70:	6aa2                	ld	s5,8(sp)
    80000f72:	6b02                	ld	s6,0(sp)
    80000f74:	6121                	addi	sp,sp,64
    80000f76:	8082                	ret
        return 0;
    80000f78:	4501                	li	a0,0
    80000f7a:	b7ed                	j	80000f64 <walk+0x82>

0000000080000f7c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000f7c:	57fd                	li	a5,-1
    80000f7e:	83e9                	srli	a5,a5,0x1a
    80000f80:	00b7f463          	bgeu	a5,a1,80000f88 <walkaddr+0xc>
    return 0;
    80000f84:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000f86:	8082                	ret
{
    80000f88:	1141                	addi	sp,sp,-16
    80000f8a:	e406                	sd	ra,8(sp)
    80000f8c:	e022                	sd	s0,0(sp)
    80000f8e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000f90:	4601                	li	a2,0
    80000f92:	f51ff0ef          	jal	ra,80000ee2 <walk>
  if(pte == 0)
    80000f96:	c105                	beqz	a0,80000fb6 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000f98:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000f9a:	0117f693          	andi	a3,a5,17
    80000f9e:	4745                	li	a4,17
    return 0;
    80000fa0:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000fa2:	00e68663          	beq	a3,a4,80000fae <walkaddr+0x32>
}
    80000fa6:	60a2                	ld	ra,8(sp)
    80000fa8:	6402                	ld	s0,0(sp)
    80000faa:	0141                	addi	sp,sp,16
    80000fac:	8082                	ret
  pa = PTE2PA(*pte);
    80000fae:	00a7d513          	srli	a0,a5,0xa
    80000fb2:	0532                	slli	a0,a0,0xc
  return pa;
    80000fb4:	bfcd                	j	80000fa6 <walkaddr+0x2a>
    return 0;
    80000fb6:	4501                	li	a0,0
    80000fb8:	b7fd                	j	80000fa6 <walkaddr+0x2a>

0000000080000fba <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000fba:	715d                	addi	sp,sp,-80
    80000fbc:	e486                	sd	ra,72(sp)
    80000fbe:	e0a2                	sd	s0,64(sp)
    80000fc0:	fc26                	sd	s1,56(sp)
    80000fc2:	f84a                	sd	s2,48(sp)
    80000fc4:	f44e                	sd	s3,40(sp)
    80000fc6:	f052                	sd	s4,32(sp)
    80000fc8:	ec56                	sd	s5,24(sp)
    80000fca:	e85a                	sd	s6,16(sp)
    80000fcc:	e45e                	sd	s7,8(sp)
    80000fce:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80000fd0:	03459793          	slli	a5,a1,0x34
    80000fd4:	e7a9                	bnez	a5,8000101e <mappages+0x64>
    80000fd6:	8aaa                	mv	s5,a0
    80000fd8:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80000fda:	03461793          	slli	a5,a2,0x34
    80000fde:	e7b1                	bnez	a5,8000102a <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    80000fe0:	ca39                	beqz	a2,80001036 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80000fe2:	79fd                	lui	s3,0xfffff
    80000fe4:	964e                	add	a2,a2,s3
    80000fe6:	00b609b3          	add	s3,a2,a1
  a = va;
    80000fea:	892e                	mv	s2,a1
    80000fec:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80000ff0:	6b85                	lui	s7,0x1
    80000ff2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80000ff6:	4605                	li	a2,1
    80000ff8:	85ca                	mv	a1,s2
    80000ffa:	8556                	mv	a0,s5
    80000ffc:	ee7ff0ef          	jal	ra,80000ee2 <walk>
    80001000:	c539                	beqz	a0,8000104e <mappages+0x94>
    if(*pte & PTE_V)
    80001002:	611c                	ld	a5,0(a0)
    80001004:	8b85                	andi	a5,a5,1
    80001006:	ef95                	bnez	a5,80001042 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001008:	80b1                	srli	s1,s1,0xc
    8000100a:	04aa                	slli	s1,s1,0xa
    8000100c:	0164e4b3          	or	s1,s1,s6
    80001010:	0014e493          	ori	s1,s1,1
    80001014:	e104                	sd	s1,0(a0)
    if(a == last)
    80001016:	05390863          	beq	s2,s3,80001066 <mappages+0xac>
    a += PGSIZE;
    8000101a:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000101c:	bfd9                	j	80000ff2 <mappages+0x38>
    panic("mappages: va not aligned");
    8000101e:	00006517          	auipc	a0,0x6
    80001022:	0b250513          	addi	a0,a0,178 # 800070d0 <digits+0x98>
    80001026:	f30ff0ef          	jal	ra,80000756 <panic>
    panic("mappages: size not aligned");
    8000102a:	00006517          	auipc	a0,0x6
    8000102e:	0c650513          	addi	a0,a0,198 # 800070f0 <digits+0xb8>
    80001032:	f24ff0ef          	jal	ra,80000756 <panic>
    panic("mappages: size");
    80001036:	00006517          	auipc	a0,0x6
    8000103a:	0da50513          	addi	a0,a0,218 # 80007110 <digits+0xd8>
    8000103e:	f18ff0ef          	jal	ra,80000756 <panic>
      panic("mappages: remap");
    80001042:	00006517          	auipc	a0,0x6
    80001046:	0de50513          	addi	a0,a0,222 # 80007120 <digits+0xe8>
    8000104a:	f0cff0ef          	jal	ra,80000756 <panic>
      return -1;
    8000104e:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001050:	60a6                	ld	ra,72(sp)
    80001052:	6406                	ld	s0,64(sp)
    80001054:	74e2                	ld	s1,56(sp)
    80001056:	7942                	ld	s2,48(sp)
    80001058:	79a2                	ld	s3,40(sp)
    8000105a:	7a02                	ld	s4,32(sp)
    8000105c:	6ae2                	ld	s5,24(sp)
    8000105e:	6b42                	ld	s6,16(sp)
    80001060:	6ba2                	ld	s7,8(sp)
    80001062:	6161                	addi	sp,sp,80
    80001064:	8082                	ret
  return 0;
    80001066:	4501                	li	a0,0
    80001068:	b7e5                	j	80001050 <mappages+0x96>

000000008000106a <kvmmap>:
{
    8000106a:	1141                	addi	sp,sp,-16
    8000106c:	e406                	sd	ra,8(sp)
    8000106e:	e022                	sd	s0,0(sp)
    80001070:	0800                	addi	s0,sp,16
    80001072:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001074:	86b2                	mv	a3,a2
    80001076:	863e                	mv	a2,a5
    80001078:	f43ff0ef          	jal	ra,80000fba <mappages>
    8000107c:	e509                	bnez	a0,80001086 <kvmmap+0x1c>
}
    8000107e:	60a2                	ld	ra,8(sp)
    80001080:	6402                	ld	s0,0(sp)
    80001082:	0141                	addi	sp,sp,16
    80001084:	8082                	ret
    panic("kvmmap");
    80001086:	00006517          	auipc	a0,0x6
    8000108a:	0aa50513          	addi	a0,a0,170 # 80007130 <digits+0xf8>
    8000108e:	ec8ff0ef          	jal	ra,80000756 <panic>

0000000080001092 <kvmmake>:
{
    80001092:	1101                	addi	sp,sp,-32
    80001094:	ec06                	sd	ra,24(sp)
    80001096:	e822                	sd	s0,16(sp)
    80001098:	e426                	sd	s1,8(sp)
    8000109a:	e04a                	sd	s2,0(sp)
    8000109c:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000109e:	a25ff0ef          	jal	ra,80000ac2 <kalloc>
    800010a2:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010a4:	6605                	lui	a2,0x1
    800010a6:	4581                	li	a1,0
    800010a8:	bbfff0ef          	jal	ra,80000c66 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800010ac:	4719                	li	a4,6
    800010ae:	6685                	lui	a3,0x1
    800010b0:	10000637          	lui	a2,0x10000
    800010b4:	100005b7          	lui	a1,0x10000
    800010b8:	8526                	mv	a0,s1
    800010ba:	fb1ff0ef          	jal	ra,8000106a <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800010be:	4719                	li	a4,6
    800010c0:	6685                	lui	a3,0x1
    800010c2:	10001637          	lui	a2,0x10001
    800010c6:	100015b7          	lui	a1,0x10001
    800010ca:	8526                	mv	a0,s1
    800010cc:	f9fff0ef          	jal	ra,8000106a <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800010d0:	4719                	li	a4,6
    800010d2:	040006b7          	lui	a3,0x4000
    800010d6:	0c000637          	lui	a2,0xc000
    800010da:	0c0005b7          	lui	a1,0xc000
    800010de:	8526                	mv	a0,s1
    800010e0:	f8bff0ef          	jal	ra,8000106a <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800010e4:	00006917          	auipc	s2,0x6
    800010e8:	f1c90913          	addi	s2,s2,-228 # 80007000 <etext>
    800010ec:	4729                	li	a4,10
    800010ee:	80006697          	auipc	a3,0x80006
    800010f2:	f1268693          	addi	a3,a3,-238 # 7000 <_entry-0x7fff9000>
    800010f6:	4605                	li	a2,1
    800010f8:	067e                	slli	a2,a2,0x1f
    800010fa:	85b2                	mv	a1,a2
    800010fc:	8526                	mv	a0,s1
    800010fe:	f6dff0ef          	jal	ra,8000106a <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001102:	4719                	li	a4,6
    80001104:	46c5                	li	a3,17
    80001106:	06ee                	slli	a3,a3,0x1b
    80001108:	412686b3          	sub	a3,a3,s2
    8000110c:	864a                	mv	a2,s2
    8000110e:	85ca                	mv	a1,s2
    80001110:	8526                	mv	a0,s1
    80001112:	f59ff0ef          	jal	ra,8000106a <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001116:	4729                	li	a4,10
    80001118:	6685                	lui	a3,0x1
    8000111a:	00005617          	auipc	a2,0x5
    8000111e:	ee660613          	addi	a2,a2,-282 # 80006000 <_trampoline>
    80001122:	040005b7          	lui	a1,0x4000
    80001126:	15fd                	addi	a1,a1,-1
    80001128:	05b2                	slli	a1,a1,0xc
    8000112a:	8526                	mv	a0,s1
    8000112c:	f3fff0ef          	jal	ra,8000106a <kvmmap>
  proc_mapstacks(kpgtbl);
    80001130:	8526                	mv	a0,s1
    80001132:	594000ef          	jal	ra,800016c6 <proc_mapstacks>
}
    80001136:	8526                	mv	a0,s1
    80001138:	60e2                	ld	ra,24(sp)
    8000113a:	6442                	ld	s0,16(sp)
    8000113c:	64a2                	ld	s1,8(sp)
    8000113e:	6902                	ld	s2,0(sp)
    80001140:	6105                	addi	sp,sp,32
    80001142:	8082                	ret

0000000080001144 <kvminit>:
{
    80001144:	1141                	addi	sp,sp,-16
    80001146:	e406                	sd	ra,8(sp)
    80001148:	e022                	sd	s0,0(sp)
    8000114a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000114c:	f47ff0ef          	jal	ra,80001092 <kvmmake>
    80001150:	00006797          	auipc	a5,0x6
    80001154:	7aa7b023          	sd	a0,1952(a5) # 800078f0 <kernel_pagetable>
}
    80001158:	60a2                	ld	ra,8(sp)
    8000115a:	6402                	ld	s0,0(sp)
    8000115c:	0141                	addi	sp,sp,16
    8000115e:	8082                	ret

0000000080001160 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001160:	715d                	addi	sp,sp,-80
    80001162:	e486                	sd	ra,72(sp)
    80001164:	e0a2                	sd	s0,64(sp)
    80001166:	fc26                	sd	s1,56(sp)
    80001168:	f84a                	sd	s2,48(sp)
    8000116a:	f44e                	sd	s3,40(sp)
    8000116c:	f052                	sd	s4,32(sp)
    8000116e:	ec56                	sd	s5,24(sp)
    80001170:	e85a                	sd	s6,16(sp)
    80001172:	e45e                	sd	s7,8(sp)
    80001174:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001176:	03459793          	slli	a5,a1,0x34
    8000117a:	e795                	bnez	a5,800011a6 <uvmunmap+0x46>
    8000117c:	8a2a                	mv	s4,a0
    8000117e:	892e                	mv	s2,a1
    80001180:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001182:	0632                	slli	a2,a2,0xc
    80001184:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001188:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000118a:	6b05                	lui	s6,0x1
    8000118c:	0535ea63          	bltu	a1,s3,800011e0 <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001190:	60a6                	ld	ra,72(sp)
    80001192:	6406                	ld	s0,64(sp)
    80001194:	74e2                	ld	s1,56(sp)
    80001196:	7942                	ld	s2,48(sp)
    80001198:	79a2                	ld	s3,40(sp)
    8000119a:	7a02                	ld	s4,32(sp)
    8000119c:	6ae2                	ld	s5,24(sp)
    8000119e:	6b42                	ld	s6,16(sp)
    800011a0:	6ba2                	ld	s7,8(sp)
    800011a2:	6161                	addi	sp,sp,80
    800011a4:	8082                	ret
    panic("uvmunmap: not aligned");
    800011a6:	00006517          	auipc	a0,0x6
    800011aa:	f9250513          	addi	a0,a0,-110 # 80007138 <digits+0x100>
    800011ae:	da8ff0ef          	jal	ra,80000756 <panic>
      panic("uvmunmap: walk");
    800011b2:	00006517          	auipc	a0,0x6
    800011b6:	f9e50513          	addi	a0,a0,-98 # 80007150 <digits+0x118>
    800011ba:	d9cff0ef          	jal	ra,80000756 <panic>
      panic("uvmunmap: not mapped");
    800011be:	00006517          	auipc	a0,0x6
    800011c2:	fa250513          	addi	a0,a0,-94 # 80007160 <digits+0x128>
    800011c6:	d90ff0ef          	jal	ra,80000756 <panic>
      panic("uvmunmap: not a leaf");
    800011ca:	00006517          	auipc	a0,0x6
    800011ce:	fae50513          	addi	a0,a0,-82 # 80007178 <digits+0x140>
    800011d2:	d84ff0ef          	jal	ra,80000756 <panic>
    *pte = 0;
    800011d6:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011da:	995a                	add	s2,s2,s6
    800011dc:	fb397ae3          	bgeu	s2,s3,80001190 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800011e0:	4601                	li	a2,0
    800011e2:	85ca                	mv	a1,s2
    800011e4:	8552                	mv	a0,s4
    800011e6:	cfdff0ef          	jal	ra,80000ee2 <walk>
    800011ea:	84aa                	mv	s1,a0
    800011ec:	d179                	beqz	a0,800011b2 <uvmunmap+0x52>
    if((*pte & PTE_V) == 0)
    800011ee:	6108                	ld	a0,0(a0)
    800011f0:	00157793          	andi	a5,a0,1
    800011f4:	d7e9                	beqz	a5,800011be <uvmunmap+0x5e>
    if(PTE_FLAGS(*pte) == PTE_V)
    800011f6:	3ff57793          	andi	a5,a0,1023
    800011fa:	fd7788e3          	beq	a5,s7,800011ca <uvmunmap+0x6a>
    if(do_free){
    800011fe:	fc0a8ce3          	beqz	s5,800011d6 <uvmunmap+0x76>
      uint64 pa = PTE2PA(*pte);
    80001202:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001204:	0532                	slli	a0,a0,0xc
    80001206:	fdcff0ef          	jal	ra,800009e2 <kfree>
    8000120a:	b7f1                	j	800011d6 <uvmunmap+0x76>

000000008000120c <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000120c:	1101                	addi	sp,sp,-32
    8000120e:	ec06                	sd	ra,24(sp)
    80001210:	e822                	sd	s0,16(sp)
    80001212:	e426                	sd	s1,8(sp)
    80001214:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001216:	8adff0ef          	jal	ra,80000ac2 <kalloc>
    8000121a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000121c:	c509                	beqz	a0,80001226 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000121e:	6605                	lui	a2,0x1
    80001220:	4581                	li	a1,0
    80001222:	a45ff0ef          	jal	ra,80000c66 <memset>
  return pagetable;
}
    80001226:	8526                	mv	a0,s1
    80001228:	60e2                	ld	ra,24(sp)
    8000122a:	6442                	ld	s0,16(sp)
    8000122c:	64a2                	ld	s1,8(sp)
    8000122e:	6105                	addi	sp,sp,32
    80001230:	8082                	ret

0000000080001232 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001232:	7179                	addi	sp,sp,-48
    80001234:	f406                	sd	ra,40(sp)
    80001236:	f022                	sd	s0,32(sp)
    80001238:	ec26                	sd	s1,24(sp)
    8000123a:	e84a                	sd	s2,16(sp)
    8000123c:	e44e                	sd	s3,8(sp)
    8000123e:	e052                	sd	s4,0(sp)
    80001240:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001242:	6785                	lui	a5,0x1
    80001244:	04f67063          	bgeu	a2,a5,80001284 <uvmfirst+0x52>
    80001248:	8a2a                	mv	s4,a0
    8000124a:	89ae                	mv	s3,a1
    8000124c:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000124e:	875ff0ef          	jal	ra,80000ac2 <kalloc>
    80001252:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001254:	6605                	lui	a2,0x1
    80001256:	4581                	li	a1,0
    80001258:	a0fff0ef          	jal	ra,80000c66 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000125c:	4779                	li	a4,30
    8000125e:	86ca                	mv	a3,s2
    80001260:	6605                	lui	a2,0x1
    80001262:	4581                	li	a1,0
    80001264:	8552                	mv	a0,s4
    80001266:	d55ff0ef          	jal	ra,80000fba <mappages>
  memmove(mem, src, sz);
    8000126a:	8626                	mv	a2,s1
    8000126c:	85ce                	mv	a1,s3
    8000126e:	854a                	mv	a0,s2
    80001270:	a53ff0ef          	jal	ra,80000cc2 <memmove>
}
    80001274:	70a2                	ld	ra,40(sp)
    80001276:	7402                	ld	s0,32(sp)
    80001278:	64e2                	ld	s1,24(sp)
    8000127a:	6942                	ld	s2,16(sp)
    8000127c:	69a2                	ld	s3,8(sp)
    8000127e:	6a02                	ld	s4,0(sp)
    80001280:	6145                	addi	sp,sp,48
    80001282:	8082                	ret
    panic("uvmfirst: more than a page");
    80001284:	00006517          	auipc	a0,0x6
    80001288:	f0c50513          	addi	a0,a0,-244 # 80007190 <digits+0x158>
    8000128c:	ccaff0ef          	jal	ra,80000756 <panic>

0000000080001290 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001290:	1101                	addi	sp,sp,-32
    80001292:	ec06                	sd	ra,24(sp)
    80001294:	e822                	sd	s0,16(sp)
    80001296:	e426                	sd	s1,8(sp)
    80001298:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000129a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000129c:	00b67d63          	bgeu	a2,a1,800012b6 <uvmdealloc+0x26>
    800012a0:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800012a2:	6785                	lui	a5,0x1
    800012a4:	17fd                	addi	a5,a5,-1
    800012a6:	00f60733          	add	a4,a2,a5
    800012aa:	767d                	lui	a2,0xfffff
    800012ac:	8f71                	and	a4,a4,a2
    800012ae:	97ae                	add	a5,a5,a1
    800012b0:	8ff1                	and	a5,a5,a2
    800012b2:	00f76863          	bltu	a4,a5,800012c2 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800012b6:	8526                	mv	a0,s1
    800012b8:	60e2                	ld	ra,24(sp)
    800012ba:	6442                	ld	s0,16(sp)
    800012bc:	64a2                	ld	s1,8(sp)
    800012be:	6105                	addi	sp,sp,32
    800012c0:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800012c2:	8f99                	sub	a5,a5,a4
    800012c4:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800012c6:	4685                	li	a3,1
    800012c8:	0007861b          	sext.w	a2,a5
    800012cc:	85ba                	mv	a1,a4
    800012ce:	e93ff0ef          	jal	ra,80001160 <uvmunmap>
    800012d2:	b7d5                	j	800012b6 <uvmdealloc+0x26>

00000000800012d4 <uvmalloc>:
  if(newsz < oldsz)
    800012d4:	08b66963          	bltu	a2,a1,80001366 <uvmalloc+0x92>
{
    800012d8:	7139                	addi	sp,sp,-64
    800012da:	fc06                	sd	ra,56(sp)
    800012dc:	f822                	sd	s0,48(sp)
    800012de:	f426                	sd	s1,40(sp)
    800012e0:	f04a                	sd	s2,32(sp)
    800012e2:	ec4e                	sd	s3,24(sp)
    800012e4:	e852                	sd	s4,16(sp)
    800012e6:	e456                	sd	s5,8(sp)
    800012e8:	e05a                	sd	s6,0(sp)
    800012ea:	0080                	addi	s0,sp,64
    800012ec:	8aaa                	mv	s5,a0
    800012ee:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800012f0:	6985                	lui	s3,0x1
    800012f2:	19fd                	addi	s3,s3,-1
    800012f4:	95ce                	add	a1,a1,s3
    800012f6:	79fd                	lui	s3,0xfffff
    800012f8:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    800012fc:	06c9f763          	bgeu	s3,a2,8000136a <uvmalloc+0x96>
    80001300:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001302:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001306:	fbcff0ef          	jal	ra,80000ac2 <kalloc>
    8000130a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000130c:	c11d                	beqz	a0,80001332 <uvmalloc+0x5e>
    memset(mem, 0, PGSIZE);
    8000130e:	6605                	lui	a2,0x1
    80001310:	4581                	li	a1,0
    80001312:	955ff0ef          	jal	ra,80000c66 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001316:	875a                	mv	a4,s6
    80001318:	86a6                	mv	a3,s1
    8000131a:	6605                	lui	a2,0x1
    8000131c:	85ca                	mv	a1,s2
    8000131e:	8556                	mv	a0,s5
    80001320:	c9bff0ef          	jal	ra,80000fba <mappages>
    80001324:	e51d                	bnez	a0,80001352 <uvmalloc+0x7e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001326:	6785                	lui	a5,0x1
    80001328:	993e                	add	s2,s2,a5
    8000132a:	fd496ee3          	bltu	s2,s4,80001306 <uvmalloc+0x32>
  return newsz;
    8000132e:	8552                	mv	a0,s4
    80001330:	a039                	j	8000133e <uvmalloc+0x6a>
      uvmdealloc(pagetable, a, oldsz);
    80001332:	864e                	mv	a2,s3
    80001334:	85ca                	mv	a1,s2
    80001336:	8556                	mv	a0,s5
    80001338:	f59ff0ef          	jal	ra,80001290 <uvmdealloc>
      return 0;
    8000133c:	4501                	li	a0,0
}
    8000133e:	70e2                	ld	ra,56(sp)
    80001340:	7442                	ld	s0,48(sp)
    80001342:	74a2                	ld	s1,40(sp)
    80001344:	7902                	ld	s2,32(sp)
    80001346:	69e2                	ld	s3,24(sp)
    80001348:	6a42                	ld	s4,16(sp)
    8000134a:	6aa2                	ld	s5,8(sp)
    8000134c:	6b02                	ld	s6,0(sp)
    8000134e:	6121                	addi	sp,sp,64
    80001350:	8082                	ret
      kfree(mem);
    80001352:	8526                	mv	a0,s1
    80001354:	e8eff0ef          	jal	ra,800009e2 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001358:	864e                	mv	a2,s3
    8000135a:	85ca                	mv	a1,s2
    8000135c:	8556                	mv	a0,s5
    8000135e:	f33ff0ef          	jal	ra,80001290 <uvmdealloc>
      return 0;
    80001362:	4501                	li	a0,0
    80001364:	bfe9                	j	8000133e <uvmalloc+0x6a>
    return oldsz;
    80001366:	852e                	mv	a0,a1
}
    80001368:	8082                	ret
  return newsz;
    8000136a:	8532                	mv	a0,a2
    8000136c:	bfc9                	j	8000133e <uvmalloc+0x6a>

000000008000136e <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000136e:	7179                	addi	sp,sp,-48
    80001370:	f406                	sd	ra,40(sp)
    80001372:	f022                	sd	s0,32(sp)
    80001374:	ec26                	sd	s1,24(sp)
    80001376:	e84a                	sd	s2,16(sp)
    80001378:	e44e                	sd	s3,8(sp)
    8000137a:	e052                	sd	s4,0(sp)
    8000137c:	1800                	addi	s0,sp,48
    8000137e:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001380:	84aa                	mv	s1,a0
    80001382:	6905                	lui	s2,0x1
    80001384:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001386:	4985                	li	s3,1
    80001388:	a811                	j	8000139c <freewalk+0x2e>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000138a:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    8000138c:	0532                	slli	a0,a0,0xc
    8000138e:	fe1ff0ef          	jal	ra,8000136e <freewalk>
      pagetable[i] = 0;
    80001392:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001396:	04a1                	addi	s1,s1,8
    80001398:	01248f63          	beq	s1,s2,800013b6 <freewalk+0x48>
    pte_t pte = pagetable[i];
    8000139c:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000139e:	00f57793          	andi	a5,a0,15
    800013a2:	ff3784e3          	beq	a5,s3,8000138a <freewalk+0x1c>
    } else if(pte & PTE_V){
    800013a6:	8905                	andi	a0,a0,1
    800013a8:	d57d                	beqz	a0,80001396 <freewalk+0x28>
      panic("freewalk: leaf");
    800013aa:	00006517          	auipc	a0,0x6
    800013ae:	e0650513          	addi	a0,a0,-506 # 800071b0 <digits+0x178>
    800013b2:	ba4ff0ef          	jal	ra,80000756 <panic>
    }
  }
  kfree((void*)pagetable);
    800013b6:	8552                	mv	a0,s4
    800013b8:	e2aff0ef          	jal	ra,800009e2 <kfree>
}
    800013bc:	70a2                	ld	ra,40(sp)
    800013be:	7402                	ld	s0,32(sp)
    800013c0:	64e2                	ld	s1,24(sp)
    800013c2:	6942                	ld	s2,16(sp)
    800013c4:	69a2                	ld	s3,8(sp)
    800013c6:	6a02                	ld	s4,0(sp)
    800013c8:	6145                	addi	sp,sp,48
    800013ca:	8082                	ret

00000000800013cc <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800013cc:	1101                	addi	sp,sp,-32
    800013ce:	ec06                	sd	ra,24(sp)
    800013d0:	e822                	sd	s0,16(sp)
    800013d2:	e426                	sd	s1,8(sp)
    800013d4:	1000                	addi	s0,sp,32
    800013d6:	84aa                	mv	s1,a0
  if(sz > 0)
    800013d8:	e989                	bnez	a1,800013ea <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800013da:	8526                	mv	a0,s1
    800013dc:	f93ff0ef          	jal	ra,8000136e <freewalk>
}
    800013e0:	60e2                	ld	ra,24(sp)
    800013e2:	6442                	ld	s0,16(sp)
    800013e4:	64a2                	ld	s1,8(sp)
    800013e6:	6105                	addi	sp,sp,32
    800013e8:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800013ea:	6605                	lui	a2,0x1
    800013ec:	167d                	addi	a2,a2,-1
    800013ee:	962e                	add	a2,a2,a1
    800013f0:	4685                	li	a3,1
    800013f2:	8231                	srli	a2,a2,0xc
    800013f4:	4581                	li	a1,0
    800013f6:	d6bff0ef          	jal	ra,80001160 <uvmunmap>
    800013fa:	b7c5                	j	800013da <uvmfree+0xe>

00000000800013fc <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800013fc:	c65d                	beqz	a2,800014aa <uvmcopy+0xae>
{
    800013fe:	715d                	addi	sp,sp,-80
    80001400:	e486                	sd	ra,72(sp)
    80001402:	e0a2                	sd	s0,64(sp)
    80001404:	fc26                	sd	s1,56(sp)
    80001406:	f84a                	sd	s2,48(sp)
    80001408:	f44e                	sd	s3,40(sp)
    8000140a:	f052                	sd	s4,32(sp)
    8000140c:	ec56                	sd	s5,24(sp)
    8000140e:	e85a                	sd	s6,16(sp)
    80001410:	e45e                	sd	s7,8(sp)
    80001412:	0880                	addi	s0,sp,80
    80001414:	8b2a                	mv	s6,a0
    80001416:	8aae                	mv	s5,a1
    80001418:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000141a:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000141c:	4601                	li	a2,0
    8000141e:	85ce                	mv	a1,s3
    80001420:	855a                	mv	a0,s6
    80001422:	ac1ff0ef          	jal	ra,80000ee2 <walk>
    80001426:	c121                	beqz	a0,80001466 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001428:	6118                	ld	a4,0(a0)
    8000142a:	00177793          	andi	a5,a4,1
    8000142e:	c3b1                	beqz	a5,80001472 <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001430:	00a75593          	srli	a1,a4,0xa
    80001434:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001438:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000143c:	e86ff0ef          	jal	ra,80000ac2 <kalloc>
    80001440:	892a                	mv	s2,a0
    80001442:	c129                	beqz	a0,80001484 <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001444:	6605                	lui	a2,0x1
    80001446:	85de                	mv	a1,s7
    80001448:	87bff0ef          	jal	ra,80000cc2 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000144c:	8726                	mv	a4,s1
    8000144e:	86ca                	mv	a3,s2
    80001450:	6605                	lui	a2,0x1
    80001452:	85ce                	mv	a1,s3
    80001454:	8556                	mv	a0,s5
    80001456:	b65ff0ef          	jal	ra,80000fba <mappages>
    8000145a:	e115                	bnez	a0,8000147e <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    8000145c:	6785                	lui	a5,0x1
    8000145e:	99be                	add	s3,s3,a5
    80001460:	fb49eee3          	bltu	s3,s4,8000141c <uvmcopy+0x20>
    80001464:	a805                	j	80001494 <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    80001466:	00006517          	auipc	a0,0x6
    8000146a:	d5a50513          	addi	a0,a0,-678 # 800071c0 <digits+0x188>
    8000146e:	ae8ff0ef          	jal	ra,80000756 <panic>
      panic("uvmcopy: page not present");
    80001472:	00006517          	auipc	a0,0x6
    80001476:	d6e50513          	addi	a0,a0,-658 # 800071e0 <digits+0x1a8>
    8000147a:	adcff0ef          	jal	ra,80000756 <panic>
      kfree(mem);
    8000147e:	854a                	mv	a0,s2
    80001480:	d62ff0ef          	jal	ra,800009e2 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001484:	4685                	li	a3,1
    80001486:	00c9d613          	srli	a2,s3,0xc
    8000148a:	4581                	li	a1,0
    8000148c:	8556                	mv	a0,s5
    8000148e:	cd3ff0ef          	jal	ra,80001160 <uvmunmap>
  return -1;
    80001492:	557d                	li	a0,-1
}
    80001494:	60a6                	ld	ra,72(sp)
    80001496:	6406                	ld	s0,64(sp)
    80001498:	74e2                	ld	s1,56(sp)
    8000149a:	7942                	ld	s2,48(sp)
    8000149c:	79a2                	ld	s3,40(sp)
    8000149e:	7a02                	ld	s4,32(sp)
    800014a0:	6ae2                	ld	s5,24(sp)
    800014a2:	6b42                	ld	s6,16(sp)
    800014a4:	6ba2                	ld	s7,8(sp)
    800014a6:	6161                	addi	sp,sp,80
    800014a8:	8082                	ret
  return 0;
    800014aa:	4501                	li	a0,0
}
    800014ac:	8082                	ret

00000000800014ae <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800014ae:	1141                	addi	sp,sp,-16
    800014b0:	e406                	sd	ra,8(sp)
    800014b2:	e022                	sd	s0,0(sp)
    800014b4:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800014b6:	4601                	li	a2,0
    800014b8:	a2bff0ef          	jal	ra,80000ee2 <walk>
  if(pte == 0)
    800014bc:	c901                	beqz	a0,800014cc <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800014be:	611c                	ld	a5,0(a0)
    800014c0:	9bbd                	andi	a5,a5,-17
    800014c2:	e11c                	sd	a5,0(a0)
}
    800014c4:	60a2                	ld	ra,8(sp)
    800014c6:	6402                	ld	s0,0(sp)
    800014c8:	0141                	addi	sp,sp,16
    800014ca:	8082                	ret
    panic("uvmclear");
    800014cc:	00006517          	auipc	a0,0x6
    800014d0:	d3450513          	addi	a0,a0,-716 # 80007200 <digits+0x1c8>
    800014d4:	a82ff0ef          	jal	ra,80000756 <panic>

00000000800014d8 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    800014d8:	c6c9                	beqz	a3,80001562 <copyout+0x8a>
{
    800014da:	711d                	addi	sp,sp,-96
    800014dc:	ec86                	sd	ra,88(sp)
    800014de:	e8a2                	sd	s0,80(sp)
    800014e0:	e4a6                	sd	s1,72(sp)
    800014e2:	e0ca                	sd	s2,64(sp)
    800014e4:	fc4e                	sd	s3,56(sp)
    800014e6:	f852                	sd	s4,48(sp)
    800014e8:	f456                	sd	s5,40(sp)
    800014ea:	f05a                	sd	s6,32(sp)
    800014ec:	ec5e                	sd	s7,24(sp)
    800014ee:	e862                	sd	s8,16(sp)
    800014f0:	e466                	sd	s9,8(sp)
    800014f2:	e06a                	sd	s10,0(sp)
    800014f4:	1080                	addi	s0,sp,96
    800014f6:	8baa                	mv	s7,a0
    800014f8:	8aae                	mv	s5,a1
    800014fa:	8b32                	mv	s6,a2
    800014fc:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800014fe:	74fd                	lui	s1,0xfffff
    80001500:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001502:	57fd                	li	a5,-1
    80001504:	83e9                	srli	a5,a5,0x1a
    80001506:	0697e063          	bltu	a5,s1,80001566 <copyout+0x8e>
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    8000150a:	4cd5                	li	s9,21
    8000150c:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    8000150e:	8c3e                	mv	s8,a5
    80001510:	a025                	j	80001538 <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    80001512:	83a9                	srli	a5,a5,0xa
    80001514:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001516:	409a8533          	sub	a0,s5,s1
    8000151a:	0009061b          	sext.w	a2,s2
    8000151e:	85da                	mv	a1,s6
    80001520:	953e                	add	a0,a0,a5
    80001522:	fa0ff0ef          	jal	ra,80000cc2 <memmove>

    len -= n;
    80001526:	412989b3          	sub	s3,s3,s2
    src += n;
    8000152a:	9b4a                	add	s6,s6,s2
  while(len > 0){
    8000152c:	02098963          	beqz	s3,8000155e <copyout+0x86>
    if(va0 >= MAXVA)
    80001530:	034c6d63          	bltu	s8,s4,8000156a <copyout+0x92>
    va0 = PGROUNDDOWN(dstva);
    80001534:	84d2                	mv	s1,s4
    dstva = va0 + PGSIZE;
    80001536:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    80001538:	4601                	li	a2,0
    8000153a:	85a6                	mv	a1,s1
    8000153c:	855e                	mv	a0,s7
    8000153e:	9a5ff0ef          	jal	ra,80000ee2 <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80001542:	c515                	beqz	a0,8000156e <copyout+0x96>
    80001544:	611c                	ld	a5,0(a0)
    80001546:	0157f713          	andi	a4,a5,21
    8000154a:	05971163          	bne	a4,s9,8000158c <copyout+0xb4>
    n = PGSIZE - (dstva - va0);
    8000154e:	01a48a33          	add	s4,s1,s10
    80001552:	415a0933          	sub	s2,s4,s5
    if(n > len)
    80001556:	fb29fee3          	bgeu	s3,s2,80001512 <copyout+0x3a>
    8000155a:	894e                	mv	s2,s3
    8000155c:	bf5d                	j	80001512 <copyout+0x3a>
  }
  return 0;
    8000155e:	4501                	li	a0,0
    80001560:	a801                	j	80001570 <copyout+0x98>
    80001562:	4501                	li	a0,0
}
    80001564:	8082                	ret
      return -1;
    80001566:	557d                	li	a0,-1
    80001568:	a021                	j	80001570 <copyout+0x98>
    8000156a:	557d                	li	a0,-1
    8000156c:	a011                	j	80001570 <copyout+0x98>
      return -1;
    8000156e:	557d                	li	a0,-1
}
    80001570:	60e6                	ld	ra,88(sp)
    80001572:	6446                	ld	s0,80(sp)
    80001574:	64a6                	ld	s1,72(sp)
    80001576:	6906                	ld	s2,64(sp)
    80001578:	79e2                	ld	s3,56(sp)
    8000157a:	7a42                	ld	s4,48(sp)
    8000157c:	7aa2                	ld	s5,40(sp)
    8000157e:	7b02                	ld	s6,32(sp)
    80001580:	6be2                	ld	s7,24(sp)
    80001582:	6c42                	ld	s8,16(sp)
    80001584:	6ca2                	ld	s9,8(sp)
    80001586:	6d02                	ld	s10,0(sp)
    80001588:	6125                	addi	sp,sp,96
    8000158a:	8082                	ret
      return -1;
    8000158c:	557d                	li	a0,-1
    8000158e:	b7cd                	j	80001570 <copyout+0x98>

0000000080001590 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001590:	c6a5                	beqz	a3,800015f8 <copyin+0x68>
{
    80001592:	715d                	addi	sp,sp,-80
    80001594:	e486                	sd	ra,72(sp)
    80001596:	e0a2                	sd	s0,64(sp)
    80001598:	fc26                	sd	s1,56(sp)
    8000159a:	f84a                	sd	s2,48(sp)
    8000159c:	f44e                	sd	s3,40(sp)
    8000159e:	f052                	sd	s4,32(sp)
    800015a0:	ec56                	sd	s5,24(sp)
    800015a2:	e85a                	sd	s6,16(sp)
    800015a4:	e45e                	sd	s7,8(sp)
    800015a6:	e062                	sd	s8,0(sp)
    800015a8:	0880                	addi	s0,sp,80
    800015aa:	8b2a                	mv	s6,a0
    800015ac:	8a2e                	mv	s4,a1
    800015ae:	8c32                	mv	s8,a2
    800015b0:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800015b2:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800015b4:	6a85                	lui	s5,0x1
    800015b6:	a00d                	j	800015d8 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800015b8:	018505b3          	add	a1,a0,s8
    800015bc:	0004861b          	sext.w	a2,s1
    800015c0:	412585b3          	sub	a1,a1,s2
    800015c4:	8552                	mv	a0,s4
    800015c6:	efcff0ef          	jal	ra,80000cc2 <memmove>

    len -= n;
    800015ca:	409989b3          	sub	s3,s3,s1
    dst += n;
    800015ce:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800015d0:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800015d4:	02098063          	beqz	s3,800015f4 <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    800015d8:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800015dc:	85ca                	mv	a1,s2
    800015de:	855a                	mv	a0,s6
    800015e0:	99dff0ef          	jal	ra,80000f7c <walkaddr>
    if(pa0 == 0)
    800015e4:	cd01                	beqz	a0,800015fc <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    800015e6:	418904b3          	sub	s1,s2,s8
    800015ea:	94d6                	add	s1,s1,s5
    if(n > len)
    800015ec:	fc99f6e3          	bgeu	s3,s1,800015b8 <copyin+0x28>
    800015f0:	84ce                	mv	s1,s3
    800015f2:	b7d9                	j	800015b8 <copyin+0x28>
  }
  return 0;
    800015f4:	4501                	li	a0,0
    800015f6:	a021                	j	800015fe <copyin+0x6e>
    800015f8:	4501                	li	a0,0
}
    800015fa:	8082                	ret
      return -1;
    800015fc:	557d                	li	a0,-1
}
    800015fe:	60a6                	ld	ra,72(sp)
    80001600:	6406                	ld	s0,64(sp)
    80001602:	74e2                	ld	s1,56(sp)
    80001604:	7942                	ld	s2,48(sp)
    80001606:	79a2                	ld	s3,40(sp)
    80001608:	7a02                	ld	s4,32(sp)
    8000160a:	6ae2                	ld	s5,24(sp)
    8000160c:	6b42                	ld	s6,16(sp)
    8000160e:	6ba2                	ld	s7,8(sp)
    80001610:	6c02                	ld	s8,0(sp)
    80001612:	6161                	addi	sp,sp,80
    80001614:	8082                	ret

0000000080001616 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001616:	c2d5                	beqz	a3,800016ba <copyinstr+0xa4>
{
    80001618:	715d                	addi	sp,sp,-80
    8000161a:	e486                	sd	ra,72(sp)
    8000161c:	e0a2                	sd	s0,64(sp)
    8000161e:	fc26                	sd	s1,56(sp)
    80001620:	f84a                	sd	s2,48(sp)
    80001622:	f44e                	sd	s3,40(sp)
    80001624:	f052                	sd	s4,32(sp)
    80001626:	ec56                	sd	s5,24(sp)
    80001628:	e85a                	sd	s6,16(sp)
    8000162a:	e45e                	sd	s7,8(sp)
    8000162c:	0880                	addi	s0,sp,80
    8000162e:	8a2a                	mv	s4,a0
    80001630:	8b2e                	mv	s6,a1
    80001632:	8bb2                	mv	s7,a2
    80001634:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001636:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001638:	6985                	lui	s3,0x1
    8000163a:	a035                	j	80001666 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000163c:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001640:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001642:	0017b793          	seqz	a5,a5
    80001646:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000164a:	60a6                	ld	ra,72(sp)
    8000164c:	6406                	ld	s0,64(sp)
    8000164e:	74e2                	ld	s1,56(sp)
    80001650:	7942                	ld	s2,48(sp)
    80001652:	79a2                	ld	s3,40(sp)
    80001654:	7a02                	ld	s4,32(sp)
    80001656:	6ae2                	ld	s5,24(sp)
    80001658:	6b42                	ld	s6,16(sp)
    8000165a:	6ba2                	ld	s7,8(sp)
    8000165c:	6161                	addi	sp,sp,80
    8000165e:	8082                	ret
    srcva = va0 + PGSIZE;
    80001660:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001664:	c4b9                	beqz	s1,800016b2 <copyinstr+0x9c>
    va0 = PGROUNDDOWN(srcva);
    80001666:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000166a:	85ca                	mv	a1,s2
    8000166c:	8552                	mv	a0,s4
    8000166e:	90fff0ef          	jal	ra,80000f7c <walkaddr>
    if(pa0 == 0)
    80001672:	c131                	beqz	a0,800016b6 <copyinstr+0xa0>
    n = PGSIZE - (srcva - va0);
    80001674:	41790833          	sub	a6,s2,s7
    80001678:	984e                	add	a6,a6,s3
    if(n > max)
    8000167a:	0104f363          	bgeu	s1,a6,80001680 <copyinstr+0x6a>
    8000167e:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001680:	955e                	add	a0,a0,s7
    80001682:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001686:	fc080de3          	beqz	a6,80001660 <copyinstr+0x4a>
    8000168a:	985a                	add	a6,a6,s6
    8000168c:	87da                	mv	a5,s6
      if(*p == '\0'){
    8000168e:	41650633          	sub	a2,a0,s6
    80001692:	14fd                	addi	s1,s1,-1
    80001694:	9b26                	add	s6,s6,s1
    80001696:	00f60733          	add	a4,a2,a5
    8000169a:	00074703          	lbu	a4,0(a4)
    8000169e:	df59                	beqz	a4,8000163c <copyinstr+0x26>
        *dst = *p;
    800016a0:	00e78023          	sb	a4,0(a5)
      --max;
    800016a4:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800016a8:	0785                	addi	a5,a5,1
    while(n > 0){
    800016aa:	ff0796e3          	bne	a5,a6,80001696 <copyinstr+0x80>
      dst++;
    800016ae:	8b42                	mv	s6,a6
    800016b0:	bf45                	j	80001660 <copyinstr+0x4a>
    800016b2:	4781                	li	a5,0
    800016b4:	b779                	j	80001642 <copyinstr+0x2c>
      return -1;
    800016b6:	557d                	li	a0,-1
    800016b8:	bf49                	j	8000164a <copyinstr+0x34>
  int got_null = 0;
    800016ba:	4781                	li	a5,0
  if(got_null){
    800016bc:	0017b793          	seqz	a5,a5
    800016c0:	40f00533          	neg	a0,a5
}
    800016c4:	8082                	ret

00000000800016c6 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800016c6:	7139                	addi	sp,sp,-64
    800016c8:	fc06                	sd	ra,56(sp)
    800016ca:	f822                	sd	s0,48(sp)
    800016cc:	f426                	sd	s1,40(sp)
    800016ce:	f04a                	sd	s2,32(sp)
    800016d0:	ec4e                	sd	s3,24(sp)
    800016d2:	e852                	sd	s4,16(sp)
    800016d4:	e456                	sd	s5,8(sp)
    800016d6:	e05a                	sd	s6,0(sp)
    800016d8:	0080                	addi	s0,sp,64
    800016da:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800016dc:	0000e497          	auipc	s1,0xe
    800016e0:	78448493          	addi	s1,s1,1924 # 8000fe60 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800016e4:	8b26                	mv	s6,s1
    800016e6:	00006a97          	auipc	s5,0x6
    800016ea:	91aa8a93          	addi	s5,s5,-1766 # 80007000 <etext>
    800016ee:	04000937          	lui	s2,0x4000
    800016f2:	197d                	addi	s2,s2,-1
    800016f4:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800016f6:	00014a17          	auipc	s4,0x14
    800016fa:	16aa0a13          	addi	s4,s4,362 # 80015860 <tickslock>
    char *pa = kalloc();
    800016fe:	bc4ff0ef          	jal	ra,80000ac2 <kalloc>
    80001702:	862a                	mv	a2,a0
    if(pa == 0)
    80001704:	c121                	beqz	a0,80001744 <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    80001706:	416485b3          	sub	a1,s1,s6
    8000170a:	858d                	srai	a1,a1,0x3
    8000170c:	000ab783          	ld	a5,0(s5)
    80001710:	02f585b3          	mul	a1,a1,a5
    80001714:	2585                	addiw	a1,a1,1
    80001716:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000171a:	4719                	li	a4,6
    8000171c:	6685                	lui	a3,0x1
    8000171e:	40b905b3          	sub	a1,s2,a1
    80001722:	854e                	mv	a0,s3
    80001724:	947ff0ef          	jal	ra,8000106a <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001728:	16848493          	addi	s1,s1,360
    8000172c:	fd4499e3          	bne	s1,s4,800016fe <proc_mapstacks+0x38>
  }
}
    80001730:	70e2                	ld	ra,56(sp)
    80001732:	7442                	ld	s0,48(sp)
    80001734:	74a2                	ld	s1,40(sp)
    80001736:	7902                	ld	s2,32(sp)
    80001738:	69e2                	ld	s3,24(sp)
    8000173a:	6a42                	ld	s4,16(sp)
    8000173c:	6aa2                	ld	s5,8(sp)
    8000173e:	6b02                	ld	s6,0(sp)
    80001740:	6121                	addi	sp,sp,64
    80001742:	8082                	ret
      panic("kalloc");
    80001744:	00006517          	auipc	a0,0x6
    80001748:	acc50513          	addi	a0,a0,-1332 # 80007210 <digits+0x1d8>
    8000174c:	80aff0ef          	jal	ra,80000756 <panic>

0000000080001750 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001750:	7139                	addi	sp,sp,-64
    80001752:	fc06                	sd	ra,56(sp)
    80001754:	f822                	sd	s0,48(sp)
    80001756:	f426                	sd	s1,40(sp)
    80001758:	f04a                	sd	s2,32(sp)
    8000175a:	ec4e                	sd	s3,24(sp)
    8000175c:	e852                	sd	s4,16(sp)
    8000175e:	e456                	sd	s5,8(sp)
    80001760:	e05a                	sd	s6,0(sp)
    80001762:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001764:	00006597          	auipc	a1,0x6
    80001768:	ab458593          	addi	a1,a1,-1356 # 80007218 <digits+0x1e0>
    8000176c:	0000e517          	auipc	a0,0xe
    80001770:	2c450513          	addi	a0,a0,708 # 8000fa30 <pid_lock>
    80001774:	b9eff0ef          	jal	ra,80000b12 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001778:	00006597          	auipc	a1,0x6
    8000177c:	aa858593          	addi	a1,a1,-1368 # 80007220 <digits+0x1e8>
    80001780:	0000e517          	auipc	a0,0xe
    80001784:	2c850513          	addi	a0,a0,712 # 8000fa48 <wait_lock>
    80001788:	b8aff0ef          	jal	ra,80000b12 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000178c:	0000e497          	auipc	s1,0xe
    80001790:	6d448493          	addi	s1,s1,1748 # 8000fe60 <proc>
      initlock(&p->lock, "proc");
    80001794:	00006b17          	auipc	s6,0x6
    80001798:	a9cb0b13          	addi	s6,s6,-1380 # 80007230 <digits+0x1f8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000179c:	8aa6                	mv	s5,s1
    8000179e:	00006a17          	auipc	s4,0x6
    800017a2:	862a0a13          	addi	s4,s4,-1950 # 80007000 <etext>
    800017a6:	04000937          	lui	s2,0x4000
    800017aa:	197d                	addi	s2,s2,-1
    800017ac:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800017ae:	00014997          	auipc	s3,0x14
    800017b2:	0b298993          	addi	s3,s3,178 # 80015860 <tickslock>
      initlock(&p->lock, "proc");
    800017b6:	85da                	mv	a1,s6
    800017b8:	8526                	mv	a0,s1
    800017ba:	b58ff0ef          	jal	ra,80000b12 <initlock>
      p->state = UNUSED;
    800017be:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800017c2:	415487b3          	sub	a5,s1,s5
    800017c6:	878d                	srai	a5,a5,0x3
    800017c8:	000a3703          	ld	a4,0(s4)
    800017cc:	02e787b3          	mul	a5,a5,a4
    800017d0:	2785                	addiw	a5,a5,1
    800017d2:	00d7979b          	slliw	a5,a5,0xd
    800017d6:	40f907b3          	sub	a5,s2,a5
    800017da:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800017dc:	16848493          	addi	s1,s1,360
    800017e0:	fd349be3          	bne	s1,s3,800017b6 <procinit+0x66>
  }
}
    800017e4:	70e2                	ld	ra,56(sp)
    800017e6:	7442                	ld	s0,48(sp)
    800017e8:	74a2                	ld	s1,40(sp)
    800017ea:	7902                	ld	s2,32(sp)
    800017ec:	69e2                	ld	s3,24(sp)
    800017ee:	6a42                	ld	s4,16(sp)
    800017f0:	6aa2                	ld	s5,8(sp)
    800017f2:	6b02                	ld	s6,0(sp)
    800017f4:	6121                	addi	sp,sp,64
    800017f6:	8082                	ret

00000000800017f8 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800017f8:	1141                	addi	sp,sp,-16
    800017fa:	e422                	sd	s0,8(sp)
    800017fc:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800017fe:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001800:	2501                	sext.w	a0,a0
    80001802:	6422                	ld	s0,8(sp)
    80001804:	0141                	addi	sp,sp,16
    80001806:	8082                	ret

0000000080001808 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001808:	1141                	addi	sp,sp,-16
    8000180a:	e422                	sd	s0,8(sp)
    8000180c:	0800                	addi	s0,sp,16
    8000180e:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001810:	2781                	sext.w	a5,a5
    80001812:	079e                	slli	a5,a5,0x7
  return c;
}
    80001814:	0000e517          	auipc	a0,0xe
    80001818:	24c50513          	addi	a0,a0,588 # 8000fa60 <cpus>
    8000181c:	953e                	add	a0,a0,a5
    8000181e:	6422                	ld	s0,8(sp)
    80001820:	0141                	addi	sp,sp,16
    80001822:	8082                	ret

0000000080001824 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001824:	1101                	addi	sp,sp,-32
    80001826:	ec06                	sd	ra,24(sp)
    80001828:	e822                	sd	s0,16(sp)
    8000182a:	e426                	sd	s1,8(sp)
    8000182c:	1000                	addi	s0,sp,32
  push_off();
    8000182e:	b24ff0ef          	jal	ra,80000b52 <push_off>
    80001832:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001834:	2781                	sext.w	a5,a5
    80001836:	079e                	slli	a5,a5,0x7
    80001838:	0000e717          	auipc	a4,0xe
    8000183c:	1f870713          	addi	a4,a4,504 # 8000fa30 <pid_lock>
    80001840:	97ba                	add	a5,a5,a4
    80001842:	7b84                	ld	s1,48(a5)
  pop_off();
    80001844:	b92ff0ef          	jal	ra,80000bd6 <pop_off>
  return p;
}
    80001848:	8526                	mv	a0,s1
    8000184a:	60e2                	ld	ra,24(sp)
    8000184c:	6442                	ld	s0,16(sp)
    8000184e:	64a2                	ld	s1,8(sp)
    80001850:	6105                	addi	sp,sp,32
    80001852:	8082                	ret

0000000080001854 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001854:	1141                	addi	sp,sp,-16
    80001856:	e406                	sd	ra,8(sp)
    80001858:	e022                	sd	s0,0(sp)
    8000185a:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    8000185c:	fc9ff0ef          	jal	ra,80001824 <myproc>
    80001860:	bcaff0ef          	jal	ra,80000c2a <release>

  if (first) {
    80001864:	00006797          	auipc	a5,0x6
    80001868:	01c7a783          	lw	a5,28(a5) # 80007880 <first.1>
    8000186c:	e799                	bnez	a5,8000187a <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    8000186e:	2bb000ef          	jal	ra,80002328 <usertrapret>
}
    80001872:	60a2                	ld	ra,8(sp)
    80001874:	6402                	ld	s0,0(sp)
    80001876:	0141                	addi	sp,sp,16
    80001878:	8082                	ret
    fsinit(ROOTDEV);
    8000187a:	4505                	li	a0,1
    8000187c:	638010ef          	jal	ra,80002eb4 <fsinit>
    first = 0;
    80001880:	00006797          	auipc	a5,0x6
    80001884:	0007a023          	sw	zero,0(a5) # 80007880 <first.1>
    __sync_synchronize();
    80001888:	0ff0000f          	fence
    8000188c:	b7cd                	j	8000186e <forkret+0x1a>

000000008000188e <allocpid>:
{
    8000188e:	1101                	addi	sp,sp,-32
    80001890:	ec06                	sd	ra,24(sp)
    80001892:	e822                	sd	s0,16(sp)
    80001894:	e426                	sd	s1,8(sp)
    80001896:	e04a                	sd	s2,0(sp)
    80001898:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    8000189a:	0000e917          	auipc	s2,0xe
    8000189e:	19690913          	addi	s2,s2,406 # 8000fa30 <pid_lock>
    800018a2:	854a                	mv	a0,s2
    800018a4:	aeeff0ef          	jal	ra,80000b92 <acquire>
  pid = nextpid;
    800018a8:	00006797          	auipc	a5,0x6
    800018ac:	fdc78793          	addi	a5,a5,-36 # 80007884 <nextpid>
    800018b0:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800018b2:	0014871b          	addiw	a4,s1,1
    800018b6:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800018b8:	854a                	mv	a0,s2
    800018ba:	b70ff0ef          	jal	ra,80000c2a <release>
}
    800018be:	8526                	mv	a0,s1
    800018c0:	60e2                	ld	ra,24(sp)
    800018c2:	6442                	ld	s0,16(sp)
    800018c4:	64a2                	ld	s1,8(sp)
    800018c6:	6902                	ld	s2,0(sp)
    800018c8:	6105                	addi	sp,sp,32
    800018ca:	8082                	ret

00000000800018cc <proc_pagetable>:
{
    800018cc:	1101                	addi	sp,sp,-32
    800018ce:	ec06                	sd	ra,24(sp)
    800018d0:	e822                	sd	s0,16(sp)
    800018d2:	e426                	sd	s1,8(sp)
    800018d4:	e04a                	sd	s2,0(sp)
    800018d6:	1000                	addi	s0,sp,32
    800018d8:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800018da:	933ff0ef          	jal	ra,8000120c <uvmcreate>
    800018de:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800018e0:	cd05                	beqz	a0,80001918 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    800018e2:	4729                	li	a4,10
    800018e4:	00004697          	auipc	a3,0x4
    800018e8:	71c68693          	addi	a3,a3,1820 # 80006000 <_trampoline>
    800018ec:	6605                	lui	a2,0x1
    800018ee:	040005b7          	lui	a1,0x4000
    800018f2:	15fd                	addi	a1,a1,-1
    800018f4:	05b2                	slli	a1,a1,0xc
    800018f6:	ec4ff0ef          	jal	ra,80000fba <mappages>
    800018fa:	02054663          	bltz	a0,80001926 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800018fe:	4719                	li	a4,6
    80001900:	05893683          	ld	a3,88(s2)
    80001904:	6605                	lui	a2,0x1
    80001906:	020005b7          	lui	a1,0x2000
    8000190a:	15fd                	addi	a1,a1,-1
    8000190c:	05b6                	slli	a1,a1,0xd
    8000190e:	8526                	mv	a0,s1
    80001910:	eaaff0ef          	jal	ra,80000fba <mappages>
    80001914:	00054f63          	bltz	a0,80001932 <proc_pagetable+0x66>
}
    80001918:	8526                	mv	a0,s1
    8000191a:	60e2                	ld	ra,24(sp)
    8000191c:	6442                	ld	s0,16(sp)
    8000191e:	64a2                	ld	s1,8(sp)
    80001920:	6902                	ld	s2,0(sp)
    80001922:	6105                	addi	sp,sp,32
    80001924:	8082                	ret
    uvmfree(pagetable, 0);
    80001926:	4581                	li	a1,0
    80001928:	8526                	mv	a0,s1
    8000192a:	aa3ff0ef          	jal	ra,800013cc <uvmfree>
    return 0;
    8000192e:	4481                	li	s1,0
    80001930:	b7e5                	j	80001918 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001932:	4681                	li	a3,0
    80001934:	4605                	li	a2,1
    80001936:	040005b7          	lui	a1,0x4000
    8000193a:	15fd                	addi	a1,a1,-1
    8000193c:	05b2                	slli	a1,a1,0xc
    8000193e:	8526                	mv	a0,s1
    80001940:	821ff0ef          	jal	ra,80001160 <uvmunmap>
    uvmfree(pagetable, 0);
    80001944:	4581                	li	a1,0
    80001946:	8526                	mv	a0,s1
    80001948:	a85ff0ef          	jal	ra,800013cc <uvmfree>
    return 0;
    8000194c:	4481                	li	s1,0
    8000194e:	b7e9                	j	80001918 <proc_pagetable+0x4c>

0000000080001950 <proc_freepagetable>:
{
    80001950:	1101                	addi	sp,sp,-32
    80001952:	ec06                	sd	ra,24(sp)
    80001954:	e822                	sd	s0,16(sp)
    80001956:	e426                	sd	s1,8(sp)
    80001958:	e04a                	sd	s2,0(sp)
    8000195a:	1000                	addi	s0,sp,32
    8000195c:	84aa                	mv	s1,a0
    8000195e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001960:	4681                	li	a3,0
    80001962:	4605                	li	a2,1
    80001964:	040005b7          	lui	a1,0x4000
    80001968:	15fd                	addi	a1,a1,-1
    8000196a:	05b2                	slli	a1,a1,0xc
    8000196c:	ff4ff0ef          	jal	ra,80001160 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001970:	4681                	li	a3,0
    80001972:	4605                	li	a2,1
    80001974:	020005b7          	lui	a1,0x2000
    80001978:	15fd                	addi	a1,a1,-1
    8000197a:	05b6                	slli	a1,a1,0xd
    8000197c:	8526                	mv	a0,s1
    8000197e:	fe2ff0ef          	jal	ra,80001160 <uvmunmap>
  uvmfree(pagetable, sz);
    80001982:	85ca                	mv	a1,s2
    80001984:	8526                	mv	a0,s1
    80001986:	a47ff0ef          	jal	ra,800013cc <uvmfree>
}
    8000198a:	60e2                	ld	ra,24(sp)
    8000198c:	6442                	ld	s0,16(sp)
    8000198e:	64a2                	ld	s1,8(sp)
    80001990:	6902                	ld	s2,0(sp)
    80001992:	6105                	addi	sp,sp,32
    80001994:	8082                	ret

0000000080001996 <freeproc>:
{
    80001996:	1101                	addi	sp,sp,-32
    80001998:	ec06                	sd	ra,24(sp)
    8000199a:	e822                	sd	s0,16(sp)
    8000199c:	e426                	sd	s1,8(sp)
    8000199e:	1000                	addi	s0,sp,32
    800019a0:	84aa                	mv	s1,a0
  if(p->trapframe)
    800019a2:	6d28                	ld	a0,88(a0)
    800019a4:	c119                	beqz	a0,800019aa <freeproc+0x14>
    kfree((void*)p->trapframe);
    800019a6:	83cff0ef          	jal	ra,800009e2 <kfree>
  p->trapframe = 0;
    800019aa:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    800019ae:	68a8                	ld	a0,80(s1)
    800019b0:	c501                	beqz	a0,800019b8 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    800019b2:	64ac                	ld	a1,72(s1)
    800019b4:	f9dff0ef          	jal	ra,80001950 <proc_freepagetable>
  p->pagetable = 0;
    800019b8:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    800019bc:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    800019c0:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    800019c4:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    800019c8:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    800019cc:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    800019d0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    800019d4:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    800019d8:	0004ac23          	sw	zero,24(s1)
}
    800019dc:	60e2                	ld	ra,24(sp)
    800019de:	6442                	ld	s0,16(sp)
    800019e0:	64a2                	ld	s1,8(sp)
    800019e2:	6105                	addi	sp,sp,32
    800019e4:	8082                	ret

00000000800019e6 <allocproc>:
{
    800019e6:	1101                	addi	sp,sp,-32
    800019e8:	ec06                	sd	ra,24(sp)
    800019ea:	e822                	sd	s0,16(sp)
    800019ec:	e426                	sd	s1,8(sp)
    800019ee:	e04a                	sd	s2,0(sp)
    800019f0:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    800019f2:	0000e497          	auipc	s1,0xe
    800019f6:	46e48493          	addi	s1,s1,1134 # 8000fe60 <proc>
    800019fa:	00014917          	auipc	s2,0x14
    800019fe:	e6690913          	addi	s2,s2,-410 # 80015860 <tickslock>
    acquire(&p->lock);
    80001a02:	8526                	mv	a0,s1
    80001a04:	98eff0ef          	jal	ra,80000b92 <acquire>
    if(p->state == UNUSED) {
    80001a08:	4c9c                	lw	a5,24(s1)
    80001a0a:	cb91                	beqz	a5,80001a1e <allocproc+0x38>
      release(&p->lock);
    80001a0c:	8526                	mv	a0,s1
    80001a0e:	a1cff0ef          	jal	ra,80000c2a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a12:	16848493          	addi	s1,s1,360
    80001a16:	ff2496e3          	bne	s1,s2,80001a02 <allocproc+0x1c>
  return 0;
    80001a1a:	4481                	li	s1,0
    80001a1c:	a089                	j	80001a5e <allocproc+0x78>
  p->pid = allocpid();
    80001a1e:	e71ff0ef          	jal	ra,8000188e <allocpid>
    80001a22:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001a24:	4785                	li	a5,1
    80001a26:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001a28:	89aff0ef          	jal	ra,80000ac2 <kalloc>
    80001a2c:	892a                	mv	s2,a0
    80001a2e:	eca8                	sd	a0,88(s1)
    80001a30:	cd15                	beqz	a0,80001a6c <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001a32:	8526                	mv	a0,s1
    80001a34:	e99ff0ef          	jal	ra,800018cc <proc_pagetable>
    80001a38:	892a                	mv	s2,a0
    80001a3a:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001a3c:	c121                	beqz	a0,80001a7c <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001a3e:	07000613          	li	a2,112
    80001a42:	4581                	li	a1,0
    80001a44:	06048513          	addi	a0,s1,96
    80001a48:	a1eff0ef          	jal	ra,80000c66 <memset>
  p->context.ra = (uint64)forkret;
    80001a4c:	00000797          	auipc	a5,0x0
    80001a50:	e0878793          	addi	a5,a5,-504 # 80001854 <forkret>
    80001a54:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001a56:	60bc                	ld	a5,64(s1)
    80001a58:	6705                	lui	a4,0x1
    80001a5a:	97ba                	add	a5,a5,a4
    80001a5c:	f4bc                	sd	a5,104(s1)
}
    80001a5e:	8526                	mv	a0,s1
    80001a60:	60e2                	ld	ra,24(sp)
    80001a62:	6442                	ld	s0,16(sp)
    80001a64:	64a2                	ld	s1,8(sp)
    80001a66:	6902                	ld	s2,0(sp)
    80001a68:	6105                	addi	sp,sp,32
    80001a6a:	8082                	ret
    freeproc(p);
    80001a6c:	8526                	mv	a0,s1
    80001a6e:	f29ff0ef          	jal	ra,80001996 <freeproc>
    release(&p->lock);
    80001a72:	8526                	mv	a0,s1
    80001a74:	9b6ff0ef          	jal	ra,80000c2a <release>
    return 0;
    80001a78:	84ca                	mv	s1,s2
    80001a7a:	b7d5                	j	80001a5e <allocproc+0x78>
    freeproc(p);
    80001a7c:	8526                	mv	a0,s1
    80001a7e:	f19ff0ef          	jal	ra,80001996 <freeproc>
    release(&p->lock);
    80001a82:	8526                	mv	a0,s1
    80001a84:	9a6ff0ef          	jal	ra,80000c2a <release>
    return 0;
    80001a88:	84ca                	mv	s1,s2
    80001a8a:	bfd1                	j	80001a5e <allocproc+0x78>

0000000080001a8c <userinit>:
{
    80001a8c:	1101                	addi	sp,sp,-32
    80001a8e:	ec06                	sd	ra,24(sp)
    80001a90:	e822                	sd	s0,16(sp)
    80001a92:	e426                	sd	s1,8(sp)
    80001a94:	1000                	addi	s0,sp,32
  p = allocproc();
    80001a96:	f51ff0ef          	jal	ra,800019e6 <allocproc>
    80001a9a:	84aa                	mv	s1,a0
  initproc = p;
    80001a9c:	00006797          	auipc	a5,0x6
    80001aa0:	e4a7be23          	sd	a0,-420(a5) # 800078f8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001aa4:	03400613          	li	a2,52
    80001aa8:	00006597          	auipc	a1,0x6
    80001aac:	de858593          	addi	a1,a1,-536 # 80007890 <initcode>
    80001ab0:	6928                	ld	a0,80(a0)
    80001ab2:	f80ff0ef          	jal	ra,80001232 <uvmfirst>
  p->sz = PGSIZE;
    80001ab6:	6785                	lui	a5,0x1
    80001ab8:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001aba:	6cb8                	ld	a4,88(s1)
    80001abc:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001ac0:	6cb8                	ld	a4,88(s1)
    80001ac2:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ac4:	4641                	li	a2,16
    80001ac6:	00005597          	auipc	a1,0x5
    80001aca:	77258593          	addi	a1,a1,1906 # 80007238 <digits+0x200>
    80001ace:	15848513          	addi	a0,s1,344
    80001ad2:	adaff0ef          	jal	ra,80000dac <safestrcpy>
  p->cwd = namei("/");
    80001ad6:	00005517          	auipc	a0,0x5
    80001ada:	77250513          	addi	a0,a0,1906 # 80007248 <digits+0x210>
    80001ade:	4b5010ef          	jal	ra,80003792 <namei>
    80001ae2:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001ae6:	478d                	li	a5,3
    80001ae8:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001aea:	8526                	mv	a0,s1
    80001aec:	93eff0ef          	jal	ra,80000c2a <release>
}
    80001af0:	60e2                	ld	ra,24(sp)
    80001af2:	6442                	ld	s0,16(sp)
    80001af4:	64a2                	ld	s1,8(sp)
    80001af6:	6105                	addi	sp,sp,32
    80001af8:	8082                	ret

0000000080001afa <growproc>:
{
    80001afa:	1101                	addi	sp,sp,-32
    80001afc:	ec06                	sd	ra,24(sp)
    80001afe:	e822                	sd	s0,16(sp)
    80001b00:	e426                	sd	s1,8(sp)
    80001b02:	e04a                	sd	s2,0(sp)
    80001b04:	1000                	addi	s0,sp,32
    80001b06:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001b08:	d1dff0ef          	jal	ra,80001824 <myproc>
    80001b0c:	84aa                	mv	s1,a0
  sz = p->sz;
    80001b0e:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001b10:	01204c63          	bgtz	s2,80001b28 <growproc+0x2e>
  } else if(n < 0){
    80001b14:	02094463          	bltz	s2,80001b3c <growproc+0x42>
  p->sz = sz;
    80001b18:	e4ac                	sd	a1,72(s1)
  return 0;
    80001b1a:	4501                	li	a0,0
}
    80001b1c:	60e2                	ld	ra,24(sp)
    80001b1e:	6442                	ld	s0,16(sp)
    80001b20:	64a2                	ld	s1,8(sp)
    80001b22:	6902                	ld	s2,0(sp)
    80001b24:	6105                	addi	sp,sp,32
    80001b26:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001b28:	4691                	li	a3,4
    80001b2a:	00b90633          	add	a2,s2,a1
    80001b2e:	6928                	ld	a0,80(a0)
    80001b30:	fa4ff0ef          	jal	ra,800012d4 <uvmalloc>
    80001b34:	85aa                	mv	a1,a0
    80001b36:	f16d                	bnez	a0,80001b18 <growproc+0x1e>
      return -1;
    80001b38:	557d                	li	a0,-1
    80001b3a:	b7cd                	j	80001b1c <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001b3c:	00b90633          	add	a2,s2,a1
    80001b40:	6928                	ld	a0,80(a0)
    80001b42:	f4eff0ef          	jal	ra,80001290 <uvmdealloc>
    80001b46:	85aa                	mv	a1,a0
    80001b48:	bfc1                	j	80001b18 <growproc+0x1e>

0000000080001b4a <fork>:
{
    80001b4a:	7139                	addi	sp,sp,-64
    80001b4c:	fc06                	sd	ra,56(sp)
    80001b4e:	f822                	sd	s0,48(sp)
    80001b50:	f426                	sd	s1,40(sp)
    80001b52:	f04a                	sd	s2,32(sp)
    80001b54:	ec4e                	sd	s3,24(sp)
    80001b56:	e852                	sd	s4,16(sp)
    80001b58:	e456                	sd	s5,8(sp)
    80001b5a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001b5c:	cc9ff0ef          	jal	ra,80001824 <myproc>
    80001b60:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001b62:	e85ff0ef          	jal	ra,800019e6 <allocproc>
    80001b66:	0e050663          	beqz	a0,80001c52 <fork+0x108>
    80001b6a:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001b6c:	048ab603          	ld	a2,72(s5)
    80001b70:	692c                	ld	a1,80(a0)
    80001b72:	050ab503          	ld	a0,80(s5)
    80001b76:	887ff0ef          	jal	ra,800013fc <uvmcopy>
    80001b7a:	04054863          	bltz	a0,80001bca <fork+0x80>
  np->sz = p->sz;
    80001b7e:	048ab783          	ld	a5,72(s5)
    80001b82:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001b86:	058ab683          	ld	a3,88(s5)
    80001b8a:	87b6                	mv	a5,a3
    80001b8c:	058a3703          	ld	a4,88(s4)
    80001b90:	12068693          	addi	a3,a3,288
    80001b94:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001b98:	6788                	ld	a0,8(a5)
    80001b9a:	6b8c                	ld	a1,16(a5)
    80001b9c:	6f90                	ld	a2,24(a5)
    80001b9e:	01073023          	sd	a6,0(a4)
    80001ba2:	e708                	sd	a0,8(a4)
    80001ba4:	eb0c                	sd	a1,16(a4)
    80001ba6:	ef10                	sd	a2,24(a4)
    80001ba8:	02078793          	addi	a5,a5,32
    80001bac:	02070713          	addi	a4,a4,32
    80001bb0:	fed792e3          	bne	a5,a3,80001b94 <fork+0x4a>
  np->trapframe->a0 = 0;
    80001bb4:	058a3783          	ld	a5,88(s4)
    80001bb8:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001bbc:	0d0a8493          	addi	s1,s5,208
    80001bc0:	0d0a0913          	addi	s2,s4,208
    80001bc4:	150a8993          	addi	s3,s5,336
    80001bc8:	a829                	j	80001be2 <fork+0x98>
    freeproc(np);
    80001bca:	8552                	mv	a0,s4
    80001bcc:	dcbff0ef          	jal	ra,80001996 <freeproc>
    release(&np->lock);
    80001bd0:	8552                	mv	a0,s4
    80001bd2:	858ff0ef          	jal	ra,80000c2a <release>
    return -1;
    80001bd6:	597d                	li	s2,-1
    80001bd8:	a09d                	j	80001c3e <fork+0xf4>
  for(i = 0; i < NOFILE; i++)
    80001bda:	04a1                	addi	s1,s1,8
    80001bdc:	0921                	addi	s2,s2,8
    80001bde:	01348963          	beq	s1,s3,80001bf0 <fork+0xa6>
    if(p->ofile[i])
    80001be2:	6088                	ld	a0,0(s1)
    80001be4:	d97d                	beqz	a0,80001bda <fork+0x90>
      np->ofile[i] = filedup(p->ofile[i]);
    80001be6:	15e020ef          	jal	ra,80003d44 <filedup>
    80001bea:	00a93023          	sd	a0,0(s2)
    80001bee:	b7f5                	j	80001bda <fork+0x90>
  np->cwd = idup(p->cwd);
    80001bf0:	150ab503          	ld	a0,336(s5)
    80001bf4:	4b6010ef          	jal	ra,800030aa <idup>
    80001bf8:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001bfc:	4641                	li	a2,16
    80001bfe:	158a8593          	addi	a1,s5,344
    80001c02:	158a0513          	addi	a0,s4,344
    80001c06:	9a6ff0ef          	jal	ra,80000dac <safestrcpy>
  pid = np->pid;
    80001c0a:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001c0e:	8552                	mv	a0,s4
    80001c10:	81aff0ef          	jal	ra,80000c2a <release>
  acquire(&wait_lock);
    80001c14:	0000e497          	auipc	s1,0xe
    80001c18:	e3448493          	addi	s1,s1,-460 # 8000fa48 <wait_lock>
    80001c1c:	8526                	mv	a0,s1
    80001c1e:	f75fe0ef          	jal	ra,80000b92 <acquire>
  np->parent = p;
    80001c22:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001c26:	8526                	mv	a0,s1
    80001c28:	802ff0ef          	jal	ra,80000c2a <release>
  acquire(&np->lock);
    80001c2c:	8552                	mv	a0,s4
    80001c2e:	f65fe0ef          	jal	ra,80000b92 <acquire>
  np->state = RUNNABLE;
    80001c32:	478d                	li	a5,3
    80001c34:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001c38:	8552                	mv	a0,s4
    80001c3a:	ff1fe0ef          	jal	ra,80000c2a <release>
}
    80001c3e:	854a                	mv	a0,s2
    80001c40:	70e2                	ld	ra,56(sp)
    80001c42:	7442                	ld	s0,48(sp)
    80001c44:	74a2                	ld	s1,40(sp)
    80001c46:	7902                	ld	s2,32(sp)
    80001c48:	69e2                	ld	s3,24(sp)
    80001c4a:	6a42                	ld	s4,16(sp)
    80001c4c:	6aa2                	ld	s5,8(sp)
    80001c4e:	6121                	addi	sp,sp,64
    80001c50:	8082                	ret
    return -1;
    80001c52:	597d                	li	s2,-1
    80001c54:	b7ed                	j	80001c3e <fork+0xf4>

0000000080001c56 <scheduler>:
{
    80001c56:	715d                	addi	sp,sp,-80
    80001c58:	e486                	sd	ra,72(sp)
    80001c5a:	e0a2                	sd	s0,64(sp)
    80001c5c:	fc26                	sd	s1,56(sp)
    80001c5e:	f84a                	sd	s2,48(sp)
    80001c60:	f44e                	sd	s3,40(sp)
    80001c62:	f052                	sd	s4,32(sp)
    80001c64:	ec56                	sd	s5,24(sp)
    80001c66:	e85a                	sd	s6,16(sp)
    80001c68:	e45e                	sd	s7,8(sp)
    80001c6a:	e062                	sd	s8,0(sp)
    80001c6c:	0880                	addi	s0,sp,80
    80001c6e:	8792                	mv	a5,tp
  int id = r_tp();
    80001c70:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001c72:	00779b13          	slli	s6,a5,0x7
    80001c76:	0000e717          	auipc	a4,0xe
    80001c7a:	dba70713          	addi	a4,a4,-582 # 8000fa30 <pid_lock>
    80001c7e:	975a                	add	a4,a4,s6
    80001c80:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001c84:	0000e717          	auipc	a4,0xe
    80001c88:	de470713          	addi	a4,a4,-540 # 8000fa68 <cpus+0x8>
    80001c8c:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001c8e:	4c11                	li	s8,4
        c->proc = p;
    80001c90:	079e                	slli	a5,a5,0x7
    80001c92:	0000ea17          	auipc	s4,0xe
    80001c96:	d9ea0a13          	addi	s4,s4,-610 # 8000fa30 <pid_lock>
    80001c9a:	9a3e                	add	s4,s4,a5
        found = 1;
    80001c9c:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001c9e:	00014997          	auipc	s3,0x14
    80001ca2:	bc298993          	addi	s3,s3,-1086 # 80015860 <tickslock>
    80001ca6:	a83d                	j	80001ce4 <scheduler+0x8e>
      release(&p->lock);
    80001ca8:	8526                	mv	a0,s1
    80001caa:	f81fe0ef          	jal	ra,80000c2a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001cae:	16848493          	addi	s1,s1,360
    80001cb2:	03348563          	beq	s1,s3,80001cdc <scheduler+0x86>
      acquire(&p->lock);
    80001cb6:	8526                	mv	a0,s1
    80001cb8:	edbfe0ef          	jal	ra,80000b92 <acquire>
      if(p->state == RUNNABLE) {
    80001cbc:	4c9c                	lw	a5,24(s1)
    80001cbe:	ff2795e3          	bne	a5,s2,80001ca8 <scheduler+0x52>
        p->state = RUNNING;
    80001cc2:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001cc6:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001cca:	06048593          	addi	a1,s1,96
    80001cce:	855a                	mv	a0,s6
    80001cd0:	5b2000ef          	jal	ra,80002282 <swtch>
        c->proc = 0;
    80001cd4:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001cd8:	8ade                	mv	s5,s7
    80001cda:	b7f9                	j	80001ca8 <scheduler+0x52>
    if(found == 0) {
    80001cdc:	000a9463          	bnez	s5,80001ce4 <scheduler+0x8e>
      asm volatile("wfi");
    80001ce0:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ce4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ce8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001cec:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001cf0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001cf4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001cf6:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001cfa:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001cfc:	0000e497          	auipc	s1,0xe
    80001d00:	16448493          	addi	s1,s1,356 # 8000fe60 <proc>
      if(p->state == RUNNABLE) {
    80001d04:	490d                	li	s2,3
    80001d06:	bf45                	j	80001cb6 <scheduler+0x60>

0000000080001d08 <sched>:
{
    80001d08:	7179                	addi	sp,sp,-48
    80001d0a:	f406                	sd	ra,40(sp)
    80001d0c:	f022                	sd	s0,32(sp)
    80001d0e:	ec26                	sd	s1,24(sp)
    80001d10:	e84a                	sd	s2,16(sp)
    80001d12:	e44e                	sd	s3,8(sp)
    80001d14:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001d16:	b0fff0ef          	jal	ra,80001824 <myproc>
    80001d1a:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001d1c:	e0dfe0ef          	jal	ra,80000b28 <holding>
    80001d20:	c92d                	beqz	a0,80001d92 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d22:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001d24:	2781                	sext.w	a5,a5
    80001d26:	079e                	slli	a5,a5,0x7
    80001d28:	0000e717          	auipc	a4,0xe
    80001d2c:	d0870713          	addi	a4,a4,-760 # 8000fa30 <pid_lock>
    80001d30:	97ba                	add	a5,a5,a4
    80001d32:	0a87a703          	lw	a4,168(a5)
    80001d36:	4785                	li	a5,1
    80001d38:	06f71363          	bne	a4,a5,80001d9e <sched+0x96>
  if(p->state == RUNNING)
    80001d3c:	4c98                	lw	a4,24(s1)
    80001d3e:	4791                	li	a5,4
    80001d40:	06f70563          	beq	a4,a5,80001daa <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d44:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001d48:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001d4a:	e7b5                	bnez	a5,80001db6 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d4c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001d4e:	0000e917          	auipc	s2,0xe
    80001d52:	ce290913          	addi	s2,s2,-798 # 8000fa30 <pid_lock>
    80001d56:	2781                	sext.w	a5,a5
    80001d58:	079e                	slli	a5,a5,0x7
    80001d5a:	97ca                	add	a5,a5,s2
    80001d5c:	0ac7a983          	lw	s3,172(a5)
    80001d60:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001d62:	2781                	sext.w	a5,a5
    80001d64:	079e                	slli	a5,a5,0x7
    80001d66:	0000e597          	auipc	a1,0xe
    80001d6a:	d0258593          	addi	a1,a1,-766 # 8000fa68 <cpus+0x8>
    80001d6e:	95be                	add	a1,a1,a5
    80001d70:	06048513          	addi	a0,s1,96
    80001d74:	50e000ef          	jal	ra,80002282 <swtch>
    80001d78:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001d7a:	2781                	sext.w	a5,a5
    80001d7c:	079e                	slli	a5,a5,0x7
    80001d7e:	97ca                	add	a5,a5,s2
    80001d80:	0b37a623          	sw	s3,172(a5)
}
    80001d84:	70a2                	ld	ra,40(sp)
    80001d86:	7402                	ld	s0,32(sp)
    80001d88:	64e2                	ld	s1,24(sp)
    80001d8a:	6942                	ld	s2,16(sp)
    80001d8c:	69a2                	ld	s3,8(sp)
    80001d8e:	6145                	addi	sp,sp,48
    80001d90:	8082                	ret
    panic("sched p->lock");
    80001d92:	00005517          	auipc	a0,0x5
    80001d96:	4be50513          	addi	a0,a0,1214 # 80007250 <digits+0x218>
    80001d9a:	9bdfe0ef          	jal	ra,80000756 <panic>
    panic("sched locks");
    80001d9e:	00005517          	auipc	a0,0x5
    80001da2:	4c250513          	addi	a0,a0,1218 # 80007260 <digits+0x228>
    80001da6:	9b1fe0ef          	jal	ra,80000756 <panic>
    panic("sched RUNNING");
    80001daa:	00005517          	auipc	a0,0x5
    80001dae:	4c650513          	addi	a0,a0,1222 # 80007270 <digits+0x238>
    80001db2:	9a5fe0ef          	jal	ra,80000756 <panic>
    panic("sched interruptible");
    80001db6:	00005517          	auipc	a0,0x5
    80001dba:	4ca50513          	addi	a0,a0,1226 # 80007280 <digits+0x248>
    80001dbe:	999fe0ef          	jal	ra,80000756 <panic>

0000000080001dc2 <yield>:
{
    80001dc2:	1101                	addi	sp,sp,-32
    80001dc4:	ec06                	sd	ra,24(sp)
    80001dc6:	e822                	sd	s0,16(sp)
    80001dc8:	e426                	sd	s1,8(sp)
    80001dca:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001dcc:	a59ff0ef          	jal	ra,80001824 <myproc>
    80001dd0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001dd2:	dc1fe0ef          	jal	ra,80000b92 <acquire>
  p->state = RUNNABLE;
    80001dd6:	478d                	li	a5,3
    80001dd8:	cc9c                	sw	a5,24(s1)
  sched();
    80001dda:	f2fff0ef          	jal	ra,80001d08 <sched>
  release(&p->lock);
    80001dde:	8526                	mv	a0,s1
    80001de0:	e4bfe0ef          	jal	ra,80000c2a <release>
}
    80001de4:	60e2                	ld	ra,24(sp)
    80001de6:	6442                	ld	s0,16(sp)
    80001de8:	64a2                	ld	s1,8(sp)
    80001dea:	6105                	addi	sp,sp,32
    80001dec:	8082                	ret

0000000080001dee <sleep>:

// Sleep on wait channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001dee:	7179                	addi	sp,sp,-48
    80001df0:	f406                	sd	ra,40(sp)
    80001df2:	f022                	sd	s0,32(sp)
    80001df4:	ec26                	sd	s1,24(sp)
    80001df6:	e84a                	sd	s2,16(sp)
    80001df8:	e44e                	sd	s3,8(sp)
    80001dfa:	1800                	addi	s0,sp,48
    80001dfc:	89aa                	mv	s3,a0
    80001dfe:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001e00:	a25ff0ef          	jal	ra,80001824 <myproc>
    80001e04:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001e06:	d8dfe0ef          	jal	ra,80000b92 <acquire>
  release(lk);
    80001e0a:	854a                	mv	a0,s2
    80001e0c:	e1ffe0ef          	jal	ra,80000c2a <release>

  // Go to sleep.
  p->chan = chan;
    80001e10:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001e14:	4789                	li	a5,2
    80001e16:	cc9c                	sw	a5,24(s1)

  sched();
    80001e18:	ef1ff0ef          	jal	ra,80001d08 <sched>

  // Tidy up.
  p->chan = 0;
    80001e1c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001e20:	8526                	mv	a0,s1
    80001e22:	e09fe0ef          	jal	ra,80000c2a <release>
  acquire(lk);
    80001e26:	854a                	mv	a0,s2
    80001e28:	d6bfe0ef          	jal	ra,80000b92 <acquire>
}
    80001e2c:	70a2                	ld	ra,40(sp)
    80001e2e:	7402                	ld	s0,32(sp)
    80001e30:	64e2                	ld	s1,24(sp)
    80001e32:	6942                	ld	s2,16(sp)
    80001e34:	69a2                	ld	s3,8(sp)
    80001e36:	6145                	addi	sp,sp,48
    80001e38:	8082                	ret

0000000080001e3a <wakeup>:

// Wake up all processes sleeping on wait channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001e3a:	7139                	addi	sp,sp,-64
    80001e3c:	fc06                	sd	ra,56(sp)
    80001e3e:	f822                	sd	s0,48(sp)
    80001e40:	f426                	sd	s1,40(sp)
    80001e42:	f04a                	sd	s2,32(sp)
    80001e44:	ec4e                	sd	s3,24(sp)
    80001e46:	e852                	sd	s4,16(sp)
    80001e48:	e456                	sd	s5,8(sp)
    80001e4a:	0080                	addi	s0,sp,64
    80001e4c:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001e4e:	0000e497          	auipc	s1,0xe
    80001e52:	01248493          	addi	s1,s1,18 # 8000fe60 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001e56:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001e58:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e5a:	00014917          	auipc	s2,0x14
    80001e5e:	a0690913          	addi	s2,s2,-1530 # 80015860 <tickslock>
    80001e62:	a801                	j	80001e72 <wakeup+0x38>
      }
      release(&p->lock);
    80001e64:	8526                	mv	a0,s1
    80001e66:	dc5fe0ef          	jal	ra,80000c2a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e6a:	16848493          	addi	s1,s1,360
    80001e6e:	03248263          	beq	s1,s2,80001e92 <wakeup+0x58>
    if(p != myproc()){
    80001e72:	9b3ff0ef          	jal	ra,80001824 <myproc>
    80001e76:	fea48ae3          	beq	s1,a0,80001e6a <wakeup+0x30>
      acquire(&p->lock);
    80001e7a:	8526                	mv	a0,s1
    80001e7c:	d17fe0ef          	jal	ra,80000b92 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001e80:	4c9c                	lw	a5,24(s1)
    80001e82:	ff3791e3          	bne	a5,s3,80001e64 <wakeup+0x2a>
    80001e86:	709c                	ld	a5,32(s1)
    80001e88:	fd479ee3          	bne	a5,s4,80001e64 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001e8c:	0154ac23          	sw	s5,24(s1)
    80001e90:	bfd1                	j	80001e64 <wakeup+0x2a>
    }
  }
}
    80001e92:	70e2                	ld	ra,56(sp)
    80001e94:	7442                	ld	s0,48(sp)
    80001e96:	74a2                	ld	s1,40(sp)
    80001e98:	7902                	ld	s2,32(sp)
    80001e9a:	69e2                	ld	s3,24(sp)
    80001e9c:	6a42                	ld	s4,16(sp)
    80001e9e:	6aa2                	ld	s5,8(sp)
    80001ea0:	6121                	addi	sp,sp,64
    80001ea2:	8082                	ret

0000000080001ea4 <reparent>:
{
    80001ea4:	7179                	addi	sp,sp,-48
    80001ea6:	f406                	sd	ra,40(sp)
    80001ea8:	f022                	sd	s0,32(sp)
    80001eaa:	ec26                	sd	s1,24(sp)
    80001eac:	e84a                	sd	s2,16(sp)
    80001eae:	e44e                	sd	s3,8(sp)
    80001eb0:	e052                	sd	s4,0(sp)
    80001eb2:	1800                	addi	s0,sp,48
    80001eb4:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001eb6:	0000e497          	auipc	s1,0xe
    80001eba:	faa48493          	addi	s1,s1,-86 # 8000fe60 <proc>
      pp->parent = initproc;
    80001ebe:	00006a17          	auipc	s4,0x6
    80001ec2:	a3aa0a13          	addi	s4,s4,-1478 # 800078f8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ec6:	00014997          	auipc	s3,0x14
    80001eca:	99a98993          	addi	s3,s3,-1638 # 80015860 <tickslock>
    80001ece:	a029                	j	80001ed8 <reparent+0x34>
    80001ed0:	16848493          	addi	s1,s1,360
    80001ed4:	01348b63          	beq	s1,s3,80001eea <reparent+0x46>
    if(pp->parent == p){
    80001ed8:	7c9c                	ld	a5,56(s1)
    80001eda:	ff279be3          	bne	a5,s2,80001ed0 <reparent+0x2c>
      pp->parent = initproc;
    80001ede:	000a3503          	ld	a0,0(s4)
    80001ee2:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001ee4:	f57ff0ef          	jal	ra,80001e3a <wakeup>
    80001ee8:	b7e5                	j	80001ed0 <reparent+0x2c>
}
    80001eea:	70a2                	ld	ra,40(sp)
    80001eec:	7402                	ld	s0,32(sp)
    80001eee:	64e2                	ld	s1,24(sp)
    80001ef0:	6942                	ld	s2,16(sp)
    80001ef2:	69a2                	ld	s3,8(sp)
    80001ef4:	6a02                	ld	s4,0(sp)
    80001ef6:	6145                	addi	sp,sp,48
    80001ef8:	8082                	ret

0000000080001efa <exit>:
{
    80001efa:	7179                	addi	sp,sp,-48
    80001efc:	f406                	sd	ra,40(sp)
    80001efe:	f022                	sd	s0,32(sp)
    80001f00:	ec26                	sd	s1,24(sp)
    80001f02:	e84a                	sd	s2,16(sp)
    80001f04:	e44e                	sd	s3,8(sp)
    80001f06:	e052                	sd	s4,0(sp)
    80001f08:	1800                	addi	s0,sp,48
    80001f0a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001f0c:	919ff0ef          	jal	ra,80001824 <myproc>
    80001f10:	89aa                	mv	s3,a0
  if(p == initproc)
    80001f12:	00006797          	auipc	a5,0x6
    80001f16:	9e67b783          	ld	a5,-1562(a5) # 800078f8 <initproc>
    80001f1a:	0d050493          	addi	s1,a0,208
    80001f1e:	15050913          	addi	s2,a0,336
    80001f22:	00a79f63          	bne	a5,a0,80001f40 <exit+0x46>
    panic("init exiting");
    80001f26:	00005517          	auipc	a0,0x5
    80001f2a:	37250513          	addi	a0,a0,882 # 80007298 <digits+0x260>
    80001f2e:	829fe0ef          	jal	ra,80000756 <panic>
      fileclose(f);
    80001f32:	659010ef          	jal	ra,80003d8a <fileclose>
      p->ofile[fd] = 0;
    80001f36:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001f3a:	04a1                	addi	s1,s1,8
    80001f3c:	01248563          	beq	s1,s2,80001f46 <exit+0x4c>
    if(p->ofile[fd]){
    80001f40:	6088                	ld	a0,0(s1)
    80001f42:	f965                	bnez	a0,80001f32 <exit+0x38>
    80001f44:	bfdd                	j	80001f3a <exit+0x40>
  begin_op();
    80001f46:	229010ef          	jal	ra,8000396e <begin_op>
  iput(p->cwd);
    80001f4a:	1509b503          	ld	a0,336(s3)
    80001f4e:	310010ef          	jal	ra,8000325e <iput>
  end_op();
    80001f52:	28d010ef          	jal	ra,800039de <end_op>
  p->cwd = 0;
    80001f56:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80001f5a:	0000e497          	auipc	s1,0xe
    80001f5e:	aee48493          	addi	s1,s1,-1298 # 8000fa48 <wait_lock>
    80001f62:	8526                	mv	a0,s1
    80001f64:	c2ffe0ef          	jal	ra,80000b92 <acquire>
  reparent(p);
    80001f68:	854e                	mv	a0,s3
    80001f6a:	f3bff0ef          	jal	ra,80001ea4 <reparent>
  wakeup(p->parent);
    80001f6e:	0389b503          	ld	a0,56(s3)
    80001f72:	ec9ff0ef          	jal	ra,80001e3a <wakeup>
  acquire(&p->lock);
    80001f76:	854e                	mv	a0,s3
    80001f78:	c1bfe0ef          	jal	ra,80000b92 <acquire>
  p->xstate = status;
    80001f7c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80001f80:	4795                	li	a5,5
    80001f82:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80001f86:	8526                	mv	a0,s1
    80001f88:	ca3fe0ef          	jal	ra,80000c2a <release>
  sched();
    80001f8c:	d7dff0ef          	jal	ra,80001d08 <sched>
  panic("zombie exit");
    80001f90:	00005517          	auipc	a0,0x5
    80001f94:	31850513          	addi	a0,a0,792 # 800072a8 <digits+0x270>
    80001f98:	fbefe0ef          	jal	ra,80000756 <panic>

0000000080001f9c <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80001f9c:	7179                	addi	sp,sp,-48
    80001f9e:	f406                	sd	ra,40(sp)
    80001fa0:	f022                	sd	s0,32(sp)
    80001fa2:	ec26                	sd	s1,24(sp)
    80001fa4:	e84a                	sd	s2,16(sp)
    80001fa6:	e44e                	sd	s3,8(sp)
    80001fa8:	1800                	addi	s0,sp,48
    80001faa:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80001fac:	0000e497          	auipc	s1,0xe
    80001fb0:	eb448493          	addi	s1,s1,-332 # 8000fe60 <proc>
    80001fb4:	00014997          	auipc	s3,0x14
    80001fb8:	8ac98993          	addi	s3,s3,-1876 # 80015860 <tickslock>
    acquire(&p->lock);
    80001fbc:	8526                	mv	a0,s1
    80001fbe:	bd5fe0ef          	jal	ra,80000b92 <acquire>
    if(p->pid == pid){
    80001fc2:	589c                	lw	a5,48(s1)
    80001fc4:	01278b63          	beq	a5,s2,80001fda <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80001fc8:	8526                	mv	a0,s1
    80001fca:	c61fe0ef          	jal	ra,80000c2a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80001fce:	16848493          	addi	s1,s1,360
    80001fd2:	ff3495e3          	bne	s1,s3,80001fbc <kill+0x20>
  }
  return -1;
    80001fd6:	557d                	li	a0,-1
    80001fd8:	a819                	j	80001fee <kill+0x52>
      p->killed = 1;
    80001fda:	4785                	li	a5,1
    80001fdc:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80001fde:	4c98                	lw	a4,24(s1)
    80001fe0:	4789                	li	a5,2
    80001fe2:	00f70d63          	beq	a4,a5,80001ffc <kill+0x60>
      release(&p->lock);
    80001fe6:	8526                	mv	a0,s1
    80001fe8:	c43fe0ef          	jal	ra,80000c2a <release>
      return 0;
    80001fec:	4501                	li	a0,0
}
    80001fee:	70a2                	ld	ra,40(sp)
    80001ff0:	7402                	ld	s0,32(sp)
    80001ff2:	64e2                	ld	s1,24(sp)
    80001ff4:	6942                	ld	s2,16(sp)
    80001ff6:	69a2                	ld	s3,8(sp)
    80001ff8:	6145                	addi	sp,sp,48
    80001ffa:	8082                	ret
        p->state = RUNNABLE;
    80001ffc:	478d                	li	a5,3
    80001ffe:	cc9c                	sw	a5,24(s1)
    80002000:	b7dd                	j	80001fe6 <kill+0x4a>

0000000080002002 <setkilled>:

void
setkilled(struct proc *p)
{
    80002002:	1101                	addi	sp,sp,-32
    80002004:	ec06                	sd	ra,24(sp)
    80002006:	e822                	sd	s0,16(sp)
    80002008:	e426                	sd	s1,8(sp)
    8000200a:	1000                	addi	s0,sp,32
    8000200c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000200e:	b85fe0ef          	jal	ra,80000b92 <acquire>
  p->killed = 1;
    80002012:	4785                	li	a5,1
    80002014:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002016:	8526                	mv	a0,s1
    80002018:	c13fe0ef          	jal	ra,80000c2a <release>
}
    8000201c:	60e2                	ld	ra,24(sp)
    8000201e:	6442                	ld	s0,16(sp)
    80002020:	64a2                	ld	s1,8(sp)
    80002022:	6105                	addi	sp,sp,32
    80002024:	8082                	ret

0000000080002026 <killed>:

int
killed(struct proc *p)
{
    80002026:	1101                	addi	sp,sp,-32
    80002028:	ec06                	sd	ra,24(sp)
    8000202a:	e822                	sd	s0,16(sp)
    8000202c:	e426                	sd	s1,8(sp)
    8000202e:	e04a                	sd	s2,0(sp)
    80002030:	1000                	addi	s0,sp,32
    80002032:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002034:	b5ffe0ef          	jal	ra,80000b92 <acquire>
  k = p->killed;
    80002038:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000203c:	8526                	mv	a0,s1
    8000203e:	bedfe0ef          	jal	ra,80000c2a <release>
  return k;
}
    80002042:	854a                	mv	a0,s2
    80002044:	60e2                	ld	ra,24(sp)
    80002046:	6442                	ld	s0,16(sp)
    80002048:	64a2                	ld	s1,8(sp)
    8000204a:	6902                	ld	s2,0(sp)
    8000204c:	6105                	addi	sp,sp,32
    8000204e:	8082                	ret

0000000080002050 <wait>:
{
    80002050:	715d                	addi	sp,sp,-80
    80002052:	e486                	sd	ra,72(sp)
    80002054:	e0a2                	sd	s0,64(sp)
    80002056:	fc26                	sd	s1,56(sp)
    80002058:	f84a                	sd	s2,48(sp)
    8000205a:	f44e                	sd	s3,40(sp)
    8000205c:	f052                	sd	s4,32(sp)
    8000205e:	ec56                	sd	s5,24(sp)
    80002060:	e85a                	sd	s6,16(sp)
    80002062:	e45e                	sd	s7,8(sp)
    80002064:	e062                	sd	s8,0(sp)
    80002066:	0880                	addi	s0,sp,80
    80002068:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000206a:	fbaff0ef          	jal	ra,80001824 <myproc>
    8000206e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002070:	0000e517          	auipc	a0,0xe
    80002074:	9d850513          	addi	a0,a0,-1576 # 8000fa48 <wait_lock>
    80002078:	b1bfe0ef          	jal	ra,80000b92 <acquire>
    havekids = 0;
    8000207c:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000207e:	4a15                	li	s4,5
        havekids = 1;
    80002080:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002082:	00013997          	auipc	s3,0x13
    80002086:	7de98993          	addi	s3,s3,2014 # 80015860 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000208a:	0000ec17          	auipc	s8,0xe
    8000208e:	9bec0c13          	addi	s8,s8,-1602 # 8000fa48 <wait_lock>
    havekids = 0;
    80002092:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002094:	0000e497          	auipc	s1,0xe
    80002098:	dcc48493          	addi	s1,s1,-564 # 8000fe60 <proc>
    8000209c:	a899                	j	800020f2 <wait+0xa2>
          pid = pp->pid;
    8000209e:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800020a2:	000b0c63          	beqz	s6,800020ba <wait+0x6a>
    800020a6:	4691                	li	a3,4
    800020a8:	02c48613          	addi	a2,s1,44
    800020ac:	85da                	mv	a1,s6
    800020ae:	05093503          	ld	a0,80(s2)
    800020b2:	c26ff0ef          	jal	ra,800014d8 <copyout>
    800020b6:	00054f63          	bltz	a0,800020d4 <wait+0x84>
          freeproc(pp);
    800020ba:	8526                	mv	a0,s1
    800020bc:	8dbff0ef          	jal	ra,80001996 <freeproc>
          release(&pp->lock);
    800020c0:	8526                	mv	a0,s1
    800020c2:	b69fe0ef          	jal	ra,80000c2a <release>
          release(&wait_lock);
    800020c6:	0000e517          	auipc	a0,0xe
    800020ca:	98250513          	addi	a0,a0,-1662 # 8000fa48 <wait_lock>
    800020ce:	b5dfe0ef          	jal	ra,80000c2a <release>
          return pid;
    800020d2:	a891                	j	80002126 <wait+0xd6>
            release(&pp->lock);
    800020d4:	8526                	mv	a0,s1
    800020d6:	b55fe0ef          	jal	ra,80000c2a <release>
            release(&wait_lock);
    800020da:	0000e517          	auipc	a0,0xe
    800020de:	96e50513          	addi	a0,a0,-1682 # 8000fa48 <wait_lock>
    800020e2:	b49fe0ef          	jal	ra,80000c2a <release>
            return -1;
    800020e6:	59fd                	li	s3,-1
    800020e8:	a83d                	j	80002126 <wait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800020ea:	16848493          	addi	s1,s1,360
    800020ee:	03348063          	beq	s1,s3,8000210e <wait+0xbe>
      if(pp->parent == p){
    800020f2:	7c9c                	ld	a5,56(s1)
    800020f4:	ff279be3          	bne	a5,s2,800020ea <wait+0x9a>
        acquire(&pp->lock);
    800020f8:	8526                	mv	a0,s1
    800020fa:	a99fe0ef          	jal	ra,80000b92 <acquire>
        if(pp->state == ZOMBIE){
    800020fe:	4c9c                	lw	a5,24(s1)
    80002100:	f9478fe3          	beq	a5,s4,8000209e <wait+0x4e>
        release(&pp->lock);
    80002104:	8526                	mv	a0,s1
    80002106:	b25fe0ef          	jal	ra,80000c2a <release>
        havekids = 1;
    8000210a:	8756                	mv	a4,s5
    8000210c:	bff9                	j	800020ea <wait+0x9a>
    if(!havekids || killed(p)){
    8000210e:	c709                	beqz	a4,80002118 <wait+0xc8>
    80002110:	854a                	mv	a0,s2
    80002112:	f15ff0ef          	jal	ra,80002026 <killed>
    80002116:	c50d                	beqz	a0,80002140 <wait+0xf0>
      release(&wait_lock);
    80002118:	0000e517          	auipc	a0,0xe
    8000211c:	93050513          	addi	a0,a0,-1744 # 8000fa48 <wait_lock>
    80002120:	b0bfe0ef          	jal	ra,80000c2a <release>
      return -1;
    80002124:	59fd                	li	s3,-1
}
    80002126:	854e                	mv	a0,s3
    80002128:	60a6                	ld	ra,72(sp)
    8000212a:	6406                	ld	s0,64(sp)
    8000212c:	74e2                	ld	s1,56(sp)
    8000212e:	7942                	ld	s2,48(sp)
    80002130:	79a2                	ld	s3,40(sp)
    80002132:	7a02                	ld	s4,32(sp)
    80002134:	6ae2                	ld	s5,24(sp)
    80002136:	6b42                	ld	s6,16(sp)
    80002138:	6ba2                	ld	s7,8(sp)
    8000213a:	6c02                	ld	s8,0(sp)
    8000213c:	6161                	addi	sp,sp,80
    8000213e:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002140:	85e2                	mv	a1,s8
    80002142:	854a                	mv	a0,s2
    80002144:	cabff0ef          	jal	ra,80001dee <sleep>
    havekids = 0;
    80002148:	b7a9                	j	80002092 <wait+0x42>

000000008000214a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000214a:	7179                	addi	sp,sp,-48
    8000214c:	f406                	sd	ra,40(sp)
    8000214e:	f022                	sd	s0,32(sp)
    80002150:	ec26                	sd	s1,24(sp)
    80002152:	e84a                	sd	s2,16(sp)
    80002154:	e44e                	sd	s3,8(sp)
    80002156:	e052                	sd	s4,0(sp)
    80002158:	1800                	addi	s0,sp,48
    8000215a:	84aa                	mv	s1,a0
    8000215c:	892e                	mv	s2,a1
    8000215e:	89b2                	mv	s3,a2
    80002160:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002162:	ec2ff0ef          	jal	ra,80001824 <myproc>
  if(user_dst){
    80002166:	cc99                	beqz	s1,80002184 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002168:	86d2                	mv	a3,s4
    8000216a:	864e                	mv	a2,s3
    8000216c:	85ca                	mv	a1,s2
    8000216e:	6928                	ld	a0,80(a0)
    80002170:	b68ff0ef          	jal	ra,800014d8 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002174:	70a2                	ld	ra,40(sp)
    80002176:	7402                	ld	s0,32(sp)
    80002178:	64e2                	ld	s1,24(sp)
    8000217a:	6942                	ld	s2,16(sp)
    8000217c:	69a2                	ld	s3,8(sp)
    8000217e:	6a02                	ld	s4,0(sp)
    80002180:	6145                	addi	sp,sp,48
    80002182:	8082                	ret
    memmove((char *)dst, src, len);
    80002184:	000a061b          	sext.w	a2,s4
    80002188:	85ce                	mv	a1,s3
    8000218a:	854a                	mv	a0,s2
    8000218c:	b37fe0ef          	jal	ra,80000cc2 <memmove>
    return 0;
    80002190:	8526                	mv	a0,s1
    80002192:	b7cd                	j	80002174 <either_copyout+0x2a>

0000000080002194 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002194:	7179                	addi	sp,sp,-48
    80002196:	f406                	sd	ra,40(sp)
    80002198:	f022                	sd	s0,32(sp)
    8000219a:	ec26                	sd	s1,24(sp)
    8000219c:	e84a                	sd	s2,16(sp)
    8000219e:	e44e                	sd	s3,8(sp)
    800021a0:	e052                	sd	s4,0(sp)
    800021a2:	1800                	addi	s0,sp,48
    800021a4:	892a                	mv	s2,a0
    800021a6:	84ae                	mv	s1,a1
    800021a8:	89b2                	mv	s3,a2
    800021aa:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800021ac:	e78ff0ef          	jal	ra,80001824 <myproc>
  if(user_src){
    800021b0:	cc99                	beqz	s1,800021ce <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800021b2:	86d2                	mv	a3,s4
    800021b4:	864e                	mv	a2,s3
    800021b6:	85ca                	mv	a1,s2
    800021b8:	6928                	ld	a0,80(a0)
    800021ba:	bd6ff0ef          	jal	ra,80001590 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800021be:	70a2                	ld	ra,40(sp)
    800021c0:	7402                	ld	s0,32(sp)
    800021c2:	64e2                	ld	s1,24(sp)
    800021c4:	6942                	ld	s2,16(sp)
    800021c6:	69a2                	ld	s3,8(sp)
    800021c8:	6a02                	ld	s4,0(sp)
    800021ca:	6145                	addi	sp,sp,48
    800021cc:	8082                	ret
    memmove(dst, (char*)src, len);
    800021ce:	000a061b          	sext.w	a2,s4
    800021d2:	85ce                	mv	a1,s3
    800021d4:	854a                	mv	a0,s2
    800021d6:	aedfe0ef          	jal	ra,80000cc2 <memmove>
    return 0;
    800021da:	8526                	mv	a0,s1
    800021dc:	b7cd                	j	800021be <either_copyin+0x2a>

00000000800021de <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800021de:	715d                	addi	sp,sp,-80
    800021e0:	e486                	sd	ra,72(sp)
    800021e2:	e0a2                	sd	s0,64(sp)
    800021e4:	fc26                	sd	s1,56(sp)
    800021e6:	f84a                	sd	s2,48(sp)
    800021e8:	f44e                	sd	s3,40(sp)
    800021ea:	f052                	sd	s4,32(sp)
    800021ec:	ec56                	sd	s5,24(sp)
    800021ee:	e85a                	sd	s6,16(sp)
    800021f0:	e45e                	sd	s7,8(sp)
    800021f2:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800021f4:	00005517          	auipc	a0,0x5
    800021f8:	ecc50513          	addi	a0,a0,-308 # 800070c0 <digits+0x88>
    800021fc:	aa6fe0ef          	jal	ra,800004a2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002200:	0000e497          	auipc	s1,0xe
    80002204:	db848493          	addi	s1,s1,-584 # 8000ffb8 <proc+0x158>
    80002208:	00013917          	auipc	s2,0x13
    8000220c:	7b090913          	addi	s2,s2,1968 # 800159b8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002210:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002212:	00005997          	auipc	s3,0x5
    80002216:	0a698993          	addi	s3,s3,166 # 800072b8 <digits+0x280>
    printf("%d %s %s", p->pid, state, p->name);
    8000221a:	00005a97          	auipc	s5,0x5
    8000221e:	0a6a8a93          	addi	s5,s5,166 # 800072c0 <digits+0x288>
    printf("\n");
    80002222:	00005a17          	auipc	s4,0x5
    80002226:	e9ea0a13          	addi	s4,s4,-354 # 800070c0 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000222a:	00005b97          	auipc	s7,0x5
    8000222e:	0d6b8b93          	addi	s7,s7,214 # 80007300 <states.0>
    80002232:	a829                	j	8000224c <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002234:	ed86a583          	lw	a1,-296(a3)
    80002238:	8556                	mv	a0,s5
    8000223a:	a68fe0ef          	jal	ra,800004a2 <printf>
    printf("\n");
    8000223e:	8552                	mv	a0,s4
    80002240:	a62fe0ef          	jal	ra,800004a2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002244:	16848493          	addi	s1,s1,360
    80002248:	03248263          	beq	s1,s2,8000226c <procdump+0x8e>
    if(p->state == UNUSED)
    8000224c:	86a6                	mv	a3,s1
    8000224e:	ec04a783          	lw	a5,-320(s1)
    80002252:	dbed                	beqz	a5,80002244 <procdump+0x66>
      state = "???";
    80002254:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002256:	fcfb6fe3          	bltu	s6,a5,80002234 <procdump+0x56>
    8000225a:	02079713          	slli	a4,a5,0x20
    8000225e:	01d75793          	srli	a5,a4,0x1d
    80002262:	97de                	add	a5,a5,s7
    80002264:	6390                	ld	a2,0(a5)
    80002266:	f679                	bnez	a2,80002234 <procdump+0x56>
      state = "???";
    80002268:	864e                	mv	a2,s3
    8000226a:	b7e9                	j	80002234 <procdump+0x56>
  }
}
    8000226c:	60a6                	ld	ra,72(sp)
    8000226e:	6406                	ld	s0,64(sp)
    80002270:	74e2                	ld	s1,56(sp)
    80002272:	7942                	ld	s2,48(sp)
    80002274:	79a2                	ld	s3,40(sp)
    80002276:	7a02                	ld	s4,32(sp)
    80002278:	6ae2                	ld	s5,24(sp)
    8000227a:	6b42                	ld	s6,16(sp)
    8000227c:	6ba2                	ld	s7,8(sp)
    8000227e:	6161                	addi	sp,sp,80
    80002280:	8082                	ret

0000000080002282 <swtch>:
    80002282:	00153023          	sd	ra,0(a0)
    80002286:	00253423          	sd	sp,8(a0)
    8000228a:	e900                	sd	s0,16(a0)
    8000228c:	ed04                	sd	s1,24(a0)
    8000228e:	03253023          	sd	s2,32(a0)
    80002292:	03353423          	sd	s3,40(a0)
    80002296:	03453823          	sd	s4,48(a0)
    8000229a:	03553c23          	sd	s5,56(a0)
    8000229e:	05653023          	sd	s6,64(a0)
    800022a2:	05753423          	sd	s7,72(a0)
    800022a6:	05853823          	sd	s8,80(a0)
    800022aa:	05953c23          	sd	s9,88(a0)
    800022ae:	07a53023          	sd	s10,96(a0)
    800022b2:	07b53423          	sd	s11,104(a0)
    800022b6:	0005b083          	ld	ra,0(a1)
    800022ba:	0085b103          	ld	sp,8(a1)
    800022be:	6980                	ld	s0,16(a1)
    800022c0:	6d84                	ld	s1,24(a1)
    800022c2:	0205b903          	ld	s2,32(a1)
    800022c6:	0285b983          	ld	s3,40(a1)
    800022ca:	0305ba03          	ld	s4,48(a1)
    800022ce:	0385ba83          	ld	s5,56(a1)
    800022d2:	0405bb03          	ld	s6,64(a1)
    800022d6:	0485bb83          	ld	s7,72(a1)
    800022da:	0505bc03          	ld	s8,80(a1)
    800022de:	0585bc83          	ld	s9,88(a1)
    800022e2:	0605bd03          	ld	s10,96(a1)
    800022e6:	0685bd83          	ld	s11,104(a1)
    800022ea:	8082                	ret

00000000800022ec <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800022ec:	1141                	addi	sp,sp,-16
    800022ee:	e406                	sd	ra,8(sp)
    800022f0:	e022                	sd	s0,0(sp)
    800022f2:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800022f4:	00005597          	auipc	a1,0x5
    800022f8:	03c58593          	addi	a1,a1,60 # 80007330 <states.0+0x30>
    800022fc:	00013517          	auipc	a0,0x13
    80002300:	56450513          	addi	a0,a0,1380 # 80015860 <tickslock>
    80002304:	80ffe0ef          	jal	ra,80000b12 <initlock>
}
    80002308:	60a2                	ld	ra,8(sp)
    8000230a:	6402                	ld	s0,0(sp)
    8000230c:	0141                	addi	sp,sp,16
    8000230e:	8082                	ret

0000000080002310 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002310:	1141                	addi	sp,sp,-16
    80002312:	e422                	sd	s0,8(sp)
    80002314:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002316:	00003797          	auipc	a5,0x3
    8000231a:	d2a78793          	addi	a5,a5,-726 # 80005040 <kernelvec>
    8000231e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002322:	6422                	ld	s0,8(sp)
    80002324:	0141                	addi	sp,sp,16
    80002326:	8082                	ret

0000000080002328 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002328:	1141                	addi	sp,sp,-16
    8000232a:	e406                	sd	ra,8(sp)
    8000232c:	e022                	sd	s0,0(sp)
    8000232e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002330:	cf4ff0ef          	jal	ra,80001824 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002334:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002338:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000233a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000233e:	00004617          	auipc	a2,0x4
    80002342:	cc260613          	addi	a2,a2,-830 # 80006000 <_trampoline>
    80002346:	00004697          	auipc	a3,0x4
    8000234a:	cba68693          	addi	a3,a3,-838 # 80006000 <_trampoline>
    8000234e:	8e91                	sub	a3,a3,a2
    80002350:	040007b7          	lui	a5,0x4000
    80002354:	17fd                	addi	a5,a5,-1
    80002356:	07b2                	slli	a5,a5,0xc
    80002358:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000235a:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000235e:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002360:	180026f3          	csrr	a3,satp
    80002364:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002366:	6d38                	ld	a4,88(a0)
    80002368:	6134                	ld	a3,64(a0)
    8000236a:	6585                	lui	a1,0x1
    8000236c:	96ae                	add	a3,a3,a1
    8000236e:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002370:	6d38                	ld	a4,88(a0)
    80002372:	00000697          	auipc	a3,0x0
    80002376:	10c68693          	addi	a3,a3,268 # 8000247e <usertrap>
    8000237a:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000237c:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000237e:	8692                	mv	a3,tp
    80002380:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002382:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002386:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000238a:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000238e:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002392:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002394:	6f18                	ld	a4,24(a4)
    80002396:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000239a:	6928                	ld	a0,80(a0)
    8000239c:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000239e:	00004717          	auipc	a4,0x4
    800023a2:	cfe70713          	addi	a4,a4,-770 # 8000609c <userret>
    800023a6:	8f11                	sub	a4,a4,a2
    800023a8:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800023aa:	577d                	li	a4,-1
    800023ac:	177e                	slli	a4,a4,0x3f
    800023ae:	8d59                	or	a0,a0,a4
    800023b0:	9782                	jalr	a5
}
    800023b2:	60a2                	ld	ra,8(sp)
    800023b4:	6402                	ld	s0,0(sp)
    800023b6:	0141                	addi	sp,sp,16
    800023b8:	8082                	ret

00000000800023ba <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800023ba:	1101                	addi	sp,sp,-32
    800023bc:	ec06                	sd	ra,24(sp)
    800023be:	e822                	sd	s0,16(sp)
    800023c0:	e426                	sd	s1,8(sp)
    800023c2:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800023c4:	c34ff0ef          	jal	ra,800017f8 <cpuid>
    800023c8:	cd19                	beqz	a0,800023e6 <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    800023ca:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800023ce:	000f4737          	lui	a4,0xf4
    800023d2:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800023d6:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800023d8:	14d79073          	csrw	0x14d,a5
}
    800023dc:	60e2                	ld	ra,24(sp)
    800023de:	6442                	ld	s0,16(sp)
    800023e0:	64a2                	ld	s1,8(sp)
    800023e2:	6105                	addi	sp,sp,32
    800023e4:	8082                	ret
    acquire(&tickslock);
    800023e6:	00013497          	auipc	s1,0x13
    800023ea:	47a48493          	addi	s1,s1,1146 # 80015860 <tickslock>
    800023ee:	8526                	mv	a0,s1
    800023f0:	fa2fe0ef          	jal	ra,80000b92 <acquire>
    ticks++;
    800023f4:	00005517          	auipc	a0,0x5
    800023f8:	50c50513          	addi	a0,a0,1292 # 80007900 <ticks>
    800023fc:	411c                	lw	a5,0(a0)
    800023fe:	2785                	addiw	a5,a5,1
    80002400:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002402:	a39ff0ef          	jal	ra,80001e3a <wakeup>
    release(&tickslock);
    80002406:	8526                	mv	a0,s1
    80002408:	823fe0ef          	jal	ra,80000c2a <release>
    8000240c:	bf7d                	j	800023ca <clockintr+0x10>

000000008000240e <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000240e:	1101                	addi	sp,sp,-32
    80002410:	ec06                	sd	ra,24(sp)
    80002412:	e822                	sd	s0,16(sp)
    80002414:	e426                	sd	s1,8(sp)
    80002416:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002418:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    8000241c:	57fd                	li	a5,-1
    8000241e:	17fe                	slli	a5,a5,0x3f
    80002420:	07a5                	addi	a5,a5,9
    80002422:	00f70d63          	beq	a4,a5,8000243c <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002426:	57fd                	li	a5,-1
    80002428:	17fe                	slli	a5,a5,0x3f
    8000242a:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    8000242c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    8000242e:	04f70463          	beq	a4,a5,80002476 <devintr+0x68>
  }
}
    80002432:	60e2                	ld	ra,24(sp)
    80002434:	6442                	ld	s0,16(sp)
    80002436:	64a2                	ld	s1,8(sp)
    80002438:	6105                	addi	sp,sp,32
    8000243a:	8082                	ret
    int irq = plic_claim();
    8000243c:	4ad020ef          	jal	ra,800050e8 <plic_claim>
    80002440:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002442:	47a9                	li	a5,10
    80002444:	02f50363          	beq	a0,a5,8000246a <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80002448:	4785                	li	a5,1
    8000244a:	02f50363          	beq	a0,a5,80002470 <devintr+0x62>
    return 1;
    8000244e:	4505                	li	a0,1
    } else if(irq){
    80002450:	d0ed                	beqz	s1,80002432 <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80002452:	85a6                	mv	a1,s1
    80002454:	00005517          	auipc	a0,0x5
    80002458:	ee450513          	addi	a0,a0,-284 # 80007338 <states.0+0x38>
    8000245c:	846fe0ef          	jal	ra,800004a2 <printf>
      plic_complete(irq);
    80002460:	8526                	mv	a0,s1
    80002462:	4a7020ef          	jal	ra,80005108 <plic_complete>
    return 1;
    80002466:	4505                	li	a0,1
    80002468:	b7e9                	j	80002432 <devintr+0x24>
      uartintr();
    8000246a:	d34fe0ef          	jal	ra,8000099e <uartintr>
    8000246e:	bfcd                	j	80002460 <devintr+0x52>
      virtio_disk_intr();
    80002470:	108030ef          	jal	ra,80005578 <virtio_disk_intr>
    80002474:	b7f5                	j	80002460 <devintr+0x52>
    clockintr();
    80002476:	f45ff0ef          	jal	ra,800023ba <clockintr>
    return 2;
    8000247a:	4509                	li	a0,2
    8000247c:	bf5d                	j	80002432 <devintr+0x24>

000000008000247e <usertrap>:
{
    8000247e:	1101                	addi	sp,sp,-32
    80002480:	ec06                	sd	ra,24(sp)
    80002482:	e822                	sd	s0,16(sp)
    80002484:	e426                	sd	s1,8(sp)
    80002486:	e04a                	sd	s2,0(sp)
    80002488:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000248a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000248e:	1007f793          	andi	a5,a5,256
    80002492:	ef85                	bnez	a5,800024ca <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002494:	00003797          	auipc	a5,0x3
    80002498:	bac78793          	addi	a5,a5,-1108 # 80005040 <kernelvec>
    8000249c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800024a0:	b84ff0ef          	jal	ra,80001824 <myproc>
    800024a4:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800024a6:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800024a8:	14102773          	csrr	a4,sepc
    800024ac:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800024ae:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800024b2:	47a1                	li	a5,8
    800024b4:	02f70163          	beq	a4,a5,800024d6 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    800024b8:	f57ff0ef          	jal	ra,8000240e <devintr>
    800024bc:	892a                	mv	s2,a0
    800024be:	c135                	beqz	a0,80002522 <usertrap+0xa4>
  if(killed(p))
    800024c0:	8526                	mv	a0,s1
    800024c2:	b65ff0ef          	jal	ra,80002026 <killed>
    800024c6:	cd1d                	beqz	a0,80002504 <usertrap+0x86>
    800024c8:	a81d                	j	800024fe <usertrap+0x80>
    panic("usertrap: not from user mode");
    800024ca:	00005517          	auipc	a0,0x5
    800024ce:	e8e50513          	addi	a0,a0,-370 # 80007358 <states.0+0x58>
    800024d2:	a84fe0ef          	jal	ra,80000756 <panic>
    if(killed(p))
    800024d6:	b51ff0ef          	jal	ra,80002026 <killed>
    800024da:	e121                	bnez	a0,8000251a <usertrap+0x9c>
    p->trapframe->epc += 4;
    800024dc:	6cb8                	ld	a4,88(s1)
    800024de:	6f1c                	ld	a5,24(a4)
    800024e0:	0791                	addi	a5,a5,4
    800024e2:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024e4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800024e8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024ec:	10079073          	csrw	sstatus,a5
    syscall();
    800024f0:	248000ef          	jal	ra,80002738 <syscall>
  if(killed(p))
    800024f4:	8526                	mv	a0,s1
    800024f6:	b31ff0ef          	jal	ra,80002026 <killed>
    800024fa:	c901                	beqz	a0,8000250a <usertrap+0x8c>
    800024fc:	4901                	li	s2,0
    exit(-1);
    800024fe:	557d                	li	a0,-1
    80002500:	9fbff0ef          	jal	ra,80001efa <exit>
  if(which_dev == 2)
    80002504:	4789                	li	a5,2
    80002506:	04f90563          	beq	s2,a5,80002550 <usertrap+0xd2>
  usertrapret();
    8000250a:	e1fff0ef          	jal	ra,80002328 <usertrapret>
}
    8000250e:	60e2                	ld	ra,24(sp)
    80002510:	6442                	ld	s0,16(sp)
    80002512:	64a2                	ld	s1,8(sp)
    80002514:	6902                	ld	s2,0(sp)
    80002516:	6105                	addi	sp,sp,32
    80002518:	8082                	ret
      exit(-1);
    8000251a:	557d                	li	a0,-1
    8000251c:	9dfff0ef          	jal	ra,80001efa <exit>
    80002520:	bf75                	j	800024dc <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002522:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002526:	5890                	lw	a2,48(s1)
    80002528:	00005517          	auipc	a0,0x5
    8000252c:	e5050513          	addi	a0,a0,-432 # 80007378 <states.0+0x78>
    80002530:	f73fd0ef          	jal	ra,800004a2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002534:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002538:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000253c:	00005517          	auipc	a0,0x5
    80002540:	e6c50513          	addi	a0,a0,-404 # 800073a8 <states.0+0xa8>
    80002544:	f5ffd0ef          	jal	ra,800004a2 <printf>
    setkilled(p);
    80002548:	8526                	mv	a0,s1
    8000254a:	ab9ff0ef          	jal	ra,80002002 <setkilled>
    8000254e:	b75d                	j	800024f4 <usertrap+0x76>
    yield();
    80002550:	873ff0ef          	jal	ra,80001dc2 <yield>
    80002554:	bf5d                	j	8000250a <usertrap+0x8c>

0000000080002556 <kerneltrap>:
{
    80002556:	7179                	addi	sp,sp,-48
    80002558:	f406                	sd	ra,40(sp)
    8000255a:	f022                	sd	s0,32(sp)
    8000255c:	ec26                	sd	s1,24(sp)
    8000255e:	e84a                	sd	s2,16(sp)
    80002560:	e44e                	sd	s3,8(sp)
    80002562:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002564:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002568:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000256c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002570:	1004f793          	andi	a5,s1,256
    80002574:	c795                	beqz	a5,800025a0 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002576:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000257a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000257c:	eb85                	bnez	a5,800025ac <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    8000257e:	e91ff0ef          	jal	ra,8000240e <devintr>
    80002582:	c91d                	beqz	a0,800025b8 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002584:	4789                	li	a5,2
    80002586:	04f50a63          	beq	a0,a5,800025da <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000258a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000258e:	10049073          	csrw	sstatus,s1
}
    80002592:	70a2                	ld	ra,40(sp)
    80002594:	7402                	ld	s0,32(sp)
    80002596:	64e2                	ld	s1,24(sp)
    80002598:	6942                	ld	s2,16(sp)
    8000259a:	69a2                	ld	s3,8(sp)
    8000259c:	6145                	addi	sp,sp,48
    8000259e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800025a0:	00005517          	auipc	a0,0x5
    800025a4:	e3050513          	addi	a0,a0,-464 # 800073d0 <states.0+0xd0>
    800025a8:	9aefe0ef          	jal	ra,80000756 <panic>
    panic("kerneltrap: interrupts enabled");
    800025ac:	00005517          	auipc	a0,0x5
    800025b0:	e4c50513          	addi	a0,a0,-436 # 800073f8 <states.0+0xf8>
    800025b4:	9a2fe0ef          	jal	ra,80000756 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025b8:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800025bc:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800025c0:	85ce                	mv	a1,s3
    800025c2:	00005517          	auipc	a0,0x5
    800025c6:	e5650513          	addi	a0,a0,-426 # 80007418 <states.0+0x118>
    800025ca:	ed9fd0ef          	jal	ra,800004a2 <printf>
    panic("kerneltrap");
    800025ce:	00005517          	auipc	a0,0x5
    800025d2:	e7250513          	addi	a0,a0,-398 # 80007440 <states.0+0x140>
    800025d6:	980fe0ef          	jal	ra,80000756 <panic>
  if(which_dev == 2 && myproc() != 0)
    800025da:	a4aff0ef          	jal	ra,80001824 <myproc>
    800025de:	d555                	beqz	a0,8000258a <kerneltrap+0x34>
    yield();
    800025e0:	fe2ff0ef          	jal	ra,80001dc2 <yield>
    800025e4:	b75d                	j	8000258a <kerneltrap+0x34>

00000000800025e6 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800025e6:	1101                	addi	sp,sp,-32
    800025e8:	ec06                	sd	ra,24(sp)
    800025ea:	e822                	sd	s0,16(sp)
    800025ec:	e426                	sd	s1,8(sp)
    800025ee:	1000                	addi	s0,sp,32
    800025f0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800025f2:	a32ff0ef          	jal	ra,80001824 <myproc>
  switch (n) {
    800025f6:	4795                	li	a5,5
    800025f8:	0497e163          	bltu	a5,s1,8000263a <argraw+0x54>
    800025fc:	048a                	slli	s1,s1,0x2
    800025fe:	00005717          	auipc	a4,0x5
    80002602:	e7a70713          	addi	a4,a4,-390 # 80007478 <states.0+0x178>
    80002606:	94ba                	add	s1,s1,a4
    80002608:	409c                	lw	a5,0(s1)
    8000260a:	97ba                	add	a5,a5,a4
    8000260c:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000260e:	6d3c                	ld	a5,88(a0)
    80002610:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002612:	60e2                	ld	ra,24(sp)
    80002614:	6442                	ld	s0,16(sp)
    80002616:	64a2                	ld	s1,8(sp)
    80002618:	6105                	addi	sp,sp,32
    8000261a:	8082                	ret
    return p->trapframe->a1;
    8000261c:	6d3c                	ld	a5,88(a0)
    8000261e:	7fa8                	ld	a0,120(a5)
    80002620:	bfcd                	j	80002612 <argraw+0x2c>
    return p->trapframe->a2;
    80002622:	6d3c                	ld	a5,88(a0)
    80002624:	63c8                	ld	a0,128(a5)
    80002626:	b7f5                	j	80002612 <argraw+0x2c>
    return p->trapframe->a3;
    80002628:	6d3c                	ld	a5,88(a0)
    8000262a:	67c8                	ld	a0,136(a5)
    8000262c:	b7dd                	j	80002612 <argraw+0x2c>
    return p->trapframe->a4;
    8000262e:	6d3c                	ld	a5,88(a0)
    80002630:	6bc8                	ld	a0,144(a5)
    80002632:	b7c5                	j	80002612 <argraw+0x2c>
    return p->trapframe->a5;
    80002634:	6d3c                	ld	a5,88(a0)
    80002636:	6fc8                	ld	a0,152(a5)
    80002638:	bfe9                	j	80002612 <argraw+0x2c>
  panic("argraw");
    8000263a:	00005517          	auipc	a0,0x5
    8000263e:	e1650513          	addi	a0,a0,-490 # 80007450 <states.0+0x150>
    80002642:	914fe0ef          	jal	ra,80000756 <panic>

0000000080002646 <fetchaddr>:
{
    80002646:	1101                	addi	sp,sp,-32
    80002648:	ec06                	sd	ra,24(sp)
    8000264a:	e822                	sd	s0,16(sp)
    8000264c:	e426                	sd	s1,8(sp)
    8000264e:	e04a                	sd	s2,0(sp)
    80002650:	1000                	addi	s0,sp,32
    80002652:	84aa                	mv	s1,a0
    80002654:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002656:	9ceff0ef          	jal	ra,80001824 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000265a:	653c                	ld	a5,72(a0)
    8000265c:	02f4f663          	bgeu	s1,a5,80002688 <fetchaddr+0x42>
    80002660:	00848713          	addi	a4,s1,8
    80002664:	02e7e463          	bltu	a5,a4,8000268c <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002668:	46a1                	li	a3,8
    8000266a:	8626                	mv	a2,s1
    8000266c:	85ca                	mv	a1,s2
    8000266e:	6928                	ld	a0,80(a0)
    80002670:	f21fe0ef          	jal	ra,80001590 <copyin>
    80002674:	00a03533          	snez	a0,a0
    80002678:	40a00533          	neg	a0,a0
}
    8000267c:	60e2                	ld	ra,24(sp)
    8000267e:	6442                	ld	s0,16(sp)
    80002680:	64a2                	ld	s1,8(sp)
    80002682:	6902                	ld	s2,0(sp)
    80002684:	6105                	addi	sp,sp,32
    80002686:	8082                	ret
    return -1;
    80002688:	557d                	li	a0,-1
    8000268a:	bfcd                	j	8000267c <fetchaddr+0x36>
    8000268c:	557d                	li	a0,-1
    8000268e:	b7fd                	j	8000267c <fetchaddr+0x36>

0000000080002690 <fetchstr>:
{
    80002690:	7179                	addi	sp,sp,-48
    80002692:	f406                	sd	ra,40(sp)
    80002694:	f022                	sd	s0,32(sp)
    80002696:	ec26                	sd	s1,24(sp)
    80002698:	e84a                	sd	s2,16(sp)
    8000269a:	e44e                	sd	s3,8(sp)
    8000269c:	1800                	addi	s0,sp,48
    8000269e:	892a                	mv	s2,a0
    800026a0:	84ae                	mv	s1,a1
    800026a2:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800026a4:	980ff0ef          	jal	ra,80001824 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800026a8:	86ce                	mv	a3,s3
    800026aa:	864a                	mv	a2,s2
    800026ac:	85a6                	mv	a1,s1
    800026ae:	6928                	ld	a0,80(a0)
    800026b0:	f67fe0ef          	jal	ra,80001616 <copyinstr>
    800026b4:	00054c63          	bltz	a0,800026cc <fetchstr+0x3c>
  return strlen(buf);
    800026b8:	8526                	mv	a0,s1
    800026ba:	f24fe0ef          	jal	ra,80000dde <strlen>
}
    800026be:	70a2                	ld	ra,40(sp)
    800026c0:	7402                	ld	s0,32(sp)
    800026c2:	64e2                	ld	s1,24(sp)
    800026c4:	6942                	ld	s2,16(sp)
    800026c6:	69a2                	ld	s3,8(sp)
    800026c8:	6145                	addi	sp,sp,48
    800026ca:	8082                	ret
    return -1;
    800026cc:	557d                	li	a0,-1
    800026ce:	bfc5                	j	800026be <fetchstr+0x2e>

00000000800026d0 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800026d0:	1101                	addi	sp,sp,-32
    800026d2:	ec06                	sd	ra,24(sp)
    800026d4:	e822                	sd	s0,16(sp)
    800026d6:	e426                	sd	s1,8(sp)
    800026d8:	1000                	addi	s0,sp,32
    800026da:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800026dc:	f0bff0ef          	jal	ra,800025e6 <argraw>
    800026e0:	c088                	sw	a0,0(s1)
}
    800026e2:	60e2                	ld	ra,24(sp)
    800026e4:	6442                	ld	s0,16(sp)
    800026e6:	64a2                	ld	s1,8(sp)
    800026e8:	6105                	addi	sp,sp,32
    800026ea:	8082                	ret

00000000800026ec <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800026ec:	1101                	addi	sp,sp,-32
    800026ee:	ec06                	sd	ra,24(sp)
    800026f0:	e822                	sd	s0,16(sp)
    800026f2:	e426                	sd	s1,8(sp)
    800026f4:	1000                	addi	s0,sp,32
    800026f6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800026f8:	eefff0ef          	jal	ra,800025e6 <argraw>
    800026fc:	e088                	sd	a0,0(s1)
}
    800026fe:	60e2                	ld	ra,24(sp)
    80002700:	6442                	ld	s0,16(sp)
    80002702:	64a2                	ld	s1,8(sp)
    80002704:	6105                	addi	sp,sp,32
    80002706:	8082                	ret

0000000080002708 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002708:	7179                	addi	sp,sp,-48
    8000270a:	f406                	sd	ra,40(sp)
    8000270c:	f022                	sd	s0,32(sp)
    8000270e:	ec26                	sd	s1,24(sp)
    80002710:	e84a                	sd	s2,16(sp)
    80002712:	1800                	addi	s0,sp,48
    80002714:	84ae                	mv	s1,a1
    80002716:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002718:	fd840593          	addi	a1,s0,-40
    8000271c:	fd1ff0ef          	jal	ra,800026ec <argaddr>
  return fetchstr(addr, buf, max);
    80002720:	864a                	mv	a2,s2
    80002722:	85a6                	mv	a1,s1
    80002724:	fd843503          	ld	a0,-40(s0)
    80002728:	f69ff0ef          	jal	ra,80002690 <fetchstr>
}
    8000272c:	70a2                	ld	ra,40(sp)
    8000272e:	7402                	ld	s0,32(sp)
    80002730:	64e2                	ld	s1,24(sp)
    80002732:	6942                	ld	s2,16(sp)
    80002734:	6145                	addi	sp,sp,48
    80002736:	8082                	ret

0000000080002738 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002738:	1101                	addi	sp,sp,-32
    8000273a:	ec06                	sd	ra,24(sp)
    8000273c:	e822                	sd	s0,16(sp)
    8000273e:	e426                	sd	s1,8(sp)
    80002740:	e04a                	sd	s2,0(sp)
    80002742:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002744:	8e0ff0ef          	jal	ra,80001824 <myproc>
    80002748:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000274a:	05853903          	ld	s2,88(a0)
    8000274e:	0a893783          	ld	a5,168(s2)
    80002752:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002756:	37fd                	addiw	a5,a5,-1
    80002758:	4751                	li	a4,20
    8000275a:	00f76f63          	bltu	a4,a5,80002778 <syscall+0x40>
    8000275e:	00369713          	slli	a4,a3,0x3
    80002762:	00005797          	auipc	a5,0x5
    80002766:	d2e78793          	addi	a5,a5,-722 # 80007490 <syscalls>
    8000276a:	97ba                	add	a5,a5,a4
    8000276c:	639c                	ld	a5,0(a5)
    8000276e:	c789                	beqz	a5,80002778 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002770:	9782                	jalr	a5
    80002772:	06a93823          	sd	a0,112(s2)
    80002776:	a829                	j	80002790 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002778:	15848613          	addi	a2,s1,344
    8000277c:	588c                	lw	a1,48(s1)
    8000277e:	00005517          	auipc	a0,0x5
    80002782:	cda50513          	addi	a0,a0,-806 # 80007458 <states.0+0x158>
    80002786:	d1dfd0ef          	jal	ra,800004a2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000278a:	6cbc                	ld	a5,88(s1)
    8000278c:	577d                	li	a4,-1
    8000278e:	fbb8                	sd	a4,112(a5)
  }
}
    80002790:	60e2                	ld	ra,24(sp)
    80002792:	6442                	ld	s0,16(sp)
    80002794:	64a2                	ld	s1,8(sp)
    80002796:	6902                	ld	s2,0(sp)
    80002798:	6105                	addi	sp,sp,32
    8000279a:	8082                	ret

000000008000279c <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    8000279c:	1101                	addi	sp,sp,-32
    8000279e:	ec06                	sd	ra,24(sp)
    800027a0:	e822                	sd	s0,16(sp)
    800027a2:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800027a4:	fec40593          	addi	a1,s0,-20
    800027a8:	4501                	li	a0,0
    800027aa:	f27ff0ef          	jal	ra,800026d0 <argint>
  exit(n);
    800027ae:	fec42503          	lw	a0,-20(s0)
    800027b2:	f48ff0ef          	jal	ra,80001efa <exit>
  return 0;  // not reached
}
    800027b6:	4501                	li	a0,0
    800027b8:	60e2                	ld	ra,24(sp)
    800027ba:	6442                	ld	s0,16(sp)
    800027bc:	6105                	addi	sp,sp,32
    800027be:	8082                	ret

00000000800027c0 <sys_getpid>:

uint64
sys_getpid(void)
{
    800027c0:	1141                	addi	sp,sp,-16
    800027c2:	e406                	sd	ra,8(sp)
    800027c4:	e022                	sd	s0,0(sp)
    800027c6:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800027c8:	85cff0ef          	jal	ra,80001824 <myproc>
}
    800027cc:	5908                	lw	a0,48(a0)
    800027ce:	60a2                	ld	ra,8(sp)
    800027d0:	6402                	ld	s0,0(sp)
    800027d2:	0141                	addi	sp,sp,16
    800027d4:	8082                	ret

00000000800027d6 <sys_fork>:

uint64
sys_fork(void)
{
    800027d6:	1141                	addi	sp,sp,-16
    800027d8:	e406                	sd	ra,8(sp)
    800027da:	e022                	sd	s0,0(sp)
    800027dc:	0800                	addi	s0,sp,16
  return fork();
    800027de:	b6cff0ef          	jal	ra,80001b4a <fork>
}
    800027e2:	60a2                	ld	ra,8(sp)
    800027e4:	6402                	ld	s0,0(sp)
    800027e6:	0141                	addi	sp,sp,16
    800027e8:	8082                	ret

00000000800027ea <sys_wait>:

uint64
sys_wait(void)
{
    800027ea:	1101                	addi	sp,sp,-32
    800027ec:	ec06                	sd	ra,24(sp)
    800027ee:	e822                	sd	s0,16(sp)
    800027f0:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800027f2:	fe840593          	addi	a1,s0,-24
    800027f6:	4501                	li	a0,0
    800027f8:	ef5ff0ef          	jal	ra,800026ec <argaddr>
  return wait(p);
    800027fc:	fe843503          	ld	a0,-24(s0)
    80002800:	851ff0ef          	jal	ra,80002050 <wait>
}
    80002804:	60e2                	ld	ra,24(sp)
    80002806:	6442                	ld	s0,16(sp)
    80002808:	6105                	addi	sp,sp,32
    8000280a:	8082                	ret

000000008000280c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000280c:	7179                	addi	sp,sp,-48
    8000280e:	f406                	sd	ra,40(sp)
    80002810:	f022                	sd	s0,32(sp)
    80002812:	ec26                	sd	s1,24(sp)
    80002814:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002816:	fdc40593          	addi	a1,s0,-36
    8000281a:	4501                	li	a0,0
    8000281c:	eb5ff0ef          	jal	ra,800026d0 <argint>
  addr = myproc()->sz;
    80002820:	804ff0ef          	jal	ra,80001824 <myproc>
    80002824:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002826:	fdc42503          	lw	a0,-36(s0)
    8000282a:	ad0ff0ef          	jal	ra,80001afa <growproc>
    8000282e:	00054863          	bltz	a0,8000283e <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002832:	8526                	mv	a0,s1
    80002834:	70a2                	ld	ra,40(sp)
    80002836:	7402                	ld	s0,32(sp)
    80002838:	64e2                	ld	s1,24(sp)
    8000283a:	6145                	addi	sp,sp,48
    8000283c:	8082                	ret
    return -1;
    8000283e:	54fd                	li	s1,-1
    80002840:	bfcd                	j	80002832 <sys_sbrk+0x26>

0000000080002842 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002842:	7139                	addi	sp,sp,-64
    80002844:	fc06                	sd	ra,56(sp)
    80002846:	f822                	sd	s0,48(sp)
    80002848:	f426                	sd	s1,40(sp)
    8000284a:	f04a                	sd	s2,32(sp)
    8000284c:	ec4e                	sd	s3,24(sp)
    8000284e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002850:	fcc40593          	addi	a1,s0,-52
    80002854:	4501                	li	a0,0
    80002856:	e7bff0ef          	jal	ra,800026d0 <argint>
  if(n < 0)
    8000285a:	fcc42783          	lw	a5,-52(s0)
    8000285e:	0607c563          	bltz	a5,800028c8 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002862:	00013517          	auipc	a0,0x13
    80002866:	ffe50513          	addi	a0,a0,-2 # 80015860 <tickslock>
    8000286a:	b28fe0ef          	jal	ra,80000b92 <acquire>
  ticks0 = ticks;
    8000286e:	00005917          	auipc	s2,0x5
    80002872:	09292903          	lw	s2,146(s2) # 80007900 <ticks>
  while(ticks - ticks0 < n){
    80002876:	fcc42783          	lw	a5,-52(s0)
    8000287a:	cb8d                	beqz	a5,800028ac <sys_sleep+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000287c:	00013997          	auipc	s3,0x13
    80002880:	fe498993          	addi	s3,s3,-28 # 80015860 <tickslock>
    80002884:	00005497          	auipc	s1,0x5
    80002888:	07c48493          	addi	s1,s1,124 # 80007900 <ticks>
    if(killed(myproc())){
    8000288c:	f99fe0ef          	jal	ra,80001824 <myproc>
    80002890:	f96ff0ef          	jal	ra,80002026 <killed>
    80002894:	ed0d                	bnez	a0,800028ce <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80002896:	85ce                	mv	a1,s3
    80002898:	8526                	mv	a0,s1
    8000289a:	d54ff0ef          	jal	ra,80001dee <sleep>
  while(ticks - ticks0 < n){
    8000289e:	409c                	lw	a5,0(s1)
    800028a0:	412787bb          	subw	a5,a5,s2
    800028a4:	fcc42703          	lw	a4,-52(s0)
    800028a8:	fee7e2e3          	bltu	a5,a4,8000288c <sys_sleep+0x4a>
  }
  release(&tickslock);
    800028ac:	00013517          	auipc	a0,0x13
    800028b0:	fb450513          	addi	a0,a0,-76 # 80015860 <tickslock>
    800028b4:	b76fe0ef          	jal	ra,80000c2a <release>
  return 0;
    800028b8:	4501                	li	a0,0
}
    800028ba:	70e2                	ld	ra,56(sp)
    800028bc:	7442                	ld	s0,48(sp)
    800028be:	74a2                	ld	s1,40(sp)
    800028c0:	7902                	ld	s2,32(sp)
    800028c2:	69e2                	ld	s3,24(sp)
    800028c4:	6121                	addi	sp,sp,64
    800028c6:	8082                	ret
    n = 0;
    800028c8:	fc042623          	sw	zero,-52(s0)
    800028cc:	bf59                	j	80002862 <sys_sleep+0x20>
      release(&tickslock);
    800028ce:	00013517          	auipc	a0,0x13
    800028d2:	f9250513          	addi	a0,a0,-110 # 80015860 <tickslock>
    800028d6:	b54fe0ef          	jal	ra,80000c2a <release>
      return -1;
    800028da:	557d                	li	a0,-1
    800028dc:	bff9                	j	800028ba <sys_sleep+0x78>

00000000800028de <sys_kill>:

uint64
sys_kill(void)
{
    800028de:	1101                	addi	sp,sp,-32
    800028e0:	ec06                	sd	ra,24(sp)
    800028e2:	e822                	sd	s0,16(sp)
    800028e4:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800028e6:	fec40593          	addi	a1,s0,-20
    800028ea:	4501                	li	a0,0
    800028ec:	de5ff0ef          	jal	ra,800026d0 <argint>
  return kill(pid);
    800028f0:	fec42503          	lw	a0,-20(s0)
    800028f4:	ea8ff0ef          	jal	ra,80001f9c <kill>
}
    800028f8:	60e2                	ld	ra,24(sp)
    800028fa:	6442                	ld	s0,16(sp)
    800028fc:	6105                	addi	sp,sp,32
    800028fe:	8082                	ret

0000000080002900 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002900:	1101                	addi	sp,sp,-32
    80002902:	ec06                	sd	ra,24(sp)
    80002904:	e822                	sd	s0,16(sp)
    80002906:	e426                	sd	s1,8(sp)
    80002908:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000290a:	00013517          	auipc	a0,0x13
    8000290e:	f5650513          	addi	a0,a0,-170 # 80015860 <tickslock>
    80002912:	a80fe0ef          	jal	ra,80000b92 <acquire>
  xticks = ticks;
    80002916:	00005497          	auipc	s1,0x5
    8000291a:	fea4a483          	lw	s1,-22(s1) # 80007900 <ticks>
  release(&tickslock);
    8000291e:	00013517          	auipc	a0,0x13
    80002922:	f4250513          	addi	a0,a0,-190 # 80015860 <tickslock>
    80002926:	b04fe0ef          	jal	ra,80000c2a <release>
  return xticks;
}
    8000292a:	02049513          	slli	a0,s1,0x20
    8000292e:	9101                	srli	a0,a0,0x20
    80002930:	60e2                	ld	ra,24(sp)
    80002932:	6442                	ld	s0,16(sp)
    80002934:	64a2                	ld	s1,8(sp)
    80002936:	6105                	addi	sp,sp,32
    80002938:	8082                	ret

000000008000293a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000293a:	7179                	addi	sp,sp,-48
    8000293c:	f406                	sd	ra,40(sp)
    8000293e:	f022                	sd	s0,32(sp)
    80002940:	ec26                	sd	s1,24(sp)
    80002942:	e84a                	sd	s2,16(sp)
    80002944:	e44e                	sd	s3,8(sp)
    80002946:	e052                	sd	s4,0(sp)
    80002948:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000294a:	00005597          	auipc	a1,0x5
    8000294e:	bf658593          	addi	a1,a1,-1034 # 80007540 <syscalls+0xb0>
    80002952:	00013517          	auipc	a0,0x13
    80002956:	f2650513          	addi	a0,a0,-218 # 80015878 <bcache>
    8000295a:	9b8fe0ef          	jal	ra,80000b12 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000295e:	0001b797          	auipc	a5,0x1b
    80002962:	f1a78793          	addi	a5,a5,-230 # 8001d878 <bcache+0x8000>
    80002966:	0001b717          	auipc	a4,0x1b
    8000296a:	17a70713          	addi	a4,a4,378 # 8001dae0 <bcache+0x8268>
    8000296e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002972:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002976:	00013497          	auipc	s1,0x13
    8000297a:	f1a48493          	addi	s1,s1,-230 # 80015890 <bcache+0x18>
    b->next = bcache.head.next;
    8000297e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002980:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002982:	00005a17          	auipc	s4,0x5
    80002986:	bc6a0a13          	addi	s4,s4,-1082 # 80007548 <syscalls+0xb8>
    b->next = bcache.head.next;
    8000298a:	2b893783          	ld	a5,696(s2)
    8000298e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002990:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002994:	85d2                	mv	a1,s4
    80002996:	01048513          	addi	a0,s1,16
    8000299a:	22a010ef          	jal	ra,80003bc4 <initsleeplock>
    bcache.head.next->prev = b;
    8000299e:	2b893783          	ld	a5,696(s2)
    800029a2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800029a4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800029a8:	45848493          	addi	s1,s1,1112
    800029ac:	fd349fe3          	bne	s1,s3,8000298a <binit+0x50>
  }
}
    800029b0:	70a2                	ld	ra,40(sp)
    800029b2:	7402                	ld	s0,32(sp)
    800029b4:	64e2                	ld	s1,24(sp)
    800029b6:	6942                	ld	s2,16(sp)
    800029b8:	69a2                	ld	s3,8(sp)
    800029ba:	6a02                	ld	s4,0(sp)
    800029bc:	6145                	addi	sp,sp,48
    800029be:	8082                	ret

00000000800029c0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800029c0:	7179                	addi	sp,sp,-48
    800029c2:	f406                	sd	ra,40(sp)
    800029c4:	f022                	sd	s0,32(sp)
    800029c6:	ec26                	sd	s1,24(sp)
    800029c8:	e84a                	sd	s2,16(sp)
    800029ca:	e44e                	sd	s3,8(sp)
    800029cc:	1800                	addi	s0,sp,48
    800029ce:	892a                	mv	s2,a0
    800029d0:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800029d2:	00013517          	auipc	a0,0x13
    800029d6:	ea650513          	addi	a0,a0,-346 # 80015878 <bcache>
    800029da:	9b8fe0ef          	jal	ra,80000b92 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800029de:	0001b497          	auipc	s1,0x1b
    800029e2:	1524b483          	ld	s1,338(s1) # 8001db30 <bcache+0x82b8>
    800029e6:	0001b797          	auipc	a5,0x1b
    800029ea:	0fa78793          	addi	a5,a5,250 # 8001dae0 <bcache+0x8268>
    800029ee:	02f48b63          	beq	s1,a5,80002a24 <bread+0x64>
    800029f2:	873e                	mv	a4,a5
    800029f4:	a021                	j	800029fc <bread+0x3c>
    800029f6:	68a4                	ld	s1,80(s1)
    800029f8:	02e48663          	beq	s1,a4,80002a24 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    800029fc:	449c                	lw	a5,8(s1)
    800029fe:	ff279ce3          	bne	a5,s2,800029f6 <bread+0x36>
    80002a02:	44dc                	lw	a5,12(s1)
    80002a04:	ff3799e3          	bne	a5,s3,800029f6 <bread+0x36>
      b->refcnt++;
    80002a08:	40bc                	lw	a5,64(s1)
    80002a0a:	2785                	addiw	a5,a5,1
    80002a0c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002a0e:	00013517          	auipc	a0,0x13
    80002a12:	e6a50513          	addi	a0,a0,-406 # 80015878 <bcache>
    80002a16:	a14fe0ef          	jal	ra,80000c2a <release>
      acquiresleep(&b->lock);
    80002a1a:	01048513          	addi	a0,s1,16
    80002a1e:	1dc010ef          	jal	ra,80003bfa <acquiresleep>
      return b;
    80002a22:	a889                	j	80002a74 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002a24:	0001b497          	auipc	s1,0x1b
    80002a28:	1044b483          	ld	s1,260(s1) # 8001db28 <bcache+0x82b0>
    80002a2c:	0001b797          	auipc	a5,0x1b
    80002a30:	0b478793          	addi	a5,a5,180 # 8001dae0 <bcache+0x8268>
    80002a34:	00f48863          	beq	s1,a5,80002a44 <bread+0x84>
    80002a38:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002a3a:	40bc                	lw	a5,64(s1)
    80002a3c:	cb91                	beqz	a5,80002a50 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002a3e:	64a4                	ld	s1,72(s1)
    80002a40:	fee49de3          	bne	s1,a4,80002a3a <bread+0x7a>
  panic("bget: no buffers");
    80002a44:	00005517          	auipc	a0,0x5
    80002a48:	b0c50513          	addi	a0,a0,-1268 # 80007550 <syscalls+0xc0>
    80002a4c:	d0bfd0ef          	jal	ra,80000756 <panic>
      b->dev = dev;
    80002a50:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002a54:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002a58:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002a5c:	4785                	li	a5,1
    80002a5e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002a60:	00013517          	auipc	a0,0x13
    80002a64:	e1850513          	addi	a0,a0,-488 # 80015878 <bcache>
    80002a68:	9c2fe0ef          	jal	ra,80000c2a <release>
      acquiresleep(&b->lock);
    80002a6c:	01048513          	addi	a0,s1,16
    80002a70:	18a010ef          	jal	ra,80003bfa <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002a74:	409c                	lw	a5,0(s1)
    80002a76:	cb89                	beqz	a5,80002a88 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002a78:	8526                	mv	a0,s1
    80002a7a:	70a2                	ld	ra,40(sp)
    80002a7c:	7402                	ld	s0,32(sp)
    80002a7e:	64e2                	ld	s1,24(sp)
    80002a80:	6942                	ld	s2,16(sp)
    80002a82:	69a2                	ld	s3,8(sp)
    80002a84:	6145                	addi	sp,sp,48
    80002a86:	8082                	ret
    virtio_disk_rw(b, 0);
    80002a88:	4581                	li	a1,0
    80002a8a:	8526                	mv	a0,s1
    80002a8c:	0d1020ef          	jal	ra,8000535c <virtio_disk_rw>
    b->valid = 1;
    80002a90:	4785                	li	a5,1
    80002a92:	c09c                	sw	a5,0(s1)
  return b;
    80002a94:	b7d5                	j	80002a78 <bread+0xb8>

0000000080002a96 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002a96:	1101                	addi	sp,sp,-32
    80002a98:	ec06                	sd	ra,24(sp)
    80002a9a:	e822                	sd	s0,16(sp)
    80002a9c:	e426                	sd	s1,8(sp)
    80002a9e:	1000                	addi	s0,sp,32
    80002aa0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002aa2:	0541                	addi	a0,a0,16
    80002aa4:	1d4010ef          	jal	ra,80003c78 <holdingsleep>
    80002aa8:	c911                	beqz	a0,80002abc <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002aaa:	4585                	li	a1,1
    80002aac:	8526                	mv	a0,s1
    80002aae:	0af020ef          	jal	ra,8000535c <virtio_disk_rw>
}
    80002ab2:	60e2                	ld	ra,24(sp)
    80002ab4:	6442                	ld	s0,16(sp)
    80002ab6:	64a2                	ld	s1,8(sp)
    80002ab8:	6105                	addi	sp,sp,32
    80002aba:	8082                	ret
    panic("bwrite");
    80002abc:	00005517          	auipc	a0,0x5
    80002ac0:	aac50513          	addi	a0,a0,-1364 # 80007568 <syscalls+0xd8>
    80002ac4:	c93fd0ef          	jal	ra,80000756 <panic>

0000000080002ac8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002ac8:	1101                	addi	sp,sp,-32
    80002aca:	ec06                	sd	ra,24(sp)
    80002acc:	e822                	sd	s0,16(sp)
    80002ace:	e426                	sd	s1,8(sp)
    80002ad0:	e04a                	sd	s2,0(sp)
    80002ad2:	1000                	addi	s0,sp,32
    80002ad4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002ad6:	01050913          	addi	s2,a0,16
    80002ada:	854a                	mv	a0,s2
    80002adc:	19c010ef          	jal	ra,80003c78 <holdingsleep>
    80002ae0:	c13d                	beqz	a0,80002b46 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80002ae2:	854a                	mv	a0,s2
    80002ae4:	15c010ef          	jal	ra,80003c40 <releasesleep>

  acquire(&bcache.lock);
    80002ae8:	00013517          	auipc	a0,0x13
    80002aec:	d9050513          	addi	a0,a0,-624 # 80015878 <bcache>
    80002af0:	8a2fe0ef          	jal	ra,80000b92 <acquire>
  b->refcnt--;
    80002af4:	40bc                	lw	a5,64(s1)
    80002af6:	37fd                	addiw	a5,a5,-1
    80002af8:	0007871b          	sext.w	a4,a5
    80002afc:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002afe:	eb05                	bnez	a4,80002b2e <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002b00:	68bc                	ld	a5,80(s1)
    80002b02:	64b8                	ld	a4,72(s1)
    80002b04:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002b06:	64bc                	ld	a5,72(s1)
    80002b08:	68b8                	ld	a4,80(s1)
    80002b0a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002b0c:	0001b797          	auipc	a5,0x1b
    80002b10:	d6c78793          	addi	a5,a5,-660 # 8001d878 <bcache+0x8000>
    80002b14:	2b87b703          	ld	a4,696(a5)
    80002b18:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002b1a:	0001b717          	auipc	a4,0x1b
    80002b1e:	fc670713          	addi	a4,a4,-58 # 8001dae0 <bcache+0x8268>
    80002b22:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002b24:	2b87b703          	ld	a4,696(a5)
    80002b28:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002b2a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002b2e:	00013517          	auipc	a0,0x13
    80002b32:	d4a50513          	addi	a0,a0,-694 # 80015878 <bcache>
    80002b36:	8f4fe0ef          	jal	ra,80000c2a <release>
}
    80002b3a:	60e2                	ld	ra,24(sp)
    80002b3c:	6442                	ld	s0,16(sp)
    80002b3e:	64a2                	ld	s1,8(sp)
    80002b40:	6902                	ld	s2,0(sp)
    80002b42:	6105                	addi	sp,sp,32
    80002b44:	8082                	ret
    panic("brelse");
    80002b46:	00005517          	auipc	a0,0x5
    80002b4a:	a2a50513          	addi	a0,a0,-1494 # 80007570 <syscalls+0xe0>
    80002b4e:	c09fd0ef          	jal	ra,80000756 <panic>

0000000080002b52 <bpin>:

void
bpin(struct buf *b) {
    80002b52:	1101                	addi	sp,sp,-32
    80002b54:	ec06                	sd	ra,24(sp)
    80002b56:	e822                	sd	s0,16(sp)
    80002b58:	e426                	sd	s1,8(sp)
    80002b5a:	1000                	addi	s0,sp,32
    80002b5c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002b5e:	00013517          	auipc	a0,0x13
    80002b62:	d1a50513          	addi	a0,a0,-742 # 80015878 <bcache>
    80002b66:	82cfe0ef          	jal	ra,80000b92 <acquire>
  b->refcnt++;
    80002b6a:	40bc                	lw	a5,64(s1)
    80002b6c:	2785                	addiw	a5,a5,1
    80002b6e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002b70:	00013517          	auipc	a0,0x13
    80002b74:	d0850513          	addi	a0,a0,-760 # 80015878 <bcache>
    80002b78:	8b2fe0ef          	jal	ra,80000c2a <release>
}
    80002b7c:	60e2                	ld	ra,24(sp)
    80002b7e:	6442                	ld	s0,16(sp)
    80002b80:	64a2                	ld	s1,8(sp)
    80002b82:	6105                	addi	sp,sp,32
    80002b84:	8082                	ret

0000000080002b86 <bunpin>:

void
bunpin(struct buf *b) {
    80002b86:	1101                	addi	sp,sp,-32
    80002b88:	ec06                	sd	ra,24(sp)
    80002b8a:	e822                	sd	s0,16(sp)
    80002b8c:	e426                	sd	s1,8(sp)
    80002b8e:	1000                	addi	s0,sp,32
    80002b90:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002b92:	00013517          	auipc	a0,0x13
    80002b96:	ce650513          	addi	a0,a0,-794 # 80015878 <bcache>
    80002b9a:	ff9fd0ef          	jal	ra,80000b92 <acquire>
  b->refcnt--;
    80002b9e:	40bc                	lw	a5,64(s1)
    80002ba0:	37fd                	addiw	a5,a5,-1
    80002ba2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002ba4:	00013517          	auipc	a0,0x13
    80002ba8:	cd450513          	addi	a0,a0,-812 # 80015878 <bcache>
    80002bac:	87efe0ef          	jal	ra,80000c2a <release>
}
    80002bb0:	60e2                	ld	ra,24(sp)
    80002bb2:	6442                	ld	s0,16(sp)
    80002bb4:	64a2                	ld	s1,8(sp)
    80002bb6:	6105                	addi	sp,sp,32
    80002bb8:	8082                	ret

0000000080002bba <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002bba:	1101                	addi	sp,sp,-32
    80002bbc:	ec06                	sd	ra,24(sp)
    80002bbe:	e822                	sd	s0,16(sp)
    80002bc0:	e426                	sd	s1,8(sp)
    80002bc2:	e04a                	sd	s2,0(sp)
    80002bc4:	1000                	addi	s0,sp,32
    80002bc6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002bc8:	00d5d59b          	srliw	a1,a1,0xd
    80002bcc:	0001b797          	auipc	a5,0x1b
    80002bd0:	3887a783          	lw	a5,904(a5) # 8001df54 <sb+0x1c>
    80002bd4:	9dbd                	addw	a1,a1,a5
    80002bd6:	debff0ef          	jal	ra,800029c0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002bda:	0074f713          	andi	a4,s1,7
    80002bde:	4785                	li	a5,1
    80002be0:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002be4:	14ce                	slli	s1,s1,0x33
    80002be6:	90d9                	srli	s1,s1,0x36
    80002be8:	00950733          	add	a4,a0,s1
    80002bec:	05874703          	lbu	a4,88(a4)
    80002bf0:	00e7f6b3          	and	a3,a5,a4
    80002bf4:	c29d                	beqz	a3,80002c1a <bfree+0x60>
    80002bf6:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002bf8:	94aa                	add	s1,s1,a0
    80002bfa:	fff7c793          	not	a5,a5
    80002bfe:	8ff9                	and	a5,a5,a4
    80002c00:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80002c04:	6ef000ef          	jal	ra,80003af2 <log_write>
  brelse(bp);
    80002c08:	854a                	mv	a0,s2
    80002c0a:	ebfff0ef          	jal	ra,80002ac8 <brelse>
}
    80002c0e:	60e2                	ld	ra,24(sp)
    80002c10:	6442                	ld	s0,16(sp)
    80002c12:	64a2                	ld	s1,8(sp)
    80002c14:	6902                	ld	s2,0(sp)
    80002c16:	6105                	addi	sp,sp,32
    80002c18:	8082                	ret
    panic("freeing free block");
    80002c1a:	00005517          	auipc	a0,0x5
    80002c1e:	95e50513          	addi	a0,a0,-1698 # 80007578 <syscalls+0xe8>
    80002c22:	b35fd0ef          	jal	ra,80000756 <panic>

0000000080002c26 <balloc>:
{
    80002c26:	711d                	addi	sp,sp,-96
    80002c28:	ec86                	sd	ra,88(sp)
    80002c2a:	e8a2                	sd	s0,80(sp)
    80002c2c:	e4a6                	sd	s1,72(sp)
    80002c2e:	e0ca                	sd	s2,64(sp)
    80002c30:	fc4e                	sd	s3,56(sp)
    80002c32:	f852                	sd	s4,48(sp)
    80002c34:	f456                	sd	s5,40(sp)
    80002c36:	f05a                	sd	s6,32(sp)
    80002c38:	ec5e                	sd	s7,24(sp)
    80002c3a:	e862                	sd	s8,16(sp)
    80002c3c:	e466                	sd	s9,8(sp)
    80002c3e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002c40:	0001b797          	auipc	a5,0x1b
    80002c44:	2fc7a783          	lw	a5,764(a5) # 8001df3c <sb+0x4>
    80002c48:	0e078163          	beqz	a5,80002d2a <balloc+0x104>
    80002c4c:	8baa                	mv	s7,a0
    80002c4e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002c50:	0001bb17          	auipc	s6,0x1b
    80002c54:	2e8b0b13          	addi	s6,s6,744 # 8001df38 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002c58:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002c5a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002c5c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002c5e:	6c89                	lui	s9,0x2
    80002c60:	a0b5                	j	80002ccc <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002c62:	974a                	add	a4,a4,s2
    80002c64:	8fd5                	or	a5,a5,a3
    80002c66:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80002c6a:	854a                	mv	a0,s2
    80002c6c:	687000ef          	jal	ra,80003af2 <log_write>
        brelse(bp);
    80002c70:	854a                	mv	a0,s2
    80002c72:	e57ff0ef          	jal	ra,80002ac8 <brelse>
  bp = bread(dev, bno);
    80002c76:	85a6                	mv	a1,s1
    80002c78:	855e                	mv	a0,s7
    80002c7a:	d47ff0ef          	jal	ra,800029c0 <bread>
    80002c7e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002c80:	40000613          	li	a2,1024
    80002c84:	4581                	li	a1,0
    80002c86:	05850513          	addi	a0,a0,88
    80002c8a:	fddfd0ef          	jal	ra,80000c66 <memset>
  log_write(bp);
    80002c8e:	854a                	mv	a0,s2
    80002c90:	663000ef          	jal	ra,80003af2 <log_write>
  brelse(bp);
    80002c94:	854a                	mv	a0,s2
    80002c96:	e33ff0ef          	jal	ra,80002ac8 <brelse>
}
    80002c9a:	8526                	mv	a0,s1
    80002c9c:	60e6                	ld	ra,88(sp)
    80002c9e:	6446                	ld	s0,80(sp)
    80002ca0:	64a6                	ld	s1,72(sp)
    80002ca2:	6906                	ld	s2,64(sp)
    80002ca4:	79e2                	ld	s3,56(sp)
    80002ca6:	7a42                	ld	s4,48(sp)
    80002ca8:	7aa2                	ld	s5,40(sp)
    80002caa:	7b02                	ld	s6,32(sp)
    80002cac:	6be2                	ld	s7,24(sp)
    80002cae:	6c42                	ld	s8,16(sp)
    80002cb0:	6ca2                	ld	s9,8(sp)
    80002cb2:	6125                	addi	sp,sp,96
    80002cb4:	8082                	ret
    brelse(bp);
    80002cb6:	854a                	mv	a0,s2
    80002cb8:	e11ff0ef          	jal	ra,80002ac8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002cbc:	015c87bb          	addw	a5,s9,s5
    80002cc0:	00078a9b          	sext.w	s5,a5
    80002cc4:	004b2703          	lw	a4,4(s6)
    80002cc8:	06eaf163          	bgeu	s5,a4,80002d2a <balloc+0x104>
    bp = bread(dev, BBLOCK(b, sb));
    80002ccc:	41fad79b          	sraiw	a5,s5,0x1f
    80002cd0:	0137d79b          	srliw	a5,a5,0x13
    80002cd4:	015787bb          	addw	a5,a5,s5
    80002cd8:	40d7d79b          	sraiw	a5,a5,0xd
    80002cdc:	01cb2583          	lw	a1,28(s6)
    80002ce0:	9dbd                	addw	a1,a1,a5
    80002ce2:	855e                	mv	a0,s7
    80002ce4:	cddff0ef          	jal	ra,800029c0 <bread>
    80002ce8:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002cea:	004b2503          	lw	a0,4(s6)
    80002cee:	000a849b          	sext.w	s1,s5
    80002cf2:	8662                	mv	a2,s8
    80002cf4:	fca4f1e3          	bgeu	s1,a0,80002cb6 <balloc+0x90>
      m = 1 << (bi % 8);
    80002cf8:	41f6579b          	sraiw	a5,a2,0x1f
    80002cfc:	01d7d69b          	srliw	a3,a5,0x1d
    80002d00:	00c6873b          	addw	a4,a3,a2
    80002d04:	00777793          	andi	a5,a4,7
    80002d08:	9f95                	subw	a5,a5,a3
    80002d0a:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002d0e:	4037571b          	sraiw	a4,a4,0x3
    80002d12:	00e906b3          	add	a3,s2,a4
    80002d16:	0586c683          	lbu	a3,88(a3)
    80002d1a:	00d7f5b3          	and	a1,a5,a3
    80002d1e:	d1b1                	beqz	a1,80002c62 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002d20:	2605                	addiw	a2,a2,1
    80002d22:	2485                	addiw	s1,s1,1
    80002d24:	fd4618e3          	bne	a2,s4,80002cf4 <balloc+0xce>
    80002d28:	b779                	j	80002cb6 <balloc+0x90>
  printf("balloc: out of blocks\n");
    80002d2a:	00005517          	auipc	a0,0x5
    80002d2e:	86650513          	addi	a0,a0,-1946 # 80007590 <syscalls+0x100>
    80002d32:	f70fd0ef          	jal	ra,800004a2 <printf>
  return 0;
    80002d36:	4481                	li	s1,0
    80002d38:	b78d                	j	80002c9a <balloc+0x74>

0000000080002d3a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002d3a:	7179                	addi	sp,sp,-48
    80002d3c:	f406                	sd	ra,40(sp)
    80002d3e:	f022                	sd	s0,32(sp)
    80002d40:	ec26                	sd	s1,24(sp)
    80002d42:	e84a                	sd	s2,16(sp)
    80002d44:	e44e                	sd	s3,8(sp)
    80002d46:	e052                	sd	s4,0(sp)
    80002d48:	1800                	addi	s0,sp,48
    80002d4a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002d4c:	47ad                	li	a5,11
    80002d4e:	02b7e663          	bltu	a5,a1,80002d7a <bmap+0x40>
    if((addr = ip->addrs[bn]) == 0){
    80002d52:	02059793          	slli	a5,a1,0x20
    80002d56:	01e7d593          	srli	a1,a5,0x1e
    80002d5a:	00b504b3          	add	s1,a0,a1
    80002d5e:	0504a903          	lw	s2,80(s1)
    80002d62:	06091663          	bnez	s2,80002dce <bmap+0x94>
      addr = balloc(ip->dev);
    80002d66:	4108                	lw	a0,0(a0)
    80002d68:	ebfff0ef          	jal	ra,80002c26 <balloc>
    80002d6c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002d70:	04090f63          	beqz	s2,80002dce <bmap+0x94>
        return 0;
      ip->addrs[bn] = addr;
    80002d74:	0524a823          	sw	s2,80(s1)
    80002d78:	a899                	j	80002dce <bmap+0x94>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002d7a:	ff45849b          	addiw	s1,a1,-12
    80002d7e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002d82:	0ff00793          	li	a5,255
    80002d86:	06e7eb63          	bltu	a5,a4,80002dfc <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002d8a:	08052903          	lw	s2,128(a0)
    80002d8e:	00091b63          	bnez	s2,80002da4 <bmap+0x6a>
      addr = balloc(ip->dev);
    80002d92:	4108                	lw	a0,0(a0)
    80002d94:	e93ff0ef          	jal	ra,80002c26 <balloc>
    80002d98:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002d9c:	02090963          	beqz	s2,80002dce <bmap+0x94>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002da0:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80002da4:	85ca                	mv	a1,s2
    80002da6:	0009a503          	lw	a0,0(s3)
    80002daa:	c17ff0ef          	jal	ra,800029c0 <bread>
    80002dae:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002db0:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002db4:	02049713          	slli	a4,s1,0x20
    80002db8:	01e75593          	srli	a1,a4,0x1e
    80002dbc:	00b784b3          	add	s1,a5,a1
    80002dc0:	0004a903          	lw	s2,0(s1)
    80002dc4:	00090e63          	beqz	s2,80002de0 <bmap+0xa6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002dc8:	8552                	mv	a0,s4
    80002dca:	cffff0ef          	jal	ra,80002ac8 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80002dce:	854a                	mv	a0,s2
    80002dd0:	70a2                	ld	ra,40(sp)
    80002dd2:	7402                	ld	s0,32(sp)
    80002dd4:	64e2                	ld	s1,24(sp)
    80002dd6:	6942                	ld	s2,16(sp)
    80002dd8:	69a2                	ld	s3,8(sp)
    80002dda:	6a02                	ld	s4,0(sp)
    80002ddc:	6145                	addi	sp,sp,48
    80002dde:	8082                	ret
      addr = balloc(ip->dev);
    80002de0:	0009a503          	lw	a0,0(s3)
    80002de4:	e43ff0ef          	jal	ra,80002c26 <balloc>
    80002de8:	0005091b          	sext.w	s2,a0
      if(addr){
    80002dec:	fc090ee3          	beqz	s2,80002dc8 <bmap+0x8e>
        a[bn] = addr;
    80002df0:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002df4:	8552                	mv	a0,s4
    80002df6:	4fd000ef          	jal	ra,80003af2 <log_write>
    80002dfa:	b7f9                	j	80002dc8 <bmap+0x8e>
  panic("bmap: out of range");
    80002dfc:	00004517          	auipc	a0,0x4
    80002e00:	7ac50513          	addi	a0,a0,1964 # 800075a8 <syscalls+0x118>
    80002e04:	953fd0ef          	jal	ra,80000756 <panic>

0000000080002e08 <iget>:
{
    80002e08:	7179                	addi	sp,sp,-48
    80002e0a:	f406                	sd	ra,40(sp)
    80002e0c:	f022                	sd	s0,32(sp)
    80002e0e:	ec26                	sd	s1,24(sp)
    80002e10:	e84a                	sd	s2,16(sp)
    80002e12:	e44e                	sd	s3,8(sp)
    80002e14:	e052                	sd	s4,0(sp)
    80002e16:	1800                	addi	s0,sp,48
    80002e18:	89aa                	mv	s3,a0
    80002e1a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002e1c:	0001b517          	auipc	a0,0x1b
    80002e20:	13c50513          	addi	a0,a0,316 # 8001df58 <itable>
    80002e24:	d6ffd0ef          	jal	ra,80000b92 <acquire>
  empty = 0;
    80002e28:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002e2a:	0001b497          	auipc	s1,0x1b
    80002e2e:	14648493          	addi	s1,s1,326 # 8001df70 <itable+0x18>
    80002e32:	0001d697          	auipc	a3,0x1d
    80002e36:	bce68693          	addi	a3,a3,-1074 # 8001fa00 <log>
    80002e3a:	a039                	j	80002e48 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002e3c:	02090963          	beqz	s2,80002e6e <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002e40:	08848493          	addi	s1,s1,136
    80002e44:	02d48863          	beq	s1,a3,80002e74 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002e48:	449c                	lw	a5,8(s1)
    80002e4a:	fef059e3          	blez	a5,80002e3c <iget+0x34>
    80002e4e:	4098                	lw	a4,0(s1)
    80002e50:	ff3716e3          	bne	a4,s3,80002e3c <iget+0x34>
    80002e54:	40d8                	lw	a4,4(s1)
    80002e56:	ff4713e3          	bne	a4,s4,80002e3c <iget+0x34>
      ip->ref++;
    80002e5a:	2785                	addiw	a5,a5,1
    80002e5c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002e5e:	0001b517          	auipc	a0,0x1b
    80002e62:	0fa50513          	addi	a0,a0,250 # 8001df58 <itable>
    80002e66:	dc5fd0ef          	jal	ra,80000c2a <release>
      return ip;
    80002e6a:	8926                	mv	s2,s1
    80002e6c:	a02d                	j	80002e96 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002e6e:	fbe9                	bnez	a5,80002e40 <iget+0x38>
    80002e70:	8926                	mv	s2,s1
    80002e72:	b7f9                	j	80002e40 <iget+0x38>
  if(empty == 0)
    80002e74:	02090a63          	beqz	s2,80002ea8 <iget+0xa0>
  ip->dev = dev;
    80002e78:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002e7c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002e80:	4785                	li	a5,1
    80002e82:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002e86:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002e8a:	0001b517          	auipc	a0,0x1b
    80002e8e:	0ce50513          	addi	a0,a0,206 # 8001df58 <itable>
    80002e92:	d99fd0ef          	jal	ra,80000c2a <release>
}
    80002e96:	854a                	mv	a0,s2
    80002e98:	70a2                	ld	ra,40(sp)
    80002e9a:	7402                	ld	s0,32(sp)
    80002e9c:	64e2                	ld	s1,24(sp)
    80002e9e:	6942                	ld	s2,16(sp)
    80002ea0:	69a2                	ld	s3,8(sp)
    80002ea2:	6a02                	ld	s4,0(sp)
    80002ea4:	6145                	addi	sp,sp,48
    80002ea6:	8082                	ret
    panic("iget: no inodes");
    80002ea8:	00004517          	auipc	a0,0x4
    80002eac:	71850513          	addi	a0,a0,1816 # 800075c0 <syscalls+0x130>
    80002eb0:	8a7fd0ef          	jal	ra,80000756 <panic>

0000000080002eb4 <fsinit>:
fsinit(int dev) {
    80002eb4:	7179                	addi	sp,sp,-48
    80002eb6:	f406                	sd	ra,40(sp)
    80002eb8:	f022                	sd	s0,32(sp)
    80002eba:	ec26                	sd	s1,24(sp)
    80002ebc:	e84a                	sd	s2,16(sp)
    80002ebe:	e44e                	sd	s3,8(sp)
    80002ec0:	1800                	addi	s0,sp,48
    80002ec2:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80002ec4:	4585                	li	a1,1
    80002ec6:	afbff0ef          	jal	ra,800029c0 <bread>
    80002eca:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002ecc:	0001b997          	auipc	s3,0x1b
    80002ed0:	06c98993          	addi	s3,s3,108 # 8001df38 <sb>
    80002ed4:	02000613          	li	a2,32
    80002ed8:	05850593          	addi	a1,a0,88
    80002edc:	854e                	mv	a0,s3
    80002ede:	de5fd0ef          	jal	ra,80000cc2 <memmove>
  brelse(bp);
    80002ee2:	8526                	mv	a0,s1
    80002ee4:	be5ff0ef          	jal	ra,80002ac8 <brelse>
  if(sb.magic != FSMAGIC)
    80002ee8:	0009a703          	lw	a4,0(s3)
    80002eec:	102037b7          	lui	a5,0x10203
    80002ef0:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002ef4:	02f71063          	bne	a4,a5,80002f14 <fsinit+0x60>
  initlog(dev, &sb);
    80002ef8:	0001b597          	auipc	a1,0x1b
    80002efc:	04058593          	addi	a1,a1,64 # 8001df38 <sb>
    80002f00:	854a                	mv	a0,s2
    80002f02:	1db000ef          	jal	ra,800038dc <initlog>
}
    80002f06:	70a2                	ld	ra,40(sp)
    80002f08:	7402                	ld	s0,32(sp)
    80002f0a:	64e2                	ld	s1,24(sp)
    80002f0c:	6942                	ld	s2,16(sp)
    80002f0e:	69a2                	ld	s3,8(sp)
    80002f10:	6145                	addi	sp,sp,48
    80002f12:	8082                	ret
    panic("invalid file system");
    80002f14:	00004517          	auipc	a0,0x4
    80002f18:	6bc50513          	addi	a0,a0,1724 # 800075d0 <syscalls+0x140>
    80002f1c:	83bfd0ef          	jal	ra,80000756 <panic>

0000000080002f20 <iinit>:
{
    80002f20:	7179                	addi	sp,sp,-48
    80002f22:	f406                	sd	ra,40(sp)
    80002f24:	f022                	sd	s0,32(sp)
    80002f26:	ec26                	sd	s1,24(sp)
    80002f28:	e84a                	sd	s2,16(sp)
    80002f2a:	e44e                	sd	s3,8(sp)
    80002f2c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002f2e:	00004597          	auipc	a1,0x4
    80002f32:	6ba58593          	addi	a1,a1,1722 # 800075e8 <syscalls+0x158>
    80002f36:	0001b517          	auipc	a0,0x1b
    80002f3a:	02250513          	addi	a0,a0,34 # 8001df58 <itable>
    80002f3e:	bd5fd0ef          	jal	ra,80000b12 <initlock>
  for(i = 0; i < NINODE; i++) {
    80002f42:	0001b497          	auipc	s1,0x1b
    80002f46:	03e48493          	addi	s1,s1,62 # 8001df80 <itable+0x28>
    80002f4a:	0001d997          	auipc	s3,0x1d
    80002f4e:	ac698993          	addi	s3,s3,-1338 # 8001fa10 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80002f52:	00004917          	auipc	s2,0x4
    80002f56:	69e90913          	addi	s2,s2,1694 # 800075f0 <syscalls+0x160>
    80002f5a:	85ca                	mv	a1,s2
    80002f5c:	8526                	mv	a0,s1
    80002f5e:	467000ef          	jal	ra,80003bc4 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002f62:	08848493          	addi	s1,s1,136
    80002f66:	ff349ae3          	bne	s1,s3,80002f5a <iinit+0x3a>
}
    80002f6a:	70a2                	ld	ra,40(sp)
    80002f6c:	7402                	ld	s0,32(sp)
    80002f6e:	64e2                	ld	s1,24(sp)
    80002f70:	6942                	ld	s2,16(sp)
    80002f72:	69a2                	ld	s3,8(sp)
    80002f74:	6145                	addi	sp,sp,48
    80002f76:	8082                	ret

0000000080002f78 <ialloc>:
{
    80002f78:	715d                	addi	sp,sp,-80
    80002f7a:	e486                	sd	ra,72(sp)
    80002f7c:	e0a2                	sd	s0,64(sp)
    80002f7e:	fc26                	sd	s1,56(sp)
    80002f80:	f84a                	sd	s2,48(sp)
    80002f82:	f44e                	sd	s3,40(sp)
    80002f84:	f052                	sd	s4,32(sp)
    80002f86:	ec56                	sd	s5,24(sp)
    80002f88:	e85a                	sd	s6,16(sp)
    80002f8a:	e45e                	sd	s7,8(sp)
    80002f8c:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80002f8e:	0001b717          	auipc	a4,0x1b
    80002f92:	fb672703          	lw	a4,-74(a4) # 8001df44 <sb+0xc>
    80002f96:	4785                	li	a5,1
    80002f98:	04e7f663          	bgeu	a5,a4,80002fe4 <ialloc+0x6c>
    80002f9c:	8aaa                	mv	s5,a0
    80002f9e:	8bae                	mv	s7,a1
    80002fa0:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002fa2:	0001ba17          	auipc	s4,0x1b
    80002fa6:	f96a0a13          	addi	s4,s4,-106 # 8001df38 <sb>
    80002faa:	00048b1b          	sext.w	s6,s1
    80002fae:	0044d793          	srli	a5,s1,0x4
    80002fb2:	018a2583          	lw	a1,24(s4)
    80002fb6:	9dbd                	addw	a1,a1,a5
    80002fb8:	8556                	mv	a0,s5
    80002fba:	a07ff0ef          	jal	ra,800029c0 <bread>
    80002fbe:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002fc0:	05850993          	addi	s3,a0,88
    80002fc4:	00f4f793          	andi	a5,s1,15
    80002fc8:	079a                	slli	a5,a5,0x6
    80002fca:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002fcc:	00099783          	lh	a5,0(s3)
    80002fd0:	cf85                	beqz	a5,80003008 <ialloc+0x90>
    brelse(bp);
    80002fd2:	af7ff0ef          	jal	ra,80002ac8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80002fd6:	0485                	addi	s1,s1,1
    80002fd8:	00ca2703          	lw	a4,12(s4)
    80002fdc:	0004879b          	sext.w	a5,s1
    80002fe0:	fce7e5e3          	bltu	a5,a4,80002faa <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80002fe4:	00004517          	auipc	a0,0x4
    80002fe8:	61450513          	addi	a0,a0,1556 # 800075f8 <syscalls+0x168>
    80002fec:	cb6fd0ef          	jal	ra,800004a2 <printf>
  return 0;
    80002ff0:	4501                	li	a0,0
}
    80002ff2:	60a6                	ld	ra,72(sp)
    80002ff4:	6406                	ld	s0,64(sp)
    80002ff6:	74e2                	ld	s1,56(sp)
    80002ff8:	7942                	ld	s2,48(sp)
    80002ffa:	79a2                	ld	s3,40(sp)
    80002ffc:	7a02                	ld	s4,32(sp)
    80002ffe:	6ae2                	ld	s5,24(sp)
    80003000:	6b42                	ld	s6,16(sp)
    80003002:	6ba2                	ld	s7,8(sp)
    80003004:	6161                	addi	sp,sp,80
    80003006:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003008:	04000613          	li	a2,64
    8000300c:	4581                	li	a1,0
    8000300e:	854e                	mv	a0,s3
    80003010:	c57fd0ef          	jal	ra,80000c66 <memset>
      dip->type = type;
    80003014:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003018:	854a                	mv	a0,s2
    8000301a:	2d9000ef          	jal	ra,80003af2 <log_write>
      brelse(bp);
    8000301e:	854a                	mv	a0,s2
    80003020:	aa9ff0ef          	jal	ra,80002ac8 <brelse>
      return iget(dev, inum);
    80003024:	85da                	mv	a1,s6
    80003026:	8556                	mv	a0,s5
    80003028:	de1ff0ef          	jal	ra,80002e08 <iget>
    8000302c:	b7d9                	j	80002ff2 <ialloc+0x7a>

000000008000302e <iupdate>:
{
    8000302e:	1101                	addi	sp,sp,-32
    80003030:	ec06                	sd	ra,24(sp)
    80003032:	e822                	sd	s0,16(sp)
    80003034:	e426                	sd	s1,8(sp)
    80003036:	e04a                	sd	s2,0(sp)
    80003038:	1000                	addi	s0,sp,32
    8000303a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000303c:	415c                	lw	a5,4(a0)
    8000303e:	0047d79b          	srliw	a5,a5,0x4
    80003042:	0001b597          	auipc	a1,0x1b
    80003046:	f0e5a583          	lw	a1,-242(a1) # 8001df50 <sb+0x18>
    8000304a:	9dbd                	addw	a1,a1,a5
    8000304c:	4108                	lw	a0,0(a0)
    8000304e:	973ff0ef          	jal	ra,800029c0 <bread>
    80003052:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003054:	05850793          	addi	a5,a0,88
    80003058:	40c8                	lw	a0,4(s1)
    8000305a:	893d                	andi	a0,a0,15
    8000305c:	051a                	slli	a0,a0,0x6
    8000305e:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003060:	04449703          	lh	a4,68(s1)
    80003064:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003068:	04649703          	lh	a4,70(s1)
    8000306c:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003070:	04849703          	lh	a4,72(s1)
    80003074:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003078:	04a49703          	lh	a4,74(s1)
    8000307c:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003080:	44f8                	lw	a4,76(s1)
    80003082:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003084:	03400613          	li	a2,52
    80003088:	05048593          	addi	a1,s1,80
    8000308c:	0531                	addi	a0,a0,12
    8000308e:	c35fd0ef          	jal	ra,80000cc2 <memmove>
  log_write(bp);
    80003092:	854a                	mv	a0,s2
    80003094:	25f000ef          	jal	ra,80003af2 <log_write>
  brelse(bp);
    80003098:	854a                	mv	a0,s2
    8000309a:	a2fff0ef          	jal	ra,80002ac8 <brelse>
}
    8000309e:	60e2                	ld	ra,24(sp)
    800030a0:	6442                	ld	s0,16(sp)
    800030a2:	64a2                	ld	s1,8(sp)
    800030a4:	6902                	ld	s2,0(sp)
    800030a6:	6105                	addi	sp,sp,32
    800030a8:	8082                	ret

00000000800030aa <idup>:
{
    800030aa:	1101                	addi	sp,sp,-32
    800030ac:	ec06                	sd	ra,24(sp)
    800030ae:	e822                	sd	s0,16(sp)
    800030b0:	e426                	sd	s1,8(sp)
    800030b2:	1000                	addi	s0,sp,32
    800030b4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800030b6:	0001b517          	auipc	a0,0x1b
    800030ba:	ea250513          	addi	a0,a0,-350 # 8001df58 <itable>
    800030be:	ad5fd0ef          	jal	ra,80000b92 <acquire>
  ip->ref++;
    800030c2:	449c                	lw	a5,8(s1)
    800030c4:	2785                	addiw	a5,a5,1
    800030c6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800030c8:	0001b517          	auipc	a0,0x1b
    800030cc:	e9050513          	addi	a0,a0,-368 # 8001df58 <itable>
    800030d0:	b5bfd0ef          	jal	ra,80000c2a <release>
}
    800030d4:	8526                	mv	a0,s1
    800030d6:	60e2                	ld	ra,24(sp)
    800030d8:	6442                	ld	s0,16(sp)
    800030da:	64a2                	ld	s1,8(sp)
    800030dc:	6105                	addi	sp,sp,32
    800030de:	8082                	ret

00000000800030e0 <ilock>:
{
    800030e0:	1101                	addi	sp,sp,-32
    800030e2:	ec06                	sd	ra,24(sp)
    800030e4:	e822                	sd	s0,16(sp)
    800030e6:	e426                	sd	s1,8(sp)
    800030e8:	e04a                	sd	s2,0(sp)
    800030ea:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800030ec:	c105                	beqz	a0,8000310c <ilock+0x2c>
    800030ee:	84aa                	mv	s1,a0
    800030f0:	451c                	lw	a5,8(a0)
    800030f2:	00f05d63          	blez	a5,8000310c <ilock+0x2c>
  acquiresleep(&ip->lock);
    800030f6:	0541                	addi	a0,a0,16
    800030f8:	303000ef          	jal	ra,80003bfa <acquiresleep>
  if(ip->valid == 0){
    800030fc:	40bc                	lw	a5,64(s1)
    800030fe:	cf89                	beqz	a5,80003118 <ilock+0x38>
}
    80003100:	60e2                	ld	ra,24(sp)
    80003102:	6442                	ld	s0,16(sp)
    80003104:	64a2                	ld	s1,8(sp)
    80003106:	6902                	ld	s2,0(sp)
    80003108:	6105                	addi	sp,sp,32
    8000310a:	8082                	ret
    panic("ilock");
    8000310c:	00004517          	auipc	a0,0x4
    80003110:	50450513          	addi	a0,a0,1284 # 80007610 <syscalls+0x180>
    80003114:	e42fd0ef          	jal	ra,80000756 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003118:	40dc                	lw	a5,4(s1)
    8000311a:	0047d79b          	srliw	a5,a5,0x4
    8000311e:	0001b597          	auipc	a1,0x1b
    80003122:	e325a583          	lw	a1,-462(a1) # 8001df50 <sb+0x18>
    80003126:	9dbd                	addw	a1,a1,a5
    80003128:	4088                	lw	a0,0(s1)
    8000312a:	897ff0ef          	jal	ra,800029c0 <bread>
    8000312e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003130:	05850593          	addi	a1,a0,88
    80003134:	40dc                	lw	a5,4(s1)
    80003136:	8bbd                	andi	a5,a5,15
    80003138:	079a                	slli	a5,a5,0x6
    8000313a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000313c:	00059783          	lh	a5,0(a1)
    80003140:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003144:	00259783          	lh	a5,2(a1)
    80003148:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000314c:	00459783          	lh	a5,4(a1)
    80003150:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003154:	00659783          	lh	a5,6(a1)
    80003158:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000315c:	459c                	lw	a5,8(a1)
    8000315e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003160:	03400613          	li	a2,52
    80003164:	05b1                	addi	a1,a1,12
    80003166:	05048513          	addi	a0,s1,80
    8000316a:	b59fd0ef          	jal	ra,80000cc2 <memmove>
    brelse(bp);
    8000316e:	854a                	mv	a0,s2
    80003170:	959ff0ef          	jal	ra,80002ac8 <brelse>
    ip->valid = 1;
    80003174:	4785                	li	a5,1
    80003176:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003178:	04449783          	lh	a5,68(s1)
    8000317c:	f3d1                	bnez	a5,80003100 <ilock+0x20>
      panic("ilock: no type");
    8000317e:	00004517          	auipc	a0,0x4
    80003182:	49a50513          	addi	a0,a0,1178 # 80007618 <syscalls+0x188>
    80003186:	dd0fd0ef          	jal	ra,80000756 <panic>

000000008000318a <iunlock>:
{
    8000318a:	1101                	addi	sp,sp,-32
    8000318c:	ec06                	sd	ra,24(sp)
    8000318e:	e822                	sd	s0,16(sp)
    80003190:	e426                	sd	s1,8(sp)
    80003192:	e04a                	sd	s2,0(sp)
    80003194:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003196:	c505                	beqz	a0,800031be <iunlock+0x34>
    80003198:	84aa                	mv	s1,a0
    8000319a:	01050913          	addi	s2,a0,16
    8000319e:	854a                	mv	a0,s2
    800031a0:	2d9000ef          	jal	ra,80003c78 <holdingsleep>
    800031a4:	cd09                	beqz	a0,800031be <iunlock+0x34>
    800031a6:	449c                	lw	a5,8(s1)
    800031a8:	00f05b63          	blez	a5,800031be <iunlock+0x34>
  releasesleep(&ip->lock);
    800031ac:	854a                	mv	a0,s2
    800031ae:	293000ef          	jal	ra,80003c40 <releasesleep>
}
    800031b2:	60e2                	ld	ra,24(sp)
    800031b4:	6442                	ld	s0,16(sp)
    800031b6:	64a2                	ld	s1,8(sp)
    800031b8:	6902                	ld	s2,0(sp)
    800031ba:	6105                	addi	sp,sp,32
    800031bc:	8082                	ret
    panic("iunlock");
    800031be:	00004517          	auipc	a0,0x4
    800031c2:	46a50513          	addi	a0,a0,1130 # 80007628 <syscalls+0x198>
    800031c6:	d90fd0ef          	jal	ra,80000756 <panic>

00000000800031ca <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800031ca:	7179                	addi	sp,sp,-48
    800031cc:	f406                	sd	ra,40(sp)
    800031ce:	f022                	sd	s0,32(sp)
    800031d0:	ec26                	sd	s1,24(sp)
    800031d2:	e84a                	sd	s2,16(sp)
    800031d4:	e44e                	sd	s3,8(sp)
    800031d6:	e052                	sd	s4,0(sp)
    800031d8:	1800                	addi	s0,sp,48
    800031da:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800031dc:	05050493          	addi	s1,a0,80
    800031e0:	08050913          	addi	s2,a0,128
    800031e4:	a021                	j	800031ec <itrunc+0x22>
    800031e6:	0491                	addi	s1,s1,4
    800031e8:	01248b63          	beq	s1,s2,800031fe <itrunc+0x34>
    if(ip->addrs[i]){
    800031ec:	408c                	lw	a1,0(s1)
    800031ee:	dde5                	beqz	a1,800031e6 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800031f0:	0009a503          	lw	a0,0(s3)
    800031f4:	9c7ff0ef          	jal	ra,80002bba <bfree>
      ip->addrs[i] = 0;
    800031f8:	0004a023          	sw	zero,0(s1)
    800031fc:	b7ed                	j	800031e6 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800031fe:	0809a583          	lw	a1,128(s3)
    80003202:	ed91                	bnez	a1,8000321e <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003204:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003208:	854e                	mv	a0,s3
    8000320a:	e25ff0ef          	jal	ra,8000302e <iupdate>
}
    8000320e:	70a2                	ld	ra,40(sp)
    80003210:	7402                	ld	s0,32(sp)
    80003212:	64e2                	ld	s1,24(sp)
    80003214:	6942                	ld	s2,16(sp)
    80003216:	69a2                	ld	s3,8(sp)
    80003218:	6a02                	ld	s4,0(sp)
    8000321a:	6145                	addi	sp,sp,48
    8000321c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000321e:	0009a503          	lw	a0,0(s3)
    80003222:	f9eff0ef          	jal	ra,800029c0 <bread>
    80003226:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003228:	05850493          	addi	s1,a0,88
    8000322c:	45850913          	addi	s2,a0,1112
    80003230:	a021                	j	80003238 <itrunc+0x6e>
    80003232:	0491                	addi	s1,s1,4
    80003234:	01248963          	beq	s1,s2,80003246 <itrunc+0x7c>
      if(a[j])
    80003238:	408c                	lw	a1,0(s1)
    8000323a:	dde5                	beqz	a1,80003232 <itrunc+0x68>
        bfree(ip->dev, a[j]);
    8000323c:	0009a503          	lw	a0,0(s3)
    80003240:	97bff0ef          	jal	ra,80002bba <bfree>
    80003244:	b7fd                	j	80003232 <itrunc+0x68>
    brelse(bp);
    80003246:	8552                	mv	a0,s4
    80003248:	881ff0ef          	jal	ra,80002ac8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000324c:	0809a583          	lw	a1,128(s3)
    80003250:	0009a503          	lw	a0,0(s3)
    80003254:	967ff0ef          	jal	ra,80002bba <bfree>
    ip->addrs[NDIRECT] = 0;
    80003258:	0809a023          	sw	zero,128(s3)
    8000325c:	b765                	j	80003204 <itrunc+0x3a>

000000008000325e <iput>:
{
    8000325e:	1101                	addi	sp,sp,-32
    80003260:	ec06                	sd	ra,24(sp)
    80003262:	e822                	sd	s0,16(sp)
    80003264:	e426                	sd	s1,8(sp)
    80003266:	e04a                	sd	s2,0(sp)
    80003268:	1000                	addi	s0,sp,32
    8000326a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000326c:	0001b517          	auipc	a0,0x1b
    80003270:	cec50513          	addi	a0,a0,-788 # 8001df58 <itable>
    80003274:	91ffd0ef          	jal	ra,80000b92 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003278:	4498                	lw	a4,8(s1)
    8000327a:	4785                	li	a5,1
    8000327c:	02f70163          	beq	a4,a5,8000329e <iput+0x40>
  ip->ref--;
    80003280:	449c                	lw	a5,8(s1)
    80003282:	37fd                	addiw	a5,a5,-1
    80003284:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003286:	0001b517          	auipc	a0,0x1b
    8000328a:	cd250513          	addi	a0,a0,-814 # 8001df58 <itable>
    8000328e:	99dfd0ef          	jal	ra,80000c2a <release>
}
    80003292:	60e2                	ld	ra,24(sp)
    80003294:	6442                	ld	s0,16(sp)
    80003296:	64a2                	ld	s1,8(sp)
    80003298:	6902                	ld	s2,0(sp)
    8000329a:	6105                	addi	sp,sp,32
    8000329c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000329e:	40bc                	lw	a5,64(s1)
    800032a0:	d3e5                	beqz	a5,80003280 <iput+0x22>
    800032a2:	04a49783          	lh	a5,74(s1)
    800032a6:	ffe9                	bnez	a5,80003280 <iput+0x22>
    acquiresleep(&ip->lock);
    800032a8:	01048913          	addi	s2,s1,16
    800032ac:	854a                	mv	a0,s2
    800032ae:	14d000ef          	jal	ra,80003bfa <acquiresleep>
    release(&itable.lock);
    800032b2:	0001b517          	auipc	a0,0x1b
    800032b6:	ca650513          	addi	a0,a0,-858 # 8001df58 <itable>
    800032ba:	971fd0ef          	jal	ra,80000c2a <release>
    itrunc(ip);
    800032be:	8526                	mv	a0,s1
    800032c0:	f0bff0ef          	jal	ra,800031ca <itrunc>
    ip->type = 0;
    800032c4:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800032c8:	8526                	mv	a0,s1
    800032ca:	d65ff0ef          	jal	ra,8000302e <iupdate>
    ip->valid = 0;
    800032ce:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800032d2:	854a                	mv	a0,s2
    800032d4:	16d000ef          	jal	ra,80003c40 <releasesleep>
    acquire(&itable.lock);
    800032d8:	0001b517          	auipc	a0,0x1b
    800032dc:	c8050513          	addi	a0,a0,-896 # 8001df58 <itable>
    800032e0:	8b3fd0ef          	jal	ra,80000b92 <acquire>
    800032e4:	bf71                	j	80003280 <iput+0x22>

00000000800032e6 <iunlockput>:
{
    800032e6:	1101                	addi	sp,sp,-32
    800032e8:	ec06                	sd	ra,24(sp)
    800032ea:	e822                	sd	s0,16(sp)
    800032ec:	e426                	sd	s1,8(sp)
    800032ee:	1000                	addi	s0,sp,32
    800032f0:	84aa                	mv	s1,a0
  iunlock(ip);
    800032f2:	e99ff0ef          	jal	ra,8000318a <iunlock>
  iput(ip);
    800032f6:	8526                	mv	a0,s1
    800032f8:	f67ff0ef          	jal	ra,8000325e <iput>
}
    800032fc:	60e2                	ld	ra,24(sp)
    800032fe:	6442                	ld	s0,16(sp)
    80003300:	64a2                	ld	s1,8(sp)
    80003302:	6105                	addi	sp,sp,32
    80003304:	8082                	ret

0000000080003306 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003306:	1141                	addi	sp,sp,-16
    80003308:	e422                	sd	s0,8(sp)
    8000330a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000330c:	411c                	lw	a5,0(a0)
    8000330e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003310:	415c                	lw	a5,4(a0)
    80003312:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003314:	04451783          	lh	a5,68(a0)
    80003318:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000331c:	04a51783          	lh	a5,74(a0)
    80003320:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003324:	04c56783          	lwu	a5,76(a0)
    80003328:	e99c                	sd	a5,16(a1)
}
    8000332a:	6422                	ld	s0,8(sp)
    8000332c:	0141                	addi	sp,sp,16
    8000332e:	8082                	ret

0000000080003330 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003330:	457c                	lw	a5,76(a0)
    80003332:	0cd7ef63          	bltu	a5,a3,80003410 <readi+0xe0>
{
    80003336:	7159                	addi	sp,sp,-112
    80003338:	f486                	sd	ra,104(sp)
    8000333a:	f0a2                	sd	s0,96(sp)
    8000333c:	eca6                	sd	s1,88(sp)
    8000333e:	e8ca                	sd	s2,80(sp)
    80003340:	e4ce                	sd	s3,72(sp)
    80003342:	e0d2                	sd	s4,64(sp)
    80003344:	fc56                	sd	s5,56(sp)
    80003346:	f85a                	sd	s6,48(sp)
    80003348:	f45e                	sd	s7,40(sp)
    8000334a:	f062                	sd	s8,32(sp)
    8000334c:	ec66                	sd	s9,24(sp)
    8000334e:	e86a                	sd	s10,16(sp)
    80003350:	e46e                	sd	s11,8(sp)
    80003352:	1880                	addi	s0,sp,112
    80003354:	8b2a                	mv	s6,a0
    80003356:	8bae                	mv	s7,a1
    80003358:	8a32                	mv	s4,a2
    8000335a:	84b6                	mv	s1,a3
    8000335c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000335e:	9f35                	addw	a4,a4,a3
    return 0;
    80003360:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003362:	08d76663          	bltu	a4,a3,800033ee <readi+0xbe>
  if(off + n > ip->size)
    80003366:	00e7f463          	bgeu	a5,a4,8000336e <readi+0x3e>
    n = ip->size - off;
    8000336a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000336e:	080a8f63          	beqz	s5,8000340c <readi+0xdc>
    80003372:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003374:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003378:	5c7d                	li	s8,-1
    8000337a:	a80d                	j	800033ac <readi+0x7c>
    8000337c:	020d1d93          	slli	s11,s10,0x20
    80003380:	020ddd93          	srli	s11,s11,0x20
    80003384:	05890793          	addi	a5,s2,88
    80003388:	86ee                	mv	a3,s11
    8000338a:	963e                	add	a2,a2,a5
    8000338c:	85d2                	mv	a1,s4
    8000338e:	855e                	mv	a0,s7
    80003390:	dbbfe0ef          	jal	ra,8000214a <either_copyout>
    80003394:	05850763          	beq	a0,s8,800033e2 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003398:	854a                	mv	a0,s2
    8000339a:	f2eff0ef          	jal	ra,80002ac8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000339e:	013d09bb          	addw	s3,s10,s3
    800033a2:	009d04bb          	addw	s1,s10,s1
    800033a6:	9a6e                	add	s4,s4,s11
    800033a8:	0559f163          	bgeu	s3,s5,800033ea <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    800033ac:	00a4d59b          	srliw	a1,s1,0xa
    800033b0:	855a                	mv	a0,s6
    800033b2:	989ff0ef          	jal	ra,80002d3a <bmap>
    800033b6:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800033ba:	c985                	beqz	a1,800033ea <readi+0xba>
    bp = bread(ip->dev, addr);
    800033bc:	000b2503          	lw	a0,0(s6)
    800033c0:	e00ff0ef          	jal	ra,800029c0 <bread>
    800033c4:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800033c6:	3ff4f613          	andi	a2,s1,1023
    800033ca:	40cc87bb          	subw	a5,s9,a2
    800033ce:	413a873b          	subw	a4,s5,s3
    800033d2:	8d3e                	mv	s10,a5
    800033d4:	2781                	sext.w	a5,a5
    800033d6:	0007069b          	sext.w	a3,a4
    800033da:	faf6f1e3          	bgeu	a3,a5,8000337c <readi+0x4c>
    800033de:	8d3a                	mv	s10,a4
    800033e0:	bf71                	j	8000337c <readi+0x4c>
      brelse(bp);
    800033e2:	854a                	mv	a0,s2
    800033e4:	ee4ff0ef          	jal	ra,80002ac8 <brelse>
      tot = -1;
    800033e8:	59fd                	li	s3,-1
  }
  return tot;
    800033ea:	0009851b          	sext.w	a0,s3
}
    800033ee:	70a6                	ld	ra,104(sp)
    800033f0:	7406                	ld	s0,96(sp)
    800033f2:	64e6                	ld	s1,88(sp)
    800033f4:	6946                	ld	s2,80(sp)
    800033f6:	69a6                	ld	s3,72(sp)
    800033f8:	6a06                	ld	s4,64(sp)
    800033fa:	7ae2                	ld	s5,56(sp)
    800033fc:	7b42                	ld	s6,48(sp)
    800033fe:	7ba2                	ld	s7,40(sp)
    80003400:	7c02                	ld	s8,32(sp)
    80003402:	6ce2                	ld	s9,24(sp)
    80003404:	6d42                	ld	s10,16(sp)
    80003406:	6da2                	ld	s11,8(sp)
    80003408:	6165                	addi	sp,sp,112
    8000340a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000340c:	89d6                	mv	s3,s5
    8000340e:	bff1                	j	800033ea <readi+0xba>
    return 0;
    80003410:	4501                	li	a0,0
}
    80003412:	8082                	ret

0000000080003414 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003414:	457c                	lw	a5,76(a0)
    80003416:	0ed7ea63          	bltu	a5,a3,8000350a <writei+0xf6>
{
    8000341a:	7159                	addi	sp,sp,-112
    8000341c:	f486                	sd	ra,104(sp)
    8000341e:	f0a2                	sd	s0,96(sp)
    80003420:	eca6                	sd	s1,88(sp)
    80003422:	e8ca                	sd	s2,80(sp)
    80003424:	e4ce                	sd	s3,72(sp)
    80003426:	e0d2                	sd	s4,64(sp)
    80003428:	fc56                	sd	s5,56(sp)
    8000342a:	f85a                	sd	s6,48(sp)
    8000342c:	f45e                	sd	s7,40(sp)
    8000342e:	f062                	sd	s8,32(sp)
    80003430:	ec66                	sd	s9,24(sp)
    80003432:	e86a                	sd	s10,16(sp)
    80003434:	e46e                	sd	s11,8(sp)
    80003436:	1880                	addi	s0,sp,112
    80003438:	8aaa                	mv	s5,a0
    8000343a:	8bae                	mv	s7,a1
    8000343c:	8a32                	mv	s4,a2
    8000343e:	8936                	mv	s2,a3
    80003440:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003442:	00e687bb          	addw	a5,a3,a4
    80003446:	0cd7e463          	bltu	a5,a3,8000350e <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000344a:	00043737          	lui	a4,0x43
    8000344e:	0cf76263          	bltu	a4,a5,80003512 <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003452:	0a0b0a63          	beqz	s6,80003506 <writei+0xf2>
    80003456:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003458:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000345c:	5c7d                	li	s8,-1
    8000345e:	a825                	j	80003496 <writei+0x82>
    80003460:	020d1d93          	slli	s11,s10,0x20
    80003464:	020ddd93          	srli	s11,s11,0x20
    80003468:	05848793          	addi	a5,s1,88
    8000346c:	86ee                	mv	a3,s11
    8000346e:	8652                	mv	a2,s4
    80003470:	85de                	mv	a1,s7
    80003472:	953e                	add	a0,a0,a5
    80003474:	d21fe0ef          	jal	ra,80002194 <either_copyin>
    80003478:	05850a63          	beq	a0,s8,800034cc <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000347c:	8526                	mv	a0,s1
    8000347e:	674000ef          	jal	ra,80003af2 <log_write>
    brelse(bp);
    80003482:	8526                	mv	a0,s1
    80003484:	e44ff0ef          	jal	ra,80002ac8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003488:	013d09bb          	addw	s3,s10,s3
    8000348c:	012d093b          	addw	s2,s10,s2
    80003490:	9a6e                	add	s4,s4,s11
    80003492:	0569f063          	bgeu	s3,s6,800034d2 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003496:	00a9559b          	srliw	a1,s2,0xa
    8000349a:	8556                	mv	a0,s5
    8000349c:	89fff0ef          	jal	ra,80002d3a <bmap>
    800034a0:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800034a4:	c59d                	beqz	a1,800034d2 <writei+0xbe>
    bp = bread(ip->dev, addr);
    800034a6:	000aa503          	lw	a0,0(s5)
    800034aa:	d16ff0ef          	jal	ra,800029c0 <bread>
    800034ae:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800034b0:	3ff97513          	andi	a0,s2,1023
    800034b4:	40ac87bb          	subw	a5,s9,a0
    800034b8:	413b073b          	subw	a4,s6,s3
    800034bc:	8d3e                	mv	s10,a5
    800034be:	2781                	sext.w	a5,a5
    800034c0:	0007069b          	sext.w	a3,a4
    800034c4:	f8f6fee3          	bgeu	a3,a5,80003460 <writei+0x4c>
    800034c8:	8d3a                	mv	s10,a4
    800034ca:	bf59                	j	80003460 <writei+0x4c>
      brelse(bp);
    800034cc:	8526                	mv	a0,s1
    800034ce:	dfaff0ef          	jal	ra,80002ac8 <brelse>
  }

  if(off > ip->size)
    800034d2:	04caa783          	lw	a5,76(s5)
    800034d6:	0127f463          	bgeu	a5,s2,800034de <writei+0xca>
    ip->size = off;
    800034da:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800034de:	8556                	mv	a0,s5
    800034e0:	b4fff0ef          	jal	ra,8000302e <iupdate>

  return tot;
    800034e4:	0009851b          	sext.w	a0,s3
}
    800034e8:	70a6                	ld	ra,104(sp)
    800034ea:	7406                	ld	s0,96(sp)
    800034ec:	64e6                	ld	s1,88(sp)
    800034ee:	6946                	ld	s2,80(sp)
    800034f0:	69a6                	ld	s3,72(sp)
    800034f2:	6a06                	ld	s4,64(sp)
    800034f4:	7ae2                	ld	s5,56(sp)
    800034f6:	7b42                	ld	s6,48(sp)
    800034f8:	7ba2                	ld	s7,40(sp)
    800034fa:	7c02                	ld	s8,32(sp)
    800034fc:	6ce2                	ld	s9,24(sp)
    800034fe:	6d42                	ld	s10,16(sp)
    80003500:	6da2                	ld	s11,8(sp)
    80003502:	6165                	addi	sp,sp,112
    80003504:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003506:	89da                	mv	s3,s6
    80003508:	bfd9                	j	800034de <writei+0xca>
    return -1;
    8000350a:	557d                	li	a0,-1
}
    8000350c:	8082                	ret
    return -1;
    8000350e:	557d                	li	a0,-1
    80003510:	bfe1                	j	800034e8 <writei+0xd4>
    return -1;
    80003512:	557d                	li	a0,-1
    80003514:	bfd1                	j	800034e8 <writei+0xd4>

0000000080003516 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003516:	1141                	addi	sp,sp,-16
    80003518:	e406                	sd	ra,8(sp)
    8000351a:	e022                	sd	s0,0(sp)
    8000351c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000351e:	4639                	li	a2,14
    80003520:	813fd0ef          	jal	ra,80000d32 <strncmp>
}
    80003524:	60a2                	ld	ra,8(sp)
    80003526:	6402                	ld	s0,0(sp)
    80003528:	0141                	addi	sp,sp,16
    8000352a:	8082                	ret

000000008000352c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000352c:	7139                	addi	sp,sp,-64
    8000352e:	fc06                	sd	ra,56(sp)
    80003530:	f822                	sd	s0,48(sp)
    80003532:	f426                	sd	s1,40(sp)
    80003534:	f04a                	sd	s2,32(sp)
    80003536:	ec4e                	sd	s3,24(sp)
    80003538:	e852                	sd	s4,16(sp)
    8000353a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000353c:	04451703          	lh	a4,68(a0)
    80003540:	4785                	li	a5,1
    80003542:	00f71a63          	bne	a4,a5,80003556 <dirlookup+0x2a>
    80003546:	892a                	mv	s2,a0
    80003548:	89ae                	mv	s3,a1
    8000354a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000354c:	457c                	lw	a5,76(a0)
    8000354e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003550:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003552:	e39d                	bnez	a5,80003578 <dirlookup+0x4c>
    80003554:	a095                	j	800035b8 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003556:	00004517          	auipc	a0,0x4
    8000355a:	0da50513          	addi	a0,a0,218 # 80007630 <syscalls+0x1a0>
    8000355e:	9f8fd0ef          	jal	ra,80000756 <panic>
      panic("dirlookup read");
    80003562:	00004517          	auipc	a0,0x4
    80003566:	0e650513          	addi	a0,a0,230 # 80007648 <syscalls+0x1b8>
    8000356a:	9ecfd0ef          	jal	ra,80000756 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000356e:	24c1                	addiw	s1,s1,16
    80003570:	04c92783          	lw	a5,76(s2)
    80003574:	04f4f163          	bgeu	s1,a5,800035b6 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003578:	4741                	li	a4,16
    8000357a:	86a6                	mv	a3,s1
    8000357c:	fc040613          	addi	a2,s0,-64
    80003580:	4581                	li	a1,0
    80003582:	854a                	mv	a0,s2
    80003584:	dadff0ef          	jal	ra,80003330 <readi>
    80003588:	47c1                	li	a5,16
    8000358a:	fcf51ce3          	bne	a0,a5,80003562 <dirlookup+0x36>
    if(de.inum == 0)
    8000358e:	fc045783          	lhu	a5,-64(s0)
    80003592:	dff1                	beqz	a5,8000356e <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003594:	fc240593          	addi	a1,s0,-62
    80003598:	854e                	mv	a0,s3
    8000359a:	f7dff0ef          	jal	ra,80003516 <namecmp>
    8000359e:	f961                	bnez	a0,8000356e <dirlookup+0x42>
      if(poff)
    800035a0:	000a0463          	beqz	s4,800035a8 <dirlookup+0x7c>
        *poff = off;
    800035a4:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800035a8:	fc045583          	lhu	a1,-64(s0)
    800035ac:	00092503          	lw	a0,0(s2)
    800035b0:	859ff0ef          	jal	ra,80002e08 <iget>
    800035b4:	a011                	j	800035b8 <dirlookup+0x8c>
  return 0;
    800035b6:	4501                	li	a0,0
}
    800035b8:	70e2                	ld	ra,56(sp)
    800035ba:	7442                	ld	s0,48(sp)
    800035bc:	74a2                	ld	s1,40(sp)
    800035be:	7902                	ld	s2,32(sp)
    800035c0:	69e2                	ld	s3,24(sp)
    800035c2:	6a42                	ld	s4,16(sp)
    800035c4:	6121                	addi	sp,sp,64
    800035c6:	8082                	ret

00000000800035c8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800035c8:	711d                	addi	sp,sp,-96
    800035ca:	ec86                	sd	ra,88(sp)
    800035cc:	e8a2                	sd	s0,80(sp)
    800035ce:	e4a6                	sd	s1,72(sp)
    800035d0:	e0ca                	sd	s2,64(sp)
    800035d2:	fc4e                	sd	s3,56(sp)
    800035d4:	f852                	sd	s4,48(sp)
    800035d6:	f456                	sd	s5,40(sp)
    800035d8:	f05a                	sd	s6,32(sp)
    800035da:	ec5e                	sd	s7,24(sp)
    800035dc:	e862                	sd	s8,16(sp)
    800035de:	e466                	sd	s9,8(sp)
    800035e0:	1080                	addi	s0,sp,96
    800035e2:	84aa                	mv	s1,a0
    800035e4:	8aae                	mv	s5,a1
    800035e6:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    800035e8:	00054703          	lbu	a4,0(a0)
    800035ec:	02f00793          	li	a5,47
    800035f0:	00f70f63          	beq	a4,a5,8000360e <namex+0x46>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800035f4:	a30fe0ef          	jal	ra,80001824 <myproc>
    800035f8:	15053503          	ld	a0,336(a0)
    800035fc:	aafff0ef          	jal	ra,800030aa <idup>
    80003600:	89aa                	mv	s3,a0
  while(*path == '/')
    80003602:	02f00913          	li	s2,47
  len = path - s;
    80003606:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003608:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000360a:	4b85                	li	s7,1
    8000360c:	a861                	j	800036a4 <namex+0xdc>
    ip = iget(ROOTDEV, ROOTINO);
    8000360e:	4585                	li	a1,1
    80003610:	4505                	li	a0,1
    80003612:	ff6ff0ef          	jal	ra,80002e08 <iget>
    80003616:	89aa                	mv	s3,a0
    80003618:	b7ed                	j	80003602 <namex+0x3a>
      iunlockput(ip);
    8000361a:	854e                	mv	a0,s3
    8000361c:	ccbff0ef          	jal	ra,800032e6 <iunlockput>
      return 0;
    80003620:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003622:	854e                	mv	a0,s3
    80003624:	60e6                	ld	ra,88(sp)
    80003626:	6446                	ld	s0,80(sp)
    80003628:	64a6                	ld	s1,72(sp)
    8000362a:	6906                	ld	s2,64(sp)
    8000362c:	79e2                	ld	s3,56(sp)
    8000362e:	7a42                	ld	s4,48(sp)
    80003630:	7aa2                	ld	s5,40(sp)
    80003632:	7b02                	ld	s6,32(sp)
    80003634:	6be2                	ld	s7,24(sp)
    80003636:	6c42                	ld	s8,16(sp)
    80003638:	6ca2                	ld	s9,8(sp)
    8000363a:	6125                	addi	sp,sp,96
    8000363c:	8082                	ret
      iunlock(ip);
    8000363e:	854e                	mv	a0,s3
    80003640:	b4bff0ef          	jal	ra,8000318a <iunlock>
      return ip;
    80003644:	bff9                	j	80003622 <namex+0x5a>
      iunlockput(ip);
    80003646:	854e                	mv	a0,s3
    80003648:	c9fff0ef          	jal	ra,800032e6 <iunlockput>
      return 0;
    8000364c:	89e6                	mv	s3,s9
    8000364e:	bfd1                	j	80003622 <namex+0x5a>
  len = path - s;
    80003650:	40b48633          	sub	a2,s1,a1
    80003654:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003658:	079c5c63          	bge	s8,s9,800036d0 <namex+0x108>
    memmove(name, s, DIRSIZ);
    8000365c:	4639                	li	a2,14
    8000365e:	8552                	mv	a0,s4
    80003660:	e62fd0ef          	jal	ra,80000cc2 <memmove>
  while(*path == '/')
    80003664:	0004c783          	lbu	a5,0(s1)
    80003668:	01279763          	bne	a5,s2,80003676 <namex+0xae>
    path++;
    8000366c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000366e:	0004c783          	lbu	a5,0(s1)
    80003672:	ff278de3          	beq	a5,s2,8000366c <namex+0xa4>
    ilock(ip);
    80003676:	854e                	mv	a0,s3
    80003678:	a69ff0ef          	jal	ra,800030e0 <ilock>
    if(ip->type != T_DIR){
    8000367c:	04499783          	lh	a5,68(s3)
    80003680:	f9779de3          	bne	a5,s7,8000361a <namex+0x52>
    if(nameiparent && *path == '\0'){
    80003684:	000a8563          	beqz	s5,8000368e <namex+0xc6>
    80003688:	0004c783          	lbu	a5,0(s1)
    8000368c:	dbcd                	beqz	a5,8000363e <namex+0x76>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000368e:	865a                	mv	a2,s6
    80003690:	85d2                	mv	a1,s4
    80003692:	854e                	mv	a0,s3
    80003694:	e99ff0ef          	jal	ra,8000352c <dirlookup>
    80003698:	8caa                	mv	s9,a0
    8000369a:	d555                	beqz	a0,80003646 <namex+0x7e>
    iunlockput(ip);
    8000369c:	854e                	mv	a0,s3
    8000369e:	c49ff0ef          	jal	ra,800032e6 <iunlockput>
    ip = next;
    800036a2:	89e6                	mv	s3,s9
  while(*path == '/')
    800036a4:	0004c783          	lbu	a5,0(s1)
    800036a8:	05279363          	bne	a5,s2,800036ee <namex+0x126>
    path++;
    800036ac:	0485                	addi	s1,s1,1
  while(*path == '/')
    800036ae:	0004c783          	lbu	a5,0(s1)
    800036b2:	ff278de3          	beq	a5,s2,800036ac <namex+0xe4>
  if(*path == 0)
    800036b6:	c78d                	beqz	a5,800036e0 <namex+0x118>
    path++;
    800036b8:	85a6                	mv	a1,s1
  len = path - s;
    800036ba:	8cda                	mv	s9,s6
    800036bc:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800036be:	01278963          	beq	a5,s2,800036d0 <namex+0x108>
    800036c2:	d7d9                	beqz	a5,80003650 <namex+0x88>
    path++;
    800036c4:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800036c6:	0004c783          	lbu	a5,0(s1)
    800036ca:	ff279ce3          	bne	a5,s2,800036c2 <namex+0xfa>
    800036ce:	b749                	j	80003650 <namex+0x88>
    memmove(name, s, len);
    800036d0:	2601                	sext.w	a2,a2
    800036d2:	8552                	mv	a0,s4
    800036d4:	deefd0ef          	jal	ra,80000cc2 <memmove>
    name[len] = 0;
    800036d8:	9cd2                	add	s9,s9,s4
    800036da:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800036de:	b759                	j	80003664 <namex+0x9c>
  if(nameiparent){
    800036e0:	f40a81e3          	beqz	s5,80003622 <namex+0x5a>
    iput(ip);
    800036e4:	854e                	mv	a0,s3
    800036e6:	b79ff0ef          	jal	ra,8000325e <iput>
    return 0;
    800036ea:	4981                	li	s3,0
    800036ec:	bf1d                	j	80003622 <namex+0x5a>
  if(*path == 0)
    800036ee:	dbed                	beqz	a5,800036e0 <namex+0x118>
  while(*path != '/' && *path != 0)
    800036f0:	0004c783          	lbu	a5,0(s1)
    800036f4:	85a6                	mv	a1,s1
    800036f6:	b7f1                	j	800036c2 <namex+0xfa>

00000000800036f8 <dirlink>:
{
    800036f8:	7139                	addi	sp,sp,-64
    800036fa:	fc06                	sd	ra,56(sp)
    800036fc:	f822                	sd	s0,48(sp)
    800036fe:	f426                	sd	s1,40(sp)
    80003700:	f04a                	sd	s2,32(sp)
    80003702:	ec4e                	sd	s3,24(sp)
    80003704:	e852                	sd	s4,16(sp)
    80003706:	0080                	addi	s0,sp,64
    80003708:	892a                	mv	s2,a0
    8000370a:	8a2e                	mv	s4,a1
    8000370c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000370e:	4601                	li	a2,0
    80003710:	e1dff0ef          	jal	ra,8000352c <dirlookup>
    80003714:	e52d                	bnez	a0,8000377e <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003716:	04c92483          	lw	s1,76(s2)
    8000371a:	c48d                	beqz	s1,80003744 <dirlink+0x4c>
    8000371c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000371e:	4741                	li	a4,16
    80003720:	86a6                	mv	a3,s1
    80003722:	fc040613          	addi	a2,s0,-64
    80003726:	4581                	li	a1,0
    80003728:	854a                	mv	a0,s2
    8000372a:	c07ff0ef          	jal	ra,80003330 <readi>
    8000372e:	47c1                	li	a5,16
    80003730:	04f51b63          	bne	a0,a5,80003786 <dirlink+0x8e>
    if(de.inum == 0)
    80003734:	fc045783          	lhu	a5,-64(s0)
    80003738:	c791                	beqz	a5,80003744 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000373a:	24c1                	addiw	s1,s1,16
    8000373c:	04c92783          	lw	a5,76(s2)
    80003740:	fcf4efe3          	bltu	s1,a5,8000371e <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003744:	4639                	li	a2,14
    80003746:	85d2                	mv	a1,s4
    80003748:	fc240513          	addi	a0,s0,-62
    8000374c:	e22fd0ef          	jal	ra,80000d6e <strncpy>
  de.inum = inum;
    80003750:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003754:	4741                	li	a4,16
    80003756:	86a6                	mv	a3,s1
    80003758:	fc040613          	addi	a2,s0,-64
    8000375c:	4581                	li	a1,0
    8000375e:	854a                	mv	a0,s2
    80003760:	cb5ff0ef          	jal	ra,80003414 <writei>
    80003764:	1541                	addi	a0,a0,-16
    80003766:	00a03533          	snez	a0,a0
    8000376a:	40a00533          	neg	a0,a0
}
    8000376e:	70e2                	ld	ra,56(sp)
    80003770:	7442                	ld	s0,48(sp)
    80003772:	74a2                	ld	s1,40(sp)
    80003774:	7902                	ld	s2,32(sp)
    80003776:	69e2                	ld	s3,24(sp)
    80003778:	6a42                	ld	s4,16(sp)
    8000377a:	6121                	addi	sp,sp,64
    8000377c:	8082                	ret
    iput(ip);
    8000377e:	ae1ff0ef          	jal	ra,8000325e <iput>
    return -1;
    80003782:	557d                	li	a0,-1
    80003784:	b7ed                	j	8000376e <dirlink+0x76>
      panic("dirlink read");
    80003786:	00004517          	auipc	a0,0x4
    8000378a:	ed250513          	addi	a0,a0,-302 # 80007658 <syscalls+0x1c8>
    8000378e:	fc9fc0ef          	jal	ra,80000756 <panic>

0000000080003792 <namei>:

struct inode*
namei(char *path)
{
    80003792:	1101                	addi	sp,sp,-32
    80003794:	ec06                	sd	ra,24(sp)
    80003796:	e822                	sd	s0,16(sp)
    80003798:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000379a:	fe040613          	addi	a2,s0,-32
    8000379e:	4581                	li	a1,0
    800037a0:	e29ff0ef          	jal	ra,800035c8 <namex>
}
    800037a4:	60e2                	ld	ra,24(sp)
    800037a6:	6442                	ld	s0,16(sp)
    800037a8:	6105                	addi	sp,sp,32
    800037aa:	8082                	ret

00000000800037ac <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800037ac:	1141                	addi	sp,sp,-16
    800037ae:	e406                	sd	ra,8(sp)
    800037b0:	e022                	sd	s0,0(sp)
    800037b2:	0800                	addi	s0,sp,16
    800037b4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800037b6:	4585                	li	a1,1
    800037b8:	e11ff0ef          	jal	ra,800035c8 <namex>
}
    800037bc:	60a2                	ld	ra,8(sp)
    800037be:	6402                	ld	s0,0(sp)
    800037c0:	0141                	addi	sp,sp,16
    800037c2:	8082                	ret

00000000800037c4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800037c4:	1101                	addi	sp,sp,-32
    800037c6:	ec06                	sd	ra,24(sp)
    800037c8:	e822                	sd	s0,16(sp)
    800037ca:	e426                	sd	s1,8(sp)
    800037cc:	e04a                	sd	s2,0(sp)
    800037ce:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800037d0:	0001c917          	auipc	s2,0x1c
    800037d4:	23090913          	addi	s2,s2,560 # 8001fa00 <log>
    800037d8:	01892583          	lw	a1,24(s2)
    800037dc:	02892503          	lw	a0,40(s2)
    800037e0:	9e0ff0ef          	jal	ra,800029c0 <bread>
    800037e4:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800037e6:	02c92683          	lw	a3,44(s2)
    800037ea:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800037ec:	02d05863          	blez	a3,8000381c <write_head+0x58>
    800037f0:	0001c797          	auipc	a5,0x1c
    800037f4:	24078793          	addi	a5,a5,576 # 8001fa30 <log+0x30>
    800037f8:	05c50713          	addi	a4,a0,92
    800037fc:	36fd                	addiw	a3,a3,-1
    800037fe:	02069613          	slli	a2,a3,0x20
    80003802:	01e65693          	srli	a3,a2,0x1e
    80003806:	0001c617          	auipc	a2,0x1c
    8000380a:	22e60613          	addi	a2,a2,558 # 8001fa34 <log+0x34>
    8000380e:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003810:	4390                	lw	a2,0(a5)
    80003812:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003814:	0791                	addi	a5,a5,4
    80003816:	0711                	addi	a4,a4,4
    80003818:	fed79ce3          	bne	a5,a3,80003810 <write_head+0x4c>
  }
  bwrite(buf);
    8000381c:	8526                	mv	a0,s1
    8000381e:	a78ff0ef          	jal	ra,80002a96 <bwrite>
  brelse(buf);
    80003822:	8526                	mv	a0,s1
    80003824:	aa4ff0ef          	jal	ra,80002ac8 <brelse>
}
    80003828:	60e2                	ld	ra,24(sp)
    8000382a:	6442                	ld	s0,16(sp)
    8000382c:	64a2                	ld	s1,8(sp)
    8000382e:	6902                	ld	s2,0(sp)
    80003830:	6105                	addi	sp,sp,32
    80003832:	8082                	ret

0000000080003834 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003834:	0001c797          	auipc	a5,0x1c
    80003838:	1f87a783          	lw	a5,504(a5) # 8001fa2c <log+0x2c>
    8000383c:	08f05f63          	blez	a5,800038da <install_trans+0xa6>
{
    80003840:	7139                	addi	sp,sp,-64
    80003842:	fc06                	sd	ra,56(sp)
    80003844:	f822                	sd	s0,48(sp)
    80003846:	f426                	sd	s1,40(sp)
    80003848:	f04a                	sd	s2,32(sp)
    8000384a:	ec4e                	sd	s3,24(sp)
    8000384c:	e852                	sd	s4,16(sp)
    8000384e:	e456                	sd	s5,8(sp)
    80003850:	e05a                	sd	s6,0(sp)
    80003852:	0080                	addi	s0,sp,64
    80003854:	8b2a                	mv	s6,a0
    80003856:	0001ca97          	auipc	s5,0x1c
    8000385a:	1daa8a93          	addi	s5,s5,474 # 8001fa30 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000385e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003860:	0001c997          	auipc	s3,0x1c
    80003864:	1a098993          	addi	s3,s3,416 # 8001fa00 <log>
    80003868:	a829                	j	80003882 <install_trans+0x4e>
    brelse(lbuf);
    8000386a:	854a                	mv	a0,s2
    8000386c:	a5cff0ef          	jal	ra,80002ac8 <brelse>
    brelse(dbuf);
    80003870:	8526                	mv	a0,s1
    80003872:	a56ff0ef          	jal	ra,80002ac8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003876:	2a05                	addiw	s4,s4,1
    80003878:	0a91                	addi	s5,s5,4
    8000387a:	02c9a783          	lw	a5,44(s3)
    8000387e:	04fa5463          	bge	s4,a5,800038c6 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003882:	0189a583          	lw	a1,24(s3)
    80003886:	014585bb          	addw	a1,a1,s4
    8000388a:	2585                	addiw	a1,a1,1
    8000388c:	0289a503          	lw	a0,40(s3)
    80003890:	930ff0ef          	jal	ra,800029c0 <bread>
    80003894:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003896:	000aa583          	lw	a1,0(s5)
    8000389a:	0289a503          	lw	a0,40(s3)
    8000389e:	922ff0ef          	jal	ra,800029c0 <bread>
    800038a2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800038a4:	40000613          	li	a2,1024
    800038a8:	05890593          	addi	a1,s2,88
    800038ac:	05850513          	addi	a0,a0,88
    800038b0:	c12fd0ef          	jal	ra,80000cc2 <memmove>
    bwrite(dbuf);  // write dst to disk
    800038b4:	8526                	mv	a0,s1
    800038b6:	9e0ff0ef          	jal	ra,80002a96 <bwrite>
    if(recovering == 0)
    800038ba:	fa0b18e3          	bnez	s6,8000386a <install_trans+0x36>
      bunpin(dbuf);
    800038be:	8526                	mv	a0,s1
    800038c0:	ac6ff0ef          	jal	ra,80002b86 <bunpin>
    800038c4:	b75d                	j	8000386a <install_trans+0x36>
}
    800038c6:	70e2                	ld	ra,56(sp)
    800038c8:	7442                	ld	s0,48(sp)
    800038ca:	74a2                	ld	s1,40(sp)
    800038cc:	7902                	ld	s2,32(sp)
    800038ce:	69e2                	ld	s3,24(sp)
    800038d0:	6a42                	ld	s4,16(sp)
    800038d2:	6aa2                	ld	s5,8(sp)
    800038d4:	6b02                	ld	s6,0(sp)
    800038d6:	6121                	addi	sp,sp,64
    800038d8:	8082                	ret
    800038da:	8082                	ret

00000000800038dc <initlog>:
{
    800038dc:	7179                	addi	sp,sp,-48
    800038de:	f406                	sd	ra,40(sp)
    800038e0:	f022                	sd	s0,32(sp)
    800038e2:	ec26                	sd	s1,24(sp)
    800038e4:	e84a                	sd	s2,16(sp)
    800038e6:	e44e                	sd	s3,8(sp)
    800038e8:	1800                	addi	s0,sp,48
    800038ea:	892a                	mv	s2,a0
    800038ec:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800038ee:	0001c497          	auipc	s1,0x1c
    800038f2:	11248493          	addi	s1,s1,274 # 8001fa00 <log>
    800038f6:	00004597          	auipc	a1,0x4
    800038fa:	d7258593          	addi	a1,a1,-654 # 80007668 <syscalls+0x1d8>
    800038fe:	8526                	mv	a0,s1
    80003900:	a12fd0ef          	jal	ra,80000b12 <initlock>
  log.start = sb->logstart;
    80003904:	0149a583          	lw	a1,20(s3)
    80003908:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000390a:	0109a783          	lw	a5,16(s3)
    8000390e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003910:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003914:	854a                	mv	a0,s2
    80003916:	8aaff0ef          	jal	ra,800029c0 <bread>
  log.lh.n = lh->n;
    8000391a:	4d34                	lw	a3,88(a0)
    8000391c:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000391e:	02d05663          	blez	a3,8000394a <initlog+0x6e>
    80003922:	05c50793          	addi	a5,a0,92
    80003926:	0001c717          	auipc	a4,0x1c
    8000392a:	10a70713          	addi	a4,a4,266 # 8001fa30 <log+0x30>
    8000392e:	36fd                	addiw	a3,a3,-1
    80003930:	02069613          	slli	a2,a3,0x20
    80003934:	01e65693          	srli	a3,a2,0x1e
    80003938:	06050613          	addi	a2,a0,96
    8000393c:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000393e:	4390                	lw	a2,0(a5)
    80003940:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003942:	0791                	addi	a5,a5,4
    80003944:	0711                	addi	a4,a4,4
    80003946:	fed79ce3          	bne	a5,a3,8000393e <initlog+0x62>
  brelse(buf);
    8000394a:	97eff0ef          	jal	ra,80002ac8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000394e:	4505                	li	a0,1
    80003950:	ee5ff0ef          	jal	ra,80003834 <install_trans>
  log.lh.n = 0;
    80003954:	0001c797          	auipc	a5,0x1c
    80003958:	0c07ac23          	sw	zero,216(a5) # 8001fa2c <log+0x2c>
  write_head(); // clear the log
    8000395c:	e69ff0ef          	jal	ra,800037c4 <write_head>
}
    80003960:	70a2                	ld	ra,40(sp)
    80003962:	7402                	ld	s0,32(sp)
    80003964:	64e2                	ld	s1,24(sp)
    80003966:	6942                	ld	s2,16(sp)
    80003968:	69a2                	ld	s3,8(sp)
    8000396a:	6145                	addi	sp,sp,48
    8000396c:	8082                	ret

000000008000396e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000396e:	1101                	addi	sp,sp,-32
    80003970:	ec06                	sd	ra,24(sp)
    80003972:	e822                	sd	s0,16(sp)
    80003974:	e426                	sd	s1,8(sp)
    80003976:	e04a                	sd	s2,0(sp)
    80003978:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000397a:	0001c517          	auipc	a0,0x1c
    8000397e:	08650513          	addi	a0,a0,134 # 8001fa00 <log>
    80003982:	a10fd0ef          	jal	ra,80000b92 <acquire>
  while(1){
    if(log.committing){
    80003986:	0001c497          	auipc	s1,0x1c
    8000398a:	07a48493          	addi	s1,s1,122 # 8001fa00 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000398e:	4979                	li	s2,30
    80003990:	a029                	j	8000399a <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003992:	85a6                	mv	a1,s1
    80003994:	8526                	mv	a0,s1
    80003996:	c58fe0ef          	jal	ra,80001dee <sleep>
    if(log.committing){
    8000399a:	50dc                	lw	a5,36(s1)
    8000399c:	fbfd                	bnez	a5,80003992 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000399e:	509c                	lw	a5,32(s1)
    800039a0:	0017871b          	addiw	a4,a5,1
    800039a4:	0007069b          	sext.w	a3,a4
    800039a8:	0027179b          	slliw	a5,a4,0x2
    800039ac:	9fb9                	addw	a5,a5,a4
    800039ae:	0017979b          	slliw	a5,a5,0x1
    800039b2:	54d8                	lw	a4,44(s1)
    800039b4:	9fb9                	addw	a5,a5,a4
    800039b6:	00f95763          	bge	s2,a5,800039c4 <begin_op+0x56>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800039ba:	85a6                	mv	a1,s1
    800039bc:	8526                	mv	a0,s1
    800039be:	c30fe0ef          	jal	ra,80001dee <sleep>
    800039c2:	bfe1                	j	8000399a <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800039c4:	0001c517          	auipc	a0,0x1c
    800039c8:	03c50513          	addi	a0,a0,60 # 8001fa00 <log>
    800039cc:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800039ce:	a5cfd0ef          	jal	ra,80000c2a <release>
      break;
    }
  }
}
    800039d2:	60e2                	ld	ra,24(sp)
    800039d4:	6442                	ld	s0,16(sp)
    800039d6:	64a2                	ld	s1,8(sp)
    800039d8:	6902                	ld	s2,0(sp)
    800039da:	6105                	addi	sp,sp,32
    800039dc:	8082                	ret

00000000800039de <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800039de:	7139                	addi	sp,sp,-64
    800039e0:	fc06                	sd	ra,56(sp)
    800039e2:	f822                	sd	s0,48(sp)
    800039e4:	f426                	sd	s1,40(sp)
    800039e6:	f04a                	sd	s2,32(sp)
    800039e8:	ec4e                	sd	s3,24(sp)
    800039ea:	e852                	sd	s4,16(sp)
    800039ec:	e456                	sd	s5,8(sp)
    800039ee:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800039f0:	0001c497          	auipc	s1,0x1c
    800039f4:	01048493          	addi	s1,s1,16 # 8001fa00 <log>
    800039f8:	8526                	mv	a0,s1
    800039fa:	998fd0ef          	jal	ra,80000b92 <acquire>
  log.outstanding -= 1;
    800039fe:	509c                	lw	a5,32(s1)
    80003a00:	37fd                	addiw	a5,a5,-1
    80003a02:	0007891b          	sext.w	s2,a5
    80003a06:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003a08:	50dc                	lw	a5,36(s1)
    80003a0a:	ef9d                	bnez	a5,80003a48 <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    80003a0c:	04091463          	bnez	s2,80003a54 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003a10:	0001c497          	auipc	s1,0x1c
    80003a14:	ff048493          	addi	s1,s1,-16 # 8001fa00 <log>
    80003a18:	4785                	li	a5,1
    80003a1a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003a1c:	8526                	mv	a0,s1
    80003a1e:	a0cfd0ef          	jal	ra,80000c2a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003a22:	54dc                	lw	a5,44(s1)
    80003a24:	04f04b63          	bgtz	a5,80003a7a <end_op+0x9c>
    acquire(&log.lock);
    80003a28:	0001c497          	auipc	s1,0x1c
    80003a2c:	fd848493          	addi	s1,s1,-40 # 8001fa00 <log>
    80003a30:	8526                	mv	a0,s1
    80003a32:	960fd0ef          	jal	ra,80000b92 <acquire>
    log.committing = 0;
    80003a36:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003a3a:	8526                	mv	a0,s1
    80003a3c:	bfefe0ef          	jal	ra,80001e3a <wakeup>
    release(&log.lock);
    80003a40:	8526                	mv	a0,s1
    80003a42:	9e8fd0ef          	jal	ra,80000c2a <release>
}
    80003a46:	a00d                	j	80003a68 <end_op+0x8a>
    panic("log.committing");
    80003a48:	00004517          	auipc	a0,0x4
    80003a4c:	c2850513          	addi	a0,a0,-984 # 80007670 <syscalls+0x1e0>
    80003a50:	d07fc0ef          	jal	ra,80000756 <panic>
    wakeup(&log);
    80003a54:	0001c497          	auipc	s1,0x1c
    80003a58:	fac48493          	addi	s1,s1,-84 # 8001fa00 <log>
    80003a5c:	8526                	mv	a0,s1
    80003a5e:	bdcfe0ef          	jal	ra,80001e3a <wakeup>
  release(&log.lock);
    80003a62:	8526                	mv	a0,s1
    80003a64:	9c6fd0ef          	jal	ra,80000c2a <release>
}
    80003a68:	70e2                	ld	ra,56(sp)
    80003a6a:	7442                	ld	s0,48(sp)
    80003a6c:	74a2                	ld	s1,40(sp)
    80003a6e:	7902                	ld	s2,32(sp)
    80003a70:	69e2                	ld	s3,24(sp)
    80003a72:	6a42                	ld	s4,16(sp)
    80003a74:	6aa2                	ld	s5,8(sp)
    80003a76:	6121                	addi	sp,sp,64
    80003a78:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a7a:	0001ca97          	auipc	s5,0x1c
    80003a7e:	fb6a8a93          	addi	s5,s5,-74 # 8001fa30 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003a82:	0001ca17          	auipc	s4,0x1c
    80003a86:	f7ea0a13          	addi	s4,s4,-130 # 8001fa00 <log>
    80003a8a:	018a2583          	lw	a1,24(s4)
    80003a8e:	012585bb          	addw	a1,a1,s2
    80003a92:	2585                	addiw	a1,a1,1
    80003a94:	028a2503          	lw	a0,40(s4)
    80003a98:	f29fe0ef          	jal	ra,800029c0 <bread>
    80003a9c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003a9e:	000aa583          	lw	a1,0(s5)
    80003aa2:	028a2503          	lw	a0,40(s4)
    80003aa6:	f1bfe0ef          	jal	ra,800029c0 <bread>
    80003aaa:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003aac:	40000613          	li	a2,1024
    80003ab0:	05850593          	addi	a1,a0,88
    80003ab4:	05848513          	addi	a0,s1,88
    80003ab8:	a0afd0ef          	jal	ra,80000cc2 <memmove>
    bwrite(to);  // write the log
    80003abc:	8526                	mv	a0,s1
    80003abe:	fd9fe0ef          	jal	ra,80002a96 <bwrite>
    brelse(from);
    80003ac2:	854e                	mv	a0,s3
    80003ac4:	804ff0ef          	jal	ra,80002ac8 <brelse>
    brelse(to);
    80003ac8:	8526                	mv	a0,s1
    80003aca:	ffffe0ef          	jal	ra,80002ac8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ace:	2905                	addiw	s2,s2,1
    80003ad0:	0a91                	addi	s5,s5,4
    80003ad2:	02ca2783          	lw	a5,44(s4)
    80003ad6:	faf94ae3          	blt	s2,a5,80003a8a <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003ada:	cebff0ef          	jal	ra,800037c4 <write_head>
    install_trans(0); // Now install writes to home locations
    80003ade:	4501                	li	a0,0
    80003ae0:	d55ff0ef          	jal	ra,80003834 <install_trans>
    log.lh.n = 0;
    80003ae4:	0001c797          	auipc	a5,0x1c
    80003ae8:	f407a423          	sw	zero,-184(a5) # 8001fa2c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003aec:	cd9ff0ef          	jal	ra,800037c4 <write_head>
    80003af0:	bf25                	j	80003a28 <end_op+0x4a>

0000000080003af2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003af2:	1101                	addi	sp,sp,-32
    80003af4:	ec06                	sd	ra,24(sp)
    80003af6:	e822                	sd	s0,16(sp)
    80003af8:	e426                	sd	s1,8(sp)
    80003afa:	e04a                	sd	s2,0(sp)
    80003afc:	1000                	addi	s0,sp,32
    80003afe:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003b00:	0001c917          	auipc	s2,0x1c
    80003b04:	f0090913          	addi	s2,s2,-256 # 8001fa00 <log>
    80003b08:	854a                	mv	a0,s2
    80003b0a:	888fd0ef          	jal	ra,80000b92 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003b0e:	02c92603          	lw	a2,44(s2)
    80003b12:	47f5                	li	a5,29
    80003b14:	06c7c363          	blt	a5,a2,80003b7a <log_write+0x88>
    80003b18:	0001c797          	auipc	a5,0x1c
    80003b1c:	f047a783          	lw	a5,-252(a5) # 8001fa1c <log+0x1c>
    80003b20:	37fd                	addiw	a5,a5,-1
    80003b22:	04f65c63          	bge	a2,a5,80003b7a <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003b26:	0001c797          	auipc	a5,0x1c
    80003b2a:	efa7a783          	lw	a5,-262(a5) # 8001fa20 <log+0x20>
    80003b2e:	04f05c63          	blez	a5,80003b86 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003b32:	4781                	li	a5,0
    80003b34:	04c05f63          	blez	a2,80003b92 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003b38:	44cc                	lw	a1,12(s1)
    80003b3a:	0001c717          	auipc	a4,0x1c
    80003b3e:	ef670713          	addi	a4,a4,-266 # 8001fa30 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003b42:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003b44:	4314                	lw	a3,0(a4)
    80003b46:	04b68663          	beq	a3,a1,80003b92 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003b4a:	2785                	addiw	a5,a5,1
    80003b4c:	0711                	addi	a4,a4,4
    80003b4e:	fef61be3          	bne	a2,a5,80003b44 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003b52:	0621                	addi	a2,a2,8
    80003b54:	060a                	slli	a2,a2,0x2
    80003b56:	0001c797          	auipc	a5,0x1c
    80003b5a:	eaa78793          	addi	a5,a5,-342 # 8001fa00 <log>
    80003b5e:	963e                	add	a2,a2,a5
    80003b60:	44dc                	lw	a5,12(s1)
    80003b62:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003b64:	8526                	mv	a0,s1
    80003b66:	fedfe0ef          	jal	ra,80002b52 <bpin>
    log.lh.n++;
    80003b6a:	0001c717          	auipc	a4,0x1c
    80003b6e:	e9670713          	addi	a4,a4,-362 # 8001fa00 <log>
    80003b72:	575c                	lw	a5,44(a4)
    80003b74:	2785                	addiw	a5,a5,1
    80003b76:	d75c                	sw	a5,44(a4)
    80003b78:	a815                	j	80003bac <log_write+0xba>
    panic("too big a transaction");
    80003b7a:	00004517          	auipc	a0,0x4
    80003b7e:	b0650513          	addi	a0,a0,-1274 # 80007680 <syscalls+0x1f0>
    80003b82:	bd5fc0ef          	jal	ra,80000756 <panic>
    panic("log_write outside of trans");
    80003b86:	00004517          	auipc	a0,0x4
    80003b8a:	b1250513          	addi	a0,a0,-1262 # 80007698 <syscalls+0x208>
    80003b8e:	bc9fc0ef          	jal	ra,80000756 <panic>
  log.lh.block[i] = b->blockno;
    80003b92:	00878713          	addi	a4,a5,8
    80003b96:	00271693          	slli	a3,a4,0x2
    80003b9a:	0001c717          	auipc	a4,0x1c
    80003b9e:	e6670713          	addi	a4,a4,-410 # 8001fa00 <log>
    80003ba2:	9736                	add	a4,a4,a3
    80003ba4:	44d4                	lw	a3,12(s1)
    80003ba6:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003ba8:	faf60ee3          	beq	a2,a5,80003b64 <log_write+0x72>
  }
  release(&log.lock);
    80003bac:	0001c517          	auipc	a0,0x1c
    80003bb0:	e5450513          	addi	a0,a0,-428 # 8001fa00 <log>
    80003bb4:	876fd0ef          	jal	ra,80000c2a <release>
}
    80003bb8:	60e2                	ld	ra,24(sp)
    80003bba:	6442                	ld	s0,16(sp)
    80003bbc:	64a2                	ld	s1,8(sp)
    80003bbe:	6902                	ld	s2,0(sp)
    80003bc0:	6105                	addi	sp,sp,32
    80003bc2:	8082                	ret

0000000080003bc4 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003bc4:	1101                	addi	sp,sp,-32
    80003bc6:	ec06                	sd	ra,24(sp)
    80003bc8:	e822                	sd	s0,16(sp)
    80003bca:	e426                	sd	s1,8(sp)
    80003bcc:	e04a                	sd	s2,0(sp)
    80003bce:	1000                	addi	s0,sp,32
    80003bd0:	84aa                	mv	s1,a0
    80003bd2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003bd4:	00004597          	auipc	a1,0x4
    80003bd8:	ae458593          	addi	a1,a1,-1308 # 800076b8 <syscalls+0x228>
    80003bdc:	0521                	addi	a0,a0,8
    80003bde:	f35fc0ef          	jal	ra,80000b12 <initlock>
  lk->name = name;
    80003be2:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003be6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003bea:	0204a423          	sw	zero,40(s1)
}
    80003bee:	60e2                	ld	ra,24(sp)
    80003bf0:	6442                	ld	s0,16(sp)
    80003bf2:	64a2                	ld	s1,8(sp)
    80003bf4:	6902                	ld	s2,0(sp)
    80003bf6:	6105                	addi	sp,sp,32
    80003bf8:	8082                	ret

0000000080003bfa <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003bfa:	1101                	addi	sp,sp,-32
    80003bfc:	ec06                	sd	ra,24(sp)
    80003bfe:	e822                	sd	s0,16(sp)
    80003c00:	e426                	sd	s1,8(sp)
    80003c02:	e04a                	sd	s2,0(sp)
    80003c04:	1000                	addi	s0,sp,32
    80003c06:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003c08:	00850913          	addi	s2,a0,8
    80003c0c:	854a                	mv	a0,s2
    80003c0e:	f85fc0ef          	jal	ra,80000b92 <acquire>
  while (lk->locked) {
    80003c12:	409c                	lw	a5,0(s1)
    80003c14:	c799                	beqz	a5,80003c22 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003c16:	85ca                	mv	a1,s2
    80003c18:	8526                	mv	a0,s1
    80003c1a:	9d4fe0ef          	jal	ra,80001dee <sleep>
  while (lk->locked) {
    80003c1e:	409c                	lw	a5,0(s1)
    80003c20:	fbfd                	bnez	a5,80003c16 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003c22:	4785                	li	a5,1
    80003c24:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003c26:	bfffd0ef          	jal	ra,80001824 <myproc>
    80003c2a:	591c                	lw	a5,48(a0)
    80003c2c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003c2e:	854a                	mv	a0,s2
    80003c30:	ffbfc0ef          	jal	ra,80000c2a <release>
}
    80003c34:	60e2                	ld	ra,24(sp)
    80003c36:	6442                	ld	s0,16(sp)
    80003c38:	64a2                	ld	s1,8(sp)
    80003c3a:	6902                	ld	s2,0(sp)
    80003c3c:	6105                	addi	sp,sp,32
    80003c3e:	8082                	ret

0000000080003c40 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003c40:	1101                	addi	sp,sp,-32
    80003c42:	ec06                	sd	ra,24(sp)
    80003c44:	e822                	sd	s0,16(sp)
    80003c46:	e426                	sd	s1,8(sp)
    80003c48:	e04a                	sd	s2,0(sp)
    80003c4a:	1000                	addi	s0,sp,32
    80003c4c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003c4e:	00850913          	addi	s2,a0,8
    80003c52:	854a                	mv	a0,s2
    80003c54:	f3ffc0ef          	jal	ra,80000b92 <acquire>
  lk->locked = 0;
    80003c58:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003c5c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003c60:	8526                	mv	a0,s1
    80003c62:	9d8fe0ef          	jal	ra,80001e3a <wakeup>
  release(&lk->lk);
    80003c66:	854a                	mv	a0,s2
    80003c68:	fc3fc0ef          	jal	ra,80000c2a <release>
}
    80003c6c:	60e2                	ld	ra,24(sp)
    80003c6e:	6442                	ld	s0,16(sp)
    80003c70:	64a2                	ld	s1,8(sp)
    80003c72:	6902                	ld	s2,0(sp)
    80003c74:	6105                	addi	sp,sp,32
    80003c76:	8082                	ret

0000000080003c78 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003c78:	7179                	addi	sp,sp,-48
    80003c7a:	f406                	sd	ra,40(sp)
    80003c7c:	f022                	sd	s0,32(sp)
    80003c7e:	ec26                	sd	s1,24(sp)
    80003c80:	e84a                	sd	s2,16(sp)
    80003c82:	e44e                	sd	s3,8(sp)
    80003c84:	1800                	addi	s0,sp,48
    80003c86:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003c88:	00850913          	addi	s2,a0,8
    80003c8c:	854a                	mv	a0,s2
    80003c8e:	f05fc0ef          	jal	ra,80000b92 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003c92:	409c                	lw	a5,0(s1)
    80003c94:	ef89                	bnez	a5,80003cae <holdingsleep+0x36>
    80003c96:	4481                	li	s1,0
  release(&lk->lk);
    80003c98:	854a                	mv	a0,s2
    80003c9a:	f91fc0ef          	jal	ra,80000c2a <release>
  return r;
}
    80003c9e:	8526                	mv	a0,s1
    80003ca0:	70a2                	ld	ra,40(sp)
    80003ca2:	7402                	ld	s0,32(sp)
    80003ca4:	64e2                	ld	s1,24(sp)
    80003ca6:	6942                	ld	s2,16(sp)
    80003ca8:	69a2                	ld	s3,8(sp)
    80003caa:	6145                	addi	sp,sp,48
    80003cac:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80003cae:	0284a983          	lw	s3,40(s1)
    80003cb2:	b73fd0ef          	jal	ra,80001824 <myproc>
    80003cb6:	5904                	lw	s1,48(a0)
    80003cb8:	413484b3          	sub	s1,s1,s3
    80003cbc:	0014b493          	seqz	s1,s1
    80003cc0:	bfe1                	j	80003c98 <holdingsleep+0x20>

0000000080003cc2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003cc2:	1141                	addi	sp,sp,-16
    80003cc4:	e406                	sd	ra,8(sp)
    80003cc6:	e022                	sd	s0,0(sp)
    80003cc8:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003cca:	00004597          	auipc	a1,0x4
    80003cce:	9fe58593          	addi	a1,a1,-1538 # 800076c8 <syscalls+0x238>
    80003cd2:	0001c517          	auipc	a0,0x1c
    80003cd6:	e7650513          	addi	a0,a0,-394 # 8001fb48 <ftable>
    80003cda:	e39fc0ef          	jal	ra,80000b12 <initlock>
}
    80003cde:	60a2                	ld	ra,8(sp)
    80003ce0:	6402                	ld	s0,0(sp)
    80003ce2:	0141                	addi	sp,sp,16
    80003ce4:	8082                	ret

0000000080003ce6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003ce6:	1101                	addi	sp,sp,-32
    80003ce8:	ec06                	sd	ra,24(sp)
    80003cea:	e822                	sd	s0,16(sp)
    80003cec:	e426                	sd	s1,8(sp)
    80003cee:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003cf0:	0001c517          	auipc	a0,0x1c
    80003cf4:	e5850513          	addi	a0,a0,-424 # 8001fb48 <ftable>
    80003cf8:	e9bfc0ef          	jal	ra,80000b92 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003cfc:	0001c497          	auipc	s1,0x1c
    80003d00:	e6448493          	addi	s1,s1,-412 # 8001fb60 <ftable+0x18>
    80003d04:	0001d717          	auipc	a4,0x1d
    80003d08:	dfc70713          	addi	a4,a4,-516 # 80020b00 <disk>
    if(f->ref == 0){
    80003d0c:	40dc                	lw	a5,4(s1)
    80003d0e:	cf89                	beqz	a5,80003d28 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003d10:	02848493          	addi	s1,s1,40
    80003d14:	fee49ce3          	bne	s1,a4,80003d0c <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003d18:	0001c517          	auipc	a0,0x1c
    80003d1c:	e3050513          	addi	a0,a0,-464 # 8001fb48 <ftable>
    80003d20:	f0bfc0ef          	jal	ra,80000c2a <release>
  return 0;
    80003d24:	4481                	li	s1,0
    80003d26:	a809                	j	80003d38 <filealloc+0x52>
      f->ref = 1;
    80003d28:	4785                	li	a5,1
    80003d2a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003d2c:	0001c517          	auipc	a0,0x1c
    80003d30:	e1c50513          	addi	a0,a0,-484 # 8001fb48 <ftable>
    80003d34:	ef7fc0ef          	jal	ra,80000c2a <release>
}
    80003d38:	8526                	mv	a0,s1
    80003d3a:	60e2                	ld	ra,24(sp)
    80003d3c:	6442                	ld	s0,16(sp)
    80003d3e:	64a2                	ld	s1,8(sp)
    80003d40:	6105                	addi	sp,sp,32
    80003d42:	8082                	ret

0000000080003d44 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003d44:	1101                	addi	sp,sp,-32
    80003d46:	ec06                	sd	ra,24(sp)
    80003d48:	e822                	sd	s0,16(sp)
    80003d4a:	e426                	sd	s1,8(sp)
    80003d4c:	1000                	addi	s0,sp,32
    80003d4e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003d50:	0001c517          	auipc	a0,0x1c
    80003d54:	df850513          	addi	a0,a0,-520 # 8001fb48 <ftable>
    80003d58:	e3bfc0ef          	jal	ra,80000b92 <acquire>
  if(f->ref < 1)
    80003d5c:	40dc                	lw	a5,4(s1)
    80003d5e:	02f05063          	blez	a5,80003d7e <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003d62:	2785                	addiw	a5,a5,1
    80003d64:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003d66:	0001c517          	auipc	a0,0x1c
    80003d6a:	de250513          	addi	a0,a0,-542 # 8001fb48 <ftable>
    80003d6e:	ebdfc0ef          	jal	ra,80000c2a <release>
  return f;
}
    80003d72:	8526                	mv	a0,s1
    80003d74:	60e2                	ld	ra,24(sp)
    80003d76:	6442                	ld	s0,16(sp)
    80003d78:	64a2                	ld	s1,8(sp)
    80003d7a:	6105                	addi	sp,sp,32
    80003d7c:	8082                	ret
    panic("filedup");
    80003d7e:	00004517          	auipc	a0,0x4
    80003d82:	95250513          	addi	a0,a0,-1710 # 800076d0 <syscalls+0x240>
    80003d86:	9d1fc0ef          	jal	ra,80000756 <panic>

0000000080003d8a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003d8a:	7139                	addi	sp,sp,-64
    80003d8c:	fc06                	sd	ra,56(sp)
    80003d8e:	f822                	sd	s0,48(sp)
    80003d90:	f426                	sd	s1,40(sp)
    80003d92:	f04a                	sd	s2,32(sp)
    80003d94:	ec4e                	sd	s3,24(sp)
    80003d96:	e852                	sd	s4,16(sp)
    80003d98:	e456                	sd	s5,8(sp)
    80003d9a:	0080                	addi	s0,sp,64
    80003d9c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003d9e:	0001c517          	auipc	a0,0x1c
    80003da2:	daa50513          	addi	a0,a0,-598 # 8001fb48 <ftable>
    80003da6:	dedfc0ef          	jal	ra,80000b92 <acquire>
  if(f->ref < 1)
    80003daa:	40dc                	lw	a5,4(s1)
    80003dac:	04f05963          	blez	a5,80003dfe <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    80003db0:	37fd                	addiw	a5,a5,-1
    80003db2:	0007871b          	sext.w	a4,a5
    80003db6:	c0dc                	sw	a5,4(s1)
    80003db8:	04e04963          	bgtz	a4,80003e0a <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003dbc:	0004a903          	lw	s2,0(s1)
    80003dc0:	0094ca83          	lbu	s5,9(s1)
    80003dc4:	0104ba03          	ld	s4,16(s1)
    80003dc8:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003dcc:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003dd0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003dd4:	0001c517          	auipc	a0,0x1c
    80003dd8:	d7450513          	addi	a0,a0,-652 # 8001fb48 <ftable>
    80003ddc:	e4ffc0ef          	jal	ra,80000c2a <release>

  if(ff.type == FD_PIPE){
    80003de0:	4785                	li	a5,1
    80003de2:	04f90363          	beq	s2,a5,80003e28 <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003de6:	3979                	addiw	s2,s2,-2
    80003de8:	4785                	li	a5,1
    80003dea:	0327e663          	bltu	a5,s2,80003e16 <fileclose+0x8c>
    begin_op();
    80003dee:	b81ff0ef          	jal	ra,8000396e <begin_op>
    iput(ff.ip);
    80003df2:	854e                	mv	a0,s3
    80003df4:	c6aff0ef          	jal	ra,8000325e <iput>
    end_op();
    80003df8:	be7ff0ef          	jal	ra,800039de <end_op>
    80003dfc:	a829                	j	80003e16 <fileclose+0x8c>
    panic("fileclose");
    80003dfe:	00004517          	auipc	a0,0x4
    80003e02:	8da50513          	addi	a0,a0,-1830 # 800076d8 <syscalls+0x248>
    80003e06:	951fc0ef          	jal	ra,80000756 <panic>
    release(&ftable.lock);
    80003e0a:	0001c517          	auipc	a0,0x1c
    80003e0e:	d3e50513          	addi	a0,a0,-706 # 8001fb48 <ftable>
    80003e12:	e19fc0ef          	jal	ra,80000c2a <release>
  }
}
    80003e16:	70e2                	ld	ra,56(sp)
    80003e18:	7442                	ld	s0,48(sp)
    80003e1a:	74a2                	ld	s1,40(sp)
    80003e1c:	7902                	ld	s2,32(sp)
    80003e1e:	69e2                	ld	s3,24(sp)
    80003e20:	6a42                	ld	s4,16(sp)
    80003e22:	6aa2                	ld	s5,8(sp)
    80003e24:	6121                	addi	sp,sp,64
    80003e26:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003e28:	85d6                	mv	a1,s5
    80003e2a:	8552                	mv	a0,s4
    80003e2c:	2ec000ef          	jal	ra,80004118 <pipeclose>
    80003e30:	b7dd                	j	80003e16 <fileclose+0x8c>

0000000080003e32 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003e32:	715d                	addi	sp,sp,-80
    80003e34:	e486                	sd	ra,72(sp)
    80003e36:	e0a2                	sd	s0,64(sp)
    80003e38:	fc26                	sd	s1,56(sp)
    80003e3a:	f84a                	sd	s2,48(sp)
    80003e3c:	f44e                	sd	s3,40(sp)
    80003e3e:	0880                	addi	s0,sp,80
    80003e40:	84aa                	mv	s1,a0
    80003e42:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003e44:	9e1fd0ef          	jal	ra,80001824 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003e48:	409c                	lw	a5,0(s1)
    80003e4a:	37f9                	addiw	a5,a5,-2
    80003e4c:	4705                	li	a4,1
    80003e4e:	02f76f63          	bltu	a4,a5,80003e8c <filestat+0x5a>
    80003e52:	892a                	mv	s2,a0
    ilock(f->ip);
    80003e54:	6c88                	ld	a0,24(s1)
    80003e56:	a8aff0ef          	jal	ra,800030e0 <ilock>
    stati(f->ip, &st);
    80003e5a:	fb840593          	addi	a1,s0,-72
    80003e5e:	6c88                	ld	a0,24(s1)
    80003e60:	ca6ff0ef          	jal	ra,80003306 <stati>
    iunlock(f->ip);
    80003e64:	6c88                	ld	a0,24(s1)
    80003e66:	b24ff0ef          	jal	ra,8000318a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003e6a:	46e1                	li	a3,24
    80003e6c:	fb840613          	addi	a2,s0,-72
    80003e70:	85ce                	mv	a1,s3
    80003e72:	05093503          	ld	a0,80(s2)
    80003e76:	e62fd0ef          	jal	ra,800014d8 <copyout>
    80003e7a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80003e7e:	60a6                	ld	ra,72(sp)
    80003e80:	6406                	ld	s0,64(sp)
    80003e82:	74e2                	ld	s1,56(sp)
    80003e84:	7942                	ld	s2,48(sp)
    80003e86:	79a2                	ld	s3,40(sp)
    80003e88:	6161                	addi	sp,sp,80
    80003e8a:	8082                	ret
  return -1;
    80003e8c:	557d                	li	a0,-1
    80003e8e:	bfc5                	j	80003e7e <filestat+0x4c>

0000000080003e90 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003e90:	7179                	addi	sp,sp,-48
    80003e92:	f406                	sd	ra,40(sp)
    80003e94:	f022                	sd	s0,32(sp)
    80003e96:	ec26                	sd	s1,24(sp)
    80003e98:	e84a                	sd	s2,16(sp)
    80003e9a:	e44e                	sd	s3,8(sp)
    80003e9c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003e9e:	00854783          	lbu	a5,8(a0)
    80003ea2:	cbc1                	beqz	a5,80003f32 <fileread+0xa2>
    80003ea4:	84aa                	mv	s1,a0
    80003ea6:	89ae                	mv	s3,a1
    80003ea8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003eaa:	411c                	lw	a5,0(a0)
    80003eac:	4705                	li	a4,1
    80003eae:	04e78363          	beq	a5,a4,80003ef4 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003eb2:	470d                	li	a4,3
    80003eb4:	04e78563          	beq	a5,a4,80003efe <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003eb8:	4709                	li	a4,2
    80003eba:	06e79663          	bne	a5,a4,80003f26 <fileread+0x96>
    ilock(f->ip);
    80003ebe:	6d08                	ld	a0,24(a0)
    80003ec0:	a20ff0ef          	jal	ra,800030e0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003ec4:	874a                	mv	a4,s2
    80003ec6:	5094                	lw	a3,32(s1)
    80003ec8:	864e                	mv	a2,s3
    80003eca:	4585                	li	a1,1
    80003ecc:	6c88                	ld	a0,24(s1)
    80003ece:	c62ff0ef          	jal	ra,80003330 <readi>
    80003ed2:	892a                	mv	s2,a0
    80003ed4:	00a05563          	blez	a0,80003ede <fileread+0x4e>
      f->off += r;
    80003ed8:	509c                	lw	a5,32(s1)
    80003eda:	9fa9                	addw	a5,a5,a0
    80003edc:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80003ede:	6c88                	ld	a0,24(s1)
    80003ee0:	aaaff0ef          	jal	ra,8000318a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80003ee4:	854a                	mv	a0,s2
    80003ee6:	70a2                	ld	ra,40(sp)
    80003ee8:	7402                	ld	s0,32(sp)
    80003eea:	64e2                	ld	s1,24(sp)
    80003eec:	6942                	ld	s2,16(sp)
    80003eee:	69a2                	ld	s3,8(sp)
    80003ef0:	6145                	addi	sp,sp,48
    80003ef2:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80003ef4:	6908                	ld	a0,16(a0)
    80003ef6:	34e000ef          	jal	ra,80004244 <piperead>
    80003efa:	892a                	mv	s2,a0
    80003efc:	b7e5                	j	80003ee4 <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003efe:	02451783          	lh	a5,36(a0)
    80003f02:	03079693          	slli	a3,a5,0x30
    80003f06:	92c1                	srli	a3,a3,0x30
    80003f08:	4725                	li	a4,9
    80003f0a:	02d76663          	bltu	a4,a3,80003f36 <fileread+0xa6>
    80003f0e:	0792                	slli	a5,a5,0x4
    80003f10:	0001c717          	auipc	a4,0x1c
    80003f14:	b9870713          	addi	a4,a4,-1128 # 8001faa8 <devsw>
    80003f18:	97ba                	add	a5,a5,a4
    80003f1a:	639c                	ld	a5,0(a5)
    80003f1c:	cf99                	beqz	a5,80003f3a <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    80003f1e:	4505                	li	a0,1
    80003f20:	9782                	jalr	a5
    80003f22:	892a                	mv	s2,a0
    80003f24:	b7c1                	j	80003ee4 <fileread+0x54>
    panic("fileread");
    80003f26:	00003517          	auipc	a0,0x3
    80003f2a:	7c250513          	addi	a0,a0,1986 # 800076e8 <syscalls+0x258>
    80003f2e:	829fc0ef          	jal	ra,80000756 <panic>
    return -1;
    80003f32:	597d                	li	s2,-1
    80003f34:	bf45                	j	80003ee4 <fileread+0x54>
      return -1;
    80003f36:	597d                	li	s2,-1
    80003f38:	b775                	j	80003ee4 <fileread+0x54>
    80003f3a:	597d                	li	s2,-1
    80003f3c:	b765                	j	80003ee4 <fileread+0x54>

0000000080003f3e <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80003f3e:	715d                	addi	sp,sp,-80
    80003f40:	e486                	sd	ra,72(sp)
    80003f42:	e0a2                	sd	s0,64(sp)
    80003f44:	fc26                	sd	s1,56(sp)
    80003f46:	f84a                	sd	s2,48(sp)
    80003f48:	f44e                	sd	s3,40(sp)
    80003f4a:	f052                	sd	s4,32(sp)
    80003f4c:	ec56                	sd	s5,24(sp)
    80003f4e:	e85a                	sd	s6,16(sp)
    80003f50:	e45e                	sd	s7,8(sp)
    80003f52:	e062                	sd	s8,0(sp)
    80003f54:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80003f56:	00954783          	lbu	a5,9(a0)
    80003f5a:	0e078863          	beqz	a5,8000404a <filewrite+0x10c>
    80003f5e:	892a                	mv	s2,a0
    80003f60:	8aae                	mv	s5,a1
    80003f62:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80003f64:	411c                	lw	a5,0(a0)
    80003f66:	4705                	li	a4,1
    80003f68:	02e78263          	beq	a5,a4,80003f8c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003f6c:	470d                	li	a4,3
    80003f6e:	02e78463          	beq	a5,a4,80003f96 <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003f72:	4709                	li	a4,2
    80003f74:	0ce79563          	bne	a5,a4,8000403e <filewrite+0x100>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80003f78:	0ac05163          	blez	a2,8000401a <filewrite+0xdc>
    int i = 0;
    80003f7c:	4981                	li	s3,0
    80003f7e:	6b05                	lui	s6,0x1
    80003f80:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80003f84:	6b85                	lui	s7,0x1
    80003f86:	c00b8b9b          	addiw	s7,s7,-1024
    80003f8a:	a041                	j	8000400a <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80003f8c:	6908                	ld	a0,16(a0)
    80003f8e:	1e2000ef          	jal	ra,80004170 <pipewrite>
    80003f92:	8a2a                	mv	s4,a0
    80003f94:	a071                	j	80004020 <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80003f96:	02451783          	lh	a5,36(a0)
    80003f9a:	03079693          	slli	a3,a5,0x30
    80003f9e:	92c1                	srli	a3,a3,0x30
    80003fa0:	4725                	li	a4,9
    80003fa2:	0ad76663          	bltu	a4,a3,8000404e <filewrite+0x110>
    80003fa6:	0792                	slli	a5,a5,0x4
    80003fa8:	0001c717          	auipc	a4,0x1c
    80003fac:	b0070713          	addi	a4,a4,-1280 # 8001faa8 <devsw>
    80003fb0:	97ba                	add	a5,a5,a4
    80003fb2:	679c                	ld	a5,8(a5)
    80003fb4:	cfd9                	beqz	a5,80004052 <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    80003fb6:	4505                	li	a0,1
    80003fb8:	9782                	jalr	a5
    80003fba:	8a2a                	mv	s4,a0
    80003fbc:	a095                	j	80004020 <filewrite+0xe2>
    80003fbe:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80003fc2:	9adff0ef          	jal	ra,8000396e <begin_op>
      ilock(f->ip);
    80003fc6:	01893503          	ld	a0,24(s2)
    80003fca:	916ff0ef          	jal	ra,800030e0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80003fce:	8762                	mv	a4,s8
    80003fd0:	02092683          	lw	a3,32(s2)
    80003fd4:	01598633          	add	a2,s3,s5
    80003fd8:	4585                	li	a1,1
    80003fda:	01893503          	ld	a0,24(s2)
    80003fde:	c36ff0ef          	jal	ra,80003414 <writei>
    80003fe2:	84aa                	mv	s1,a0
    80003fe4:	00a05763          	blez	a0,80003ff2 <filewrite+0xb4>
        f->off += r;
    80003fe8:	02092783          	lw	a5,32(s2)
    80003fec:	9fa9                	addw	a5,a5,a0
    80003fee:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80003ff2:	01893503          	ld	a0,24(s2)
    80003ff6:	994ff0ef          	jal	ra,8000318a <iunlock>
      end_op();
    80003ffa:	9e5ff0ef          	jal	ra,800039de <end_op>

      if(r != n1){
    80003ffe:	009c1f63          	bne	s8,s1,8000401c <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    80004002:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004006:	0149db63          	bge	s3,s4,8000401c <filewrite+0xde>
      int n1 = n - i;
    8000400a:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    8000400e:	84be                	mv	s1,a5
    80004010:	2781                	sext.w	a5,a5
    80004012:	fafb56e3          	bge	s6,a5,80003fbe <filewrite+0x80>
    80004016:	84de                	mv	s1,s7
    80004018:	b75d                	j	80003fbe <filewrite+0x80>
    int i = 0;
    8000401a:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000401c:	013a1f63          	bne	s4,s3,8000403a <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004020:	8552                	mv	a0,s4
    80004022:	60a6                	ld	ra,72(sp)
    80004024:	6406                	ld	s0,64(sp)
    80004026:	74e2                	ld	s1,56(sp)
    80004028:	7942                	ld	s2,48(sp)
    8000402a:	79a2                	ld	s3,40(sp)
    8000402c:	7a02                	ld	s4,32(sp)
    8000402e:	6ae2                	ld	s5,24(sp)
    80004030:	6b42                	ld	s6,16(sp)
    80004032:	6ba2                	ld	s7,8(sp)
    80004034:	6c02                	ld	s8,0(sp)
    80004036:	6161                	addi	sp,sp,80
    80004038:	8082                	ret
    ret = (i == n ? n : -1);
    8000403a:	5a7d                	li	s4,-1
    8000403c:	b7d5                	j	80004020 <filewrite+0xe2>
    panic("filewrite");
    8000403e:	00003517          	auipc	a0,0x3
    80004042:	6ba50513          	addi	a0,a0,1722 # 800076f8 <syscalls+0x268>
    80004046:	f10fc0ef          	jal	ra,80000756 <panic>
    return -1;
    8000404a:	5a7d                	li	s4,-1
    8000404c:	bfd1                	j	80004020 <filewrite+0xe2>
      return -1;
    8000404e:	5a7d                	li	s4,-1
    80004050:	bfc1                	j	80004020 <filewrite+0xe2>
    80004052:	5a7d                	li	s4,-1
    80004054:	b7f1                	j	80004020 <filewrite+0xe2>

0000000080004056 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004056:	7179                	addi	sp,sp,-48
    80004058:	f406                	sd	ra,40(sp)
    8000405a:	f022                	sd	s0,32(sp)
    8000405c:	ec26                	sd	s1,24(sp)
    8000405e:	e84a                	sd	s2,16(sp)
    80004060:	e44e                	sd	s3,8(sp)
    80004062:	e052                	sd	s4,0(sp)
    80004064:	1800                	addi	s0,sp,48
    80004066:	84aa                	mv	s1,a0
    80004068:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000406a:	0005b023          	sd	zero,0(a1)
    8000406e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004072:	c75ff0ef          	jal	ra,80003ce6 <filealloc>
    80004076:	e088                	sd	a0,0(s1)
    80004078:	cd35                	beqz	a0,800040f4 <pipealloc+0x9e>
    8000407a:	c6dff0ef          	jal	ra,80003ce6 <filealloc>
    8000407e:	00aa3023          	sd	a0,0(s4)
    80004082:	c52d                	beqz	a0,800040ec <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004084:	a3ffc0ef          	jal	ra,80000ac2 <kalloc>
    80004088:	892a                	mv	s2,a0
    8000408a:	cd31                	beqz	a0,800040e6 <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    8000408c:	4985                	li	s3,1
    8000408e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004092:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004096:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000409a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000409e:	00003597          	auipc	a1,0x3
    800040a2:	66a58593          	addi	a1,a1,1642 # 80007708 <syscalls+0x278>
    800040a6:	a6dfc0ef          	jal	ra,80000b12 <initlock>
  (*f0)->type = FD_PIPE;
    800040aa:	609c                	ld	a5,0(s1)
    800040ac:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800040b0:	609c                	ld	a5,0(s1)
    800040b2:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800040b6:	609c                	ld	a5,0(s1)
    800040b8:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800040bc:	609c                	ld	a5,0(s1)
    800040be:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800040c2:	000a3783          	ld	a5,0(s4)
    800040c6:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800040ca:	000a3783          	ld	a5,0(s4)
    800040ce:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800040d2:	000a3783          	ld	a5,0(s4)
    800040d6:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800040da:	000a3783          	ld	a5,0(s4)
    800040de:	0127b823          	sd	s2,16(a5)
  return 0;
    800040e2:	4501                	li	a0,0
    800040e4:	a005                	j	80004104 <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800040e6:	6088                	ld	a0,0(s1)
    800040e8:	e501                	bnez	a0,800040f0 <pipealloc+0x9a>
    800040ea:	a029                	j	800040f4 <pipealloc+0x9e>
    800040ec:	6088                	ld	a0,0(s1)
    800040ee:	c11d                	beqz	a0,80004114 <pipealloc+0xbe>
    fileclose(*f0);
    800040f0:	c9bff0ef          	jal	ra,80003d8a <fileclose>
  if(*f1)
    800040f4:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800040f8:	557d                	li	a0,-1
  if(*f1)
    800040fa:	c789                	beqz	a5,80004104 <pipealloc+0xae>
    fileclose(*f1);
    800040fc:	853e                	mv	a0,a5
    800040fe:	c8dff0ef          	jal	ra,80003d8a <fileclose>
  return -1;
    80004102:	557d                	li	a0,-1
}
    80004104:	70a2                	ld	ra,40(sp)
    80004106:	7402                	ld	s0,32(sp)
    80004108:	64e2                	ld	s1,24(sp)
    8000410a:	6942                	ld	s2,16(sp)
    8000410c:	69a2                	ld	s3,8(sp)
    8000410e:	6a02                	ld	s4,0(sp)
    80004110:	6145                	addi	sp,sp,48
    80004112:	8082                	ret
  return -1;
    80004114:	557d                	li	a0,-1
    80004116:	b7fd                	j	80004104 <pipealloc+0xae>

0000000080004118 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004118:	1101                	addi	sp,sp,-32
    8000411a:	ec06                	sd	ra,24(sp)
    8000411c:	e822                	sd	s0,16(sp)
    8000411e:	e426                	sd	s1,8(sp)
    80004120:	e04a                	sd	s2,0(sp)
    80004122:	1000                	addi	s0,sp,32
    80004124:	84aa                	mv	s1,a0
    80004126:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004128:	a6bfc0ef          	jal	ra,80000b92 <acquire>
  if(writable){
    8000412c:	02090763          	beqz	s2,8000415a <pipeclose+0x42>
    pi->writeopen = 0;
    80004130:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004134:	21848513          	addi	a0,s1,536
    80004138:	d03fd0ef          	jal	ra,80001e3a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000413c:	2204b783          	ld	a5,544(s1)
    80004140:	e785                	bnez	a5,80004168 <pipeclose+0x50>
    release(&pi->lock);
    80004142:	8526                	mv	a0,s1
    80004144:	ae7fc0ef          	jal	ra,80000c2a <release>
    kfree((char*)pi);
    80004148:	8526                	mv	a0,s1
    8000414a:	899fc0ef          	jal	ra,800009e2 <kfree>
  } else
    release(&pi->lock);
}
    8000414e:	60e2                	ld	ra,24(sp)
    80004150:	6442                	ld	s0,16(sp)
    80004152:	64a2                	ld	s1,8(sp)
    80004154:	6902                	ld	s2,0(sp)
    80004156:	6105                	addi	sp,sp,32
    80004158:	8082                	ret
    pi->readopen = 0;
    8000415a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000415e:	21c48513          	addi	a0,s1,540
    80004162:	cd9fd0ef          	jal	ra,80001e3a <wakeup>
    80004166:	bfd9                	j	8000413c <pipeclose+0x24>
    release(&pi->lock);
    80004168:	8526                	mv	a0,s1
    8000416a:	ac1fc0ef          	jal	ra,80000c2a <release>
}
    8000416e:	b7c5                	j	8000414e <pipeclose+0x36>

0000000080004170 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004170:	711d                	addi	sp,sp,-96
    80004172:	ec86                	sd	ra,88(sp)
    80004174:	e8a2                	sd	s0,80(sp)
    80004176:	e4a6                	sd	s1,72(sp)
    80004178:	e0ca                	sd	s2,64(sp)
    8000417a:	fc4e                	sd	s3,56(sp)
    8000417c:	f852                	sd	s4,48(sp)
    8000417e:	f456                	sd	s5,40(sp)
    80004180:	f05a                	sd	s6,32(sp)
    80004182:	ec5e                	sd	s7,24(sp)
    80004184:	e862                	sd	s8,16(sp)
    80004186:	1080                	addi	s0,sp,96
    80004188:	84aa                	mv	s1,a0
    8000418a:	8aae                	mv	s5,a1
    8000418c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000418e:	e96fd0ef          	jal	ra,80001824 <myproc>
    80004192:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004194:	8526                	mv	a0,s1
    80004196:	9fdfc0ef          	jal	ra,80000b92 <acquire>
  while(i < n){
    8000419a:	09405c63          	blez	s4,80004232 <pipewrite+0xc2>
  int i = 0;
    8000419e:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800041a0:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800041a2:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800041a6:	21c48b93          	addi	s7,s1,540
    800041aa:	a81d                	j	800041e0 <pipewrite+0x70>
      release(&pi->lock);
    800041ac:	8526                	mv	a0,s1
    800041ae:	a7dfc0ef          	jal	ra,80000c2a <release>
      return -1;
    800041b2:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800041b4:	854a                	mv	a0,s2
    800041b6:	60e6                	ld	ra,88(sp)
    800041b8:	6446                	ld	s0,80(sp)
    800041ba:	64a6                	ld	s1,72(sp)
    800041bc:	6906                	ld	s2,64(sp)
    800041be:	79e2                	ld	s3,56(sp)
    800041c0:	7a42                	ld	s4,48(sp)
    800041c2:	7aa2                	ld	s5,40(sp)
    800041c4:	7b02                	ld	s6,32(sp)
    800041c6:	6be2                	ld	s7,24(sp)
    800041c8:	6c42                	ld	s8,16(sp)
    800041ca:	6125                	addi	sp,sp,96
    800041cc:	8082                	ret
      wakeup(&pi->nread);
    800041ce:	8562                	mv	a0,s8
    800041d0:	c6bfd0ef          	jal	ra,80001e3a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800041d4:	85a6                	mv	a1,s1
    800041d6:	855e                	mv	a0,s7
    800041d8:	c17fd0ef          	jal	ra,80001dee <sleep>
  while(i < n){
    800041dc:	05495c63          	bge	s2,s4,80004234 <pipewrite+0xc4>
    if(pi->readopen == 0 || killed(pr)){
    800041e0:	2204a783          	lw	a5,544(s1)
    800041e4:	d7e1                	beqz	a5,800041ac <pipewrite+0x3c>
    800041e6:	854e                	mv	a0,s3
    800041e8:	e3ffd0ef          	jal	ra,80002026 <killed>
    800041ec:	f161                	bnez	a0,800041ac <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800041ee:	2184a783          	lw	a5,536(s1)
    800041f2:	21c4a703          	lw	a4,540(s1)
    800041f6:	2007879b          	addiw	a5,a5,512
    800041fa:	fcf70ae3          	beq	a4,a5,800041ce <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800041fe:	4685                	li	a3,1
    80004200:	01590633          	add	a2,s2,s5
    80004204:	faf40593          	addi	a1,s0,-81
    80004208:	0509b503          	ld	a0,80(s3)
    8000420c:	b84fd0ef          	jal	ra,80001590 <copyin>
    80004210:	03650263          	beq	a0,s6,80004234 <pipewrite+0xc4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004214:	21c4a783          	lw	a5,540(s1)
    80004218:	0017871b          	addiw	a4,a5,1
    8000421c:	20e4ae23          	sw	a4,540(s1)
    80004220:	1ff7f793          	andi	a5,a5,511
    80004224:	97a6                	add	a5,a5,s1
    80004226:	faf44703          	lbu	a4,-81(s0)
    8000422a:	00e78c23          	sb	a4,24(a5)
      i++;
    8000422e:	2905                	addiw	s2,s2,1
    80004230:	b775                	j	800041dc <pipewrite+0x6c>
  int i = 0;
    80004232:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004234:	21848513          	addi	a0,s1,536
    80004238:	c03fd0ef          	jal	ra,80001e3a <wakeup>
  release(&pi->lock);
    8000423c:	8526                	mv	a0,s1
    8000423e:	9edfc0ef          	jal	ra,80000c2a <release>
  return i;
    80004242:	bf8d                	j	800041b4 <pipewrite+0x44>

0000000080004244 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004244:	715d                	addi	sp,sp,-80
    80004246:	e486                	sd	ra,72(sp)
    80004248:	e0a2                	sd	s0,64(sp)
    8000424a:	fc26                	sd	s1,56(sp)
    8000424c:	f84a                	sd	s2,48(sp)
    8000424e:	f44e                	sd	s3,40(sp)
    80004250:	f052                	sd	s4,32(sp)
    80004252:	ec56                	sd	s5,24(sp)
    80004254:	e85a                	sd	s6,16(sp)
    80004256:	0880                	addi	s0,sp,80
    80004258:	84aa                	mv	s1,a0
    8000425a:	892e                	mv	s2,a1
    8000425c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000425e:	dc6fd0ef          	jal	ra,80001824 <myproc>
    80004262:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004264:	8526                	mv	a0,s1
    80004266:	92dfc0ef          	jal	ra,80000b92 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000426a:	2184a703          	lw	a4,536(s1)
    8000426e:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004272:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004276:	02f71363          	bne	a4,a5,8000429c <piperead+0x58>
    8000427a:	2244a783          	lw	a5,548(s1)
    8000427e:	cf99                	beqz	a5,8000429c <piperead+0x58>
    if(killed(pr)){
    80004280:	8552                	mv	a0,s4
    80004282:	da5fd0ef          	jal	ra,80002026 <killed>
    80004286:	e141                	bnez	a0,80004306 <piperead+0xc2>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004288:	85a6                	mv	a1,s1
    8000428a:	854e                	mv	a0,s3
    8000428c:	b63fd0ef          	jal	ra,80001dee <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004290:	2184a703          	lw	a4,536(s1)
    80004294:	21c4a783          	lw	a5,540(s1)
    80004298:	fef701e3          	beq	a4,a5,8000427a <piperead+0x36>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000429c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000429e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800042a0:	05505163          	blez	s5,800042e2 <piperead+0x9e>
    if(pi->nread == pi->nwrite)
    800042a4:	2184a783          	lw	a5,536(s1)
    800042a8:	21c4a703          	lw	a4,540(s1)
    800042ac:	02f70b63          	beq	a4,a5,800042e2 <piperead+0x9e>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800042b0:	0017871b          	addiw	a4,a5,1
    800042b4:	20e4ac23          	sw	a4,536(s1)
    800042b8:	1ff7f793          	andi	a5,a5,511
    800042bc:	97a6                	add	a5,a5,s1
    800042be:	0187c783          	lbu	a5,24(a5)
    800042c2:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800042c6:	4685                	li	a3,1
    800042c8:	fbf40613          	addi	a2,s0,-65
    800042cc:	85ca                	mv	a1,s2
    800042ce:	050a3503          	ld	a0,80(s4)
    800042d2:	a06fd0ef          	jal	ra,800014d8 <copyout>
    800042d6:	01650663          	beq	a0,s6,800042e2 <piperead+0x9e>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800042da:	2985                	addiw	s3,s3,1
    800042dc:	0905                	addi	s2,s2,1
    800042de:	fd3a93e3          	bne	s5,s3,800042a4 <piperead+0x60>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800042e2:	21c48513          	addi	a0,s1,540
    800042e6:	b55fd0ef          	jal	ra,80001e3a <wakeup>
  release(&pi->lock);
    800042ea:	8526                	mv	a0,s1
    800042ec:	93ffc0ef          	jal	ra,80000c2a <release>
  return i;
}
    800042f0:	854e                	mv	a0,s3
    800042f2:	60a6                	ld	ra,72(sp)
    800042f4:	6406                	ld	s0,64(sp)
    800042f6:	74e2                	ld	s1,56(sp)
    800042f8:	7942                	ld	s2,48(sp)
    800042fa:	79a2                	ld	s3,40(sp)
    800042fc:	7a02                	ld	s4,32(sp)
    800042fe:	6ae2                	ld	s5,24(sp)
    80004300:	6b42                	ld	s6,16(sp)
    80004302:	6161                	addi	sp,sp,80
    80004304:	8082                	ret
      release(&pi->lock);
    80004306:	8526                	mv	a0,s1
    80004308:	923fc0ef          	jal	ra,80000c2a <release>
      return -1;
    8000430c:	59fd                	li	s3,-1
    8000430e:	b7cd                	j	800042f0 <piperead+0xac>

0000000080004310 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004310:	1141                	addi	sp,sp,-16
    80004312:	e422                	sd	s0,8(sp)
    80004314:	0800                	addi	s0,sp,16
    80004316:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004318:	8905                	andi	a0,a0,1
    8000431a:	c111                	beqz	a0,8000431e <flags2perm+0xe>
      perm = PTE_X;
    8000431c:	4521                	li	a0,8
    if(flags & 0x2)
    8000431e:	8b89                	andi	a5,a5,2
    80004320:	c399                	beqz	a5,80004326 <flags2perm+0x16>
      perm |= PTE_W;
    80004322:	00456513          	ori	a0,a0,4
    return perm;
}
    80004326:	6422                	ld	s0,8(sp)
    80004328:	0141                	addi	sp,sp,16
    8000432a:	8082                	ret

000000008000432c <exec>:

int
exec(char *path, char **argv)
{
    8000432c:	de010113          	addi	sp,sp,-544
    80004330:	20113c23          	sd	ra,536(sp)
    80004334:	20813823          	sd	s0,528(sp)
    80004338:	20913423          	sd	s1,520(sp)
    8000433c:	21213023          	sd	s2,512(sp)
    80004340:	ffce                	sd	s3,504(sp)
    80004342:	fbd2                	sd	s4,496(sp)
    80004344:	f7d6                	sd	s5,488(sp)
    80004346:	f3da                	sd	s6,480(sp)
    80004348:	efde                	sd	s7,472(sp)
    8000434a:	ebe2                	sd	s8,464(sp)
    8000434c:	e7e6                	sd	s9,456(sp)
    8000434e:	e3ea                	sd	s10,448(sp)
    80004350:	ff6e                	sd	s11,440(sp)
    80004352:	1400                	addi	s0,sp,544
    80004354:	892a                	mv	s2,a0
    80004356:	dea43423          	sd	a0,-536(s0)
    8000435a:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000435e:	cc6fd0ef          	jal	ra,80001824 <myproc>
    80004362:	84aa                	mv	s1,a0

  begin_op();
    80004364:	e0aff0ef          	jal	ra,8000396e <begin_op>

  if((ip = namei(path)) == 0){
    80004368:	854a                	mv	a0,s2
    8000436a:	c28ff0ef          	jal	ra,80003792 <namei>
    8000436e:	c13d                	beqz	a0,800043d4 <exec+0xa8>
    80004370:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004372:	d6ffe0ef          	jal	ra,800030e0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004376:	04000713          	li	a4,64
    8000437a:	4681                	li	a3,0
    8000437c:	e5040613          	addi	a2,s0,-432
    80004380:	4581                	li	a1,0
    80004382:	8556                	mv	a0,s5
    80004384:	fadfe0ef          	jal	ra,80003330 <readi>
    80004388:	04000793          	li	a5,64
    8000438c:	00f51a63          	bne	a0,a5,800043a0 <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004390:	e5042703          	lw	a4,-432(s0)
    80004394:	464c47b7          	lui	a5,0x464c4
    80004398:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000439c:	04f70063          	beq	a4,a5,800043dc <exec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800043a0:	8556                	mv	a0,s5
    800043a2:	f45fe0ef          	jal	ra,800032e6 <iunlockput>
    end_op();
    800043a6:	e38ff0ef          	jal	ra,800039de <end_op>
  }
  return -1;
    800043aa:	557d                	li	a0,-1
}
    800043ac:	21813083          	ld	ra,536(sp)
    800043b0:	21013403          	ld	s0,528(sp)
    800043b4:	20813483          	ld	s1,520(sp)
    800043b8:	20013903          	ld	s2,512(sp)
    800043bc:	79fe                	ld	s3,504(sp)
    800043be:	7a5e                	ld	s4,496(sp)
    800043c0:	7abe                	ld	s5,488(sp)
    800043c2:	7b1e                	ld	s6,480(sp)
    800043c4:	6bfe                	ld	s7,472(sp)
    800043c6:	6c5e                	ld	s8,464(sp)
    800043c8:	6cbe                	ld	s9,456(sp)
    800043ca:	6d1e                	ld	s10,448(sp)
    800043cc:	7dfa                	ld	s11,440(sp)
    800043ce:	22010113          	addi	sp,sp,544
    800043d2:	8082                	ret
    end_op();
    800043d4:	e0aff0ef          	jal	ra,800039de <end_op>
    return -1;
    800043d8:	557d                	li	a0,-1
    800043da:	bfc9                	j	800043ac <exec+0x80>
  if((pagetable = proc_pagetable(p)) == 0)
    800043dc:	8526                	mv	a0,s1
    800043de:	ceefd0ef          	jal	ra,800018cc <proc_pagetable>
    800043e2:	8b2a                	mv	s6,a0
    800043e4:	dd55                	beqz	a0,800043a0 <exec+0x74>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800043e6:	e7042783          	lw	a5,-400(s0)
    800043ea:	e8845703          	lhu	a4,-376(s0)
    800043ee:	c325                	beqz	a4,8000444e <exec+0x122>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800043f0:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800043f2:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800043f6:	6a05                	lui	s4,0x1
    800043f8:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800043fc:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004400:	6d85                	lui	s11,0x1
    80004402:	7d7d                	lui	s10,0xfffff
    80004404:	a411                	j	80004608 <exec+0x2dc>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004406:	00003517          	auipc	a0,0x3
    8000440a:	30a50513          	addi	a0,a0,778 # 80007710 <syscalls+0x280>
    8000440e:	b48fc0ef          	jal	ra,80000756 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004412:	874a                	mv	a4,s2
    80004414:	009c86bb          	addw	a3,s9,s1
    80004418:	4581                	li	a1,0
    8000441a:	8556                	mv	a0,s5
    8000441c:	f15fe0ef          	jal	ra,80003330 <readi>
    80004420:	2501                	sext.w	a0,a0
    80004422:	18a91263          	bne	s2,a0,800045a6 <exec+0x27a>
  for(i = 0; i < sz; i += PGSIZE){
    80004426:	009d84bb          	addw	s1,s11,s1
    8000442a:	013d09bb          	addw	s3,s10,s3
    8000442e:	1b74fd63          	bgeu	s1,s7,800045e8 <exec+0x2bc>
    pa = walkaddr(pagetable, va + i);
    80004432:	02049593          	slli	a1,s1,0x20
    80004436:	9181                	srli	a1,a1,0x20
    80004438:	95e2                	add	a1,a1,s8
    8000443a:	855a                	mv	a0,s6
    8000443c:	b41fc0ef          	jal	ra,80000f7c <walkaddr>
    80004440:	862a                	mv	a2,a0
    if(pa == 0)
    80004442:	d171                	beqz	a0,80004406 <exec+0xda>
      n = PGSIZE;
    80004444:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004446:	fd49f6e3          	bgeu	s3,s4,80004412 <exec+0xe6>
      n = sz - i;
    8000444a:	894e                	mv	s2,s3
    8000444c:	b7d9                	j	80004412 <exec+0xe6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000444e:	4901                	li	s2,0
  iunlockput(ip);
    80004450:	8556                	mv	a0,s5
    80004452:	e95fe0ef          	jal	ra,800032e6 <iunlockput>
  end_op();
    80004456:	d88ff0ef          	jal	ra,800039de <end_op>
  p = myproc();
    8000445a:	bcafd0ef          	jal	ra,80001824 <myproc>
    8000445e:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004460:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004464:	6785                	lui	a5,0x1
    80004466:	17fd                	addi	a5,a5,-1
    80004468:	993e                	add	s2,s2,a5
    8000446a:	77fd                	lui	a5,0xfffff
    8000446c:	00f977b3          	and	a5,s2,a5
    80004470:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004474:	4691                	li	a3,4
    80004476:	6609                	lui	a2,0x2
    80004478:	963e                	add	a2,a2,a5
    8000447a:	85be                	mv	a1,a5
    8000447c:	855a                	mv	a0,s6
    8000447e:	e57fc0ef          	jal	ra,800012d4 <uvmalloc>
    80004482:	8c2a                	mv	s8,a0
  ip = 0;
    80004484:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004486:	12050063          	beqz	a0,800045a6 <exec+0x27a>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    8000448a:	75f9                	lui	a1,0xffffe
    8000448c:	95aa                	add	a1,a1,a0
    8000448e:	855a                	mv	a0,s6
    80004490:	81efd0ef          	jal	ra,800014ae <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004494:	7afd                	lui	s5,0xfffff
    80004496:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004498:	df043783          	ld	a5,-528(s0)
    8000449c:	6388                	ld	a0,0(a5)
    8000449e:	c135                	beqz	a0,80004502 <exec+0x1d6>
    800044a0:	e9040993          	addi	s3,s0,-368
    800044a4:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800044a8:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800044aa:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800044ac:	933fc0ef          	jal	ra,80000dde <strlen>
    800044b0:	0015079b          	addiw	a5,a0,1
    800044b4:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800044b8:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800044bc:	11596a63          	bltu	s2,s5,800045d0 <exec+0x2a4>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800044c0:	df043d83          	ld	s11,-528(s0)
    800044c4:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800044c8:	8552                	mv	a0,s4
    800044ca:	915fc0ef          	jal	ra,80000dde <strlen>
    800044ce:	0015069b          	addiw	a3,a0,1
    800044d2:	8652                	mv	a2,s4
    800044d4:	85ca                	mv	a1,s2
    800044d6:	855a                	mv	a0,s6
    800044d8:	800fd0ef          	jal	ra,800014d8 <copyout>
    800044dc:	0e054e63          	bltz	a0,800045d8 <exec+0x2ac>
    ustack[argc] = sp;
    800044e0:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800044e4:	0485                	addi	s1,s1,1
    800044e6:	008d8793          	addi	a5,s11,8
    800044ea:	def43823          	sd	a5,-528(s0)
    800044ee:	008db503          	ld	a0,8(s11)
    800044f2:	c911                	beqz	a0,80004506 <exec+0x1da>
    if(argc >= MAXARG)
    800044f4:	09a1                	addi	s3,s3,8
    800044f6:	fb3c9be3          	bne	s9,s3,800044ac <exec+0x180>
  sz = sz1;
    800044fa:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800044fe:	4a81                	li	s5,0
    80004500:	a05d                	j	800045a6 <exec+0x27a>
  sp = sz;
    80004502:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004504:	4481                	li	s1,0
  ustack[argc] = 0;
    80004506:	00349793          	slli	a5,s1,0x3
    8000450a:	f9040713          	addi	a4,s0,-112
    8000450e:	97ba                	add	a5,a5,a4
    80004510:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffde2c0>
  sp -= (argc+1) * sizeof(uint64);
    80004514:	00148693          	addi	a3,s1,1
    80004518:	068e                	slli	a3,a3,0x3
    8000451a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000451e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004522:	01597663          	bgeu	s2,s5,8000452e <exec+0x202>
  sz = sz1;
    80004526:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000452a:	4a81                	li	s5,0
    8000452c:	a8ad                	j	800045a6 <exec+0x27a>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000452e:	e9040613          	addi	a2,s0,-368
    80004532:	85ca                	mv	a1,s2
    80004534:	855a                	mv	a0,s6
    80004536:	fa3fc0ef          	jal	ra,800014d8 <copyout>
    8000453a:	0a054363          	bltz	a0,800045e0 <exec+0x2b4>
  p->trapframe->a1 = sp;
    8000453e:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80004542:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004546:	de843783          	ld	a5,-536(s0)
    8000454a:	0007c703          	lbu	a4,0(a5)
    8000454e:	cf11                	beqz	a4,8000456a <exec+0x23e>
    80004550:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004552:	02f00693          	li	a3,47
    80004556:	a039                	j	80004564 <exec+0x238>
      last = s+1;
    80004558:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000455c:	0785                	addi	a5,a5,1
    8000455e:	fff7c703          	lbu	a4,-1(a5)
    80004562:	c701                	beqz	a4,8000456a <exec+0x23e>
    if(*s == '/')
    80004564:	fed71ce3          	bne	a4,a3,8000455c <exec+0x230>
    80004568:	bfc5                	j	80004558 <exec+0x22c>
  safestrcpy(p->name, last, sizeof(p->name));
    8000456a:	4641                	li	a2,16
    8000456c:	de843583          	ld	a1,-536(s0)
    80004570:	158b8513          	addi	a0,s7,344
    80004574:	839fc0ef          	jal	ra,80000dac <safestrcpy>
  oldpagetable = p->pagetable;
    80004578:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    8000457c:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004580:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004584:	058bb783          	ld	a5,88(s7)
    80004588:	e6843703          	ld	a4,-408(s0)
    8000458c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000458e:	058bb783          	ld	a5,88(s7)
    80004592:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004596:	85ea                	mv	a1,s10
    80004598:	bb8fd0ef          	jal	ra,80001950 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000459c:	0004851b          	sext.w	a0,s1
    800045a0:	b531                	j	800043ac <exec+0x80>
    800045a2:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800045a6:	df843583          	ld	a1,-520(s0)
    800045aa:	855a                	mv	a0,s6
    800045ac:	ba4fd0ef          	jal	ra,80001950 <proc_freepagetable>
  if(ip){
    800045b0:	de0a98e3          	bnez	s5,800043a0 <exec+0x74>
  return -1;
    800045b4:	557d                	li	a0,-1
    800045b6:	bbdd                	j	800043ac <exec+0x80>
    800045b8:	df243c23          	sd	s2,-520(s0)
    800045bc:	b7ed                	j	800045a6 <exec+0x27a>
    800045be:	df243c23          	sd	s2,-520(s0)
    800045c2:	b7d5                	j	800045a6 <exec+0x27a>
    800045c4:	df243c23          	sd	s2,-520(s0)
    800045c8:	bff9                	j	800045a6 <exec+0x27a>
    800045ca:	df243c23          	sd	s2,-520(s0)
    800045ce:	bfe1                	j	800045a6 <exec+0x27a>
  sz = sz1;
    800045d0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800045d4:	4a81                	li	s5,0
    800045d6:	bfc1                	j	800045a6 <exec+0x27a>
  sz = sz1;
    800045d8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800045dc:	4a81                	li	s5,0
    800045de:	b7e1                	j	800045a6 <exec+0x27a>
  sz = sz1;
    800045e0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800045e4:	4a81                	li	s5,0
    800045e6:	b7c1                	j	800045a6 <exec+0x27a>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800045e8:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800045ec:	e0843783          	ld	a5,-504(s0)
    800045f0:	0017869b          	addiw	a3,a5,1
    800045f4:	e0d43423          	sd	a3,-504(s0)
    800045f8:	e0043783          	ld	a5,-512(s0)
    800045fc:	0387879b          	addiw	a5,a5,56
    80004600:	e8845703          	lhu	a4,-376(s0)
    80004604:	e4e6d6e3          	bge	a3,a4,80004450 <exec+0x124>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004608:	2781                	sext.w	a5,a5
    8000460a:	e0f43023          	sd	a5,-512(s0)
    8000460e:	03800713          	li	a4,56
    80004612:	86be                	mv	a3,a5
    80004614:	e1840613          	addi	a2,s0,-488
    80004618:	4581                	li	a1,0
    8000461a:	8556                	mv	a0,s5
    8000461c:	d15fe0ef          	jal	ra,80003330 <readi>
    80004620:	03800793          	li	a5,56
    80004624:	f6f51fe3          	bne	a0,a5,800045a2 <exec+0x276>
    if(ph.type != ELF_PROG_LOAD)
    80004628:	e1842783          	lw	a5,-488(s0)
    8000462c:	4705                	li	a4,1
    8000462e:	fae79fe3          	bne	a5,a4,800045ec <exec+0x2c0>
    if(ph.memsz < ph.filesz)
    80004632:	e4043483          	ld	s1,-448(s0)
    80004636:	e3843783          	ld	a5,-456(s0)
    8000463a:	f6f4efe3          	bltu	s1,a5,800045b8 <exec+0x28c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000463e:	e2843783          	ld	a5,-472(s0)
    80004642:	94be                	add	s1,s1,a5
    80004644:	f6f4ede3          	bltu	s1,a5,800045be <exec+0x292>
    if(ph.vaddr % PGSIZE != 0)
    80004648:	de043703          	ld	a4,-544(s0)
    8000464c:	8ff9                	and	a5,a5,a4
    8000464e:	fbbd                	bnez	a5,800045c4 <exec+0x298>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004650:	e1c42503          	lw	a0,-484(s0)
    80004654:	cbdff0ef          	jal	ra,80004310 <flags2perm>
    80004658:	86aa                	mv	a3,a0
    8000465a:	8626                	mv	a2,s1
    8000465c:	85ca                	mv	a1,s2
    8000465e:	855a                	mv	a0,s6
    80004660:	c75fc0ef          	jal	ra,800012d4 <uvmalloc>
    80004664:	dea43c23          	sd	a0,-520(s0)
    80004668:	d12d                	beqz	a0,800045ca <exec+0x29e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000466a:	e2843c03          	ld	s8,-472(s0)
    8000466e:	e2042c83          	lw	s9,-480(s0)
    80004672:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004676:	f60b89e3          	beqz	s7,800045e8 <exec+0x2bc>
    8000467a:	89de                	mv	s3,s7
    8000467c:	4481                	li	s1,0
    8000467e:	bb55                	j	80004432 <exec+0x106>

0000000080004680 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004680:	7179                	addi	sp,sp,-48
    80004682:	f406                	sd	ra,40(sp)
    80004684:	f022                	sd	s0,32(sp)
    80004686:	ec26                	sd	s1,24(sp)
    80004688:	e84a                	sd	s2,16(sp)
    8000468a:	1800                	addi	s0,sp,48
    8000468c:	892e                	mv	s2,a1
    8000468e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004690:	fdc40593          	addi	a1,s0,-36
    80004694:	83cfe0ef          	jal	ra,800026d0 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004698:	fdc42703          	lw	a4,-36(s0)
    8000469c:	47bd                	li	a5,15
    8000469e:	02e7e963          	bltu	a5,a4,800046d0 <argfd+0x50>
    800046a2:	982fd0ef          	jal	ra,80001824 <myproc>
    800046a6:	fdc42703          	lw	a4,-36(s0)
    800046aa:	01a70793          	addi	a5,a4,26
    800046ae:	078e                	slli	a5,a5,0x3
    800046b0:	953e                	add	a0,a0,a5
    800046b2:	611c                	ld	a5,0(a0)
    800046b4:	c385                	beqz	a5,800046d4 <argfd+0x54>
    return -1;
  if(pfd)
    800046b6:	00090463          	beqz	s2,800046be <argfd+0x3e>
    *pfd = fd;
    800046ba:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800046be:	4501                	li	a0,0
  if(pf)
    800046c0:	c091                	beqz	s1,800046c4 <argfd+0x44>
    *pf = f;
    800046c2:	e09c                	sd	a5,0(s1)
}
    800046c4:	70a2                	ld	ra,40(sp)
    800046c6:	7402                	ld	s0,32(sp)
    800046c8:	64e2                	ld	s1,24(sp)
    800046ca:	6942                	ld	s2,16(sp)
    800046cc:	6145                	addi	sp,sp,48
    800046ce:	8082                	ret
    return -1;
    800046d0:	557d                	li	a0,-1
    800046d2:	bfcd                	j	800046c4 <argfd+0x44>
    800046d4:	557d                	li	a0,-1
    800046d6:	b7fd                	j	800046c4 <argfd+0x44>

00000000800046d8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800046d8:	1101                	addi	sp,sp,-32
    800046da:	ec06                	sd	ra,24(sp)
    800046dc:	e822                	sd	s0,16(sp)
    800046de:	e426                	sd	s1,8(sp)
    800046e0:	1000                	addi	s0,sp,32
    800046e2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800046e4:	940fd0ef          	jal	ra,80001824 <myproc>
    800046e8:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800046ea:	0d050793          	addi	a5,a0,208
    800046ee:	4501                	li	a0,0
    800046f0:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800046f2:	6398                	ld	a4,0(a5)
    800046f4:	cb19                	beqz	a4,8000470a <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800046f6:	2505                	addiw	a0,a0,1
    800046f8:	07a1                	addi	a5,a5,8
    800046fa:	fed51ce3          	bne	a0,a3,800046f2 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800046fe:	557d                	li	a0,-1
}
    80004700:	60e2                	ld	ra,24(sp)
    80004702:	6442                	ld	s0,16(sp)
    80004704:	64a2                	ld	s1,8(sp)
    80004706:	6105                	addi	sp,sp,32
    80004708:	8082                	ret
      p->ofile[fd] = f;
    8000470a:	01a50793          	addi	a5,a0,26
    8000470e:	078e                	slli	a5,a5,0x3
    80004710:	963e                	add	a2,a2,a5
    80004712:	e204                	sd	s1,0(a2)
      return fd;
    80004714:	b7f5                	j	80004700 <fdalloc+0x28>

0000000080004716 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004716:	715d                	addi	sp,sp,-80
    80004718:	e486                	sd	ra,72(sp)
    8000471a:	e0a2                	sd	s0,64(sp)
    8000471c:	fc26                	sd	s1,56(sp)
    8000471e:	f84a                	sd	s2,48(sp)
    80004720:	f44e                	sd	s3,40(sp)
    80004722:	f052                	sd	s4,32(sp)
    80004724:	ec56                	sd	s5,24(sp)
    80004726:	e85a                	sd	s6,16(sp)
    80004728:	0880                	addi	s0,sp,80
    8000472a:	8b2e                	mv	s6,a1
    8000472c:	89b2                	mv	s3,a2
    8000472e:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004730:	fb040593          	addi	a1,s0,-80
    80004734:	878ff0ef          	jal	ra,800037ac <nameiparent>
    80004738:	84aa                	mv	s1,a0
    8000473a:	10050b63          	beqz	a0,80004850 <create+0x13a>
    return 0;

  ilock(dp);
    8000473e:	9a3fe0ef          	jal	ra,800030e0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004742:	4601                	li	a2,0
    80004744:	fb040593          	addi	a1,s0,-80
    80004748:	8526                	mv	a0,s1
    8000474a:	de3fe0ef          	jal	ra,8000352c <dirlookup>
    8000474e:	8aaa                	mv	s5,a0
    80004750:	c521                	beqz	a0,80004798 <create+0x82>
    iunlockput(dp);
    80004752:	8526                	mv	a0,s1
    80004754:	b93fe0ef          	jal	ra,800032e6 <iunlockput>
    ilock(ip);
    80004758:	8556                	mv	a0,s5
    8000475a:	987fe0ef          	jal	ra,800030e0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000475e:	000b059b          	sext.w	a1,s6
    80004762:	4789                	li	a5,2
    80004764:	02f59563          	bne	a1,a5,8000478e <create+0x78>
    80004768:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffde404>
    8000476c:	37f9                	addiw	a5,a5,-2
    8000476e:	17c2                	slli	a5,a5,0x30
    80004770:	93c1                	srli	a5,a5,0x30
    80004772:	4705                	li	a4,1
    80004774:	00f76d63          	bltu	a4,a5,8000478e <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004778:	8556                	mv	a0,s5
    8000477a:	60a6                	ld	ra,72(sp)
    8000477c:	6406                	ld	s0,64(sp)
    8000477e:	74e2                	ld	s1,56(sp)
    80004780:	7942                	ld	s2,48(sp)
    80004782:	79a2                	ld	s3,40(sp)
    80004784:	7a02                	ld	s4,32(sp)
    80004786:	6ae2                	ld	s5,24(sp)
    80004788:	6b42                	ld	s6,16(sp)
    8000478a:	6161                	addi	sp,sp,80
    8000478c:	8082                	ret
    iunlockput(ip);
    8000478e:	8556                	mv	a0,s5
    80004790:	b57fe0ef          	jal	ra,800032e6 <iunlockput>
    return 0;
    80004794:	4a81                	li	s5,0
    80004796:	b7cd                	j	80004778 <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004798:	85da                	mv	a1,s6
    8000479a:	4088                	lw	a0,0(s1)
    8000479c:	fdcfe0ef          	jal	ra,80002f78 <ialloc>
    800047a0:	8a2a                	mv	s4,a0
    800047a2:	cd1d                	beqz	a0,800047e0 <create+0xca>
  ilock(ip);
    800047a4:	93dfe0ef          	jal	ra,800030e0 <ilock>
  ip->major = major;
    800047a8:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800047ac:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800047b0:	4905                	li	s2,1
    800047b2:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800047b6:	8552                	mv	a0,s4
    800047b8:	877fe0ef          	jal	ra,8000302e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800047bc:	000b059b          	sext.w	a1,s6
    800047c0:	03258563          	beq	a1,s2,800047ea <create+0xd4>
  if(dirlink(dp, name, ip->inum) < 0)
    800047c4:	004a2603          	lw	a2,4(s4)
    800047c8:	fb040593          	addi	a1,s0,-80
    800047cc:	8526                	mv	a0,s1
    800047ce:	f2bfe0ef          	jal	ra,800036f8 <dirlink>
    800047d2:	06054363          	bltz	a0,80004838 <create+0x122>
  iunlockput(dp);
    800047d6:	8526                	mv	a0,s1
    800047d8:	b0ffe0ef          	jal	ra,800032e6 <iunlockput>
  return ip;
    800047dc:	8ad2                	mv	s5,s4
    800047de:	bf69                	j	80004778 <create+0x62>
    iunlockput(dp);
    800047e0:	8526                	mv	a0,s1
    800047e2:	b05fe0ef          	jal	ra,800032e6 <iunlockput>
    return 0;
    800047e6:	8ad2                	mv	s5,s4
    800047e8:	bf41                	j	80004778 <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800047ea:	004a2603          	lw	a2,4(s4)
    800047ee:	00003597          	auipc	a1,0x3
    800047f2:	f4258593          	addi	a1,a1,-190 # 80007730 <syscalls+0x2a0>
    800047f6:	8552                	mv	a0,s4
    800047f8:	f01fe0ef          	jal	ra,800036f8 <dirlink>
    800047fc:	02054e63          	bltz	a0,80004838 <create+0x122>
    80004800:	40d0                	lw	a2,4(s1)
    80004802:	00003597          	auipc	a1,0x3
    80004806:	f3658593          	addi	a1,a1,-202 # 80007738 <syscalls+0x2a8>
    8000480a:	8552                	mv	a0,s4
    8000480c:	eedfe0ef          	jal	ra,800036f8 <dirlink>
    80004810:	02054463          	bltz	a0,80004838 <create+0x122>
  if(dirlink(dp, name, ip->inum) < 0)
    80004814:	004a2603          	lw	a2,4(s4)
    80004818:	fb040593          	addi	a1,s0,-80
    8000481c:	8526                	mv	a0,s1
    8000481e:	edbfe0ef          	jal	ra,800036f8 <dirlink>
    80004822:	00054b63          	bltz	a0,80004838 <create+0x122>
    dp->nlink++;  // for ".."
    80004826:	04a4d783          	lhu	a5,74(s1)
    8000482a:	2785                	addiw	a5,a5,1
    8000482c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004830:	8526                	mv	a0,s1
    80004832:	ffcfe0ef          	jal	ra,8000302e <iupdate>
    80004836:	b745                	j	800047d6 <create+0xc0>
  ip->nlink = 0;
    80004838:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000483c:	8552                	mv	a0,s4
    8000483e:	ff0fe0ef          	jal	ra,8000302e <iupdate>
  iunlockput(ip);
    80004842:	8552                	mv	a0,s4
    80004844:	aa3fe0ef          	jal	ra,800032e6 <iunlockput>
  iunlockput(dp);
    80004848:	8526                	mv	a0,s1
    8000484a:	a9dfe0ef          	jal	ra,800032e6 <iunlockput>
  return 0;
    8000484e:	b72d                	j	80004778 <create+0x62>
    return 0;
    80004850:	8aaa                	mv	s5,a0
    80004852:	b71d                	j	80004778 <create+0x62>

0000000080004854 <sys_dup>:
{
    80004854:	7179                	addi	sp,sp,-48
    80004856:	f406                	sd	ra,40(sp)
    80004858:	f022                	sd	s0,32(sp)
    8000485a:	ec26                	sd	s1,24(sp)
    8000485c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000485e:	fd840613          	addi	a2,s0,-40
    80004862:	4581                	li	a1,0
    80004864:	4501                	li	a0,0
    80004866:	e1bff0ef          	jal	ra,80004680 <argfd>
    return -1;
    8000486a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000486c:	00054f63          	bltz	a0,8000488a <sys_dup+0x36>
  if((fd=fdalloc(f)) < 0)
    80004870:	fd843503          	ld	a0,-40(s0)
    80004874:	e65ff0ef          	jal	ra,800046d8 <fdalloc>
    80004878:	84aa                	mv	s1,a0
    return -1;
    8000487a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000487c:	00054763          	bltz	a0,8000488a <sys_dup+0x36>
  filedup(f);
    80004880:	fd843503          	ld	a0,-40(s0)
    80004884:	cc0ff0ef          	jal	ra,80003d44 <filedup>
  return fd;
    80004888:	87a6                	mv	a5,s1
}
    8000488a:	853e                	mv	a0,a5
    8000488c:	70a2                	ld	ra,40(sp)
    8000488e:	7402                	ld	s0,32(sp)
    80004890:	64e2                	ld	s1,24(sp)
    80004892:	6145                	addi	sp,sp,48
    80004894:	8082                	ret

0000000080004896 <sys_read>:
{
    80004896:	7179                	addi	sp,sp,-48
    80004898:	f406                	sd	ra,40(sp)
    8000489a:	f022                	sd	s0,32(sp)
    8000489c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000489e:	fd840593          	addi	a1,s0,-40
    800048a2:	4505                	li	a0,1
    800048a4:	e49fd0ef          	jal	ra,800026ec <argaddr>
  argint(2, &n);
    800048a8:	fe440593          	addi	a1,s0,-28
    800048ac:	4509                	li	a0,2
    800048ae:	e23fd0ef          	jal	ra,800026d0 <argint>
  if(argfd(0, 0, &f) < 0)
    800048b2:	fe840613          	addi	a2,s0,-24
    800048b6:	4581                	li	a1,0
    800048b8:	4501                	li	a0,0
    800048ba:	dc7ff0ef          	jal	ra,80004680 <argfd>
    800048be:	87aa                	mv	a5,a0
    return -1;
    800048c0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800048c2:	0007ca63          	bltz	a5,800048d6 <sys_read+0x40>
  return fileread(f, p, n);
    800048c6:	fe442603          	lw	a2,-28(s0)
    800048ca:	fd843583          	ld	a1,-40(s0)
    800048ce:	fe843503          	ld	a0,-24(s0)
    800048d2:	dbeff0ef          	jal	ra,80003e90 <fileread>
}
    800048d6:	70a2                	ld	ra,40(sp)
    800048d8:	7402                	ld	s0,32(sp)
    800048da:	6145                	addi	sp,sp,48
    800048dc:	8082                	ret

00000000800048de <sys_write>:
{
    800048de:	7179                	addi	sp,sp,-48
    800048e0:	f406                	sd	ra,40(sp)
    800048e2:	f022                	sd	s0,32(sp)
    800048e4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800048e6:	fd840593          	addi	a1,s0,-40
    800048ea:	4505                	li	a0,1
    800048ec:	e01fd0ef          	jal	ra,800026ec <argaddr>
  argint(2, &n);
    800048f0:	fe440593          	addi	a1,s0,-28
    800048f4:	4509                	li	a0,2
    800048f6:	ddbfd0ef          	jal	ra,800026d0 <argint>
  if(argfd(0, 0, &f) < 0)
    800048fa:	fe840613          	addi	a2,s0,-24
    800048fe:	4581                	li	a1,0
    80004900:	4501                	li	a0,0
    80004902:	d7fff0ef          	jal	ra,80004680 <argfd>
    80004906:	87aa                	mv	a5,a0
    return -1;
    80004908:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000490a:	0007ca63          	bltz	a5,8000491e <sys_write+0x40>
  return filewrite(f, p, n);
    8000490e:	fe442603          	lw	a2,-28(s0)
    80004912:	fd843583          	ld	a1,-40(s0)
    80004916:	fe843503          	ld	a0,-24(s0)
    8000491a:	e24ff0ef          	jal	ra,80003f3e <filewrite>
}
    8000491e:	70a2                	ld	ra,40(sp)
    80004920:	7402                	ld	s0,32(sp)
    80004922:	6145                	addi	sp,sp,48
    80004924:	8082                	ret

0000000080004926 <sys_close>:
{
    80004926:	1101                	addi	sp,sp,-32
    80004928:	ec06                	sd	ra,24(sp)
    8000492a:	e822                	sd	s0,16(sp)
    8000492c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000492e:	fe040613          	addi	a2,s0,-32
    80004932:	fec40593          	addi	a1,s0,-20
    80004936:	4501                	li	a0,0
    80004938:	d49ff0ef          	jal	ra,80004680 <argfd>
    return -1;
    8000493c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000493e:	02054063          	bltz	a0,8000495e <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004942:	ee3fc0ef          	jal	ra,80001824 <myproc>
    80004946:	fec42783          	lw	a5,-20(s0)
    8000494a:	07e9                	addi	a5,a5,26
    8000494c:	078e                	slli	a5,a5,0x3
    8000494e:	97aa                	add	a5,a5,a0
    80004950:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80004954:	fe043503          	ld	a0,-32(s0)
    80004958:	c32ff0ef          	jal	ra,80003d8a <fileclose>
  return 0;
    8000495c:	4781                	li	a5,0
}
    8000495e:	853e                	mv	a0,a5
    80004960:	60e2                	ld	ra,24(sp)
    80004962:	6442                	ld	s0,16(sp)
    80004964:	6105                	addi	sp,sp,32
    80004966:	8082                	ret

0000000080004968 <sys_fstat>:
{
    80004968:	1101                	addi	sp,sp,-32
    8000496a:	ec06                	sd	ra,24(sp)
    8000496c:	e822                	sd	s0,16(sp)
    8000496e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004970:	fe040593          	addi	a1,s0,-32
    80004974:	4505                	li	a0,1
    80004976:	d77fd0ef          	jal	ra,800026ec <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000497a:	fe840613          	addi	a2,s0,-24
    8000497e:	4581                	li	a1,0
    80004980:	4501                	li	a0,0
    80004982:	cffff0ef          	jal	ra,80004680 <argfd>
    80004986:	87aa                	mv	a5,a0
    return -1;
    80004988:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000498a:	0007c863          	bltz	a5,8000499a <sys_fstat+0x32>
  return filestat(f, st);
    8000498e:	fe043583          	ld	a1,-32(s0)
    80004992:	fe843503          	ld	a0,-24(s0)
    80004996:	c9cff0ef          	jal	ra,80003e32 <filestat>
}
    8000499a:	60e2                	ld	ra,24(sp)
    8000499c:	6442                	ld	s0,16(sp)
    8000499e:	6105                	addi	sp,sp,32
    800049a0:	8082                	ret

00000000800049a2 <sys_link>:
{
    800049a2:	7169                	addi	sp,sp,-304
    800049a4:	f606                	sd	ra,296(sp)
    800049a6:	f222                	sd	s0,288(sp)
    800049a8:	ee26                	sd	s1,280(sp)
    800049aa:	ea4a                	sd	s2,272(sp)
    800049ac:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800049ae:	08000613          	li	a2,128
    800049b2:	ed040593          	addi	a1,s0,-304
    800049b6:	4501                	li	a0,0
    800049b8:	d51fd0ef          	jal	ra,80002708 <argstr>
    return -1;
    800049bc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800049be:	0c054663          	bltz	a0,80004a8a <sys_link+0xe8>
    800049c2:	08000613          	li	a2,128
    800049c6:	f5040593          	addi	a1,s0,-176
    800049ca:	4505                	li	a0,1
    800049cc:	d3dfd0ef          	jal	ra,80002708 <argstr>
    return -1;
    800049d0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800049d2:	0a054c63          	bltz	a0,80004a8a <sys_link+0xe8>
  begin_op();
    800049d6:	f99fe0ef          	jal	ra,8000396e <begin_op>
  if((ip = namei(old)) == 0){
    800049da:	ed040513          	addi	a0,s0,-304
    800049de:	db5fe0ef          	jal	ra,80003792 <namei>
    800049e2:	84aa                	mv	s1,a0
    800049e4:	c525                	beqz	a0,80004a4c <sys_link+0xaa>
  ilock(ip);
    800049e6:	efafe0ef          	jal	ra,800030e0 <ilock>
  if(ip->type == T_DIR){
    800049ea:	04449703          	lh	a4,68(s1)
    800049ee:	4785                	li	a5,1
    800049f0:	06f70263          	beq	a4,a5,80004a54 <sys_link+0xb2>
  ip->nlink++;
    800049f4:	04a4d783          	lhu	a5,74(s1)
    800049f8:	2785                	addiw	a5,a5,1
    800049fa:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800049fe:	8526                	mv	a0,s1
    80004a00:	e2efe0ef          	jal	ra,8000302e <iupdate>
  iunlock(ip);
    80004a04:	8526                	mv	a0,s1
    80004a06:	f84fe0ef          	jal	ra,8000318a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004a0a:	fd040593          	addi	a1,s0,-48
    80004a0e:	f5040513          	addi	a0,s0,-176
    80004a12:	d9bfe0ef          	jal	ra,800037ac <nameiparent>
    80004a16:	892a                	mv	s2,a0
    80004a18:	c921                	beqz	a0,80004a68 <sys_link+0xc6>
  ilock(dp);
    80004a1a:	ec6fe0ef          	jal	ra,800030e0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004a1e:	00092703          	lw	a4,0(s2)
    80004a22:	409c                	lw	a5,0(s1)
    80004a24:	02f71f63          	bne	a4,a5,80004a62 <sys_link+0xc0>
    80004a28:	40d0                	lw	a2,4(s1)
    80004a2a:	fd040593          	addi	a1,s0,-48
    80004a2e:	854a                	mv	a0,s2
    80004a30:	cc9fe0ef          	jal	ra,800036f8 <dirlink>
    80004a34:	02054763          	bltz	a0,80004a62 <sys_link+0xc0>
  iunlockput(dp);
    80004a38:	854a                	mv	a0,s2
    80004a3a:	8adfe0ef          	jal	ra,800032e6 <iunlockput>
  iput(ip);
    80004a3e:	8526                	mv	a0,s1
    80004a40:	81ffe0ef          	jal	ra,8000325e <iput>
  end_op();
    80004a44:	f9bfe0ef          	jal	ra,800039de <end_op>
  return 0;
    80004a48:	4781                	li	a5,0
    80004a4a:	a081                	j	80004a8a <sys_link+0xe8>
    end_op();
    80004a4c:	f93fe0ef          	jal	ra,800039de <end_op>
    return -1;
    80004a50:	57fd                	li	a5,-1
    80004a52:	a825                	j	80004a8a <sys_link+0xe8>
    iunlockput(ip);
    80004a54:	8526                	mv	a0,s1
    80004a56:	891fe0ef          	jal	ra,800032e6 <iunlockput>
    end_op();
    80004a5a:	f85fe0ef          	jal	ra,800039de <end_op>
    return -1;
    80004a5e:	57fd                	li	a5,-1
    80004a60:	a02d                	j	80004a8a <sys_link+0xe8>
    iunlockput(dp);
    80004a62:	854a                	mv	a0,s2
    80004a64:	883fe0ef          	jal	ra,800032e6 <iunlockput>
  ilock(ip);
    80004a68:	8526                	mv	a0,s1
    80004a6a:	e76fe0ef          	jal	ra,800030e0 <ilock>
  ip->nlink--;
    80004a6e:	04a4d783          	lhu	a5,74(s1)
    80004a72:	37fd                	addiw	a5,a5,-1
    80004a74:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004a78:	8526                	mv	a0,s1
    80004a7a:	db4fe0ef          	jal	ra,8000302e <iupdate>
  iunlockput(ip);
    80004a7e:	8526                	mv	a0,s1
    80004a80:	867fe0ef          	jal	ra,800032e6 <iunlockput>
  end_op();
    80004a84:	f5bfe0ef          	jal	ra,800039de <end_op>
  return -1;
    80004a88:	57fd                	li	a5,-1
}
    80004a8a:	853e                	mv	a0,a5
    80004a8c:	70b2                	ld	ra,296(sp)
    80004a8e:	7412                	ld	s0,288(sp)
    80004a90:	64f2                	ld	s1,280(sp)
    80004a92:	6952                	ld	s2,272(sp)
    80004a94:	6155                	addi	sp,sp,304
    80004a96:	8082                	ret

0000000080004a98 <sys_unlink>:
{
    80004a98:	7151                	addi	sp,sp,-240
    80004a9a:	f586                	sd	ra,232(sp)
    80004a9c:	f1a2                	sd	s0,224(sp)
    80004a9e:	eda6                	sd	s1,216(sp)
    80004aa0:	e9ca                	sd	s2,208(sp)
    80004aa2:	e5ce                	sd	s3,200(sp)
    80004aa4:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004aa6:	08000613          	li	a2,128
    80004aaa:	f3040593          	addi	a1,s0,-208
    80004aae:	4501                	li	a0,0
    80004ab0:	c59fd0ef          	jal	ra,80002708 <argstr>
    80004ab4:	12054b63          	bltz	a0,80004bea <sys_unlink+0x152>
  begin_op();
    80004ab8:	eb7fe0ef          	jal	ra,8000396e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004abc:	fb040593          	addi	a1,s0,-80
    80004ac0:	f3040513          	addi	a0,s0,-208
    80004ac4:	ce9fe0ef          	jal	ra,800037ac <nameiparent>
    80004ac8:	84aa                	mv	s1,a0
    80004aca:	c54d                	beqz	a0,80004b74 <sys_unlink+0xdc>
  ilock(dp);
    80004acc:	e14fe0ef          	jal	ra,800030e0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004ad0:	00003597          	auipc	a1,0x3
    80004ad4:	c6058593          	addi	a1,a1,-928 # 80007730 <syscalls+0x2a0>
    80004ad8:	fb040513          	addi	a0,s0,-80
    80004adc:	a3bfe0ef          	jal	ra,80003516 <namecmp>
    80004ae0:	10050a63          	beqz	a0,80004bf4 <sys_unlink+0x15c>
    80004ae4:	00003597          	auipc	a1,0x3
    80004ae8:	c5458593          	addi	a1,a1,-940 # 80007738 <syscalls+0x2a8>
    80004aec:	fb040513          	addi	a0,s0,-80
    80004af0:	a27fe0ef          	jal	ra,80003516 <namecmp>
    80004af4:	10050063          	beqz	a0,80004bf4 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004af8:	f2c40613          	addi	a2,s0,-212
    80004afc:	fb040593          	addi	a1,s0,-80
    80004b00:	8526                	mv	a0,s1
    80004b02:	a2bfe0ef          	jal	ra,8000352c <dirlookup>
    80004b06:	892a                	mv	s2,a0
    80004b08:	0e050663          	beqz	a0,80004bf4 <sys_unlink+0x15c>
  ilock(ip);
    80004b0c:	dd4fe0ef          	jal	ra,800030e0 <ilock>
  if(ip->nlink < 1)
    80004b10:	04a91783          	lh	a5,74(s2)
    80004b14:	06f05463          	blez	a5,80004b7c <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004b18:	04491703          	lh	a4,68(s2)
    80004b1c:	4785                	li	a5,1
    80004b1e:	06f70563          	beq	a4,a5,80004b88 <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    80004b22:	4641                	li	a2,16
    80004b24:	4581                	li	a1,0
    80004b26:	fc040513          	addi	a0,s0,-64
    80004b2a:	93cfc0ef          	jal	ra,80000c66 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004b2e:	4741                	li	a4,16
    80004b30:	f2c42683          	lw	a3,-212(s0)
    80004b34:	fc040613          	addi	a2,s0,-64
    80004b38:	4581                	li	a1,0
    80004b3a:	8526                	mv	a0,s1
    80004b3c:	8d9fe0ef          	jal	ra,80003414 <writei>
    80004b40:	47c1                	li	a5,16
    80004b42:	08f51563          	bne	a0,a5,80004bcc <sys_unlink+0x134>
  if(ip->type == T_DIR){
    80004b46:	04491703          	lh	a4,68(s2)
    80004b4a:	4785                	li	a5,1
    80004b4c:	08f70663          	beq	a4,a5,80004bd8 <sys_unlink+0x140>
  iunlockput(dp);
    80004b50:	8526                	mv	a0,s1
    80004b52:	f94fe0ef          	jal	ra,800032e6 <iunlockput>
  ip->nlink--;
    80004b56:	04a95783          	lhu	a5,74(s2)
    80004b5a:	37fd                	addiw	a5,a5,-1
    80004b5c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004b60:	854a                	mv	a0,s2
    80004b62:	cccfe0ef          	jal	ra,8000302e <iupdate>
  iunlockput(ip);
    80004b66:	854a                	mv	a0,s2
    80004b68:	f7efe0ef          	jal	ra,800032e6 <iunlockput>
  end_op();
    80004b6c:	e73fe0ef          	jal	ra,800039de <end_op>
  return 0;
    80004b70:	4501                	li	a0,0
    80004b72:	a079                	j	80004c00 <sys_unlink+0x168>
    end_op();
    80004b74:	e6bfe0ef          	jal	ra,800039de <end_op>
    return -1;
    80004b78:	557d                	li	a0,-1
    80004b7a:	a059                	j	80004c00 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80004b7c:	00003517          	auipc	a0,0x3
    80004b80:	bc450513          	addi	a0,a0,-1084 # 80007740 <syscalls+0x2b0>
    80004b84:	bd3fb0ef          	jal	ra,80000756 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004b88:	04c92703          	lw	a4,76(s2)
    80004b8c:	02000793          	li	a5,32
    80004b90:	f8e7f9e3          	bgeu	a5,a4,80004b22 <sys_unlink+0x8a>
    80004b94:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004b98:	4741                	li	a4,16
    80004b9a:	86ce                	mv	a3,s3
    80004b9c:	f1840613          	addi	a2,s0,-232
    80004ba0:	4581                	li	a1,0
    80004ba2:	854a                	mv	a0,s2
    80004ba4:	f8cfe0ef          	jal	ra,80003330 <readi>
    80004ba8:	47c1                	li	a5,16
    80004baa:	00f51b63          	bne	a0,a5,80004bc0 <sys_unlink+0x128>
    if(de.inum != 0)
    80004bae:	f1845783          	lhu	a5,-232(s0)
    80004bb2:	ef95                	bnez	a5,80004bee <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004bb4:	29c1                	addiw	s3,s3,16
    80004bb6:	04c92783          	lw	a5,76(s2)
    80004bba:	fcf9efe3          	bltu	s3,a5,80004b98 <sys_unlink+0x100>
    80004bbe:	b795                	j	80004b22 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004bc0:	00003517          	auipc	a0,0x3
    80004bc4:	b9850513          	addi	a0,a0,-1128 # 80007758 <syscalls+0x2c8>
    80004bc8:	b8ffb0ef          	jal	ra,80000756 <panic>
    panic("unlink: writei");
    80004bcc:	00003517          	auipc	a0,0x3
    80004bd0:	ba450513          	addi	a0,a0,-1116 # 80007770 <syscalls+0x2e0>
    80004bd4:	b83fb0ef          	jal	ra,80000756 <panic>
    dp->nlink--;
    80004bd8:	04a4d783          	lhu	a5,74(s1)
    80004bdc:	37fd                	addiw	a5,a5,-1
    80004bde:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004be2:	8526                	mv	a0,s1
    80004be4:	c4afe0ef          	jal	ra,8000302e <iupdate>
    80004be8:	b7a5                	j	80004b50 <sys_unlink+0xb8>
    return -1;
    80004bea:	557d                	li	a0,-1
    80004bec:	a811                	j	80004c00 <sys_unlink+0x168>
    iunlockput(ip);
    80004bee:	854a                	mv	a0,s2
    80004bf0:	ef6fe0ef          	jal	ra,800032e6 <iunlockput>
  iunlockput(dp);
    80004bf4:	8526                	mv	a0,s1
    80004bf6:	ef0fe0ef          	jal	ra,800032e6 <iunlockput>
  end_op();
    80004bfa:	de5fe0ef          	jal	ra,800039de <end_op>
  return -1;
    80004bfe:	557d                	li	a0,-1
}
    80004c00:	70ae                	ld	ra,232(sp)
    80004c02:	740e                	ld	s0,224(sp)
    80004c04:	64ee                	ld	s1,216(sp)
    80004c06:	694e                	ld	s2,208(sp)
    80004c08:	69ae                	ld	s3,200(sp)
    80004c0a:	616d                	addi	sp,sp,240
    80004c0c:	8082                	ret

0000000080004c0e <sys_open>:

uint64
sys_open(void)
{
    80004c0e:	7131                	addi	sp,sp,-192
    80004c10:	fd06                	sd	ra,184(sp)
    80004c12:	f922                	sd	s0,176(sp)
    80004c14:	f526                	sd	s1,168(sp)
    80004c16:	f14a                	sd	s2,160(sp)
    80004c18:	ed4e                	sd	s3,152(sp)
    80004c1a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004c1c:	f4c40593          	addi	a1,s0,-180
    80004c20:	4505                	li	a0,1
    80004c22:	aaffd0ef          	jal	ra,800026d0 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004c26:	08000613          	li	a2,128
    80004c2a:	f5040593          	addi	a1,s0,-176
    80004c2e:	4501                	li	a0,0
    80004c30:	ad9fd0ef          	jal	ra,80002708 <argstr>
    80004c34:	87aa                	mv	a5,a0
    return -1;
    80004c36:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004c38:	0807cd63          	bltz	a5,80004cd2 <sys_open+0xc4>

  begin_op();
    80004c3c:	d33fe0ef          	jal	ra,8000396e <begin_op>

  if(omode & O_CREATE){
    80004c40:	f4c42783          	lw	a5,-180(s0)
    80004c44:	2007f793          	andi	a5,a5,512
    80004c48:	c3c5                	beqz	a5,80004ce8 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004c4a:	4681                	li	a3,0
    80004c4c:	4601                	li	a2,0
    80004c4e:	4589                	li	a1,2
    80004c50:	f5040513          	addi	a0,s0,-176
    80004c54:	ac3ff0ef          	jal	ra,80004716 <create>
    80004c58:	84aa                	mv	s1,a0
    if(ip == 0){
    80004c5a:	c159                	beqz	a0,80004ce0 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004c5c:	04449703          	lh	a4,68(s1)
    80004c60:	478d                	li	a5,3
    80004c62:	00f71763          	bne	a4,a5,80004c70 <sys_open+0x62>
    80004c66:	0464d703          	lhu	a4,70(s1)
    80004c6a:	47a5                	li	a5,9
    80004c6c:	0ae7e963          	bltu	a5,a4,80004d1e <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004c70:	876ff0ef          	jal	ra,80003ce6 <filealloc>
    80004c74:	89aa                	mv	s3,a0
    80004c76:	0c050963          	beqz	a0,80004d48 <sys_open+0x13a>
    80004c7a:	a5fff0ef          	jal	ra,800046d8 <fdalloc>
    80004c7e:	892a                	mv	s2,a0
    80004c80:	0c054163          	bltz	a0,80004d42 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004c84:	04449703          	lh	a4,68(s1)
    80004c88:	478d                	li	a5,3
    80004c8a:	0af70163          	beq	a4,a5,80004d2c <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004c8e:	4789                	li	a5,2
    80004c90:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80004c94:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80004c98:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80004c9c:	f4c42783          	lw	a5,-180(s0)
    80004ca0:	0017c713          	xori	a4,a5,1
    80004ca4:	8b05                	andi	a4,a4,1
    80004ca6:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004caa:	0037f713          	andi	a4,a5,3
    80004cae:	00e03733          	snez	a4,a4
    80004cb2:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004cb6:	4007f793          	andi	a5,a5,1024
    80004cba:	c791                	beqz	a5,80004cc6 <sys_open+0xb8>
    80004cbc:	04449703          	lh	a4,68(s1)
    80004cc0:	4789                	li	a5,2
    80004cc2:	06f70c63          	beq	a4,a5,80004d3a <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    80004cc6:	8526                	mv	a0,s1
    80004cc8:	cc2fe0ef          	jal	ra,8000318a <iunlock>
  end_op();
    80004ccc:	d13fe0ef          	jal	ra,800039de <end_op>

  return fd;
    80004cd0:	854a                	mv	a0,s2
}
    80004cd2:	70ea                	ld	ra,184(sp)
    80004cd4:	744a                	ld	s0,176(sp)
    80004cd6:	74aa                	ld	s1,168(sp)
    80004cd8:	790a                	ld	s2,160(sp)
    80004cda:	69ea                	ld	s3,152(sp)
    80004cdc:	6129                	addi	sp,sp,192
    80004cde:	8082                	ret
      end_op();
    80004ce0:	cfffe0ef          	jal	ra,800039de <end_op>
      return -1;
    80004ce4:	557d                	li	a0,-1
    80004ce6:	b7f5                	j	80004cd2 <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    80004ce8:	f5040513          	addi	a0,s0,-176
    80004cec:	aa7fe0ef          	jal	ra,80003792 <namei>
    80004cf0:	84aa                	mv	s1,a0
    80004cf2:	c115                	beqz	a0,80004d16 <sys_open+0x108>
    ilock(ip);
    80004cf4:	becfe0ef          	jal	ra,800030e0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004cf8:	04449703          	lh	a4,68(s1)
    80004cfc:	4785                	li	a5,1
    80004cfe:	f4f71fe3          	bne	a4,a5,80004c5c <sys_open+0x4e>
    80004d02:	f4c42783          	lw	a5,-180(s0)
    80004d06:	d7ad                	beqz	a5,80004c70 <sys_open+0x62>
      iunlockput(ip);
    80004d08:	8526                	mv	a0,s1
    80004d0a:	ddcfe0ef          	jal	ra,800032e6 <iunlockput>
      end_op();
    80004d0e:	cd1fe0ef          	jal	ra,800039de <end_op>
      return -1;
    80004d12:	557d                	li	a0,-1
    80004d14:	bf7d                	j	80004cd2 <sys_open+0xc4>
      end_op();
    80004d16:	cc9fe0ef          	jal	ra,800039de <end_op>
      return -1;
    80004d1a:	557d                	li	a0,-1
    80004d1c:	bf5d                	j	80004cd2 <sys_open+0xc4>
    iunlockput(ip);
    80004d1e:	8526                	mv	a0,s1
    80004d20:	dc6fe0ef          	jal	ra,800032e6 <iunlockput>
    end_op();
    80004d24:	cbbfe0ef          	jal	ra,800039de <end_op>
    return -1;
    80004d28:	557d                	li	a0,-1
    80004d2a:	b765                	j	80004cd2 <sys_open+0xc4>
    f->type = FD_DEVICE;
    80004d2c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80004d30:	04649783          	lh	a5,70(s1)
    80004d34:	02f99223          	sh	a5,36(s3)
    80004d38:	b785                	j	80004c98 <sys_open+0x8a>
    itrunc(ip);
    80004d3a:	8526                	mv	a0,s1
    80004d3c:	c8efe0ef          	jal	ra,800031ca <itrunc>
    80004d40:	b759                	j	80004cc6 <sys_open+0xb8>
      fileclose(f);
    80004d42:	854e                	mv	a0,s3
    80004d44:	846ff0ef          	jal	ra,80003d8a <fileclose>
    iunlockput(ip);
    80004d48:	8526                	mv	a0,s1
    80004d4a:	d9cfe0ef          	jal	ra,800032e6 <iunlockput>
    end_op();
    80004d4e:	c91fe0ef          	jal	ra,800039de <end_op>
    return -1;
    80004d52:	557d                	li	a0,-1
    80004d54:	bfbd                	j	80004cd2 <sys_open+0xc4>

0000000080004d56 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004d56:	7175                	addi	sp,sp,-144
    80004d58:	e506                	sd	ra,136(sp)
    80004d5a:	e122                	sd	s0,128(sp)
    80004d5c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004d5e:	c11fe0ef          	jal	ra,8000396e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004d62:	08000613          	li	a2,128
    80004d66:	f7040593          	addi	a1,s0,-144
    80004d6a:	4501                	li	a0,0
    80004d6c:	99dfd0ef          	jal	ra,80002708 <argstr>
    80004d70:	02054363          	bltz	a0,80004d96 <sys_mkdir+0x40>
    80004d74:	4681                	li	a3,0
    80004d76:	4601                	li	a2,0
    80004d78:	4585                	li	a1,1
    80004d7a:	f7040513          	addi	a0,s0,-144
    80004d7e:	999ff0ef          	jal	ra,80004716 <create>
    80004d82:	c911                	beqz	a0,80004d96 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004d84:	d62fe0ef          	jal	ra,800032e6 <iunlockput>
  end_op();
    80004d88:	c57fe0ef          	jal	ra,800039de <end_op>
  return 0;
    80004d8c:	4501                	li	a0,0
}
    80004d8e:	60aa                	ld	ra,136(sp)
    80004d90:	640a                	ld	s0,128(sp)
    80004d92:	6149                	addi	sp,sp,144
    80004d94:	8082                	ret
    end_op();
    80004d96:	c49fe0ef          	jal	ra,800039de <end_op>
    return -1;
    80004d9a:	557d                	li	a0,-1
    80004d9c:	bfcd                	j	80004d8e <sys_mkdir+0x38>

0000000080004d9e <sys_mknod>:

uint64
sys_mknod(void)
{
    80004d9e:	7135                	addi	sp,sp,-160
    80004da0:	ed06                	sd	ra,152(sp)
    80004da2:	e922                	sd	s0,144(sp)
    80004da4:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004da6:	bc9fe0ef          	jal	ra,8000396e <begin_op>
  argint(1, &major);
    80004daa:	f6c40593          	addi	a1,s0,-148
    80004dae:	4505                	li	a0,1
    80004db0:	921fd0ef          	jal	ra,800026d0 <argint>
  argint(2, &minor);
    80004db4:	f6840593          	addi	a1,s0,-152
    80004db8:	4509                	li	a0,2
    80004dba:	917fd0ef          	jal	ra,800026d0 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004dbe:	08000613          	li	a2,128
    80004dc2:	f7040593          	addi	a1,s0,-144
    80004dc6:	4501                	li	a0,0
    80004dc8:	941fd0ef          	jal	ra,80002708 <argstr>
    80004dcc:	02054563          	bltz	a0,80004df6 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004dd0:	f6841683          	lh	a3,-152(s0)
    80004dd4:	f6c41603          	lh	a2,-148(s0)
    80004dd8:	458d                	li	a1,3
    80004dda:	f7040513          	addi	a0,s0,-144
    80004dde:	939ff0ef          	jal	ra,80004716 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004de2:	c911                	beqz	a0,80004df6 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004de4:	d02fe0ef          	jal	ra,800032e6 <iunlockput>
  end_op();
    80004de8:	bf7fe0ef          	jal	ra,800039de <end_op>
  return 0;
    80004dec:	4501                	li	a0,0
}
    80004dee:	60ea                	ld	ra,152(sp)
    80004df0:	644a                	ld	s0,144(sp)
    80004df2:	610d                	addi	sp,sp,160
    80004df4:	8082                	ret
    end_op();
    80004df6:	be9fe0ef          	jal	ra,800039de <end_op>
    return -1;
    80004dfa:	557d                	li	a0,-1
    80004dfc:	bfcd                	j	80004dee <sys_mknod+0x50>

0000000080004dfe <sys_chdir>:

uint64
sys_chdir(void)
{
    80004dfe:	7135                	addi	sp,sp,-160
    80004e00:	ed06                	sd	ra,152(sp)
    80004e02:	e922                	sd	s0,144(sp)
    80004e04:	e526                	sd	s1,136(sp)
    80004e06:	e14a                	sd	s2,128(sp)
    80004e08:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004e0a:	a1bfc0ef          	jal	ra,80001824 <myproc>
    80004e0e:	892a                	mv	s2,a0
  
  begin_op();
    80004e10:	b5ffe0ef          	jal	ra,8000396e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004e14:	08000613          	li	a2,128
    80004e18:	f6040593          	addi	a1,s0,-160
    80004e1c:	4501                	li	a0,0
    80004e1e:	8ebfd0ef          	jal	ra,80002708 <argstr>
    80004e22:	04054163          	bltz	a0,80004e64 <sys_chdir+0x66>
    80004e26:	f6040513          	addi	a0,s0,-160
    80004e2a:	969fe0ef          	jal	ra,80003792 <namei>
    80004e2e:	84aa                	mv	s1,a0
    80004e30:	c915                	beqz	a0,80004e64 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80004e32:	aaefe0ef          	jal	ra,800030e0 <ilock>
  if(ip->type != T_DIR){
    80004e36:	04449703          	lh	a4,68(s1)
    80004e3a:	4785                	li	a5,1
    80004e3c:	02f71863          	bne	a4,a5,80004e6c <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80004e40:	8526                	mv	a0,s1
    80004e42:	b48fe0ef          	jal	ra,8000318a <iunlock>
  iput(p->cwd);
    80004e46:	15093503          	ld	a0,336(s2)
    80004e4a:	c14fe0ef          	jal	ra,8000325e <iput>
  end_op();
    80004e4e:	b91fe0ef          	jal	ra,800039de <end_op>
  p->cwd = ip;
    80004e52:	14993823          	sd	s1,336(s2)
  return 0;
    80004e56:	4501                	li	a0,0
}
    80004e58:	60ea                	ld	ra,152(sp)
    80004e5a:	644a                	ld	s0,144(sp)
    80004e5c:	64aa                	ld	s1,136(sp)
    80004e5e:	690a                	ld	s2,128(sp)
    80004e60:	610d                	addi	sp,sp,160
    80004e62:	8082                	ret
    end_op();
    80004e64:	b7bfe0ef          	jal	ra,800039de <end_op>
    return -1;
    80004e68:	557d                	li	a0,-1
    80004e6a:	b7fd                	j	80004e58 <sys_chdir+0x5a>
    iunlockput(ip);
    80004e6c:	8526                	mv	a0,s1
    80004e6e:	c78fe0ef          	jal	ra,800032e6 <iunlockput>
    end_op();
    80004e72:	b6dfe0ef          	jal	ra,800039de <end_op>
    return -1;
    80004e76:	557d                	li	a0,-1
    80004e78:	b7c5                	j	80004e58 <sys_chdir+0x5a>

0000000080004e7a <sys_exec>:

uint64
sys_exec(void)
{
    80004e7a:	7145                	addi	sp,sp,-464
    80004e7c:	e786                	sd	ra,456(sp)
    80004e7e:	e3a2                	sd	s0,448(sp)
    80004e80:	ff26                	sd	s1,440(sp)
    80004e82:	fb4a                	sd	s2,432(sp)
    80004e84:	f74e                	sd	s3,424(sp)
    80004e86:	f352                	sd	s4,416(sp)
    80004e88:	ef56                	sd	s5,408(sp)
    80004e8a:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80004e8c:	e3840593          	addi	a1,s0,-456
    80004e90:	4505                	li	a0,1
    80004e92:	85bfd0ef          	jal	ra,800026ec <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80004e96:	08000613          	li	a2,128
    80004e9a:	f4040593          	addi	a1,s0,-192
    80004e9e:	4501                	li	a0,0
    80004ea0:	869fd0ef          	jal	ra,80002708 <argstr>
    80004ea4:	87aa                	mv	a5,a0
    return -1;
    80004ea6:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80004ea8:	0a07c463          	bltz	a5,80004f50 <sys_exec+0xd6>
  }
  memset(argv, 0, sizeof(argv));
    80004eac:	10000613          	li	a2,256
    80004eb0:	4581                	li	a1,0
    80004eb2:	e4040513          	addi	a0,s0,-448
    80004eb6:	db1fb0ef          	jal	ra,80000c66 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004eba:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80004ebe:	89a6                	mv	s3,s1
    80004ec0:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80004ec2:	02000a13          	li	s4,32
    80004ec6:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80004eca:	00391793          	slli	a5,s2,0x3
    80004ece:	e3040593          	addi	a1,s0,-464
    80004ed2:	e3843503          	ld	a0,-456(s0)
    80004ed6:	953e                	add	a0,a0,a5
    80004ed8:	f6efd0ef          	jal	ra,80002646 <fetchaddr>
    80004edc:	02054663          	bltz	a0,80004f08 <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    80004ee0:	e3043783          	ld	a5,-464(s0)
    80004ee4:	cf8d                	beqz	a5,80004f1e <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80004ee6:	bddfb0ef          	jal	ra,80000ac2 <kalloc>
    80004eea:	85aa                	mv	a1,a0
    80004eec:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80004ef0:	cd01                	beqz	a0,80004f08 <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80004ef2:	6605                	lui	a2,0x1
    80004ef4:	e3043503          	ld	a0,-464(s0)
    80004ef8:	f98fd0ef          	jal	ra,80002690 <fetchstr>
    80004efc:	00054663          	bltz	a0,80004f08 <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    80004f00:	0905                	addi	s2,s2,1
    80004f02:	09a1                	addi	s3,s3,8
    80004f04:	fd4911e3          	bne	s2,s4,80004ec6 <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004f08:	10048913          	addi	s2,s1,256
    80004f0c:	6088                	ld	a0,0(s1)
    80004f0e:	c121                	beqz	a0,80004f4e <sys_exec+0xd4>
    kfree(argv[i]);
    80004f10:	ad3fb0ef          	jal	ra,800009e2 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004f14:	04a1                	addi	s1,s1,8
    80004f16:	ff249be3          	bne	s1,s2,80004f0c <sys_exec+0x92>
  return -1;
    80004f1a:	557d                	li	a0,-1
    80004f1c:	a815                	j	80004f50 <sys_exec+0xd6>
      argv[i] = 0;
    80004f1e:	0a8e                	slli	s5,s5,0x3
    80004f20:	fc040793          	addi	a5,s0,-64
    80004f24:	9abe                	add	s5,s5,a5
    80004f26:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80004f2a:	e4040593          	addi	a1,s0,-448
    80004f2e:	f4040513          	addi	a0,s0,-192
    80004f32:	bfaff0ef          	jal	ra,8000432c <exec>
    80004f36:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004f38:	10048993          	addi	s3,s1,256
    80004f3c:	6088                	ld	a0,0(s1)
    80004f3e:	c511                	beqz	a0,80004f4a <sys_exec+0xd0>
    kfree(argv[i]);
    80004f40:	aa3fb0ef          	jal	ra,800009e2 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004f44:	04a1                	addi	s1,s1,8
    80004f46:	ff349be3          	bne	s1,s3,80004f3c <sys_exec+0xc2>
  return ret;
    80004f4a:	854a                	mv	a0,s2
    80004f4c:	a011                	j	80004f50 <sys_exec+0xd6>
  return -1;
    80004f4e:	557d                	li	a0,-1
}
    80004f50:	60be                	ld	ra,456(sp)
    80004f52:	641e                	ld	s0,448(sp)
    80004f54:	74fa                	ld	s1,440(sp)
    80004f56:	795a                	ld	s2,432(sp)
    80004f58:	79ba                	ld	s3,424(sp)
    80004f5a:	7a1a                	ld	s4,416(sp)
    80004f5c:	6afa                	ld	s5,408(sp)
    80004f5e:	6179                	addi	sp,sp,464
    80004f60:	8082                	ret

0000000080004f62 <sys_pipe>:

uint64
sys_pipe(void)
{
    80004f62:	7139                	addi	sp,sp,-64
    80004f64:	fc06                	sd	ra,56(sp)
    80004f66:	f822                	sd	s0,48(sp)
    80004f68:	f426                	sd	s1,40(sp)
    80004f6a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80004f6c:	8b9fc0ef          	jal	ra,80001824 <myproc>
    80004f70:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80004f72:	fd840593          	addi	a1,s0,-40
    80004f76:	4501                	li	a0,0
    80004f78:	f74fd0ef          	jal	ra,800026ec <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80004f7c:	fc840593          	addi	a1,s0,-56
    80004f80:	fd040513          	addi	a0,s0,-48
    80004f84:	8d2ff0ef          	jal	ra,80004056 <pipealloc>
    return -1;
    80004f88:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80004f8a:	0a054463          	bltz	a0,80005032 <sys_pipe+0xd0>
  fd0 = -1;
    80004f8e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80004f92:	fd043503          	ld	a0,-48(s0)
    80004f96:	f42ff0ef          	jal	ra,800046d8 <fdalloc>
    80004f9a:	fca42223          	sw	a0,-60(s0)
    80004f9e:	08054163          	bltz	a0,80005020 <sys_pipe+0xbe>
    80004fa2:	fc843503          	ld	a0,-56(s0)
    80004fa6:	f32ff0ef          	jal	ra,800046d8 <fdalloc>
    80004faa:	fca42023          	sw	a0,-64(s0)
    80004fae:	06054063          	bltz	a0,8000500e <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004fb2:	4691                	li	a3,4
    80004fb4:	fc440613          	addi	a2,s0,-60
    80004fb8:	fd843583          	ld	a1,-40(s0)
    80004fbc:	68a8                	ld	a0,80(s1)
    80004fbe:	d1afc0ef          	jal	ra,800014d8 <copyout>
    80004fc2:	00054e63          	bltz	a0,80004fde <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80004fc6:	4691                	li	a3,4
    80004fc8:	fc040613          	addi	a2,s0,-64
    80004fcc:	fd843583          	ld	a1,-40(s0)
    80004fd0:	0591                	addi	a1,a1,4
    80004fd2:	68a8                	ld	a0,80(s1)
    80004fd4:	d04fc0ef          	jal	ra,800014d8 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80004fd8:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004fda:	04055c63          	bgez	a0,80005032 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80004fde:	fc442783          	lw	a5,-60(s0)
    80004fe2:	07e9                	addi	a5,a5,26
    80004fe4:	078e                	slli	a5,a5,0x3
    80004fe6:	97a6                	add	a5,a5,s1
    80004fe8:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80004fec:	fc042503          	lw	a0,-64(s0)
    80004ff0:	0569                	addi	a0,a0,26
    80004ff2:	050e                	slli	a0,a0,0x3
    80004ff4:	94aa                	add	s1,s1,a0
    80004ff6:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80004ffa:	fd043503          	ld	a0,-48(s0)
    80004ffe:	d8dfe0ef          	jal	ra,80003d8a <fileclose>
    fileclose(wf);
    80005002:	fc843503          	ld	a0,-56(s0)
    80005006:	d85fe0ef          	jal	ra,80003d8a <fileclose>
    return -1;
    8000500a:	57fd                	li	a5,-1
    8000500c:	a01d                	j	80005032 <sys_pipe+0xd0>
    if(fd0 >= 0)
    8000500e:	fc442783          	lw	a5,-60(s0)
    80005012:	0007c763          	bltz	a5,80005020 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005016:	07e9                	addi	a5,a5,26
    80005018:	078e                	slli	a5,a5,0x3
    8000501a:	94be                	add	s1,s1,a5
    8000501c:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005020:	fd043503          	ld	a0,-48(s0)
    80005024:	d67fe0ef          	jal	ra,80003d8a <fileclose>
    fileclose(wf);
    80005028:	fc843503          	ld	a0,-56(s0)
    8000502c:	d5ffe0ef          	jal	ra,80003d8a <fileclose>
    return -1;
    80005030:	57fd                	li	a5,-1
}
    80005032:	853e                	mv	a0,a5
    80005034:	70e2                	ld	ra,56(sp)
    80005036:	7442                	ld	s0,48(sp)
    80005038:	74a2                	ld	s1,40(sp)
    8000503a:	6121                	addi	sp,sp,64
    8000503c:	8082                	ret
	...

0000000080005040 <kernelvec>:
    80005040:	7111                	addi	sp,sp,-256
    80005042:	e006                	sd	ra,0(sp)
    80005044:	e40a                	sd	sp,8(sp)
    80005046:	e80e                	sd	gp,16(sp)
    80005048:	ec12                	sd	tp,24(sp)
    8000504a:	f016                	sd	t0,32(sp)
    8000504c:	f41a                	sd	t1,40(sp)
    8000504e:	f81e                	sd	t2,48(sp)
    80005050:	e4aa                	sd	a0,72(sp)
    80005052:	e8ae                	sd	a1,80(sp)
    80005054:	ecb2                	sd	a2,88(sp)
    80005056:	f0b6                	sd	a3,96(sp)
    80005058:	f4ba                	sd	a4,104(sp)
    8000505a:	f8be                	sd	a5,112(sp)
    8000505c:	fcc2                	sd	a6,120(sp)
    8000505e:	e146                	sd	a7,128(sp)
    80005060:	edf2                	sd	t3,216(sp)
    80005062:	f1f6                	sd	t4,224(sp)
    80005064:	f5fa                	sd	t5,232(sp)
    80005066:	f9fe                	sd	t6,240(sp)
    80005068:	ceefd0ef          	jal	ra,80002556 <kerneltrap>
    8000506c:	6082                	ld	ra,0(sp)
    8000506e:	6122                	ld	sp,8(sp)
    80005070:	61c2                	ld	gp,16(sp)
    80005072:	7282                	ld	t0,32(sp)
    80005074:	7322                	ld	t1,40(sp)
    80005076:	73c2                	ld	t2,48(sp)
    80005078:	6526                	ld	a0,72(sp)
    8000507a:	65c6                	ld	a1,80(sp)
    8000507c:	6666                	ld	a2,88(sp)
    8000507e:	7686                	ld	a3,96(sp)
    80005080:	7726                	ld	a4,104(sp)
    80005082:	77c6                	ld	a5,112(sp)
    80005084:	7866                	ld	a6,120(sp)
    80005086:	688a                	ld	a7,128(sp)
    80005088:	6e6e                	ld	t3,216(sp)
    8000508a:	7e8e                	ld	t4,224(sp)
    8000508c:	7f2e                	ld	t5,232(sp)
    8000508e:	7fce                	ld	t6,240(sp)
    80005090:	6111                	addi	sp,sp,256
    80005092:	10200073          	sret
	...

000000008000509e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000509e:	1141                	addi	sp,sp,-16
    800050a0:	e422                	sd	s0,8(sp)
    800050a2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800050a4:	0c0007b7          	lui	a5,0xc000
    800050a8:	4705                	li	a4,1
    800050aa:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800050ac:	c3d8                	sw	a4,4(a5)
}
    800050ae:	6422                	ld	s0,8(sp)
    800050b0:	0141                	addi	sp,sp,16
    800050b2:	8082                	ret

00000000800050b4 <plicinithart>:

void
plicinithart(void)
{
    800050b4:	1141                	addi	sp,sp,-16
    800050b6:	e406                	sd	ra,8(sp)
    800050b8:	e022                	sd	s0,0(sp)
    800050ba:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800050bc:	f3cfc0ef          	jal	ra,800017f8 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800050c0:	0085171b          	slliw	a4,a0,0x8
    800050c4:	0c0027b7          	lui	a5,0xc002
    800050c8:	97ba                	add	a5,a5,a4
    800050ca:	40200713          	li	a4,1026
    800050ce:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800050d2:	00d5151b          	slliw	a0,a0,0xd
    800050d6:	0c2017b7          	lui	a5,0xc201
    800050da:	953e                	add	a0,a0,a5
    800050dc:	00052023          	sw	zero,0(a0)
}
    800050e0:	60a2                	ld	ra,8(sp)
    800050e2:	6402                	ld	s0,0(sp)
    800050e4:	0141                	addi	sp,sp,16
    800050e6:	8082                	ret

00000000800050e8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800050e8:	1141                	addi	sp,sp,-16
    800050ea:	e406                	sd	ra,8(sp)
    800050ec:	e022                	sd	s0,0(sp)
    800050ee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800050f0:	f08fc0ef          	jal	ra,800017f8 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800050f4:	00d5179b          	slliw	a5,a0,0xd
    800050f8:	0c201537          	lui	a0,0xc201
    800050fc:	953e                	add	a0,a0,a5
  return irq;
}
    800050fe:	4148                	lw	a0,4(a0)
    80005100:	60a2                	ld	ra,8(sp)
    80005102:	6402                	ld	s0,0(sp)
    80005104:	0141                	addi	sp,sp,16
    80005106:	8082                	ret

0000000080005108 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005108:	1101                	addi	sp,sp,-32
    8000510a:	ec06                	sd	ra,24(sp)
    8000510c:	e822                	sd	s0,16(sp)
    8000510e:	e426                	sd	s1,8(sp)
    80005110:	1000                	addi	s0,sp,32
    80005112:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005114:	ee4fc0ef          	jal	ra,800017f8 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005118:	00d5151b          	slliw	a0,a0,0xd
    8000511c:	0c2017b7          	lui	a5,0xc201
    80005120:	97aa                	add	a5,a5,a0
    80005122:	c3c4                	sw	s1,4(a5)
}
    80005124:	60e2                	ld	ra,24(sp)
    80005126:	6442                	ld	s0,16(sp)
    80005128:	64a2                	ld	s1,8(sp)
    8000512a:	6105                	addi	sp,sp,32
    8000512c:	8082                	ret

000000008000512e <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000512e:	1141                	addi	sp,sp,-16
    80005130:	e406                	sd	ra,8(sp)
    80005132:	e022                	sd	s0,0(sp)
    80005134:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005136:	479d                	li	a5,7
    80005138:	04a7ca63          	blt	a5,a0,8000518c <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    8000513c:	0001c797          	auipc	a5,0x1c
    80005140:	9c478793          	addi	a5,a5,-1596 # 80020b00 <disk>
    80005144:	97aa                	add	a5,a5,a0
    80005146:	0187c783          	lbu	a5,24(a5)
    8000514a:	e7b9                	bnez	a5,80005198 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000514c:	00451613          	slli	a2,a0,0x4
    80005150:	0001c797          	auipc	a5,0x1c
    80005154:	9b078793          	addi	a5,a5,-1616 # 80020b00 <disk>
    80005158:	6394                	ld	a3,0(a5)
    8000515a:	96b2                	add	a3,a3,a2
    8000515c:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005160:	6398                	ld	a4,0(a5)
    80005162:	9732                	add	a4,a4,a2
    80005164:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005168:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    8000516c:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005170:	953e                	add	a0,a0,a5
    80005172:	4785                	li	a5,1
    80005174:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005178:	0001c517          	auipc	a0,0x1c
    8000517c:	9a050513          	addi	a0,a0,-1632 # 80020b18 <disk+0x18>
    80005180:	cbbfc0ef          	jal	ra,80001e3a <wakeup>
}
    80005184:	60a2                	ld	ra,8(sp)
    80005186:	6402                	ld	s0,0(sp)
    80005188:	0141                	addi	sp,sp,16
    8000518a:	8082                	ret
    panic("free_desc 1");
    8000518c:	00002517          	auipc	a0,0x2
    80005190:	5f450513          	addi	a0,a0,1524 # 80007780 <syscalls+0x2f0>
    80005194:	dc2fb0ef          	jal	ra,80000756 <panic>
    panic("free_desc 2");
    80005198:	00002517          	auipc	a0,0x2
    8000519c:	5f850513          	addi	a0,a0,1528 # 80007790 <syscalls+0x300>
    800051a0:	db6fb0ef          	jal	ra,80000756 <panic>

00000000800051a4 <virtio_disk_init>:
{
    800051a4:	1101                	addi	sp,sp,-32
    800051a6:	ec06                	sd	ra,24(sp)
    800051a8:	e822                	sd	s0,16(sp)
    800051aa:	e426                	sd	s1,8(sp)
    800051ac:	e04a                	sd	s2,0(sp)
    800051ae:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800051b0:	00002597          	auipc	a1,0x2
    800051b4:	5f058593          	addi	a1,a1,1520 # 800077a0 <syscalls+0x310>
    800051b8:	0001c517          	auipc	a0,0x1c
    800051bc:	a7050513          	addi	a0,a0,-1424 # 80020c28 <disk+0x128>
    800051c0:	953fb0ef          	jal	ra,80000b12 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800051c4:	100017b7          	lui	a5,0x10001
    800051c8:	4398                	lw	a4,0(a5)
    800051ca:	2701                	sext.w	a4,a4
    800051cc:	747277b7          	lui	a5,0x74727
    800051d0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800051d4:	14f71063          	bne	a4,a5,80005314 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800051d8:	100017b7          	lui	a5,0x10001
    800051dc:	43dc                	lw	a5,4(a5)
    800051de:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800051e0:	4709                	li	a4,2
    800051e2:	12e79963          	bne	a5,a4,80005314 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800051e6:	100017b7          	lui	a5,0x10001
    800051ea:	479c                	lw	a5,8(a5)
    800051ec:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800051ee:	12e79363          	bne	a5,a4,80005314 <virtio_disk_init+0x170>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800051f2:	100017b7          	lui	a5,0x10001
    800051f6:	47d8                	lw	a4,12(a5)
    800051f8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800051fa:	554d47b7          	lui	a5,0x554d4
    800051fe:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005202:	10f71963          	bne	a4,a5,80005314 <virtio_disk_init+0x170>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005206:	100017b7          	lui	a5,0x10001
    8000520a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000520e:	4705                	li	a4,1
    80005210:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005212:	470d                	li	a4,3
    80005214:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005216:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005218:	c7ffe737          	lui	a4,0xc7ffe
    8000521c:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fddb1f>
    80005220:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005222:	2701                	sext.w	a4,a4
    80005224:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005226:	472d                	li	a4,11
    80005228:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    8000522a:	5bbc                	lw	a5,112(a5)
    8000522c:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005230:	8ba1                	andi	a5,a5,8
    80005232:	0e078763          	beqz	a5,80005320 <virtio_disk_init+0x17c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005236:	100017b7          	lui	a5,0x10001
    8000523a:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000523e:	43fc                	lw	a5,68(a5)
    80005240:	2781                	sext.w	a5,a5
    80005242:	0e079563          	bnez	a5,8000532c <virtio_disk_init+0x188>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005246:	100017b7          	lui	a5,0x10001
    8000524a:	5bdc                	lw	a5,52(a5)
    8000524c:	2781                	sext.w	a5,a5
  if(max == 0)
    8000524e:	0e078563          	beqz	a5,80005338 <virtio_disk_init+0x194>
  if(max < NUM)
    80005252:	471d                	li	a4,7
    80005254:	0ef77863          	bgeu	a4,a5,80005344 <virtio_disk_init+0x1a0>
  disk.desc = kalloc();
    80005258:	86bfb0ef          	jal	ra,80000ac2 <kalloc>
    8000525c:	0001c497          	auipc	s1,0x1c
    80005260:	8a448493          	addi	s1,s1,-1884 # 80020b00 <disk>
    80005264:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005266:	85dfb0ef          	jal	ra,80000ac2 <kalloc>
    8000526a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000526c:	857fb0ef          	jal	ra,80000ac2 <kalloc>
    80005270:	87aa                	mv	a5,a0
    80005272:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005274:	6088                	ld	a0,0(s1)
    80005276:	cd69                	beqz	a0,80005350 <virtio_disk_init+0x1ac>
    80005278:	0001c717          	auipc	a4,0x1c
    8000527c:	89073703          	ld	a4,-1904(a4) # 80020b08 <disk+0x8>
    80005280:	cb61                	beqz	a4,80005350 <virtio_disk_init+0x1ac>
    80005282:	c7f9                	beqz	a5,80005350 <virtio_disk_init+0x1ac>
  memset(disk.desc, 0, PGSIZE);
    80005284:	6605                	lui	a2,0x1
    80005286:	4581                	li	a1,0
    80005288:	9dffb0ef          	jal	ra,80000c66 <memset>
  memset(disk.avail, 0, PGSIZE);
    8000528c:	0001c497          	auipc	s1,0x1c
    80005290:	87448493          	addi	s1,s1,-1932 # 80020b00 <disk>
    80005294:	6605                	lui	a2,0x1
    80005296:	4581                	li	a1,0
    80005298:	6488                	ld	a0,8(s1)
    8000529a:	9cdfb0ef          	jal	ra,80000c66 <memset>
  memset(disk.used, 0, PGSIZE);
    8000529e:	6605                	lui	a2,0x1
    800052a0:	4581                	li	a1,0
    800052a2:	6888                	ld	a0,16(s1)
    800052a4:	9c3fb0ef          	jal	ra,80000c66 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800052a8:	100017b7          	lui	a5,0x10001
    800052ac:	4721                	li	a4,8
    800052ae:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800052b0:	4098                	lw	a4,0(s1)
    800052b2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800052b6:	40d8                	lw	a4,4(s1)
    800052b8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800052bc:	6498                	ld	a4,8(s1)
    800052be:	0007069b          	sext.w	a3,a4
    800052c2:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800052c6:	9701                	srai	a4,a4,0x20
    800052c8:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800052cc:	6898                	ld	a4,16(s1)
    800052ce:	0007069b          	sext.w	a3,a4
    800052d2:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800052d6:	9701                	srai	a4,a4,0x20
    800052d8:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800052dc:	4705                	li	a4,1
    800052de:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800052e0:	00e48c23          	sb	a4,24(s1)
    800052e4:	00e48ca3          	sb	a4,25(s1)
    800052e8:	00e48d23          	sb	a4,26(s1)
    800052ec:	00e48da3          	sb	a4,27(s1)
    800052f0:	00e48e23          	sb	a4,28(s1)
    800052f4:	00e48ea3          	sb	a4,29(s1)
    800052f8:	00e48f23          	sb	a4,30(s1)
    800052fc:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005300:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005304:	0727a823          	sw	s2,112(a5)
}
    80005308:	60e2                	ld	ra,24(sp)
    8000530a:	6442                	ld	s0,16(sp)
    8000530c:	64a2                	ld	s1,8(sp)
    8000530e:	6902                	ld	s2,0(sp)
    80005310:	6105                	addi	sp,sp,32
    80005312:	8082                	ret
    panic("could not find virtio disk");
    80005314:	00002517          	auipc	a0,0x2
    80005318:	49c50513          	addi	a0,a0,1180 # 800077b0 <syscalls+0x320>
    8000531c:	c3afb0ef          	jal	ra,80000756 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005320:	00002517          	auipc	a0,0x2
    80005324:	4b050513          	addi	a0,a0,1200 # 800077d0 <syscalls+0x340>
    80005328:	c2efb0ef          	jal	ra,80000756 <panic>
    panic("virtio disk should not be ready");
    8000532c:	00002517          	auipc	a0,0x2
    80005330:	4c450513          	addi	a0,a0,1220 # 800077f0 <syscalls+0x360>
    80005334:	c22fb0ef          	jal	ra,80000756 <panic>
    panic("virtio disk has no queue 0");
    80005338:	00002517          	auipc	a0,0x2
    8000533c:	4d850513          	addi	a0,a0,1240 # 80007810 <syscalls+0x380>
    80005340:	c16fb0ef          	jal	ra,80000756 <panic>
    panic("virtio disk max queue too short");
    80005344:	00002517          	auipc	a0,0x2
    80005348:	4ec50513          	addi	a0,a0,1260 # 80007830 <syscalls+0x3a0>
    8000534c:	c0afb0ef          	jal	ra,80000756 <panic>
    panic("virtio disk kalloc");
    80005350:	00002517          	auipc	a0,0x2
    80005354:	50050513          	addi	a0,a0,1280 # 80007850 <syscalls+0x3c0>
    80005358:	bfefb0ef          	jal	ra,80000756 <panic>

000000008000535c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000535c:	7119                	addi	sp,sp,-128
    8000535e:	fc86                	sd	ra,120(sp)
    80005360:	f8a2                	sd	s0,112(sp)
    80005362:	f4a6                	sd	s1,104(sp)
    80005364:	f0ca                	sd	s2,96(sp)
    80005366:	ecce                	sd	s3,88(sp)
    80005368:	e8d2                	sd	s4,80(sp)
    8000536a:	e4d6                	sd	s5,72(sp)
    8000536c:	e0da                	sd	s6,64(sp)
    8000536e:	fc5e                	sd	s7,56(sp)
    80005370:	f862                	sd	s8,48(sp)
    80005372:	f466                	sd	s9,40(sp)
    80005374:	f06a                	sd	s10,32(sp)
    80005376:	ec6e                	sd	s11,24(sp)
    80005378:	0100                	addi	s0,sp,128
    8000537a:	8aaa                	mv	s5,a0
    8000537c:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000537e:	00c52d03          	lw	s10,12(a0)
    80005382:	001d1d1b          	slliw	s10,s10,0x1
    80005386:	1d02                	slli	s10,s10,0x20
    80005388:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    8000538c:	0001c517          	auipc	a0,0x1c
    80005390:	89c50513          	addi	a0,a0,-1892 # 80020c28 <disk+0x128>
    80005394:	ffefb0ef          	jal	ra,80000b92 <acquire>
  for(int i = 0; i < 3; i++){
    80005398:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000539a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000539c:	0001bb97          	auipc	s7,0x1b
    800053a0:	764b8b93          	addi	s7,s7,1892 # 80020b00 <disk>
  for(int i = 0; i < 3; i++){
    800053a4:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800053a6:	0001cc97          	auipc	s9,0x1c
    800053aa:	882c8c93          	addi	s9,s9,-1918 # 80020c28 <disk+0x128>
    800053ae:	a8a9                	j	80005408 <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800053b0:	00fb8733          	add	a4,s7,a5
    800053b4:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800053b8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800053ba:	0207c563          	bltz	a5,800053e4 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800053be:	2905                	addiw	s2,s2,1
    800053c0:	0611                	addi	a2,a2,4
    800053c2:	05690863          	beq	s2,s6,80005412 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    800053c6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800053c8:	0001b717          	auipc	a4,0x1b
    800053cc:	73870713          	addi	a4,a4,1848 # 80020b00 <disk>
    800053d0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800053d2:	01874683          	lbu	a3,24(a4)
    800053d6:	fee9                	bnez	a3,800053b0 <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    800053d8:	2785                	addiw	a5,a5,1
    800053da:	0705                	addi	a4,a4,1
    800053dc:	fe979be3          	bne	a5,s1,800053d2 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800053e0:	57fd                	li	a5,-1
    800053e2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800053e4:	01205b63          	blez	s2,800053fa <virtio_disk_rw+0x9e>
    800053e8:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800053ea:	000a2503          	lw	a0,0(s4)
    800053ee:	d41ff0ef          	jal	ra,8000512e <free_desc>
      for(int j = 0; j < i; j++)
    800053f2:	2d85                	addiw	s11,s11,1
    800053f4:	0a11                	addi	s4,s4,4
    800053f6:	ffb91ae3          	bne	s2,s11,800053ea <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800053fa:	85e6                	mv	a1,s9
    800053fc:	0001b517          	auipc	a0,0x1b
    80005400:	71c50513          	addi	a0,a0,1820 # 80020b18 <disk+0x18>
    80005404:	9ebfc0ef          	jal	ra,80001dee <sleep>
  for(int i = 0; i < 3; i++){
    80005408:	f8040a13          	addi	s4,s0,-128
{
    8000540c:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    8000540e:	894e                	mv	s2,s3
    80005410:	bf5d                	j	800053c6 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005412:	f8042583          	lw	a1,-128(s0)
    80005416:	00a58793          	addi	a5,a1,10
    8000541a:	0792                	slli	a5,a5,0x4

  if(write)
    8000541c:	0001b617          	auipc	a2,0x1b
    80005420:	6e460613          	addi	a2,a2,1764 # 80020b00 <disk>
    80005424:	00f60733          	add	a4,a2,a5
    80005428:	018036b3          	snez	a3,s8
    8000542c:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000542e:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005432:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005436:	f6078693          	addi	a3,a5,-160
    8000543a:	6218                	ld	a4,0(a2)
    8000543c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000543e:	00878513          	addi	a0,a5,8
    80005442:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005444:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005446:	6208                	ld	a0,0(a2)
    80005448:	96aa                	add	a3,a3,a0
    8000544a:	4741                	li	a4,16
    8000544c:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000544e:	4705                	li	a4,1
    80005450:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80005454:	f8442703          	lw	a4,-124(s0)
    80005458:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000545c:	0712                	slli	a4,a4,0x4
    8000545e:	953a                	add	a0,a0,a4
    80005460:	058a8693          	addi	a3,s5,88
    80005464:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    80005466:	6208                	ld	a0,0(a2)
    80005468:	972a                	add	a4,a4,a0
    8000546a:	40000693          	li	a3,1024
    8000546e:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80005470:	001c3c13          	seqz	s8,s8
    80005474:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005476:	001c6c13          	ori	s8,s8,1
    8000547a:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    8000547e:	f8842603          	lw	a2,-120(s0)
    80005482:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005486:	0001b697          	auipc	a3,0x1b
    8000548a:	67a68693          	addi	a3,a3,1658 # 80020b00 <disk>
    8000548e:	00258713          	addi	a4,a1,2
    80005492:	0712                	slli	a4,a4,0x4
    80005494:	9736                	add	a4,a4,a3
    80005496:	587d                	li	a6,-1
    80005498:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000549c:	0612                	slli	a2,a2,0x4
    8000549e:	9532                	add	a0,a0,a2
    800054a0:	f9078793          	addi	a5,a5,-112
    800054a4:	97b6                	add	a5,a5,a3
    800054a6:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    800054a8:	629c                	ld	a5,0(a3)
    800054aa:	97b2                	add	a5,a5,a2
    800054ac:	4605                	li	a2,1
    800054ae:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800054b0:	4509                	li	a0,2
    800054b2:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    800054b6:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800054ba:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800054be:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800054c2:	6698                	ld	a4,8(a3)
    800054c4:	00275783          	lhu	a5,2(a4)
    800054c8:	8b9d                	andi	a5,a5,7
    800054ca:	0786                	slli	a5,a5,0x1
    800054cc:	97ba                	add	a5,a5,a4
    800054ce:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800054d2:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800054d6:	6698                	ld	a4,8(a3)
    800054d8:	00275783          	lhu	a5,2(a4)
    800054dc:	2785                	addiw	a5,a5,1
    800054de:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800054e2:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800054e6:	100017b7          	lui	a5,0x10001
    800054ea:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800054ee:	004aa783          	lw	a5,4(s5)
    800054f2:	00c79f63          	bne	a5,a2,80005510 <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    800054f6:	0001b917          	auipc	s2,0x1b
    800054fa:	73290913          	addi	s2,s2,1842 # 80020c28 <disk+0x128>
  while(b->disk == 1) {
    800054fe:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80005500:	85ca                	mv	a1,s2
    80005502:	8556                	mv	a0,s5
    80005504:	8ebfc0ef          	jal	ra,80001dee <sleep>
  while(b->disk == 1) {
    80005508:	004aa783          	lw	a5,4(s5)
    8000550c:	fe978ae3          	beq	a5,s1,80005500 <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    80005510:	f8042903          	lw	s2,-128(s0)
    80005514:	00290793          	addi	a5,s2,2
    80005518:	00479713          	slli	a4,a5,0x4
    8000551c:	0001b797          	auipc	a5,0x1b
    80005520:	5e478793          	addi	a5,a5,1508 # 80020b00 <disk>
    80005524:	97ba                	add	a5,a5,a4
    80005526:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000552a:	0001b997          	auipc	s3,0x1b
    8000552e:	5d698993          	addi	s3,s3,1494 # 80020b00 <disk>
    80005532:	00491713          	slli	a4,s2,0x4
    80005536:	0009b783          	ld	a5,0(s3)
    8000553a:	97ba                	add	a5,a5,a4
    8000553c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005540:	854a                	mv	a0,s2
    80005542:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005546:	be9ff0ef          	jal	ra,8000512e <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000554a:	8885                	andi	s1,s1,1
    8000554c:	f0fd                	bnez	s1,80005532 <virtio_disk_rw+0x1d6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000554e:	0001b517          	auipc	a0,0x1b
    80005552:	6da50513          	addi	a0,a0,1754 # 80020c28 <disk+0x128>
    80005556:	ed4fb0ef          	jal	ra,80000c2a <release>
}
    8000555a:	70e6                	ld	ra,120(sp)
    8000555c:	7446                	ld	s0,112(sp)
    8000555e:	74a6                	ld	s1,104(sp)
    80005560:	7906                	ld	s2,96(sp)
    80005562:	69e6                	ld	s3,88(sp)
    80005564:	6a46                	ld	s4,80(sp)
    80005566:	6aa6                	ld	s5,72(sp)
    80005568:	6b06                	ld	s6,64(sp)
    8000556a:	7be2                	ld	s7,56(sp)
    8000556c:	7c42                	ld	s8,48(sp)
    8000556e:	7ca2                	ld	s9,40(sp)
    80005570:	7d02                	ld	s10,32(sp)
    80005572:	6de2                	ld	s11,24(sp)
    80005574:	6109                	addi	sp,sp,128
    80005576:	8082                	ret

0000000080005578 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005578:	1101                	addi	sp,sp,-32
    8000557a:	ec06                	sd	ra,24(sp)
    8000557c:	e822                	sd	s0,16(sp)
    8000557e:	e426                	sd	s1,8(sp)
    80005580:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005582:	0001b497          	auipc	s1,0x1b
    80005586:	57e48493          	addi	s1,s1,1406 # 80020b00 <disk>
    8000558a:	0001b517          	auipc	a0,0x1b
    8000558e:	69e50513          	addi	a0,a0,1694 # 80020c28 <disk+0x128>
    80005592:	e00fb0ef          	jal	ra,80000b92 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005596:	10001737          	lui	a4,0x10001
    8000559a:	533c                	lw	a5,96(a4)
    8000559c:	8b8d                	andi	a5,a5,3
    8000559e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800055a0:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800055a4:	689c                	ld	a5,16(s1)
    800055a6:	0204d703          	lhu	a4,32(s1)
    800055aa:	0027d783          	lhu	a5,2(a5)
    800055ae:	04f70663          	beq	a4,a5,800055fa <virtio_disk_intr+0x82>
    __sync_synchronize();
    800055b2:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800055b6:	6898                	ld	a4,16(s1)
    800055b8:	0204d783          	lhu	a5,32(s1)
    800055bc:	8b9d                	andi	a5,a5,7
    800055be:	078e                	slli	a5,a5,0x3
    800055c0:	97ba                	add	a5,a5,a4
    800055c2:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800055c4:	00278713          	addi	a4,a5,2
    800055c8:	0712                	slli	a4,a4,0x4
    800055ca:	9726                	add	a4,a4,s1
    800055cc:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800055d0:	e321                	bnez	a4,80005610 <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800055d2:	0789                	addi	a5,a5,2
    800055d4:	0792                	slli	a5,a5,0x4
    800055d6:	97a6                	add	a5,a5,s1
    800055d8:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800055da:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800055de:	85dfc0ef          	jal	ra,80001e3a <wakeup>

    disk.used_idx += 1;
    800055e2:	0204d783          	lhu	a5,32(s1)
    800055e6:	2785                	addiw	a5,a5,1
    800055e8:	17c2                	slli	a5,a5,0x30
    800055ea:	93c1                	srli	a5,a5,0x30
    800055ec:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800055f0:	6898                	ld	a4,16(s1)
    800055f2:	00275703          	lhu	a4,2(a4)
    800055f6:	faf71ee3          	bne	a4,a5,800055b2 <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    800055fa:	0001b517          	auipc	a0,0x1b
    800055fe:	62e50513          	addi	a0,a0,1582 # 80020c28 <disk+0x128>
    80005602:	e28fb0ef          	jal	ra,80000c2a <release>
}
    80005606:	60e2                	ld	ra,24(sp)
    80005608:	6442                	ld	s0,16(sp)
    8000560a:	64a2                	ld	s1,8(sp)
    8000560c:	6105                	addi	sp,sp,32
    8000560e:	8082                	ret
      panic("virtio_disk_intr status");
    80005610:	00002517          	auipc	a0,0x2
    80005614:	25850513          	addi	a0,a0,600 # 80007868 <syscalls+0x3d8>
    80005618:	93efb0ef          	jal	ra,80000756 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
