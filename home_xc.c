/* xc - forth-style calculator project

Remarks:

    -   Support for user defined variables.

        -   When variable is invoked, a pointer to storage is pushed on stack

        -   Load command reads a cell of data from pointer

        -   Store command writes a cell of data to pointer

        -   Read command reads a cell and also increments the pointer

        -   Write command writes a cell and also increments the pointer

        -   By default, variables are one cell in size, but could be different

    -   Support for stdin processing

        -   gets function -- buffer

            -   Read a line from stdin and store to given buffer

            -   this function also returns a flag

        -   readline function -- buffer -- buffer+=len

            -   Read a line from stdin and write to given buffer, increment ptr

            -   this function also returns a flag

    -   @filename source

    -   @name func { }

    -   @name create { } 0 , @name create

    -   @name variable

    -   value @name const

    -   Concept of a contiguous heap

        -   When a variable is created, it points to current location

        -   Use of allot to advance the heap pointer

        -   Constant is a variable which is read-only loaded on exec

    -   create x1 or x1 create

    -   here

    -   allot

    -   cells

    -   comma

    -   Memory sections:

            Registers

            Dictionary

            Code

            Data

            Stack

    -   Dynamic compilation and execution, execute tokens as soon as possible while compiling

        -   Concept of state machine for pending tokens

        -   Use concept of completion routine, callback when next tokens arrive


*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/* Dictionary of tokens */

union calc_cell;

union calc_cell
{
    signed long int s;

    unsigned long int u;

    float f;

    void * p;

    char const * c;

    union calc_cell * r;

    void (*callback)(void);

};

struct calc_token
{
    /* Pointer to original source characters */
    char const * name;

    /* Pointer to token handler */
    /* Extra data here... */
    union calc_cell code[2];

};

static unsigned int dict_len = 0u;

#define DICT_MAX 1024u

static unsigned int const dict_max = DICT_MAX;

static struct calc_token dict_array[DICT_MAX];

static struct calc_token * dict_find(
    char const * name)
{
    unsigned int dict_it;

    for (dict_it = 0; dict_it < dict_len; dict_it++)
    {
        struct calc_token * node = dict_array + dict_it;

        if (node->name)
        {
            if (0 == strcmp(name, node->name))
            {
                return node;
            }
        }
    }

    return 0;
}

static void f_nop(void);

static struct calc_token * dict_add(
    char const * name)
{
    struct calc_token * buf;

    /* Create a token */
    if (dict_len < dict_max)
    {
        /* Store into dictionary */
        buf = dict_array + dict_len;

        buf->name = strdup(name);

        buf->code[0].callback = &(f_nop);

        buf->code[1].r = NULL;

        dict_len ++;
    }
    else
    {
        buf = 0;
    }

    return buf;
}

/* Data segment */

#define DS_MAX 1024u

static unsigned int const ds_max = DS_MAX;

static union calc_cell ds[DS_MAX];

static union calc_cell here;

#define SP_MAX 1024u

static unsigned int const sp_max = SP_MAX;

static union calc_cell ss[SP_MAX];

static union calc_cell * sp = ss;

/* Code segment */

#if 0
static unsigned int level = 0u;
#endif

static unsigned int cs_len = 0u;

#define CS_MAX 1024u

static unsigned int const cs_max = CS_MAX;

static union calc_cell cs[CS_MAX];

static union calc_cell * pc = cs;

static union calc_cell pop()
{
    if (sp > ss)
    {
        return *(--sp);
    }
    else
    {
        static union calc_cell null = {0};
        return null;
    }
}

#if 0
static signed long int popl()
{
    union calc_cell o = pop();
    return o.s;
}
#endif

static void * popv()
{
    union calc_cell o = pop();
    return o.p;
}

static void push(union calc_cell value)
{
    if (sp < ss + sp_max)
    {
        *(sp++) = value;
    }
}

static void pushl(signed long int value)
{
    union calc_cell o;
    o.s = value;
    push(o);
}

static void pushv(void* value)
{
    union calc_cell o;
    o.p = value;
    push(o);
}

static void f_nop() {
}

static void f_dup() {
    union calc_cell num1 = pop();
    push(num1);
    push(num1);
}

static void f_swap() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    push(num2);
    push(num1);
}

static void f_add() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    num1.s += num2.s;
    push(num1);
}

static void f_sub() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    num1.s -= num2.s;
    push(num1);
}

static void f_mul() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    num1.s *= num2.s;
    push(num1);
}

static void f_div() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    if (num2.s)
    {
        num1.s /= num2.s;
    }
    else
    {
        num1.s = 0;
    }
    push(num1);
}

static void f_mod() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    if (num2.s)
    {
        num1.s %= num2.s;
    }
    else
    {
        num1.s = 0;
    }
    push(num1);
}

static void f_neg() {
    union calc_cell num1 = pop();
    num1.s = -num1.s;
    push(num1);
}

static void f_shl() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    num1.s <<= num2.s;
    push(num1);
}

static void f_shr() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    num1.s >>= num2.s;
    push(num1);
}

static void f_shl1() {
    union calc_cell num1 = pop();
    num1.s <<= 1;
    push(num1);
}

static void f_shr1() {
    union calc_cell num1 = pop();
    num1.s >>= 1;
    push(num1);
}

static void f_or() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    num1.s |= num2.s;
    push(num1);
}

static void f_and() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    num1.s &= num2.s;
    push(num1);
}

static void f_xor() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    num1.s ^= num2.s;
    push(num1);
}

static void f_not() {
    union calc_cell num1 = pop();
    num1.s = !num1.s;
    push(num1);
}

static void f_abs() {
    union calc_cell num1 = pop();
    if (num1.s < 0)
    {
        num1.s = -num1.s;
    }
    push(num1);
}

static void f_min() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    push(num1.s < num2.s ? num1 : num2);
}

static void f_max() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    push(num1.s > num2.s ? num1 : num2);
}

static void f_true() {
    pushl(-1);
}

static void f_false() {
    pushl(0);
}

static void cs_write(union calc_cell code) {
    if (cs_len < cs_max)
    {
        cs[cs_len] = code;

        cs_len ++;
    }
}

static void cs_write_callback(void (*callback)()) {
    union calc_cell o;
    o.callback = callback;
    cs_write(o);
}

static void cs_write_buffer(void * buffer) {
    union calc_cell o;
    o.p = buffer;
    cs_write(o);
}

static char pc_compare(void (*callback)()) {
    return (pc->callback == callback);
}

static void f_literal_integer() {
    pc ++;
    push(*pc);
}

static void f_literal_string() {
    pc ++;
    pushv(pc->p);
}

static void exec1();

static void f_literal_call() {
    pc ++;

    union calc_cell * backup = pc;

    pc = pc->r;

    exec1();

    pc = backup;
}

static void f_unknown() {
    pc ++;

    union calc_cell * backup = pc;

    pc = pc->r;

    (*(pc->callback))();

    pc = backup;
}

static void exec1() {
    if (pc < cs + cs_len)
    {
        (*(pc->callback))();
    }
}

static void f_end() {
}

static void f_exit() {
}

static void f_begin() {
#if 0
    level ++;
#endif
    pc ++;
    while (!pc_compare(&f_exit))
    {
        if (pc_compare(&f_end))
        {
            break;
        }
        else
        {
            exec1();
            pc ++;
        }
    }
#if 0
    -- level;
#endif
}

static void skip_block() {
#if 0
    level ++;
#endif
    pc ++;
    while (!pc_compare(&f_exit))
    {
        if (pc_compare(&f_end))
        {
            break;
        }
        else
        {
            if (pc_compare(&f_begin))
            {
                skip_block();
            }
            pc ++;
        }
    }
#if 0
    -- level;
#endif
}

static void skip1() {
    if (pc_compare(&f_begin))
    {
        skip_block();
    }
}

static void f_else() {
}

static void f_if() {
    union calc_cell num1 = pop();
    pc ++;
    if (num1.s)
    {
        exec1();
    }
    else
    {
        skip1();
    }
    pc ++;
    if (pc_compare(&f_else))
    {
        pc ++;
        if (num1.s)
        {
            skip1();
        }
        else
        {
            exec1();
        }
    }
    else
    {
        pc --;
    }
}

