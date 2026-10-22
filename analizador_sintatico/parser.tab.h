/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

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

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_PARSER_TAB_H_INCLUDED
# define YY_YY_PARSER_TAB_H_INCLUDED
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
    GENSET = 258,                  /* GENSET  */
    DISJOINT = 259,                /* DISJOINT  */
    COMPLETE = 260,                /* COMPLETE  */
    GENERAL = 261,                 /* GENERAL  */
    SPECIFICS = 262,               /* SPECIFICS  */
    WHERE = 263,                   /* WHERE  */
    PACKAGE = 264,                 /* PACKAGE  */
    IMPORT = 265,                  /* IMPORT  */
    FUNCTIONAL_COMPLEXES = 266,    /* FUNCTIONAL_COMPLEXES  */
    NUMBER = 267,                  /* NUMBER  */
    STRING = 268,                  /* STRING  */
    BOOLEAN = 269,                 /* BOOLEAN  */
    DATE = 270,                    /* DATE  */
    TIME = 271,                    /* TIME  */
    DATETIME = 272,                /* DATETIME  */
    ORDERED = 273,                 /* ORDERED  */
    CONST = 274,                   /* CONST  */
    DERIVED = 275,                 /* DERIVED  */
    SUBSETS = 276,                 /* SUBSETS  */
    REDEFINES = 277,               /* REDEFINES  */
    EVENT = 278,                   /* EVENT  */
    SITUATION = 279,               /* SITUATION  */
    PROCESS = 280,                 /* PROCESS  */
    CATEGORY = 281,                /* CATEGORY  */
    MIXIN = 282,                   /* MIXIN  */
    PHASE_MIXIN = 283,             /* PHASE_MIXIN  */
    ROLE_MIXIN = 284,              /* ROLE_MIXIN  */
    HISTORICAL_MIXIN = 285,        /* HISTORICAL_MIXIN  */
    HISTORICAL_ROLE = 286,         /* HISTORICAL_ROLE  */
    HISTORICAL_ROLE_MIXIN = 287,   /* HISTORICAL_ROLE_MIXIN  */
    KIND = 288,                    /* KIND  */
    COLLECTIVE = 289,              /* COLLECTIVE  */
    QUANTITY = 290,                /* QUANTITY  */
    QUALITY = 291,                 /* QUALITY  */
    MODE = 292,                    /* MODE  */
    INTRINSIC_MODES = 293,         /* INTRINSIC_MODES  */
    EXTRINSIC_MODES = 294,         /* EXTRINSIC_MODES  */
    SUBKIND = 295,                 /* SUBKIND  */
    PHASE = 296,                   /* PHASE  */
    ROLE = 297,                    /* ROLE  */
    RELATOR = 298,                 /* RELATOR  */
    MATERIAL = 299,                /* MATERIAL  */
    DERIVATION = 300,              /* DERIVATION  */
    COMPARATIVE = 301,             /* COMPARATIVE  */
    MEDIATION = 302,               /* MEDIATION  */
    CHARACTERIZATION = 303,        /* CHARACTERIZATION  */
    EXTERNAL_DEPENDENCE = 304,     /* EXTERNAL_DEPENDENCE  */
    COMPONENT_OF = 305,            /* COMPONENT_OF  */
    MEMBER_OF = 306,               /* MEMBER_OF  */
    SUB_COLLECTION_OF = 307,       /* SUB_COLLECTION_OF  */
    SUB_QUALITY_OF = 308,          /* SUB_QUALITY_OF  */
    INSTANTIATION = 309,           /* INSTANTIATION  */
    TERMINATION = 310,             /* TERMINATION  */
    PARTICIPATIONAL = 311,         /* PARTICIPATIONAL  */
    PARTICIPATION = 312,           /* PARTICIPATION  */
    HISTORICAL_DEPENDENCE = 313,   /* HISTORICAL_DEPENDENCE  */
    CREATION = 314,                /* CREATION  */
    MANIFESTATION = 315,           /* MANIFESTATION  */
    BRINGS_ABOUT = 316,            /* BRINGS_ABOUT  */
    TRIGGERS = 317,                /* TRIGGERS  */
    COMPOSITION = 318,             /* COMPOSITION  */
    AGGREGATION = 319,             /* AGGREGATION  */
    INHERENCE = 320,               /* INHERENCE  */
    VALUE = 321,                   /* VALUE  */
    FORMAL = 322,                  /* FORMAL  */
    CONSTITUTION = 323,            /* CONSTITUTION  */
    NUMBER_LITERAL = 324,          /* NUMBER_LITERAL  */
    SPECIAL_SYMBOL = 325,          /* SPECIAL_SYMBOL  */
    DATA_TYPE = 326,               /* DATA_TYPE  */
    INSTANCE_NAME = 327,           /* INSTANCE_NAME  */
    NEW_TYPE = 328,                /* NEW_TYPE  */
    CLASS_NAME = 329,              /* CLASS_NAME  */
    RELATION_NAME = 330,           /* RELATION_NAME  */
    UNKNOWN = 331,                 /* UNKNOWN  */
    RELATION_KW = 332,             /* RELATION_KW  */
    CARDINALITY = 333,             /* CARDINALITY  */
    DASH = 334,                    /* DASH  */
    AGGREGATION_OP = 335,          /* AGGREGATION_OP  */
    COMPOSITION_OP = 336,          /* COMPOSITION_OP  */
    ENUM = 337,                    /* ENUM  */
    SPECIALIZES = 338,             /* SPECIALIZES  */
    ATTR_NAME = 339                /* ATTR_NAME  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */
