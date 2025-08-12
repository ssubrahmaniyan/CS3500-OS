
user/_HelloWorld:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
   0:	4505                	li	a0,1
   2:	00001597          	auipc	a1,0x1
   6:	ffe58593          	addi	a1,a1,-2 # 1000 <saddr>
   a:	02200613          	li	a2,34
   e:	48c1                	li	a7,16
  10:	00000073          	ecall
  14:	4501                	li	a0,0
  16:	4889                	li	a7,2
  18:	00000073          	ecall

000000000000001c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  1c:	1141                	addi	sp,sp,-16
  1e:	e406                	sd	ra,8(sp)
  20:	e022                	sd	s0,0(sp)
  22:	0800                	addi	s0,sp,16
  extern int main();
  main();
  24:	fddff0ef          	jal	ra,0 <main>
  exit(0);
  28:	4501                	li	a0,0
  2a:	25e000ef          	jal	ra,288 <exit>

000000000000002e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  2e:	1141                	addi	sp,sp,-16
  30:	e422                	sd	s0,8(sp)
  32:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  34:	87aa                	mv	a5,a0
  36:	0585                	addi	a1,a1,1
  38:	0785                	addi	a5,a5,1
  3a:	fff5c703          	lbu	a4,-1(a1)
  3e:	fee78fa3          	sb	a4,-1(a5)
  42:	fb75                	bnez	a4,36 <strcpy+0x8>
    ;
  return os;
}
  44:	6422                	ld	s0,8(sp)
  46:	0141                	addi	sp,sp,16
  48:	8082                	ret

000000000000004a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  4a:	1141                	addi	sp,sp,-16
  4c:	e422                	sd	s0,8(sp)
  4e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  50:	00054783          	lbu	a5,0(a0)
  54:	cb91                	beqz	a5,68 <strcmp+0x1e>
  56:	0005c703          	lbu	a4,0(a1)
  5a:	00f71763          	bne	a4,a5,68 <strcmp+0x1e>
    p++, q++;
  5e:	0505                	addi	a0,a0,1
  60:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  62:	00054783          	lbu	a5,0(a0)
  66:	fbe5                	bnez	a5,56 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  68:	0005c503          	lbu	a0,0(a1)
}
  6c:	40a7853b          	subw	a0,a5,a0
  70:	6422                	ld	s0,8(sp)
  72:	0141                	addi	sp,sp,16
  74:	8082                	ret

0000000000000076 <strlen>:

uint
strlen(const char *s)
{
  76:	1141                	addi	sp,sp,-16
  78:	e422                	sd	s0,8(sp)
  7a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  7c:	00054783          	lbu	a5,0(a0)
  80:	cf91                	beqz	a5,9c <strlen+0x26>
  82:	0505                	addi	a0,a0,1
  84:	87aa                	mv	a5,a0
  86:	4685                	li	a3,1
  88:	9e89                	subw	a3,a3,a0
  8a:	00f6853b          	addw	a0,a3,a5
  8e:	0785                	addi	a5,a5,1
  90:	fff7c703          	lbu	a4,-1(a5)
  94:	fb7d                	bnez	a4,8a <strlen+0x14>
    ;
  return n;
}
  96:	6422                	ld	s0,8(sp)
  98:	0141                	addi	sp,sp,16
  9a:	8082                	ret
  for(n = 0; s[n]; n++)
  9c:	4501                	li	a0,0
  9e:	bfe5                	j	96 <strlen+0x20>

00000000000000a0 <memset>:

void*
memset(void *dst, int c, uint n)
{
  a0:	1141                	addi	sp,sp,-16
  a2:	e422                	sd	s0,8(sp)
  a4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  a6:	ca19                	beqz	a2,bc <memset+0x1c>
  a8:	87aa                	mv	a5,a0
  aa:	1602                	slli	a2,a2,0x20
  ac:	9201                	srli	a2,a2,0x20
  ae:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  b2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  b6:	0785                	addi	a5,a5,1
  b8:	fee79de3          	bne	a5,a4,b2 <memset+0x12>
  }
  return dst;
}
  bc:	6422                	ld	s0,8(sp)
  be:	0141                	addi	sp,sp,16
  c0:	8082                	ret

00000000000000c2 <strchr>:

char*
strchr(const char *s, char c)
{
  c2:	1141                	addi	sp,sp,-16
  c4:	e422                	sd	s0,8(sp)
  c6:	0800                	addi	s0,sp,16
  for(; *s; s++)
  c8:	00054783          	lbu	a5,0(a0)
  cc:	cb99                	beqz	a5,e2 <strchr+0x20>
    if(*s == c)
  ce:	00f58763          	beq	a1,a5,dc <strchr+0x1a>
  for(; *s; s++)
  d2:	0505                	addi	a0,a0,1
  d4:	00054783          	lbu	a5,0(a0)
  d8:	fbfd                	bnez	a5,ce <strchr+0xc>
      return (char*)s;
  return 0;
  da:	4501                	li	a0,0
}
  dc:	6422                	ld	s0,8(sp)
  de:	0141                	addi	sp,sp,16
  e0:	8082                	ret
  return 0;
  e2:	4501                	li	a0,0
  e4:	bfe5                	j	dc <strchr+0x1a>

00000000000000e6 <gets>:

char*
gets(char *buf, int max)
{
  e6:	711d                	addi	sp,sp,-96
  e8:	ec86                	sd	ra,88(sp)
  ea:	e8a2                	sd	s0,80(sp)
  ec:	e4a6                	sd	s1,72(sp)
  ee:	e0ca                	sd	s2,64(sp)
  f0:	fc4e                	sd	s3,56(sp)
  f2:	f852                	sd	s4,48(sp)
  f4:	f456                	sd	s5,40(sp)
  f6:	f05a                	sd	s6,32(sp)
  f8:	ec5e                	sd	s7,24(sp)
  fa:	1080                	addi	s0,sp,96
  fc:	8baa                	mv	s7,a0
  fe:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 100:	892a                	mv	s2,a0
 102:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 104:	4aa9                	li	s5,10
 106:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 108:	89a6                	mv	s3,s1
 10a:	2485                	addiw	s1,s1,1
 10c:	0344d663          	bge	s1,s4,138 <gets+0x52>
    cc = read(0, &c, 1);
 110:	4605                	li	a2,1
 112:	faf40593          	addi	a1,s0,-81
 116:	4501                	li	a0,0
 118:	188000ef          	jal	ra,2a0 <read>
    if(cc < 1)
 11c:	00a05e63          	blez	a0,138 <gets+0x52>
    buf[i++] = c;
 120:	faf44783          	lbu	a5,-81(s0)
 124:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 128:	01578763          	beq	a5,s5,136 <gets+0x50>
 12c:	0905                	addi	s2,s2,1
 12e:	fd679de3          	bne	a5,s6,108 <gets+0x22>
  for(i=0; i+1 < max; ){
 132:	89a6                	mv	s3,s1
 134:	a011                	j	138 <gets+0x52>
 136:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 138:	99de                	add	s3,s3,s7
 13a:	00098023          	sb	zero,0(s3)
  return buf;
}
 13e:	855e                	mv	a0,s7
 140:	60e6                	ld	ra,88(sp)
 142:	6446                	ld	s0,80(sp)
 144:	64a6                	ld	s1,72(sp)
 146:	6906                	ld	s2,64(sp)
 148:	79e2                	ld	s3,56(sp)
 14a:	7a42                	ld	s4,48(sp)
 14c:	7aa2                	ld	s5,40(sp)
 14e:	7b02                	ld	s6,32(sp)
 150:	6be2                	ld	s7,24(sp)
 152:	6125                	addi	sp,sp,96
 154:	8082                	ret

0000000000000156 <stat>:

int
stat(const char *n, struct stat *st)
{
 156:	1101                	addi	sp,sp,-32
 158:	ec06                	sd	ra,24(sp)
 15a:	e822                	sd	s0,16(sp)
 15c:	e426                	sd	s1,8(sp)
 15e:	e04a                	sd	s2,0(sp)
 160:	1000                	addi	s0,sp,32
 162:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 164:	4581                	li	a1,0
 166:	162000ef          	jal	ra,2c8 <open>
  if(fd < 0)
 16a:	02054163          	bltz	a0,18c <stat+0x36>
 16e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 170:	85ca                	mv	a1,s2
 172:	16e000ef          	jal	ra,2e0 <fstat>
 176:	892a                	mv	s2,a0
  close(fd);
 178:	8526                	mv	a0,s1
 17a:	136000ef          	jal	ra,2b0 <close>
  return r;
}
 17e:	854a                	mv	a0,s2
 180:	60e2                	ld	ra,24(sp)
 182:	6442                	ld	s0,16(sp)
 184:	64a2                	ld	s1,8(sp)
 186:	6902                	ld	s2,0(sp)
 188:	6105                	addi	sp,sp,32
 18a:	8082                	ret
    return -1;
 18c:	597d                	li	s2,-1
 18e:	bfc5                	j	17e <stat+0x28>

0000000000000190 <atoi>:

int
atoi(const char *s)
{
 190:	1141                	addi	sp,sp,-16
 192:	e422                	sd	s0,8(sp)
 194:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 196:	00054603          	lbu	a2,0(a0)
 19a:	fd06079b          	addiw	a5,a2,-48
 19e:	0ff7f793          	zext.b	a5,a5
 1a2:	4725                	li	a4,9
 1a4:	02f76963          	bltu	a4,a5,1d6 <atoi+0x46>
 1a8:	86aa                	mv	a3,a0
  n = 0;
 1aa:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1ac:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1ae:	0685                	addi	a3,a3,1
 1b0:	0025179b          	slliw	a5,a0,0x2
 1b4:	9fa9                	addw	a5,a5,a0
 1b6:	0017979b          	slliw	a5,a5,0x1
 1ba:	9fb1                	addw	a5,a5,a2
 1bc:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1c0:	0006c603          	lbu	a2,0(a3)
 1c4:	fd06071b          	addiw	a4,a2,-48
 1c8:	0ff77713          	zext.b	a4,a4
 1cc:	fee5f1e3          	bgeu	a1,a4,1ae <atoi+0x1e>
  return n;
}
 1d0:	6422                	ld	s0,8(sp)
 1d2:	0141                	addi	sp,sp,16
 1d4:	8082                	ret
  n = 0;
 1d6:	4501                	li	a0,0
 1d8:	bfe5                	j	1d0 <atoi+0x40>

00000000000001da <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1da:	1141                	addi	sp,sp,-16
 1dc:	e422                	sd	s0,8(sp)
 1de:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1e0:	02b57463          	bgeu	a0,a1,208 <memmove+0x2e>
    while(n-- > 0)
 1e4:	00c05f63          	blez	a2,202 <memmove+0x28>
 1e8:	1602                	slli	a2,a2,0x20
 1ea:	9201                	srli	a2,a2,0x20
 1ec:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 1f0:	872a                	mv	a4,a0
      *dst++ = *src++;
 1f2:	0585                	addi	a1,a1,1
 1f4:	0705                	addi	a4,a4,1
 1f6:	fff5c683          	lbu	a3,-1(a1)
 1fa:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 1fe:	fee79ae3          	bne	a5,a4,1f2 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 202:	6422                	ld	s0,8(sp)
 204:	0141                	addi	sp,sp,16
 206:	8082                	ret
    dst += n;
 208:	00c50733          	add	a4,a0,a2
    src += n;
 20c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 20e:	fec05ae3          	blez	a2,202 <memmove+0x28>
 212:	fff6079b          	addiw	a5,a2,-1
 216:	1782                	slli	a5,a5,0x20
 218:	9381                	srli	a5,a5,0x20
 21a:	fff7c793          	not	a5,a5
 21e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 220:	15fd                	addi	a1,a1,-1
 222:	177d                	addi	a4,a4,-1
 224:	0005c683          	lbu	a3,0(a1)
 228:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 22c:	fee79ae3          	bne	a5,a4,220 <memmove+0x46>
 230:	bfc9                	j	202 <memmove+0x28>

0000000000000232 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 232:	1141                	addi	sp,sp,-16
 234:	e422                	sd	s0,8(sp)
 236:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 238:	ca05                	beqz	a2,268 <memcmp+0x36>
 23a:	fff6069b          	addiw	a3,a2,-1
 23e:	1682                	slli	a3,a3,0x20
 240:	9281                	srli	a3,a3,0x20
 242:	0685                	addi	a3,a3,1
 244:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 246:	00054783          	lbu	a5,0(a0)
 24a:	0005c703          	lbu	a4,0(a1)
 24e:	00e79863          	bne	a5,a4,25e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 252:	0505                	addi	a0,a0,1
    p2++;
 254:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 256:	fed518e3          	bne	a0,a3,246 <memcmp+0x14>
  }
  return 0;
 25a:	4501                	li	a0,0
 25c:	a019                	j	262 <memcmp+0x30>
      return *p1 - *p2;
 25e:	40e7853b          	subw	a0,a5,a4
}
 262:	6422                	ld	s0,8(sp)
 264:	0141                	addi	sp,sp,16
 266:	8082                	ret
  return 0;
 268:	4501                	li	a0,0
 26a:	bfe5                	j	262 <memcmp+0x30>