static void f_gt() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    num1.s = (num1.s > num2.s);
    push(num1);
}

static void f_lt() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    num1.s = (num1.s < num2.s);
    push(num1);
}

static void f_eq() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    num1.s = (num1.s == num2.s);
    push(num1);
}

static void f_ne() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    num1.s = (num1.s != num2.s);
    push(num1);
}

static void f_ge() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    num1.s = (num1.s >= num2.s);
    push(num1);
}

static void f_le() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    num1.s = (num1.s <= num2.s);
    push(num1);
}

static void f_eq0() {
    union calc_cell num1 = pop();
    num1.s = (num1.s == 0);
    push(num1);
}

static void f_ne0() {
    union calc_cell num1 = pop();
    num1.s = (num1.s != 0);
    push(num1);
}

static void f_gt0() {
    union calc_cell num1 = pop();
    num1.s = (num1.s > 0);
    push(num1);
}

static void f_lt0() {
    union calc_cell num1 = pop();
    num1.s = (num1.s < 0);
    push(num1);
}

static void f_ge0() {
    union calc_cell num1 = pop();
    num1.s = (num1.s >= 0);
    push(num1);
}

static void f_le0() {
    union calc_cell num1 = pop();
    num1.s = (num1.s <= 0);
    push(num1);
}

static void f_inc() {
    union calc_cell num1 = pop();
    num1.s ++;
    push(num1);
}

static void f_dec() {
    union calc_cell num1 = pop();
    num1.s --;
    push(num1);
}

static void f_drop() {
    (void)(pop());
}

static void f_nip() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    (void)(num1);
    push(num2);
}

static void f_over() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    push(num1);
    push(num2);
    push(num1);
}

static void f_tuck() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    push(num2);
    push(num1);
    push(num2);
}

static void f_pick() {
    union calc_cell num1 = pop();
    if ((num1.s >= 0) && (num1.s < sp - ss))
    {
        push(*(sp - 1 - num1.u));
    }
}

static void f_rot() {
    union calc_cell num3 = pop();
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    push(num2);
    push(num3);
    push(num1);
}

static void f_dots() {
    /* dump what remains in ss */
    for (unsigned int si = 0u; si < (unsigned int)(sp - ss); si++)
    {
        printf("[%u] %11ld -- 0x%08lx\n", si, ss[si].s, ss[si].u);
    }
}

/* repeat a block of code 'num1' times */
static void f_repeat() {
    union calc_cell num1 = pop();
    pc ++;
    union calc_cell * label = pc;
    while (num1.s-- > 0)
    {
        pc = label;
        exec1();
    }
}

/* for loop in 0 to 'num1'-1 range */
static void f_for() {
    union calc_cell num1 = pop();
    pc ++;
    union calc_cell * label = pc;
    for (signed long int i=0; i<num1.s; i++)
    {
        pc = label;
        pushl(i);
        exec1();
    }
}

/* while 'num1' is true */
static void f_while() {
    union calc_cell num1;
    pc ++;
    union calc_cell * label = pc;
    for (;;)
    {
        pc = label;
        num1 = pop();
        if (num1.s)
        {
            exec1();
        }
        else
        {
            skip1();
            break;
        }
    }
}

static void f_dot() {
    union calc_cell num1 = pop();
    printf("%ld", num1.s);
}

static void f_udot() {
    union calc_cell num1 = pop();
    printf("%lu", num1.u);
}

static void f_xdot() {
    union calc_cell num1 = pop();
    printf("%lx", num1.u);
}

static void f_sdot() {
    union calc_cell buf = pop();
    printf("%s", buf.c);
}

static void f_cdot() {
    union calc_cell num1 = pop();
    printf("%c", (char)num1.s);
}

static void f_fdot() {
    union calc_cell num1 = pop();
    printf("%f", num1.f);
}

static void f_dotr() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    printf("%*ld", (int)num2.s, num1.s);
}

static void f_udotr() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    printf("%*lu", (int)num2.s, num1.u);
}

static void f_xdotr() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    printf("%*lx", (int)num2.s, num1.u);
}

