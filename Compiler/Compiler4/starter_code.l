%option noyywrap

%{
#include<bits/stdc++.h>
#include "1905037_symboltable.h"
#include "y.tab.h"
using namespace std;
extern YYSTYPE yylval;
extern SymbolTable *table;

int line_count=1;
int err_count=0;

//FILE *logout;
//FILE *tokenout;
extern FILE *logout;


string char_converter(string s)
{
	string ss;
	int i;
	for(i=1; i<s.size()-1; i++)
	{
		if(s[i]=='\\'&&i+1<s.size()-1)
		{
			if(s[i+1]=='n')
			{
				i++;
				ss.push_back('\n');
			}
			else if(s[i+1]=='t')
			{
				i++;
				ss.push_back('\t');
			}
			else if(s[i+1]=='r')
			{
				i++;
				ss.push_back('\r');
			}
			else if(s[i+1]=='v')
			{
				i++;
				ss.push_back('\v');
			}
			else if(s[i+1]=='b')
			{
				i++;
				ss.push_back('\b');
			}
			else if(s[i+1]=='f')
			{
				i++;
				ss.push_back('\f');
			}
			else if(s[i+1]=='a')
			{
				i++;
				ss.push_back('\a');
			}
			else
			{
				i++;
				ss+=s[i];
			}
		}
		else if(s[i]!='\\')
		{
			ss.push_back(s[i]);
		}
	}
	return ss;
}

%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n
CONST_INT {DIGIT}+
FLOAT ({DIGIT}*\.{DIGIT}+([Ee][+-]?{DIGIT}+)?|{DIGIT}+\.?[Ee][+-]?{DIGIT}+)
IDENTIFIER ({LETTER}|_)({LETTER}|_|{DIGIT})*
CHARECTER ([^\\\'\"\r\n]|\\n|\\t|\\\"|\\\'|\\\\|\\a|\\f|\\r|\\b|\\v|\\0|\\[\r]?\n)
CONST_CHAR \'{CHARECTER}\'
SINGLELINE_STRING \"([^\\\'\"\n\r]|\\n|\\t|\\\"|\\\'|\\\\|\\a|\\f|\\r|\\b|\\v|\\0)*\"
MULTILINE_BROKEN_STRING \"{CHARECTER}*\"
SINGLE_LINE_COMMENT \/\/[^\r\n]*([\r]?\n|$)
SINGLE_LINE_BROKEN_COMMENT \/\/([^\r\n]*\\[\r]?\n)*[^\r\n]*
MULTILINE_COMMENT \/\*([^\*]|\*[^\/])*\*\/
REDUNDANT_DECIMAL_POINTS {DIGIT}*\.{DIGIT}+(\.{DIGIT}*)+
ILLFORMED_NUMBER {DIGIT}+(\.{DIGIT}+)*[Ee][+-]?{DIGIT}+(\.{DIGIT}*)+
INVALID_SUFFIX_IN_NUMBER_OR_PREFIX_IN_IDENTIFIER ({FLOAT}|{CONST_INT}){IDENTIFIER}
MULTICHARECTER_CONST_CHAR \'{CHARECTER}{CHARECTER}+\'
UNFINISHED_CONST_CHAR \'{CHARECTER}*
EMPTY_CONST_CHAR \'\'
UNFINISHED_STRING \"([^\\\'\"\n\r]|\\n|\\t|\\\"|\\\'|\\\\|\\a|\\f|\\r|\\b|\\v|\\0|\\[\r]?\n)*
UNFINISHED_MULTILINE_COMMENT \/\*([^\*]|\*[^\/])*

%%

{NEWLINE} {line_count++;}
{WHITESPACE} {}

"if" {
	fprintf(logout, "Line# %d: Token <IF> Lexeme %s found\n", line_count, yytext);
	yylval=new SymbolInfo(string(yytext),"IF",line_count,line_count);
	return IF;
}
"else" {
	fprintf(logout, "Line# %d: Token <ELSE> Lexeme %s found\n", line_count, yytext);
	yylval=new SymbolInfo(string(yytext),"ELSE",line_count,line_count);
	return ELSE;
}


"int" {
	fprintf(logout, "Line# %d: Token <INT> Lexeme %s found\n", line_count, yytext);
	yylval=new SymbolInfo(string(yytext),"INT",line_count,line_count);
	return INT;
}
"float"	{
	fprintf(logout, "Line# %d: Token <FLOAT> Lexeme %s found\n", line_count, yytext);
	yylval=new SymbolInfo(string(yytext),"FLOAT",line_count,line_count);
	return FLOAT;
}
"void" {
	fprintf(logout, "Line# %d: Token <VOID> Lexeme %s found\n", line_count, yytext);
	yylval=new SymbolInfo(string(yytext),"VOID",line_count,line_count);
	return VOID;
}

"for" {
	fprintf(logout, "Line# %d: Token <FOR> Lexeme %s found\n", line_count, yytext);
	yylval=new SymbolInfo(string(yytext),"FOR",line_count,line_count);
	return FOR;
}

"while"	{
	fprintf(logout, "Line# %d: Token <WHILE> Lexeme %s found\n", line_count, yytext);
	yylval=new SymbolInfo(string(yytext),"WHILE",line_count,line_count);
	return WHILE;
}

"return" {
	fprintf(logout, "Line# %d: Token <RETURN> Lexeme %s found\n", line_count, yytext);
	yylval=new SymbolInfo(string(yytext),"RETURN",line_count,line_count);
	return RETURN;
}
"println"	{
	fprintf(logout, "Line# %d: Token <RETURN> Lexeme %s found\n", line_count, yytext);
	yylval=new SymbolInfo(string(yytext),"PRINTLN",line_count,line_count);
	return PRINTLN;
	}

"+"	|
"-"	{
	fprintf(logout, "Line# %d: Token <ADDOP> Lexeme %s found\n", line_count, yytext);
	yylval=new SymbolInfo(string(yytext),"ADDOP",line_count,line_count);
	return ADDOP;
}

"/" |
"%" |
"*" {
	fprintf(logout, "Line# %d: Token <MULOP> Lexeme %s found\n", line_count, yytext);
	yylval=new SymbolInfo(string(yytext),"MULOP",line_count,line_count);
	return MULOP;
}

"++" {
	fprintf(logout, "Line# %d: Token <INCOP> Lexeme %s found\n", line_count, yytext);
	yylval=new SymbolInfo(string(yytext),"INCOP",line_count,line_count);
	return INCOP;
}

"--" {
	fprintf(logout, "Line# %d: Token <DECOP> Lexeme %s found\n", line_count, yytext);
	yylval=new SymbolInfo(string(yytext),"DECOP",line_count,line_count);
	return DECOP;
}

"<" |
"<=" |
">" |
">=" |
"==" |
"!=" {
	fprintf(logout, "Line# %d: Token <RELOP> Lexeme %s found\n", line_count, yytext);
	yylval=new SymbolInfo(string(yytext),"RELOP",line_count,line_count);
	return RELOP;
}

"=" {
	fprintf(logout, "Line# %d: Token <ASSIGNOP> Lexeme %s found\n", line_count, yytext);
		yylval=new SymbolInfo(string(yytext),"ASSIGNOP",line_count,line_count);
		return ASSIGNOP;
	}



"&&" |
"||" {
	fprintf(logout, "Line# %d: Token <LOGICOP> Lexeme %s found\n", line_count, yytext);
		yylval=new SymbolInfo(string(yytext),"LOGICOP",line_count,line_count);
	return LOGICOP;
	}


"(" {
	fprintf(logout, "Line# %d: Token <LPAREN> Lexeme %s found\n", line_count, yytext);
	yylval=new SymbolInfo(string(yytext),"LPAREN",line_count,line_count);
	return LPAREN;
}

")" {
	fprintf(logout, "Line# %d: Token <RPAREN> Lexeme %s found\n", line_count, yytext);
	yylval=new SymbolInfo(string(yytext),"RPAREN",line_count,line_count);
	return RPAREN;
}

"[" {
	fprintf(logout, "Line# %d: Token <LTHIRD> Lexeme %s found\n", line_count, yytext);
	yylval=new SymbolInfo(string(yytext),"LTHIRD",line_count,line_count);
	return LTHIRD;
}

"]" {
	fprintf(logout, "Line# %d: Token <RTHIRD> Lexeme %s found\n", line_count, yytext);
	yylval=new SymbolInfo(string(yytext),"RTHIRD",line_count,line_count);
	return RTHIRD;
}

"{" {
	//symboltable.EnterScope();
	fprintf(logout, "Line# %d: Token <LCURL> Lexeme %s found\n", line_count, yytext);
	yylval=new SymbolInfo(string(yytext),"LCURL",line_count,line_count);
	return LCURL;
}

"}" {
	//symboltable.ExitScope();
	fprintf(logout, "Line# %d: Token <RCURL> Lexeme %s found\n", line_count, yytext);
	yylval=new SymbolInfo(string(yytext),"RCURL",line_count,line_count);
	return RCURL;
}

"!" {
	fprintf(logout, "Line# %d: Token <NOT> Lexeme %s found\n", line_count, yytext);
	yylval=new SymbolInfo(string(yytext),"NOT",line_count,line_count);
	return NOT;
}

"," {
	fprintf(logout, "Line# %d: Token <COMMA> Lexeme %s found\n", line_count, yytext);
	yylval=new SymbolInfo(string(yytext),"COMMA",line_count,line_count);
	return COMMA;
}

";" {
	fprintf(logout, "Line# %d: Token <SEMICOLON> Lexeme %s found\n", line_count, yytext);
	yylval=new SymbolInfo(string(yytext),"SEMICOLON",line_count,line_count);
	return SEMICOLON;
}


{CONST_INT} {
	fprintf(logout,"Line# %d: Token <CONST_INT> Lexeme %s found\n",line_count,yytext);
	yylval=new SymbolInfo(string(yytext),"CONST_INT",line_count,line_count);
	return CONST_INT;
}


{FLOAT} {
	fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
	yylval=new SymbolInfo(string(yytext),"CONST_FLOAT",line_count,line_count);
	return CONST_FLOAT;
}

{IDENTIFIER} {
	fprintf(logout, "Line# %d: Token <ID> Lexeme %s found\n", line_count, yytext);

	/*SymbolInfo* a=new SymbolInfo();	
	a->setName(yytext);
    a->setType("ID");	*/
	//bool ok =symboltable.Insert(*a);

	/*if(ok)
	{
		symboltable.PrintAllScopeTable(logout);
	}
	else
	{
		fprintf(logout, "\t%s already exisits in the current ScopeTable\n", yytext);
	}*/
	yylval=new SymbolInfo(string(yytext),"ID",line_count,line_count);
	return ID;
}

{SINGLE_LINE_COMMENT} {
	string str = yytext;
	int crit_line_cnt=0;
	if(str[str.size()-1] == '\n')
	{
		str.pop_back();
		crit_line_cnt++;
	}

	if(str[str.size()-1] == '\r')
		str.pop_back();
	
	fprintf(logout, "Line# %d: Token <SINGLE LINE COMMENT> Lexeme %s found\n", line_count, str.c_str());
	line_count+=crit_line_cnt;

}
{SINGLE_LINE_BROKEN_COMMENT} {
	string str=yytext;
	if(str[str.size()-1]== '\n')
	{
		line_count++;
		str.pop_back();
	}

	if(str[str.size()-1]== '\r')
		str.pop_back();

	fprintf(logout, "Line# %d: Token <SINGLE LINE COMMENT> Lexeme %s found\n", line_count, str.c_str());

	for(int i = 0; i < str.size(); i++)
		if(str[i] == '\n')
			++line_count;
}

{MULTILINE_COMMENT} {
	fprintf(logout, "Line# %d: Token <MULTI LINE COMMENT> Lexeme %s found\n", line_count, yytext);
	string str=yytext;
	for(int i = 0; i < str.size(); i++)
		if(str[i] =='\n')
			++line_count;
}

{REDUNDANT_DECIMAL_POINTS} {
	fprintf(logout, "Error at line# %d: TOO_MANY_DECIMAL_POINTS %s\n", line_count, yytext);
	err_count++;
}

{ILLFORMED_NUMBER} {
	fprintf(logout, "Error at line# %d: ILLFORMED_NUMBER %s\n", line_count, yytext);
	err_count++;
}
{INVALID_SUFFIX_IN_NUMBER_OR_PREFIX_IN_IDENTIFIER} {
	fprintf(logout, "Error at line# %d: INVALID_ID_SUFFIX_NUM_PREFIX %s\n", line_count, yytext);
	err_count++;
}
{MULTICHARECTER_CONST_CHAR} {
	fprintf(logout, "Error at line# %d: MULTICHAR_CONST_CHAR %s\n", line_count, yytext);
	err_count++;
}
{UNFINISHED_CONST_CHAR} {
	fprintf(logout, "Error at line# %d: UNFINISHED_CONST_CHAR %s\n", line_count, yytext);
	err_count++;
}
{EMPTY_CONST_CHAR} {
	fprintf(logout, "Error at line# %d: EMPTY_CONST_CHAR %s\n", line_count, yytext);
	err_count++;
}
{UNFINISHED_STRING} {
	fprintf(logout, "Error at line# %d: UNFINISHED_STRING %s\n", line_count, yytext);
	string str=yytext;
	for(int i = 0; i < str.size(); i++)
		if(str[i]=='\n')
			line_count++;
	err_count++;
}

{UNFINISHED_MULTILINE_COMMENT} {
	fprintf(logout, "Error at line# %d: UNFINISHED_COMMENT %s\n", line_count, yytext);
	string str = yytext;
	for(int i = 0; i < str.size(); ++i)
		if(str[i]=='\n')
			line_count++;
	err_count++;
}

. {
    //fprintf(logout, "Error at line# %d: UNRECOGNIZED_CHAR %s\n", line_count, yytext);err_count++;
}



%%

/*int main(int argc, char** argv) {
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");

	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("1905037_log.txt","w");
	tokenout= fopen("1905037_token.txt","w");

	yyin= fin;
	yylex();
	//st.print();
	symboltable.PrintAllScopeTable(logout);
	fprintf(logout, "Total lines: %llu\n", line_count);
    fprintf(logout, "Total errors: %llu\n", err_count);
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}*/