000000000000026c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e406                	sd	ra,8(sp)
 270:	e022                	sd	s0,0(sp)
 272:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 274:	f67ff0ef          	jal	ra,1da <memmove>
}
 278:	60a2                	ld	ra,8(sp)
 27a:	6402                	ld	s0,0(sp)
 27c:	0141                	addi	sp,sp,16
 27e:	8082                	ret

0000000000000280 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 280:	4885                	li	a7,1
 ecall
 282:	00000073          	ecall
 ret
 286:	8082                	ret

0000000000000288 <exit>:
.global exit
exit:
 li a7, SYS_exit
 288:	4889                	li	a7,2
 ecall
 28a:	00000073          	ecall
 ret
 28e:	8082                	ret

0000000000000290 <wait>:
.global wait
wait:
 li a7, SYS_wait
 290:	488d                	li	a7,3
 ecall
 292:	00000073          	ecall
 ret
 296:	8082                	ret

0000000000000298 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 298:	4891                	li	a7,4
 ecall
 29a:	00000073          	ecall
 ret
 29e:	8082                	ret

00000000000002a0 <read>:
.global read
read:
 li a7, SYS_read
 2a0:	4895                	li	a7,5
 ecall
 2a2:	00000073          	ecall
 ret
 2a6:	8082                	ret

00000000000002a8 <write>:
.global write
write:
 li a7, SYS_write
 2a8:	48c1                	li	a7,16
 ecall
 2aa:	00000073          	ecall
 ret
 2ae:	8082                	ret

00000000000002b0 <close>:
.global close
close:
 li a7, SYS_close
 2b0:	48d5                	li	a7,21
 ecall
 2b2:	00000073          	ecall
 ret
 2b6:	8082                	ret

00000000000002b8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2b8:	4899                	li	a7,6
 ecall
 2ba:	00000073          	ecall
 ret
 2be:	8082                	ret

00000000000002c0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2c0:	489d                	li	a7,7
 ecall
 2c2:	00000073          	ecall
 ret
 2c6:	8082                	ret

00000000000002c8 <open>:
.global open
open:
 li a7, SYS_open
 2c8:	48bd                	li	a7,15
 ecall
 2ca:	00000073          	ecall
 ret
 2ce:	8082                	ret

00000000000002d0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2d0:	48c5                	li	a7,17
 ecall
 2d2:	00000073          	ecall
 ret
 2d6:	8082                	ret

