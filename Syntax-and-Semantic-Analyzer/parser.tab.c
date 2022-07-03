/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison implementation for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output, and Bison version.  */
#define YYBISON 30802

/* Bison version string.  */
#define YYBISON_VERSION "3.8.2"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1




/* First part of user prologue.  */
#line 1 "parser.y"

    #include <iostream>
    #include <cstdlib>
    #include <cstring>
    #include <cmath>
    #include <string>
    #include "../Symbol Table Manager/include.hpp"

    using namespace std;

    extern FILE* yyin;
    FILE* input_file, log_file, error_file;

    SymbolTable* symbol_table_ptr;

    int yyparse();
    int yylex();

    int yyerror(char* str) {

    }

#line 94 "parser.tab.c"

# ifndef YY_CAST
#  ifdef __cplusplus
#   define YY_CAST(Type, Val) static_cast<Type> (Val)
#   define YY_REINTERPRET_CAST(Type, Val) reinterpret_cast<Type> (Val)
#  else
#   define YY_CAST(Type, Val) ((Type) (Val))
#   define YY_REINTERPRET_CAST(Type, Val) ((Type) (Val))
#  endif
# endif
# ifndef YY_NULLPTR
#  if defined __cplusplus
#   if 201103L <= __cplusplus
#    define YY_NULLPTR nullptr
#   else
#    define YY_NULLPTR 0
#   endif
#  else
#   define YY_NULLPTR ((void*)0)
#  endif
# endif


/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    LPAREN = 258,                  /* LPAREN  */
    RPAREN = 259,                  /* RPAREN  */
    SEMICOLON = 260,               /* SEMICOLON  */
    COMMA = 261,                   /* COMMA  */
    LCURL = 262,                   /* LCURL  */
    RCURL = 263,                   /* RCURL  */
    INT = 264,                     /* INT  */
    FLOAT = 265,                   /* FLOAT  */
    VOID = 266,                    /* VOID  */
    LTHIRD = 267,                  /* LTHIRD  */
    RTHIRD = 268,                  /* RTHIRD  */
    FOR = 269,                     /* FOR  */
    IF = 270,                      /* IF  */
    ELSE = 271,                    /* ELSE  */
    WHILE = 272,                   /* WHILE  */
    PRINTLN = 273,                 /* PRINTLN  */
    RETURN = 274,                  /* RETURN  */
    ASSIGNOP = 275,                /* ASSIGNOP  */
    LOGICOP = 276,                 /* LOGICOP  */
    RELOP = 277,                   /* RELOP  */
    ADDOP = 278,                   /* ADDOP  */
    MULOP = 279,                   /* MULOP  */
    NOT = 280,                     /* NOT  */
    INCOP = 281,                   /* INCOP  */
    DECOP = 282,                   /* DECOP  */
    ID = 283,                      /* ID  */
    CONST_INT = 284,               /* CONST_INT  */
    CONST_FLOAT = 285,             /* CONST_FLOAT  */
    SHIFT_ELSE = 286               /* SHIFT_ELSE  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 24 "parser.y"

    int int_val;
    SymbolInfo* syminfo_ptr;

#line 177 "parser.tab.c"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);



/* Symbol kind.  */
enum yysymbol_kind_t
{
  YYSYMBOL_YYEMPTY = -2,
  YYSYMBOL_YYEOF = 0,                      /* "end of file"  */
  YYSYMBOL_YYerror = 1,                    /* error  */
  YYSYMBOL_YYUNDEF = 2,                    /* "invalid token"  */
  YYSYMBOL_LPAREN = 3,                     /* LPAREN  */
  YYSYMBOL_RPAREN = 4,                     /* RPAREN  */
  YYSYMBOL_SEMICOLON = 5,                  /* SEMICOLON  */
  YYSYMBOL_COMMA = 6,                      /* COMMA  */
  YYSYMBOL_LCURL = 7,                      /* LCURL  */
  YYSYMBOL_RCURL = 8,                      /* RCURL  */
  YYSYMBOL_INT = 9,                        /* INT  */
  YYSYMBOL_FLOAT = 10,                     /* FLOAT  */
  YYSYMBOL_VOID = 11,                      /* VOID  */
  YYSYMBOL_LTHIRD = 12,                    /* LTHIRD  */
  YYSYMBOL_RTHIRD = 13,                    /* RTHIRD  */
  YYSYMBOL_FOR = 14,                       /* FOR  */
  YYSYMBOL_IF = 15,                        /* IF  */
  YYSYMBOL_ELSE = 16,                      /* ELSE  */
  YYSYMBOL_WHILE = 17,                     /* WHILE  */
  YYSYMBOL_PRINTLN = 18,                   /* PRINTLN  */
  YYSYMBOL_RETURN = 19,                    /* RETURN  */
  YYSYMBOL_ASSIGNOP = 20,                  /* ASSIGNOP  */
  YYSYMBOL_LOGICOP = 21,                   /* LOGICOP  */
  YYSYMBOL_RELOP = 22,                     /* RELOP  */
  YYSYMBOL_ADDOP = 23,                     /* ADDOP  */
  YYSYMBOL_MULOP = 24,                     /* MULOP  */
  YYSYMBOL_NOT = 25,                       /* NOT  */
  YYSYMBOL_INCOP = 26,                     /* INCOP  */
  YYSYMBOL_DECOP = 27,                     /* DECOP  */
  YYSYMBOL_ID = 28,                        /* ID  */
  YYSYMBOL_CONST_INT = 29,                 /* CONST_INT  */
  YYSYMBOL_CONST_FLOAT = 30,               /* CONST_FLOAT  */
  YYSYMBOL_SHIFT_ELSE = 31,                /* SHIFT_ELSE  */
  YYSYMBOL_YYACCEPT = 32,                  /* $accept  */
  YYSYMBOL_start = 33,                     /* start  */
  YYSYMBOL_program = 34,                   /* program  */
  YYSYMBOL_unit = 35,                      /* unit  */
  YYSYMBOL_func_declaration = 36,          /* func_declaration  */
  YYSYMBOL_func_definition = 37,           /* func_definition  */
  YYSYMBOL_parameter_list = 38,            /* parameter_list  */
  YYSYMBOL_compound_statement = 39,        /* compound_statement  */
  YYSYMBOL_var_declaration = 40,           /* var_declaration  */
  YYSYMBOL_type_specifier = 41,            /* type_specifier  */
  YYSYMBOL_declaration_list = 42,          /* declaration_list  */
  YYSYMBOL_statements = 43,                /* statements  */
  YYSYMBOL_statement = 44,                 /* statement  */
  YYSYMBOL_expression_statement = 45,      /* expression_statement  */
  YYSYMBOL_variable = 46,                  /* variable  */
  YYSYMBOL_expression = 47,                /* expression  */
  YYSYMBOL_logic_expression = 48,          /* logic_expression  */
  YYSYMBOL_rel_expression = 49,            /* rel_expression  */
  YYSYMBOL_simple_expression = 50,         /* simple_expression  */
  YYSYMBOL_term = 51,                      /* term  */
  YYSYMBOL_unary_expression = 52,          /* unary_expression  */
  YYSYMBOL_factor = 53,                    /* factor  */
  YYSYMBOL_argument_list = 54,             /* argument_list  */
  YYSYMBOL_arguments = 55                  /* arguments  */
};
typedef enum yysymbol_kind_t yysymbol_kind_t;