static void f_sdotr() {
    union calc_cell num2 = pop();
    union calc_cell buf = pop();
    printf("%*s", (int)num2.s, buf.c);
}

static void f_fdotr() {
    union calc_cell num3 = pop();
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    printf("%*.*f", (int)num2.s, (int)num3.s, num1.f);
}

static void f_cr() {
    printf("%c", '\n');
}

static void f_space() {
    printf("%c", ' ');
}

static void f_tab() {
    printf("%c", '\t');
}

static void f_alloc() {
    union calc_cell num1 = pop();
    void * buf = malloc(num1.u);
    pushv(buf);
}

static void f_free() {
    void * buf = popv();
    free(buf);
}

static void f_strcpy() {
    char const * src = (char const *)popv();
    char * dst = (char *)popv();
    strcpy(dst, src);
}

static void f_strcat() {
    char const * src = (char const *)popv();
    char * dst = (char *)popv();
    strcat(dst, src);
}

static void f_strlen() {
    union calc_cell num1 = pop();
    num1.s = strlen(num1.c);
    push(num1);
}

static void f_strtok() {
    char const * pattern = (char const *)popv();
    char * dst = (char *)popv();
    char const * result = strtok(dst, pattern);
    pushv((void *)(result));
}

static void f_strdup() {
    char const * src = (char const *)popv();
    char * dst = strdup(src);
    pushv((void *)(dst));
}

static void f_here() {
    push(here);
}

static void f_allot() {
    union calc_cell num1 = pop();
    here.c += num1.s;
}

static void f_create() {
    /* get next instruction */
    pc ++;
    if (pc_compare(f_unknown))
    {
        pc ++;
        {
            pc->r[0].callback = &(f_literal_string);

            pc->r[1] = here;
        }
    }
    else
    {
        printf("not a valid variable name\n");
    }
}

static void f_value() {
    union calc_cell num1 = pop();
    pc ++;
    {
        if (pc_compare(f_unknown))
        {
            pc ++;
            {
                pc->r[0].callback = &(f_literal_integer);

                pc->r[1] = num1;
            }
        }
        else
        {
            printf("not a valid variable name\n");
        }
    }
}

static void f_comma() {
    union calc_cell num1 = pop();
    *(here.r) = num1;
    here.r ++;
}

static void f_ccomma() {
    union calc_cell num2 = pop();
    *(char *)(here.c) = (char)(num2.s);
    here.c ++;
}

static void f_scomma() {
    char const * src = (char const *)popv();
    int src_len = strlen(src);
    strcpy((char *)(here.c), src);
    here.c += src_len;
}

static void f_itoa() {
    char * dst = (char *)malloc(28);
    union calc_cell num1 = pop();
    sprintf(dst, "%ld", num1.s);
    pushv(dst);
}

static signed long int conv_atoi(char const * src) {
    signed long int num1 = 0;
    if (('0' == src[0]) && ('x' == src[1]))
    {
        sscanf(src, "%lx", &num1);
    }
    else
    {
        sscanf(src, "%ld", &num1);
    }
    return num1;
}

static float conv_atof(char const * src) {
    float num1 = 0.0f;
    sscanf(src, "%f", &num1);
    return num1;
}

static void f_atoi() {
    char const * src = (char const *)popv();
    signed long int num1 = conv_atoi(src);
    pushl(num1);
}

static void f_gets() {
    char * buf = (char *)popv();
    signed long int result;
    if (buf == fgets(buf, 4096, stdin))
    {
        /* remove the trailing cr if present */
        unsigned int buf_len = strlen(buf);
        if ('\n' == buf[buf_len-1])
        {
            buf[buf_len-1] = '\0';
        }
        result = 1;
    }
    else
    {
        *buf = 0;
        result = 0;
    }
    pushl(result);
}

static void f_load() {
    union calc_cell buf = pop();
    push(*buf.r);
}

static void f_store() {
    union calc_cell buf = pop();
    *buf.r = pop();
}

static void f_cells() {
    union calc_cell num1 = pop();
    num1.s *= sizeof(union calc_cell);
    push(num1);
}

static void f_skip() {
    pc ++;
    skip1();
}

static void f_pc() {
    pushv(pc);
}