00000000000002d8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2d8:	48c9                	li	a7,18
 ecall
 2da:	00000073          	ecall
 ret
 2de:	8082                	ret

00000000000002e0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2e0:	48a1                	li	a7,8
 ecall
 2e2:	00000073          	ecall
 ret
 2e6:	8082                	ret

00000000000002e8 <link>:
.global link
link:
 li a7, SYS_link
 2e8:	48cd                	li	a7,19
 ecall
 2ea:	00000073          	ecall
 ret
 2ee:	8082                	ret

00000000000002f0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 2f0:	48d1                	li	a7,20
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 2f8:	48a5                	li	a7,9
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <dup>:
.global dup
dup:
 li a7, SYS_dup
 300:	48a9                	li	a7,10
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 308:	48ad                	li	a7,11
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 310:	48b1                	li	a7,12
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 318:	48b5                	li	a7,13
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 320:	48b9                	li	a7,14
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 328:	1101                	addi	sp,sp,-32
 32a:	ec06                	sd	ra,24(sp)
 32c:	e822                	sd	s0,16(sp)
 32e:	1000                	addi	s0,sp,32
 330:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 334:	4605                	li	a2,1
 336:	fef40593          	addi	a1,s0,-17
 33a:	f6fff0ef          	jal	ra,2a8 <write>
}
 33e:	60e2                	ld	ra,24(sp)
 340:	6442                	ld	s0,16(sp)
 342:	6105                	addi	sp,sp,32
 344:	8082                	ret

0000000000000346 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 346:	715d                	addi	sp,sp,-80
 348:	e486                	sd	ra,72(sp)
 34a:	e0a2                	sd	s0,64(sp)
 34c:	fc26                	sd	s1,56(sp)
 34e:	f84a                	sd	s2,48(sp)
 350:	f44e                	sd	s3,40(sp)
 352:	0880                	addi	s0,sp,80
 354:	84aa                	mv	s1,a0
  char buf[20];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 356:	c299                	beqz	a3,35c <printint+0x16>
 358:	0805c663          	bltz	a1,3e4 <printint+0x9e>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 35c:	2581                	sext.w	a1,a1
  neg = 0;
 35e:	4881                	li	a7,0
 360:	fb840693          	addi	a3,s0,-72
  }

  i = 0;
 364:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 366:	2601                	sext.w	a2,a2
 368:	00000517          	auipc	a0,0x0
 36c:	4d050513          	addi	a0,a0,1232 # 838 <digits>
 370:	883a                	mv	a6,a4
 372:	2705                	addiw	a4,a4,1
 374:	02c5f7bb          	remuw	a5,a1,a2
 378:	1782                	slli	a5,a5,0x20
 37a:	9381                	srli	a5,a5,0x20
 37c:	97aa                	add	a5,a5,a0
 37e:	0007c783          	lbu	a5,0(a5)
 382:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 386:	0005879b          	sext.w	a5,a1
 38a:	02c5d5bb          	divuw	a1,a1,a2
 38e:	0685                	addi	a3,a3,1
 390:	fec7f0e3          	bgeu	a5,a2,370 <printint+0x2a>
  if(neg)
 394:	00088b63          	beqz	a7,3aa <printint+0x64>
    buf[i++] = '-';
 398:	fd040793          	addi	a5,s0,-48
 39c:	973e                	add	a4,a4,a5
 39e:	02d00793          	li	a5,45
 3a2:	fef70423          	sb	a5,-24(a4)
 3a6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3aa:	02e05663          	blez	a4,3d6 <printint+0x90>
 3ae:	fb840793          	addi	a5,s0,-72
 3b2:	00e78933          	add	s2,a5,a4
 3b6:	fff78993          	addi	s3,a5,-1
 3ba:	99ba                	add	s3,s3,a4
 3bc:	377d                	addiw	a4,a4,-1
 3be:	1702                	slli	a4,a4,0x20
 3c0:	9301                	srli	a4,a4,0x20
 3c2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3c6:	fff94583          	lbu	a1,-1(s2)
 3ca:	8526                	mv	a0,s1
 3cc:	f5dff0ef          	jal	ra,328 <putc>
  while(--i >= 0)
 3d0:	197d                	addi	s2,s2,-1
 3d2:	ff391ae3          	bne	s2,s3,3c6 <printint+0x80>
}
 3d6:	60a6                	ld	ra,72(sp)
 3d8:	6406                	ld	s0,64(sp)
 3da:	74e2                	ld	s1,56(sp)
 3dc:	7942                	ld	s2,48(sp)
 3de:	79a2                	ld	s3,40(sp)
 3e0:	6161                	addi	sp,sp,80
 3e2:	8082                	ret
    x = -xx;
 3e4:	40b005bb          	negw	a1,a1
    neg = 1;
 3e8:	4885                	li	a7,1
    x = -xx;
 3ea:	bf9d                	j	360 <printint+0x1a>