#ifdef short
# undef short
#endif

/* On compilers that do not define __PTRDIFF_MAX__ etc., make sure
   <limits.h> and (if available) <stdint.h> are included
   so that the code can choose integer types of a good width.  */

#ifndef __PTRDIFF_MAX__
# include <limits.h> /* INFRINGES ON USER NAME SPACE */
# if defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stdint.h> /* INFRINGES ON USER NAME SPACE */
#  define YY_STDINT_H
# endif
#endif

/* Narrow types that promote to a signed type and that can represent a
   signed or unsigned integer of at least N bits.  In tables they can
   save space and decrease cache pressure.  Promoting to a signed type
   helps avoid bugs in integer arithmetic.  */

#ifdef __INT_LEAST8_MAX__
typedef __INT_LEAST8_TYPE__ yytype_int8;
#elif defined YY_STDINT_H
typedef int_least8_t yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef __INT_LEAST16_MAX__
typedef __INT_LEAST16_TYPE__ yytype_int16;
#elif defined YY_STDINT_H
typedef int_least16_t yytype_int16;
#else
typedef short yytype_int16;
#endif

/* Work around bug in HP-UX 11.23, which defines these macros
   incorrectly for preprocessor constants.  This workaround can likely
   be removed in 2023, as HPE has promised support for HP-UX 11.23
   (aka HP-UX 11i v2) only through the end of 2022; see Table 2 of
   <https://h20195.www2.hpe.com/V2/getpdf.aspx/4AA4-7673ENW.pdf>.  */
#ifdef __hpux
# undef UINT_LEAST8_MAX
# undef UINT_LEAST16_MAX
# define UINT_LEAST8_MAX 255
# define UINT_LEAST16_MAX 65535
#endif

#if defined __UINT_LEAST8_MAX__ && __UINT_LEAST8_MAX__ <= __INT_MAX__
typedef __UINT_LEAST8_TYPE__ yytype_uint8;
#elif (!defined __UINT_LEAST8_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST8_MAX <= INT_MAX)
typedef uint_least8_t yytype_uint8;
#elif !defined __UINT_LEAST8_MAX__ && UCHAR_MAX <= INT_MAX
typedef unsigned char yytype_uint8;
#else
typedef short yytype_uint8;
#endif

#if defined __UINT_LEAST16_MAX__ && __UINT_LEAST16_MAX__ <= __INT_MAX__
typedef __UINT_LEAST16_TYPE__ yytype_uint16;
#elif (!defined __UINT_LEAST16_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST16_MAX <= INT_MAX)
typedef uint_least16_t yytype_uint16;
#elif !defined __UINT_LEAST16_MAX__ && USHRT_MAX <= INT_MAX
typedef unsigned short yytype_uint16;
#else
typedef int yytype_uint16;
#endif