static void f_sp0() {
    pushv(ss);
}

static void f_spload() {
    pushv(sp);
}

static void f_spstore() {
    union calc_cell num1 = pop();
    sp = num1.r;
}

static void f_call() {
    union calc_cell num1 = pop();
    {
        union calc_cell * backup = pc;

        pc = num1.r;

        exec1();

        pc = backup;
    }
}

static void f_func() {
    pc ++;
    {
        if (pc_compare(f_unknown))
        {
            pc ++;
            {
                pc->r[0].callback = &(f_literal_call);

                pc->r[1].r = pc + 1;

                pc ++;

                skip1();
            }
        }
        else
        {
            printf("not a valid function name\n");
        }
    }
}

static void f_itof() {
    union calc_cell num1 = pop();
    num1.f = (float)(num1.s);
    push(num1);
}

static void f_ftoi() {
    union calc_cell num1 = pop();
    num1.s = (signed long int)(num1.f);
    push(num1);
}

static void f_atof() {
    union calc_cell num1 = pop();
    num1.f = conv_atof(num1.c);
    push(num1);
}

static void f_ftoa() {
    char * dst = (char *)malloc(28);
    union calc_cell num1 = pop();
    sprintf(dst, "%f", num1.f);
    pushv(dst);
}

static void f_fadd() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    num1.f += num2.f;
    push(num1);
}

static void f_fsub() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    num1.f -= num2.f;
    push(num1);
}

static void f_fmul() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    num1.f *= num2.f;
    push(num1);
}

static void f_fdiv() {
    union calc_cell num2 = pop();
    union calc_cell num1 = pop();
    num1.f /= num2.f;
    push(num1);
}

static void f_fneg() {
    union calc_cell num1 = pop();
    num1.f = -num1.f;
    push(num1);
}

static void f_sleep() {
    union calc_cell num1 = pop();
    usleep(num1.u * 1000);
}

/* array of commands */
static void f_list();
static void f_help();

struct calc_builtin
{
    char const * name;

    void (*callback)(void);

};