00000000000003ec <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 3ec:	7119                	addi	sp,sp,-128
 3ee:	fc86                	sd	ra,120(sp)
 3f0:	f8a2                	sd	s0,112(sp)
 3f2:	f4a6                	sd	s1,104(sp)
 3f4:	f0ca                	sd	s2,96(sp)
 3f6:	ecce                	sd	s3,88(sp)
 3f8:	e8d2                	sd	s4,80(sp)
 3fa:	e4d6                	sd	s5,72(sp)
 3fc:	e0da                	sd	s6,64(sp)
 3fe:	fc5e                	sd	s7,56(sp)
 400:	f862                	sd	s8,48(sp)
 402:	f466                	sd	s9,40(sp)
 404:	f06a                	sd	s10,32(sp)
 406:	ec6e                	sd	s11,24(sp)
 408:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 40a:	0005c903          	lbu	s2,0(a1)
 40e:	22090e63          	beqz	s2,64a <vprintf+0x25e>
 412:	8b2a                	mv	s6,a0
 414:	8a2e                	mv	s4,a1
 416:	8bb2                	mv	s7,a2
  state = 0;
 418:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 41a:	4481                	li	s1,0
 41c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 41e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 422:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 426:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 42a:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 42e:	00000c97          	auipc	s9,0x0
 432:	40ac8c93          	addi	s9,s9,1034 # 838 <digits>
 436:	a005                	j	456 <vprintf+0x6a>
        putc(fd, c0);
 438:	85ca                	mv	a1,s2
 43a:	855a                	mv	a0,s6
 43c:	eedff0ef          	jal	ra,328 <putc>
 440:	a019                	j	446 <vprintf+0x5a>
    } else if(state == '%'){
 442:	03598263          	beq	s3,s5,466 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 446:	2485                	addiw	s1,s1,1
 448:	8726                	mv	a4,s1
 44a:	009a07b3          	add	a5,s4,s1
 44e:	0007c903          	lbu	s2,0(a5)
 452:	1e090c63          	beqz	s2,64a <vprintf+0x25e>
    c0 = fmt[i] & 0xff;
 456:	0009079b          	sext.w	a5,s2
    if(state == 0){
 45a:	fe0994e3          	bnez	s3,442 <vprintf+0x56>
      if(c0 == '%'){
 45e:	fd579de3          	bne	a5,s5,438 <vprintf+0x4c>
        state = '%';
 462:	89be                	mv	s3,a5
 464:	b7cd                	j	446 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 466:	cfa5                	beqz	a5,4de <vprintf+0xf2>
 468:	00ea06b3          	add	a3,s4,a4
 46c:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 470:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 472:	c681                	beqz	a3,47a <vprintf+0x8e>
 474:	9752                	add	a4,a4,s4
 476:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 47a:	03878a63          	beq	a5,s8,4ae <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 47e:	05a78463          	beq	a5,s10,4c6 <vprintf+0xda>
      } else if(c0 == 'u'){
 482:	0db78763          	beq	a5,s11,550 <vprintf+0x164>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 486:	07800713          	li	a4,120
 48a:	10e78963          	beq	a5,a4,59c <vprintf+0x1b0>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 48e:	07000713          	li	a4,112
 492:	12e78e63          	beq	a5,a4,5ce <vprintf+0x1e2>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 496:	07300713          	li	a4,115
 49a:	16e78b63          	beq	a5,a4,610 <vprintf+0x224>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 49e:	05579063          	bne	a5,s5,4de <vprintf+0xf2>
        putc(fd, '%');
 4a2:	85d6                	mv	a1,s5
 4a4:	855a                	mv	a0,s6
 4a6:	e83ff0ef          	jal	ra,328 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 4aa:	4981                	li	s3,0
 4ac:	bf69                	j	446 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 4ae:	008b8913          	addi	s2,s7,8
 4b2:	4685                	li	a3,1
 4b4:	4629                	li	a2,10
 4b6:	000ba583          	lw	a1,0(s7)
 4ba:	855a                	mv	a0,s6
 4bc:	e8bff0ef          	jal	ra,346 <printint>
 4c0:	8bca                	mv	s7,s2
      state = 0;
 4c2:	4981                	li	s3,0
 4c4:	b749                	j	446 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 4c6:	03868663          	beq	a3,s8,4f2 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 4ca:	05a68163          	beq	a3,s10,50c <vprintf+0x120>
      } else if(c0 == 'l' && c1 == 'u'){
 4ce:	09b68d63          	beq	a3,s11,568 <vprintf+0x17c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 4d2:	03a68f63          	beq	a3,s10,510 <vprintf+0x124>
      } else if(c0 == 'l' && c1 == 'x'){
 4d6:	07800793          	li	a5,120
 4da:	0cf68d63          	beq	a3,a5,5b4 <vprintf+0x1c8>
        putc(fd, '%');
 4de:	85d6                	mv	a1,s5
 4e0:	855a                	mv	a0,s6
 4e2:	e47ff0ef          	jal	ra,328 <putc>
        putc(fd, c0);
 4e6:	85ca                	mv	a1,s2
 4e8:	855a                	mv	a0,s6
 4ea:	e3fff0ef          	jal	ra,328 <putc>
      state = 0;
 4ee:	4981                	li	s3,0
 4f0:	bf99                	j	446 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 4f2:	008b8913          	addi	s2,s7,8
 4f6:	4685                	li	a3,1
 4f8:	4629                	li	a2,10
 4fa:	000bb583          	ld	a1,0(s7)
 4fe:	855a                	mv	a0,s6
 500:	e47ff0ef          	jal	ra,346 <printint>
        i += 1;
 504:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 506:	8bca                	mv	s7,s2
      state = 0;
 508:	4981                	li	s3,0
        i += 1;
 50a:	bf35                	j	446 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 50c:	03860563          	beq	a2,s8,536 <vprintf+0x14a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 510:	07b60963          	beq	a2,s11,582 <vprintf+0x196>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 514:	07800793          	li	a5,120
 518:	fcf613e3          	bne	a2,a5,4de <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 51c:	008b8913          	addi	s2,s7,8
 520:	4681                	li	a3,0
 522:	4641                	li	a2,16
 524:	000bb583          	ld	a1,0(s7)
 528:	855a                	mv	a0,s6
 52a:	e1dff0ef          	jal	ra,346 <printint>
        i += 2;
 52e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 530:	8bca                	mv	s7,s2
      state = 0;
 532:	4981                	li	s3,0
        i += 2;
 534:	bf09                	j	446 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 536:	008b8913          	addi	s2,s7,8
 53a:	4685                	li	a3,1
 53c:	4629                	li	a2,10
 53e:	000bb583          	ld	a1,0(s7)
 542:	855a                	mv	a0,s6
 544:	e03ff0ef          	jal	ra,346 <printint>
        i += 2;
 548:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 54a:	8bca                	mv	s7,s2
      state = 0;
 54c:	4981                	li	s3,0
        i += 2;
 54e:	bde5                	j	446 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 0);
 550:	008b8913          	addi	s2,s7,8
 554:	4681                	li	a3,0
 556:	4629                	li	a2,10
 558:	000ba583          	lw	a1,0(s7)
 55c:	855a                	mv	a0,s6
 55e:	de9ff0ef          	jal	ra,346 <printint>
 562:	8bca                	mv	s7,s2
      state = 0;
 564:	4981                	li	s3,0
 566:	b5c5                	j	446 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 568:	008b8913          	addi	s2,s7,8
 56c:	4681                	li	a3,0
 56e:	4629                	li	a2,10
 570:	000bb583          	ld	a1,0(s7)
 574:	855a                	mv	a0,s6
 576:	dd1ff0ef          	jal	ra,346 <printint>
        i += 1;
 57a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 57c:	8bca                	mv	s7,s2
      state = 0;
 57e:	4981                	li	s3,0
        i += 1;
 580:	b5d9                	j	446 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 582:	008b8913          	addi	s2,s7,8
 586:	4681                	li	a3,0
 588:	4629                	li	a2,10
 58a:	000bb583          	ld	a1,0(s7)
 58e:	855a                	mv	a0,s6
 590:	db7ff0ef          	jal	ra,346 <printint>
        i += 2;
 594:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 596:	8bca                	mv	s7,s2
      state = 0;
 598:	4981                	li	s3,0
        i += 2;
 59a:	b575                	j	446 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 16, 0);
 59c:	008b8913          	addi	s2,s7,8
 5a0:	4681                	li	a3,0
 5a2:	4641                	li	a2,16
 5a4:	000ba583          	lw	a1,0(s7)
 5a8:	855a                	mv	a0,s6
 5aa:	d9dff0ef          	jal	ra,346 <printint>
 5ae:	8bca                	mv	s7,s2
      state = 0;
 5b0:	4981                	li	s3,0
 5b2:	bd51                	j	446 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5b4:	008b8913          	addi	s2,s7,8
 5b8:	4681                	li	a3,0
 5ba:	4641                	li	a2,16
 5bc:	000bb583          	ld	a1,0(s7)
 5c0:	855a                	mv	a0,s6
 5c2:	d85ff0ef          	jal	ra,346 <printint>
        i += 1;
 5c6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 5c8:	8bca                	mv	s7,s2
      state = 0;
 5ca:	4981                	li	s3,0
        i += 1;
 5cc:	bdad                	j	446 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 5ce:	008b8793          	addi	a5,s7,8
 5d2:	f8f43423          	sd	a5,-120(s0)
 5d6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5da:	03000593          	li	a1,48
 5de:	855a                	mv	a0,s6
 5e0:	d49ff0ef          	jal	ra,328 <putc>
  putc(fd, 'x');
 5e4:	07800593          	li	a1,120
 5e8:	855a                	mv	a0,s6
 5ea:	d3fff0ef          	jal	ra,328 <putc>
 5ee:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5f0:	03c9d793          	srli	a5,s3,0x3c
 5f4:	97e6                	add	a5,a5,s9
 5f6:	0007c583          	lbu	a1,0(a5)
 5fa:	855a                	mv	a0,s6
 5fc:	d2dff0ef          	jal	ra,328 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 600:	0992                	slli	s3,s3,0x4
 602:	397d                	addiw	s2,s2,-1
 604:	fe0916e3          	bnez	s2,5f0 <vprintf+0x204>
        printptr(fd, va_arg(ap, uint64));
 608:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 60c:	4981                	li	s3,0
 60e:	bd25                	j	446 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 610:	008b8993          	addi	s3,s7,8
 614:	000bb903          	ld	s2,0(s7)
 618:	00090f63          	beqz	s2,636 <vprintf+0x24a>
        for(; *s; s++)
 61c:	00094583          	lbu	a1,0(s2)
 620:	c195                	beqz	a1,644 <vprintf+0x258>
          putc(fd, *s);
 622:	855a                	mv	a0,s6
 624:	d05ff0ef          	jal	ra,328 <putc>
        for(; *s; s++)
 628:	0905                	addi	s2,s2,1
 62a:	00094583          	lbu	a1,0(s2)
 62e:	f9f5                	bnez	a1,622 <vprintf+0x236>
        if((s = va_arg(ap, char*)) == 0)
 630:	8bce                	mv	s7,s3
      state = 0;
 632:	4981                	li	s3,0
 634:	bd09                	j	446 <vprintf+0x5a>
          s = "(null)";
 636:	00000917          	auipc	s2,0x0
 63a:	1fa90913          	addi	s2,s2,506 # 830 <malloc+0xe4>
        for(; *s; s++)
 63e:	02800593          	li	a1,40
 642:	b7c5                	j	622 <vprintf+0x236>
        if((s = va_arg(ap, char*)) == 0)
 644:	8bce                	mv	s7,s3
      state = 0;
 646:	4981                	li	s3,0
 648:	bbfd                	j	446 <vprintf+0x5a>
    }
  }
}
 64a:	70e6                	ld	ra,120(sp)
 64c:	7446                	ld	s0,112(sp)
 64e:	74a6                	ld	s1,104(sp)
 650:	7906                	ld	s2,96(sp)
 652:	69e6                	ld	s3,88(sp)
 654:	6a46                	ld	s4,80(sp)
 656:	6aa6                	ld	s5,72(sp)
 658:	6b06                	ld	s6,64(sp)
 65a:	7be2                	ld	s7,56(sp)
 65c:	7c42                	ld	s8,48(sp)
 65e:	7ca2                	ld	s9,40(sp)
 660:	7d02                	ld	s10,32(sp)
 662:	6de2                	ld	s11,24(sp)
 664:	6109                	addi	sp,sp,128
 666:	8082                	ret