#ifndef YYPTRDIFF_T
# if defined __PTRDIFF_TYPE__ && defined __PTRDIFF_MAX__
#  define YYPTRDIFF_T __PTRDIFF_TYPE__
#  define YYPTRDIFF_MAXIMUM __PTRDIFF_MAX__
# elif defined PTRDIFF_MAX
#  ifndef ptrdiff_t
#   include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  endif
#  define YYPTRDIFF_T ptrdiff_t
#  define YYPTRDIFF_MAXIMUM PTRDIFF_MAX
# else
#  define YYPTRDIFF_T long
#  define YYPTRDIFF_MAXIMUM LONG_MAX
# endif
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned
# endif
#endif

#define YYSIZE_MAXIMUM                                  \
  YY_CAST (YYPTRDIFF_T,                                 \
           (YYPTRDIFF_MAXIMUM < YY_CAST (YYSIZE_T, -1)  \
            ? YYPTRDIFF_MAXIMUM                         \
            : YY_CAST (YYSIZE_T, -1)))

#define YYSIZEOF(X) YY_CAST (YYPTRDIFF_T, sizeof (X))


/* Stored state numbers (used for stacks). */
typedef yytype_int8 yy_state_t;

/* State numbers in computations.  */
typedef int yy_state_fast_t;

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif


#ifndef YY_ATTRIBUTE_PURE
# if defined __GNUC__ && 2 < __GNUC__ + (96 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_PURE __attribute__ ((__pure__))
# else
#  define YY_ATTRIBUTE_PURE
# endif
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# if defined __GNUC__ && 2 < __GNUC__ + (7 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_UNUSED __attribute__ ((__unused__))
# else
#  define YY_ATTRIBUTE_UNUSED
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YY_USE(E) ((void) (E))
#else
# define YY_USE(E) /* empty */
#endif

/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
#if defined __GNUC__ && ! defined __ICC && 406 <= __GNUC__ * 100 + __GNUC_MINOR__
# if __GNUC__ * 100 + __GNUC_MINOR__ < 407
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")
# else
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")              \
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# endif
# define YY_IGNORE_MAYBE_UNINITIALIZED_END      \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif

#if defined __cplusplus && defined __GNUC__ && ! defined __ICC && 6 <= __GNUC__
# define YY_IGNORE_USELESS_CAST_BEGIN                          \
    _Pragma ("GCC diagnostic push")                            \
    _Pragma ("GCC diagnostic ignored \"-Wuseless-cast\"")
# define YY_IGNORE_USELESS_CAST_END            \
    _Pragma ("GCC diagnostic pop")
#endif
#ifndef YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_END
#endif


#define YY_ASSERT(E) ((void) (0 && (E)))

#if !defined yyoverflow

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* !defined yyoverflow */

#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yy_state_t yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (YYSIZEOF (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (YYSIZEOF (yy_state_t) + YYSIZEOF (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYPTRDIFF_T yynewbytes;                                         \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * YYSIZEOF (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / YYSIZEOF (*yyptr);                        \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, YY_CAST (YYSIZE_T, (Count)) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYPTRDIFF_T yyi;                      \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  11
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   162

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  32
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  24
/* YYNRULES -- Number of rules.  */
#define YYNRULES  64
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  118

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   286


/* YYTRANSLATE(TOKEN-NUM) -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, with out-of-bounds checking.  */
#define YYTRANSLATE(YYX)                                \
  (0 <= (YYX) && (YYX) <= YYMAXUTOK                     \
   ? YY_CAST (yysymbol_kind_t, yytranslate[YYX])        \
   : YYSYMBOL_YYUNDEF)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex.  */
static const yytype_int8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31
};

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,    57,    57,    63,    66,    72,    75,    78,    84,    87,
      93,    96,   102,   105,   108,   111,   117,   120,   126,   132,
     135,   138,   144,   147,   150,   153,   159,   162,   168,   171,
     174,   177,   180,   183,   186,   189,   192,   198,   201,   207,
     210,   216,   219,   225,   228,   234,   237,   243,   246,   252,
     255,   261,   264,   267,   273,   276,   279,   282,   285,   288,
     291,   297,   300,   306,   309
};
#endif

/** Accessing symbol of state STATE.  */
#define YY_ACCESSING_SYMBOL(State) YY_CAST (yysymbol_kind_t, yystos[State])

#if YYDEBUG || 0
/* The user-facing name of the symbol whose (internal) number is
   YYSYMBOL.  No bounds checking.  */
static const char *yysymbol_name (yysymbol_kind_t yysymbol) YY_ATTRIBUTE_UNUSED;

/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "\"end of file\"", "error", "\"invalid token\"", "LPAREN", "RPAREN",
  "SEMICOLON", "COMMA", "LCURL", "RCURL", "INT", "FLOAT", "VOID", "LTHIRD",
  "RTHIRD", "FOR", "IF", "ELSE", "WHILE", "PRINTLN", "RETURN", "ASSIGNOP",
  "LOGICOP", "RELOP", "ADDOP", "MULOP", "NOT", "INCOP", "DECOP", "ID",
  "CONST_INT", "CONST_FLOAT", "SHIFT_ELSE", "$accept", "start", "program",
  "unit", "func_declaration", "func_definition", "parameter_list",
  "compound_statement", "var_declaration", "type_specifier",
  "declaration_list", "statements", "statement", "expression_statement",
  "variable", "expression", "logic_expression", "rel_expression",
  "simple_expression", "term", "unary_expression", "factor",
  "argument_list", "arguments", YY_NULLPTR
};