static struct calc_builtin cmdv[] = {
    { "nop", f_nop },
    { "dup", f_dup },
    { "swap", f_swap },
    { "drop", f_drop },
    { "nip", f_nip },
    { "add", f_add },
    { "+", f_add },
    { "sub", f_sub },
    { "-", f_sub },
    { "mul", f_mul },
    { "*", f_mul },
    { "div", f_div },
    { "/", f_div },
    { "mod", f_mod },
    { "%", f_mod },
    { "neg", f_neg },
    { "-", f_neg },
    { "inc", f_inc },
    { "++", f_inc },
    { "dec", f_dec },
    { "--", f_dec },
    { "shl", f_shl },
    { "<<", f_shl },
    { "shr", f_shr },
    { ">>", f_shr },
    { "shl1", f_shl1 },
    { "<<1", f_shl1 },
    { "shr1", f_shr1 },
    { ">>1", f_shr1 },
    { "or", f_or },
    { "|", f_or },
    { "and", f_and },
    { "&", f_and },
    { "xor", f_xor },
    { "^", f_xor },
    { "not", f_not },
    { "~", f_not },
    { "abs", f_abs },
    { "min", f_min },
    { "max", f_max },
    { "gt", f_gt },
    { ">" , f_gt },
    { "lt", f_lt },
    { "<", f_lt },
    { "eq", f_eq },
    { "==", f_eq },
    { "ne", f_ne },
    { "!=", f_ne },
    { "ge", f_ge },
    { ">=", f_ge },
    { "le", f_le },
    { "<=", f_le },
    { "eq0", f_eq0 },
    { "==0", f_eq0 },
    { "ne0", f_ne0 },
    { "!=0", f_ne0 },
    { "gt0", f_gt0 },
    { ">0", f_gt0 },
    { "lt0", f_lt0 },
    { "<0", f_lt0 },
    { "ge0", f_ge0 },
    { ">=0", f_ge0 },
    { "le0", f_le0 },
    { "<=0", f_le0 },
    { "true", f_true },
    { "false", f_false },
    { "begin", f_begin },
    { "{", f_begin },
    { "end", f_end },
    { "}", f_end },
    { "if", f_if },
    { "else", f_else },
    { "repeat", f_repeat },
    { "for", f_for },
    { "while", f_while },
    { "nip", f_nip },
    { "over", f_over },
    { "tuck", f_tuck },
    { "pick", f_pick },
    { "rot", f_rot },
    { ".s", f_dots },
    { ".", f_dot },
    { "print", f_dot },
    { "u.", f_udot },
    { "x.", f_xdot },
    { "s.", f_sdot },
    { "c.", f_cdot },
    { "f.", f_fdot },
    { ".r", f_dotr },
    { "u.r", f_udotr },
    { "x.r", f_xdotr },
    { "s.r", f_sdotr },
    { "f.r", f_fdotr },
    { "cr", f_cr },
    { ".n", f_cr },
    { "tab", f_tab },
    { ".t", f_tab },
    { "space", f_space },
    { "_", f_space },
    { "alloc", f_alloc },
    { "free", f_free },
    { "strcpy", f_strcpy },
    { "strcat", f_strcat },
    { "strlen", f_strlen },
    { "strtok", f_strtok },
    { "strdup", f_strdup },
    { "here", f_here },
    { "allot", f_allot },
    { "create", f_create },
    { "value", f_value },
    { ",", f_comma },
    { "c,", f_ccomma },
    { "s,", f_scomma },
    { "itoa", f_itoa },
    { "atoi", f_atoi },
    { "gets", f_gets },
    { "load", f_load },
    { "ld", f_load },
    { "@", f_load },
    { "store", f_store },
    { "st", f_store },
    { "!", f_store },
    { "cells", f_cells },
    { "skip", f_skip },
    { "pc", f_pc },
    { "sp0", f_sp0 },
    { "sp@", f_spload },
    { "sp!", f_spstore },
    { "call", f_call },
    { "func", f_func },
    { "itof", f_itof },
    { "ftoi", f_ftoi },
    { "atof", f_atof },
    { "ftoa", f_ftoa },
    { "fadd", f_fadd },
    { "fsub", f_fsub },
    { "fmul", f_fmul },
    { "fdiv", f_fdiv },
    { "fneg", f_fneg },
    { "sleep", f_sleep },
    { "list", f_list },
    { "help", f_help }
    /* # comment */
    /* \ comment */
    /* ( ) comment */
    /* pow */
    /* roll */
};

static unsigned int const cmdc = (unsigned int)(sizeof(cmdv)/sizeof(cmdv[0u]));

static struct calc_builtin const * cmdv_find(char const * word)
{
    for (unsigned int cmdi = 0; cmdi < cmdc; cmdi ++)
    {
        if (0 == strcmp(word, cmdv[cmdi].name))
        {
            return cmdv + cmdi;
        }
    }

    return 0;
}

static void f_help() {
    for (unsigned int cmdi = 0u; cmdi < cmdc; cmdi ++)
    {
        printf("%s\n", cmdv[cmdi].name);
    }
}

static void f_list() {
    printf("vvv list vvv\n");
#if 1
    for (unsigned int i = 0u; i < cs_len; i++)
    {
        if (f_unknown == cs[i].callback)
        {
            printf("[%u] unknown\n", i);
        }
        else if (f_literal_integer == cs[i].callback)
        {
            printf("[%u] integer\n", i);
        }
        else if (f_literal_string == cs[i].callback)
        {
            printf("[%u] string\n", i);
        }
        else if (f_literal_call == cs[i].callback)
        {
            printf("[%u] call\n", i);
        }
        else
        {
            for (unsigned int cmdi = 0; cmdi < cmdc; cmdi ++)
            {
                if (cs[i].callback == cmdv[cmdi].callback)
                {
                    printf("[%u] %s\n", i, cmdv[cmdi].name);
                    break;
                }
            }
        }

#if 0
        if (f_literal_string == token->callback)
        {
            printf("[%u] string \'%s\'\n", i, (char const *)(token + 1));
        }
        else
        {
            printf("[%u] %s\n", i, token->name);
        }
#endif
    }
#endif
    printf("^^^ list ^^^\n");
}