0000000000000668 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 668:	715d                	addi	sp,sp,-80
 66a:	ec06                	sd	ra,24(sp)
 66c:	e822                	sd	s0,16(sp)
 66e:	1000                	addi	s0,sp,32
 670:	e010                	sd	a2,0(s0)
 672:	e414                	sd	a3,8(s0)
 674:	e818                	sd	a4,16(s0)
 676:	ec1c                	sd	a5,24(s0)
 678:	03043023          	sd	a6,32(s0)
 67c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 680:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 684:	8622                	mv	a2,s0
 686:	d67ff0ef          	jal	ra,3ec <vprintf>
}
 68a:	60e2                	ld	ra,24(sp)
 68c:	6442                	ld	s0,16(sp)
 68e:	6161                	addi	sp,sp,80
 690:	8082                	ret

0000000000000692 <printf>:

void
printf(const char *fmt, ...)
{
 692:	711d                	addi	sp,sp,-96
 694:	ec06                	sd	ra,24(sp)
 696:	e822                	sd	s0,16(sp)
 698:	1000                	addi	s0,sp,32
 69a:	e40c                	sd	a1,8(s0)
 69c:	e810                	sd	a2,16(s0)
 69e:	ec14                	sd	a3,24(s0)
 6a0:	f018                	sd	a4,32(s0)
 6a2:	f41c                	sd	a5,40(s0)
 6a4:	03043823          	sd	a6,48(s0)
 6a8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6ac:	00840613          	addi	a2,s0,8
 6b0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6b4:	85aa                	mv	a1,a0
 6b6:	4505                	li	a0,1
 6b8:	d35ff0ef          	jal	ra,3ec <vprintf>
}
 6bc:	60e2                	ld	ra,24(sp)
 6be:	6442                	ld	s0,16(sp)
 6c0:	6125                	addi	sp,sp,96
 6c2:	8082                	ret