static const char *
yysymbol_name (yysymbol_kind_t yysymbol)
{
  return yytname[yysymbol];
}
#endif

#define YYPACT_NINF (-70)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-1)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
      49,   -70,   -70,   -70,    31,    49,   -70,   -70,   -70,   -70,
      27,   -70,   -70,    18,    59,     9,    33,   -70,    54,    38,
      48,    58,    53,    75,   -70,    66,   -70,    56,    49,   -70,
     -70,    61,   131,   -70,   -70,    85,    89,    90,    95,   131,
     131,   131,    20,   -70,   -70,   -70,   -70,    72,    94,   -70,
     -70,    24,   101,   -70,    86,    -8,    91,   -70,   -70,   -70,
     -70,    82,   103,   110,    -1,   131,   131,    92,   113,    52,
     -70,   -70,   131,   131,   109,   -70,   -70,   131,   -70,   -70,
     -70,   131,   131,   131,   131,   -70,   -70,   -70,    -1,   124,
     126,   134,   -70,   -70,   138,   120,   130,   -70,   -70,   112,
      91,   -70,   131,   122,   122,   139,   -70,   131,   -70,   142,
     132,   -70,   -70,   -70,   122,   122,   -70,   -70
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int8 yydefact[] =
{
       0,    19,    20,    21,     0,     2,     4,     6,     7,     5,
       0,     1,     3,    24,     0,     0,     0,    18,     0,     0,
       0,    15,     0,    22,     9,     0,    11,     0,     0,    14,
      25,     0,     0,    37,    17,     0,     0,     0,     0,     0,
       0,     0,    39,    57,    58,    30,    28,     0,     0,    26,
      29,    54,     0,    41,    43,    45,    47,    49,    53,     8,
      10,    13,     0,     0,     0,     0,     0,     0,     0,    54,
      51,    52,    62,     0,    24,    16,    27,     0,    59,    60,
      38,     0,     0,     0,     0,    12,    23,    56,     0,     0,
       0,     0,    36,    64,     0,    61,     0,    42,    44,    46,
      48,    50,     0,     0,     0,     0,    55,     0,    40,     0,
      32,    34,    35,    63,     0,     0,    31,    33
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
     -70,   -70,   -70,   144,   -70,   -70,   -70,    -2,    35,    11,
     -70,   -70,   -47,   -52,   -35,   -32,   -69,    74,    71,    79,
     -31,   -70,   -70,   -70
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int8 yydefgoto[] =
{
       0,     4,     5,     6,     7,     8,    20,    45,    46,    47,
      14,    48,    49,    50,    51,    52,    53,    54,    55,    56,
      57,    58,    94,    95
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int8 yytable[] =
{
      63,    76,    32,    93,    33,    69,    69,    68,    97,    70,
      71,    10,    88,    19,    82,    83,    10,    26,     1,     2,
       3,    15,    40,    72,    41,    60,    21,    42,    43,    44,
      16,    11,    73,    89,    90,     9,   102,    69,   113,    61,
       9,    96,    69,    24,    77,    25,    69,    69,    69,    69,
      78,    79,    27,   101,    28,    13,   110,   111,     1,     2,
       3,    59,    22,    25,    17,    18,    30,   116,   117,    32,
     109,    33,    69,    25,    34,     1,     2,     3,    78,    79,
      35,    36,    23,    37,    38,    39,    29,    31,    64,    40,
      62,    41,    65,    66,    42,    43,    44,    32,    67,    33,
      74,    25,    75,     1,     2,     3,    80,    81,    35,    36,
      85,    37,    38,    39,    87,    84,    86,    40,    92,    41,
      91,    16,    42,    43,    44,    32,   107,    33,   103,    25,
     104,     1,     2,     3,    32,    83,    35,    36,   105,    37,
      38,    39,   106,   108,   112,    40,   114,    41,   115,    12,
      42,    43,    44,    99,    40,    98,    41,     0,     0,    42,
      43,    44,   100
};

static const yytype_int8 yycheck[] =
{
      32,    48,     3,    72,     5,    40,    41,    39,    77,    40,
      41,     0,    64,     4,    22,    23,     5,    19,     9,    10,
      11,     3,    23,     3,    25,    27,    15,    28,    29,    30,
      12,     0,    12,    65,    66,     0,    88,    72,   107,    28,
       5,    73,    77,     5,    20,     7,    81,    82,    83,    84,
      26,    27,     4,    84,     6,    28,   103,   104,     9,    10,
      11,     5,    29,     7,     5,     6,    13,   114,   115,     3,
     102,     5,   107,     7,     8,     9,    10,    11,    26,    27,
      14,    15,    28,    17,    18,    19,    28,    12,     3,    23,
      29,    25,     3,     3,    28,    29,    30,     3,     3,     5,
      28,     7,     8,     9,    10,    11,     5,    21,    14,    15,
      28,    17,    18,    19,     4,    24,    13,    23,     5,    25,
      28,    12,    28,    29,    30,     3,     6,     5,     4,     7,
       4,     9,    10,    11,     3,    23,    14,    15,     4,    17,
      18,    19,     4,    13,     5,    23,     4,    25,    16,     5,
      28,    29,    30,    82,    23,    81,    25,    -1,    -1,    28,
      29,    30,    83
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int8 yystos[] =
{
       0,     9,    10,    11,    33,    34,    35,    36,    37,    40,
      41,     0,    35,    28,    42,     3,    12,     5,     6,     4,
      38,    41,    29,    28,     5,     7,    39,     4,     6,    28,
      13,    12,     3,     5,     8,    14,    15,    17,    18,    19,
      23,    25,    28,    29,    30,    39,    40,    41,    43,    44,
      45,    46,    47,    48,    49,    50,    51,    52,    53,     5,
      39,    41,    29,    47,     3,     3,     3,     3,    47,    46,
      52,    52,     3,    12,    28,     8,    44,    20,    26,    27,
       5,    21,    22,    23,    24,    28,    13,     4,    45,    47,
      47,    28,     5,    48,    54,    55,    47,    48,    49,    50,
      51,    52,    45,     4,     4,     4,     4,     6,    13,    47,
      44,    44,     5,    48,     4,    16,    44,    44
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr1[] =
{
       0,    32,    33,    34,    34,    35,    35,    35,    36,    36,
      37,    37,    38,    38,    38,    38,    39,    39,    40,    41,
      41,    41,    42,    42,    42,    42,    43,    43,    44,    44,
      44,    44,    44,    44,    44,    44,    44,    45,    45,    46,
      46,    47,    47,    48,    48,    49,    49,    50,    50,    51,
      51,    52,    52,    52,    53,    53,    53,    53,    53,    53,
      53,    54,    54,    55,    55
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     1,     2,     1,     1,     1,     1,     6,     5,
       6,     5,     4,     3,     2,     1,     3,     2,     3,     1,
       1,     1,     3,     6,     1,     4,     1,     2,     1,     1,
       1,     7,     5,     7,     5,     5,     3,     1,     2,     1,
       4,     1,     3,     1,     3,     1,     3,     1,     3,     1,
       3,     2,     2,     1,     1,     4,     3,     1,     1,     2,
       2,     1,     0,     3,     1
};


enum { YYENOMEM = -2 };

#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab
#define YYNOMEM         goto yyexhaustedlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                    \
  do                                                              \
    if (yychar == YYEMPTY)                                        \
      {                                                           \
        yychar = (Token);                                         \
        yylval = (Value);                                         \
        YYPOPSTACK (yylen);                                       \
        yystate = *yyssp;                                         \
        goto yybackup;                                            \
      }                                                           \
    else                                                          \
      {                                                           \
        yyerror (YY_("syntax error: cannot back up")); \
        YYERROR;                                                  \
      }                                                           \
  while (0)

/* Backward compatibility with an undocumented macro.
   Use YYerror or YYUNDEF. */
#define YYERRCODE YYUNDEF


/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)




# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Kind, Value); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*-----------------------------------.
| Print this symbol's value on YYO.  |
`-----------------------------------*/

static void
yy_symbol_value_print (FILE *yyo,
                       yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  FILE *yyoutput = yyo;
  YY_USE (yyoutput);
  if (!yyvaluep)
    return;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/*---------------------------.
| Print this symbol on YYO.  |
`---------------------------*/

static void
yy_symbol_print (FILE *yyo,
                 yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  YYFPRINTF (yyo, "%s %s (",
             yykind < YYNTOKENS ? "token" : "nterm", yysymbol_name (yykind));

  yy_symbol_value_print (yyo, yykind, yyvaluep);
  YYFPRINTF (yyo, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yy_state_t *yybottom, yy_state_t *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yy_state_t *yyssp, YYSTYPE *yyvsp,
                 int yyrule)
{
  int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %d):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       YY_ACCESSING_SYMBOL (+yyssp[yyi + 1 - yynrhs]),
                       &yyvsp[(yyi + 1) - (yynrhs)]);
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, Rule); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args) ((void) 0)
# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif






/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg,
            yysymbol_kind_t yykind, YYSTYPE *yyvaluep)
{
  YY_USE (yyvaluep);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yykind, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/* Lookahead token kind.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Number of syntax errors so far.  */
int yynerrs;




/*----------.
| yyparse.  |
`----------*/

int
yyparse (void)
{
    yy_state_fast_t yystate = 0;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus = 0;

    /* Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* Their size.  */
    YYPTRDIFF_T yystacksize = YYINITDEPTH;

    /* The state stack: array, bottom, top.  */
    yy_state_t yyssa[YYINITDEPTH];
    yy_state_t *yyss = yyssa;
    yy_state_t *yyssp = yyss;

    /* The semantic value stack: array, bottom, top.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs = yyvsa;
    YYSTYPE *yyvsp = yyvs;

  int yyn;
  /* The return value of yyparse.  */
  int yyresult;
  /* Lookahead symbol kind.  */
  yysymbol_kind_t yytoken = YYSYMBOL_YYEMPTY;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;



#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yychar = YYEMPTY; /* Cause a token to be read.  */

  goto yysetstate;


/*------------------------------------------------------------.
| yynewstate -- push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;


/*--------------------------------------------------------------------.
| yysetstate -- set current state (the top of the stack) to yystate.  |
`--------------------------------------------------------------------*/
yysetstate:
  YYDPRINTF ((stderr, "Entering state %d\n", yystate));
  YY_ASSERT (0 <= yystate && yystate < YYNSTATES);
  YY_IGNORE_USELESS_CAST_BEGIN
  *yyssp = YY_CAST (yy_state_t, yystate);
  YY_IGNORE_USELESS_CAST_END
  YY_STACK_PRINT (yyss, yyssp);

  if (yyss + yystacksize - 1 <= yyssp)
#if !defined yyoverflow && !defined YYSTACK_RELOCATE
    YYNOMEM;
#else
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYPTRDIFF_T yysize = yyssp - yyss + 1;

# if defined yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        yy_state_t *yyss1 = yyss;
        YYSTYPE *yyvs1 = yyvs;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * YYSIZEOF (*yyssp),
                    &yyvs1, yysize * YYSIZEOF (*yyvsp),
                    &yystacksize);
        yyss = yyss1;
        yyvs = yyvs1;
      }