/* Short string encoding

+hello                 ->  "hello"

+hello_world..         ->  "hello world."

+hello_world...n       ->  "hello world.\n"

+.thello_world...n     ->  "\thello world.\n"

*/
static char * decode_string(char const * word, unsigned int word_len)
{
    char * buf = (char *)malloc(word_len + 1);
    if (buf)
    {
        char * buf_it;
        char const * src_it;
        buf_it = buf;
        src_it = word + 1;
        while (*src_it)
        {
            if ('_' == *src_it)
            {
                *(buf_it++) = ' ';
            }
            else
            {
                if ('.' == *src_it)
                {
                    src_it ++;
                    if ('t' == *src_it)
                    {
                        *(buf_it++) = '\t';
                    }
                    else if ('n' == *src_it)
                    {
                        *(buf_it++) = '\n';
                    }
                    else
                    {
                        *(buf_it++) = *src_it;
                    }
                }
                else
                {
                    *(buf_it++) = *src_it;
                }
            }

            src_it ++;
        }

        *(buf_it++) = '\0';
    }

    return buf;
}

static char inside_comment = 0;

static void compile_word(char const * word)
{
    unsigned int word_len = strlen(word);

    /* detect beginning of comment */
    if (inside_comment)
    {
        if (0 == strcmp(word, "!"))
        {
            inside_comment = 0;
        }
    }
    else if (0 == strcmp(word, "!"))
    {
        inside_comment = 1;
    }
    else
    {
        struct calc_builtin const * builtin_item = 0;

        /* detect command from table */
        builtin_item = cmdv_find(word);

        if (builtin_item)
        {
            cs_write_callback(builtin_item->callback);
        }
        else
        {
            struct calc_token * dict_item = 0;

            dict_item = dict_find(word);

            /* detect existing dynamic variable name */
            if (dict_item)
            {
                cs_write_callback(f_unknown);

                cs_write_buffer(dict_item->code);
            }
            else
            {
                /* else detect a literal number */
                if (
                    (
                        ('0' <= word[0])
                        && ('9' >= word[0]))
                    || (
                        ('-' == word[0])
                        && (word[1] >= '0')
                        && (word[1] <= '9')))
                {
                    union calc_cell o;

                    /* detect a floating point number */
                    if (strchr(word, '.'))
                    {
                        o.f = conv_atof(word);
                    }
                    else
                    {
                        o.s = conv_atoi(word);
                    }

                    cs_write_callback(f_literal_integer);

                    cs_write(o);
                }
                /* detect a short string */
                else if ('+' == word[0])
                {
                    char * buf = decode_string(word, word_len);

                    if (buf)
                    {
                        cs_write_callback(f_literal_string);

                        cs_write_buffer(buf);
                    }
                }
                else
                {
                    /* add new word into dictionary */
                    dict_item = dict_add(word);

                    cs_write_callback(f_unknown);

                    cs_write_buffer(dict_item->code);
                }
            }
        }
    }
}

static void compile_file(FILE* fp)
{
    unsigned int word_len = 0;

    char word_buf[128];

    int c;

    do
    {
        c = fgetc(fp);

        if ((c == EOF) || (c == ' ') || (c == '\t') || (c == '\n') || (c == '\r'))
        {
            /* flush word */
            if (word_len)
            {
                word_buf[word_len] = '\0';

                compile_word(word_buf);

                word_len = 0;
            }
        }
        else
        {
            if (word_len < 127)
            {
                word_buf[word_len] = (char)c;

                word_len ++;
            }
        }
    }
    while (c != EOF);
}

int main(int argc, char** argv)
{
    /* Setup here pointer */
    here.r = ds;

    if (argc > 1)
    {
        /* process list of tokens from command line */
        for (int argi = 1; argi < argc; argi ++)
        {
            compile_word(argv[argi]);
        }
    }
    else
    {
        /* process list of tokens from stdin */
        compile_file(stdin);
    }

    /* terminate the program */
    cs_write_callback(f_exit);

    /* execute the program */
    while (!pc_compare(&f_exit))
    {
        exec1();
        pc ++;
    }

    /* dump what remains in ss */
    f_dots();

    return 0;
}