00000000000006c4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6c4:	1141                	addi	sp,sp,-16
 6c6:	e422                	sd	s0,8(sp)
 6c8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6ca:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ce:	00001797          	auipc	a5,0x1
 6d2:	9627b783          	ld	a5,-1694(a5) # 1030 <freep>
 6d6:	a805                	j	706 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6d8:	4618                	lw	a4,8(a2)
 6da:	9db9                	addw	a1,a1,a4
 6dc:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6e0:	6398                	ld	a4,0(a5)
 6e2:	6318                	ld	a4,0(a4)
 6e4:	fee53823          	sd	a4,-16(a0)
 6e8:	a091                	j	72c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6ea:	ff852703          	lw	a4,-8(a0)
 6ee:	9e39                	addw	a2,a2,a4
 6f0:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6f2:	ff053703          	ld	a4,-16(a0)
 6f6:	e398                	sd	a4,0(a5)
 6f8:	a099                	j	73e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6fa:	6398                	ld	a4,0(a5)
 6fc:	00e7e463          	bltu	a5,a4,704 <free+0x40>
 700:	00e6ea63          	bltu	a3,a4,714 <free+0x50>
{
 704:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 706:	fed7fae3          	bgeu	a5,a3,6fa <free+0x36>
 70a:	6398                	ld	a4,0(a5)
 70c:	00e6e463          	bltu	a3,a4,714 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 710:	fee7eae3          	bltu	a5,a4,704 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 714:	ff852583          	lw	a1,-8(a0)
 718:	6390                	ld	a2,0(a5)
 71a:	02059813          	slli	a6,a1,0x20
 71e:	01c85713          	srli	a4,a6,0x1c
 722:	9736                	add	a4,a4,a3
 724:	fae60ae3          	beq	a2,a4,6d8 <free+0x14>
    bp->s.ptr = p->s.ptr;
 728:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 72c:	4790                	lw	a2,8(a5)
 72e:	02061593          	slli	a1,a2,0x20
 732:	01c5d713          	srli	a4,a1,0x1c
 736:	973e                	add	a4,a4,a5
 738:	fae689e3          	beq	a3,a4,6ea <free+0x26>
  } else
    p->s.ptr = bp;
 73c:	e394                	sd	a3,0(a5)
  freep = p;
 73e:	00001717          	auipc	a4,0x1
 742:	8ef73923          	sd	a5,-1806(a4) # 1030 <freep>
}
 746:	6422                	ld	s0,8(sp)
 748:	0141                	addi	sp,sp,16
 74a:	8082                	ret