# else /* defined YYSTACK_RELOCATE */
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        YYNOMEM;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yy_state_t *yyss1 = yyss;
        union yyalloc *yyptr =
          YY_CAST (union yyalloc *,
                   YYSTACK_ALLOC (YY_CAST (YYSIZE_T, YYSTACK_BYTES (yystacksize))));
        if (! yyptr)
          YYNOMEM;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YY_IGNORE_USELESS_CAST_BEGIN
      YYDPRINTF ((stderr, "Stack size increased to %ld\n",
                  YY_CAST (long, yystacksize)));
      YY_IGNORE_USELESS_CAST_END

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }
#endif /* !defined yyoverflow && !defined YYSTACK_RELOCATE */


  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;


/*-----------.
| yybackup.  |
`-----------*/
yybackup:
  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either empty, or end-of-input, or a valid lookahead.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token\n"));
      yychar = yylex ();
    }

  if (yychar <= YYEOF)
    {
      yychar = YYEOF;
      yytoken = YYSYMBOL_YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else if (yychar == YYerror)
    {
      /* The scanner already issued an error message, process directly
         to error recovery.  But do not keep the error token as
         lookahead, it is too special and may lead us to an endless
         loop in error recovery. */
      yychar = YYUNDEF;
      yytoken = YYSYMBOL_YYerror;
      goto yyerrlab1;
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yytable_value_is_error (yyn))
        goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);
  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  /* Discard the shifted token.  */
  yychar = YYEMPTY;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
  case 2: /* start: program  */
#line 57 "parser.y"
            {

    }
#line 1298 "parser.tab.c"
    break;

  case 3: /* program: program unit  */
#line 63 "parser.y"
                 {

    }
#line 1306 "parser.tab.c"
    break;

  case 4: /* program: unit  */
#line 66 "parser.y"
           {

    }
#line 1314 "parser.tab.c"
    break;

  case 5: /* unit: var_declaration  */
#line 72 "parser.y"
                    {

    }
#line 1322 "parser.tab.c"
    break;

  case 6: /* unit: func_declaration  */
#line 75 "parser.y"
                       {

    }
#line 1330 "parser.tab.c"
    break;

  case 7: /* unit: func_definition  */
#line 78 "parser.y"
                      {

    }
#line 1338 "parser.tab.c"
    break;

  case 8: /* func_declaration: type_specifier ID LPAREN parameter_list RPAREN SEMICOLON  */
#line 84 "parser.y"
                                                             {

    }
#line 1346 "parser.tab.c"
    break;

  case 9: /* func_declaration: type_specifier ID LPAREN RPAREN SEMICOLON  */
#line 87 "parser.y"
                                                {

    }
#line 1354 "parser.tab.c"
    break;

  case 10: /* func_definition: type_specifier ID LPAREN parameter_list RPAREN compound_statement  */
#line 93 "parser.y"
                                                                      {

    }
#line 1362 "parser.tab.c"
    break;

  case 11: /* func_definition: type_specifier ID LPAREN RPAREN compound_statement  */
#line 96 "parser.y"
                                                         {

    }
#line 1370 "parser.tab.c"
    break;

  case 12: /* parameter_list: parameter_list COMMA type_specifier ID  */
#line 102 "parser.y"
                                           {

    }
#line 1378 "parser.tab.c"
    break;

  case 13: /* parameter_list: parameter_list COMMA type_specifier  */
#line 105 "parser.y"
                                          {

    }
#line 1386 "parser.tab.c"
    break;

  case 14: /* parameter_list: type_specifier ID  */
#line 108 "parser.y"
                        {

    }
#line 1394 "parser.tab.c"
    break;

  case 15: /* parameter_list: type_specifier  */
#line 111 "parser.y"
                     {

    }