000000000000074c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 74c:	7139                	addi	sp,sp,-64
 74e:	fc06                	sd	ra,56(sp)
 750:	f822                	sd	s0,48(sp)
 752:	f426                	sd	s1,40(sp)
 754:	f04a                	sd	s2,32(sp)
 756:	ec4e                	sd	s3,24(sp)
 758:	e852                	sd	s4,16(sp)
 75a:	e456                	sd	s5,8(sp)
 75c:	e05a                	sd	s6,0(sp)
 75e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 760:	02051493          	slli	s1,a0,0x20
 764:	9081                	srli	s1,s1,0x20
 766:	04bd                	addi	s1,s1,15
 768:	8091                	srli	s1,s1,0x4
 76a:	0014899b          	addiw	s3,s1,1
 76e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 770:	00001517          	auipc	a0,0x1
 774:	8c053503          	ld	a0,-1856(a0) # 1030 <freep>
 778:	c515                	beqz	a0,7a4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 77a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 77c:	4798                	lw	a4,8(a5)
 77e:	02977f63          	bgeu	a4,s1,7bc <malloc+0x70>
 782:	8a4e                	mv	s4,s3
 784:	0009871b          	sext.w	a4,s3
 788:	6685                	lui	a3,0x1
 78a:	00d77363          	bgeu	a4,a3,790 <malloc+0x44>
 78e:	6a05                	lui	s4,0x1
 790:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 794:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 798:	00001917          	auipc	s2,0x1
 79c:	89890913          	addi	s2,s2,-1896 # 1030 <freep>
  if(p == (char*)-1)
 7a0:	5afd                	li	s5,-1
 7a2:	a885                	j	812 <malloc+0xc6>
    base.s.ptr = freep = prevp = &base;
 7a4:	00001797          	auipc	a5,0x1
 7a8:	89c78793          	addi	a5,a5,-1892 # 1040 <base>
 7ac:	00001717          	auipc	a4,0x1
 7b0:	88f73223          	sd	a5,-1916(a4) # 1030 <freep>
 7b4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7b6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7ba:	b7e1                	j	782 <malloc+0x36>
      if(p->s.size == nunits)
 7bc:	02e48c63          	beq	s1,a4,7f4 <malloc+0xa8>
        p->s.size -= nunits;
 7c0:	4137073b          	subw	a4,a4,s3
 7c4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7c6:	02071693          	slli	a3,a4,0x20
 7ca:	01c6d713          	srli	a4,a3,0x1c
 7ce:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7d0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7d4:	00001717          	auipc	a4,0x1
 7d8:	84a73e23          	sd	a0,-1956(a4) # 1030 <freep>
      return (void*)(p + 1);
 7dc:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7e0:	70e2                	ld	ra,56(sp)
 7e2:	7442                	ld	s0,48(sp)
 7e4:	74a2                	ld	s1,40(sp)
 7e6:	7902                	ld	s2,32(sp)
 7e8:	69e2                	ld	s3,24(sp)
 7ea:	6a42                	ld	s4,16(sp)
 7ec:	6aa2                	ld	s5,8(sp)
 7ee:	6b02                	ld	s6,0(sp)
 7f0:	6121                	addi	sp,sp,64
 7f2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7f4:	6398                	ld	a4,0(a5)
 7f6:	e118                	sd	a4,0(a0)
 7f8:	bff1                	j	7d4 <malloc+0x88>
  hp->s.size = nu;
 7fa:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7fe:	0541                	addi	a0,a0,16
 800:	ec5ff0ef          	jal	ra,6c4 <free>
  return freep;
 804:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 808:	dd61                	beqz	a0,7e0 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 80a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 80c:	4798                	lw	a4,8(a5)
 80e:	fa9777e3          	bgeu	a4,s1,7bc <malloc+0x70>
    if(p == freep)
 812:	00093703          	ld	a4,0(s2)
 816:	853e                	mv	a0,a5
 818:	fef719e3          	bne	a4,a5,80a <malloc+0xbe>
  p = sbrk(nu * sizeof(Header));
 81c:	8552                	mv	a0,s4
 81e:	af3ff0ef          	jal	ra,310 <sbrk>
  if(p == (char*)-1)
 822:	fd551ce3          	bne	a0,s5,7fa <malloc+0xae>
        return 0;
 826:	4501                	li	a0,0
 828:	bf65                	j	7e0 <malloc+0x94>