#line 1402 "parser.tab.c"
    break;

  case 16: /* compound_statement: LCURL statements RCURL  */
#line 117 "parser.y"
                           {

    }
#line 1410 "parser.tab.c"
    break;

  case 17: /* compound_statement: LCURL RCURL  */
#line 120 "parser.y"
                  {

    }
#line 1418 "parser.tab.c"
    break;

  case 18: /* var_declaration: type_specifier declaration_list SEMICOLON  */
#line 126 "parser.y"
                                              {

    }
#line 1426 "parser.tab.c"
    break;

  case 19: /* type_specifier: INT  */
#line 132 "parser.y"
        {

    }
#line 1434 "parser.tab.c"
    break;

  case 20: /* type_specifier: FLOAT  */
#line 135 "parser.y"
            {

    }
#line 1442 "parser.tab.c"
    break;

  case 21: /* type_specifier: VOID  */
#line 138 "parser.y"
           {

    }
#line 1450 "parser.tab.c"
    break;

  case 22: /* declaration_list: declaration_list COMMA ID  */
#line 144 "parser.y"
                              {

    }
#line 1458 "parser.tab.c"
    break;

  case 23: /* declaration_list: declaration_list COMMA ID LTHIRD CONST_INT RTHIRD  */
#line 147 "parser.y"
                                                        {

    }
#line 1466 "parser.tab.c"
    break;

  case 24: /* declaration_list: ID  */
#line 150 "parser.y"
         {

    }
#line 1474 "parser.tab.c"
    break;

  case 25: /* declaration_list: ID LTHIRD CONST_INT RTHIRD  */
#line 153 "parser.y"
                                 {

    }
#line 1482 "parser.tab.c"
    break;

  case 26: /* statements: statement  */
#line 159 "parser.y"
              {

    }
#line 1490 "parser.tab.c"
    break;

  case 27: /* statements: statements statement  */
#line 162 "parser.y"
                           {

    }
#line 1498 "parser.tab.c"
    break;

  case 28: /* statement: var_declaration  */
#line 168 "parser.y"
                    {

    }
#line 1506 "parser.tab.c"
    break;

  case 29: /* statement: expression_statement  */
#line 171 "parser.y"
                           {

    }
#line 1514 "parser.tab.c"
    break;

  case 30: /* statement: compound_statement  */
#line 174 "parser.y"
                         {

    }
#line 1522 "parser.tab.c"
    break;

  case 31: /* statement: FOR LPAREN expression_statement expression_statement expression RPAREN statement  */
#line 177 "parser.y"
                                                                                       {

    }
#line 1530 "parser.tab.c"
    break;

  case 32: /* statement: IF LPAREN expression RPAREN statement  */
#line 180 "parser.y"
                                                             {

    }
#line 1538 "parser.tab.c"
    break;

  case 33: /* statement: IF LPAREN expression RPAREN statement ELSE statement  */
#line 183 "parser.y"
                                                           {

    }
#line 1546 "parser.tab.c"
    break;

  case 34: /* statement: WHILE LPAREN expression RPAREN statement  */
#line 186 "parser.y"
                                               {

    }
#line 1554 "parser.tab.c"
    break;

  case 35: /* statement: PRINTLN LPAREN ID RPAREN SEMICOLON  */
#line 189 "parser.y"
                                         {

    }
#line 1562 "parser.tab.c"
    break;

  case 36: /* statement: RETURN expression SEMICOLON  */
#line 192 "parser.y"
                                  {

    }
#line 1570 "parser.tab.c"
    break;

  case 37: /* expression_statement: SEMICOLON  */
#line 198 "parser.y"
              {

    }
#line 1578 "parser.tab.c"
    break;

  case 38: /* expression_statement: expression SEMICOLON  */
#line 201 "parser.y"
                           {

    }
#line 1586 "parser.tab.c"
    break;

  case 39: /* variable: ID  */
#line 207 "parser.y"
       {

    }
#line 1594 "parser.tab.c"
    break;

  case 40: /* variable: ID LTHIRD expression RTHIRD  */
#line 210 "parser.y"
                                  {

    }
#line 1602 "parser.tab.c"
    break;

  case 41: /* expression: logic_expression  */
#line 216 "parser.y"
                     {

    }
#line 1610 "parser.tab.c"
    break;

  case 42: /* expression: variable ASSIGNOP logic_expression  */
#line 219 "parser.y"
                                         {

    }
#line 1618 "parser.tab.c"
    break;

  case 43: /* logic_expression: rel_expression  */
#line 225 "parser.y"
                   {

    }
#line 1626 "parser.tab.c"
    break;

  case 44: /* logic_expression: rel_expression LOGICOP rel_expression  */
#line 228 "parser.y"
                                            {

    }
#line 1634 "parser.tab.c"
    break;

  case 45: /* rel_expression: simple_expression  */
#line 234 "parser.y"
                      {
        
    }
#line 1642 "parser.tab.c"
    break;

  case 46: /* rel_expression: simple_expression RELOP simple_expression  */
#line 237 "parser.y"
                                                {

    }
#line 1650 "parser.tab.c"
    break;

  case 47: /* simple_expression: term  */
#line 243 "parser.y"
         {

    }
#line 1658 "parser.tab.c"
    break;

  case 48: /* simple_expression: simple_expression ADDOP term  */
#line 246 "parser.y"
                                   {

    }
#line 1666 "parser.tab.c"
    break;

  case 49: /* term: unary_expression  */
#line 252 "parser.y"
                     {

    }
#line 1674 "parser.tab.c"
    break;

  case 50: /* term: term MULOP unary_expression  */
#line 255 "parser.y"
                                  {

    }
#line 1682 "parser.tab.c"
    break;

  case 51: /* unary_expression: ADDOP unary_expression  */
#line 261 "parser.y"
                           {

    }
#line 1690 "parser.tab.c"
    break;

  case 52: /* unary_expression: NOT unary_expression  */
#line 264 "parser.y"
                           {

    }
#line 1698 "parser.tab.c"
    break;

  case 53: /* unary_expression: factor  */
#line 267 "parser.y"
             {

    }
#line 1706 "parser.tab.c"
    break;

  case 54: /* factor: variable  */
#line 273 "parser.y"
             {

    }
#line 1714 "parser.tab.c"
    break;

  case 55: /* factor: ID LPAREN argument_list RPAREN  */
#line 276 "parser.y"
                                     {

    }
#line 1722 "parser.tab.c"
    break;

  case 56: /* factor: LPAREN expression RPAREN  */
#line 279 "parser.y"
                               {

    }
#line 1730 "parser.tab.c"
    break;

  case 57: /* factor: CONST_INT  */
#line 282 "parser.y"
                {

    }
#line 1738 "parser.tab.c"
    break;

  case 58: /* factor: CONST_FLOAT  */
#line 285 "parser.y"
                  {

    }
#line 1746 "parser.tab.c"
    break;

  case 59: /* factor: variable INCOP  */
#line 288 "parser.y"
                     {

    }
#line 1754 "parser.tab.c"
    break;

  case 60: /* factor: variable DECOP  */
#line 291 "parser.y"
                     {

    }
#line 1762 "parser.tab.c"
    break;

  case 61: /* argument_list: arguments  */
#line 297 "parser.y"
              {

    }
#line 1770 "parser.tab.c"
    break;

  case 62: /* argument_list: %empty  */
#line 300 "parser.y"
      {

    }
#line 1778 "parser.tab.c"
    break;

  case 63: /* arguments: arguments COMMA logic_expression  */
#line 306 "parser.y"
                                     {

    }
#line 1786 "parser.tab.c"
    break;

  case 64: /* arguments: logic_expression  */
#line 309 "parser.y"
                       {

    }
#line 1794 "parser.tab.c"
    break;


#line 1798 "parser.tab.c"

      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", YY_CAST (yysymbol_kind_t, yyr1[yyn]), &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;

  *++yyvsp = yyval;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */
  {
    const int yylhs = yyr1[yyn] - YYNTOKENS;
    const int yyi = yypgoto[yylhs] + *yyssp;
    yystate = (0 <= yyi && yyi <= YYLAST && yycheck[yyi] == *yyssp
               ? yytable[yyi]
               : yydefgoto[yylhs]);
  }

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYSYMBOL_YYEMPTY : YYTRANSLATE (yychar);
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
      yyerror (YY_("syntax error"));
    }

  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= YYEOF)
        {
          /* Return failure if at end of input.  */
          if (yychar == YYEOF)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval);
          yychar = YYEMPTY;
        }
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:
  /* Pacify compilers when the user code never invokes YYERROR and the
     label yyerrorlab therefore never appears in user code.  */
  if (0)
    YYERROR;
  ++yynerrs;

  /* Do not reclaim the symbols of the rule whose action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  /* Pop stack until we find a state that shifts the error token.  */
  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYSYMBOL_YYerror;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYSYMBOL_YYerror)
            {
              yyn = yytable[yyn];
              if (0 < yyn)
                break;
            }
        }

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
        YYABORT;


      yydestruct ("Error: popping",
                  YY_ACCESSING_SYMBOL (yystate), yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", YY_ACCESSING_SYMBOL (yyn), yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturnlab;


/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturnlab;


/*-----------------------------------------------------------.
| yyexhaustedlab -- YYNOMEM (memory exhaustion) comes here.  |
`-----------------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  goto yyreturnlab;


/*----------------------------------------------------------.
| yyreturnlab -- parsing is finished, clean up and return.  |
`----------------------------------------------------------*/
yyreturnlab:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  YY_ACCESSING_SYMBOL (+*yyssp), yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif

  return yyresult;
}

#line 314 "parser.y"



int main(int argc, char* argv[]) {
    if (argc != 2) {
        cout << "ERROR: Parser needs input file as argument\n";
        return 1;
    }

    input_file = fopen(argv[1], "r");
    log_file = fopen("log.txt", "w");
    error_file = fopen("error.txt", "w");

    if (!input_file || !log_file || !error_file) {
        cout << "ERROR: Could not open file\n";
        return 1;
    }

    yyin = input_file;

    yyparse();

    fclose(input_file);
    fclose(log_file);
    fclose(error_file);

    return 0;
}
