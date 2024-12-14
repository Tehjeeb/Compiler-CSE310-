%option noyywrap

%{
#include<bits/stdc++.h>
#include "1905037_symboltable.h"
using namespace std;
int line_count=1;
int err_count=0;
FILE *logout;
FILE *tokenout;

SymbolTable symboltable(10);

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
	fprintf(tokenout,"<IF, %s>\n", yytext);
	fprintf(logout,"Line# %d: Token <IF> Lexeme %s found\n",line_count,yytext);
}
"else" {
	fprintf(tokenout,"<ELSE, %s>\n", yytext);
	fprintf(logout,"Line# %d: Token <ELSE> Lexeme %s found\n",line_count,yytext);
}

"switch" {
	fprintf(tokenout,"<SWITCH, %s>\n", yytext);
	fprintf(logout,"Line# %d: Token <SWITCH> Lexeme %s found\n",line_count,yytext);
}
"case" {
	fprintf(tokenout,"<CASE, %s>\n", yytext);
	fprintf(logout,"Line# %d: Token <CASE> Lexeme %s found\n",line_count,yytext);
}
"defult" {
	fprintf(tokenout,"<DEFAULT, %s>\n", yytext);
	fprintf(logout,"Line# %d: Token <DEFAULT> Lexeme %s found\n",line_count,yytext);
}

"int" {
	fprintf(tokenout,"<INT, %s>\n", yytext);
	fprintf(logout,"Line# %d: Token <INT> Lexeme %s found\n",line_count,yytext);
}
"char" {
	fprintf(tokenout,"<CHAR, %s>\n", yytext);
	fprintf(logout,"Line# %d: Token <CHAR> Lexeme %s found\n",line_count,yytext);
}
"double" {
	fprintf(tokenout,"<DOUBLE, %s>\n", yytext);
	fprintf(logout,"Line# %d: Token <DOUBLE> Lexeme %s found\n",line_count,yytext);
}
"float"	{
	fprintf(tokenout,"<FLOAT, %s>\n", yytext);
	fprintf(logout,"Line# %d: Token <ELSE> Lexeme %s found\n",line_count,yytext);
}
"void" {
	fprintf(tokenout,"<VOID, %s>\n", yytext);
	fprintf(logout,"Line# %d: Token <VOID> Lexeme %s found\n",line_count,yytext);
}


"for" {
	fprintf(tokenout,"<FOR, %s>\n", yytext);
	fprintf(logout,"Line# %d: Token <FOR> Lexeme %s found\n",line_count,yytext);
}
"do" {
	fprintf(tokenout,"<DO, %s>\n", yytext);
	fprintf(logout,"Line# %d: Token <DO> Lexeme %s found\n",line_count,yytext);
}
"while"	{
	fprintf(tokenout,"<WHILE, %s>\n", yytext);
	fprintf(logout,"Line# %d: Token <WHILE> Lexeme %s found\n",line_count,yytext);
}
"break"	{
	fprintf(tokenout,"<BREAK, %s>\n", yytext);
	fprintf(logout,"Line# %d: Token <BREAK> Lexeme %s found\n",line_count,yytext);
}
"continue" {
	fprintf(tokenout,"<CONTINUE, %s>\n", yytext);
	fprintf(logout,"Line# %d: Token <CONTINUE> Lexeme %s found\n",line_count,yytext);
}
"return" {
	fprintf(tokenout,"<RETURN, %s>\n", yytext);
	fprintf(logout,"Line# %d: Token <RETURN> Lexeme %s found\n",line_count,yytext);
}

"+"	|
"-"	{
	fprintf(tokenout,"<ADDOP ,%s>\n",yytext);
	fprintf(logout,"Line# %d: Token <ADDOP> Lexeme %s found\n",line_count,yytext);
}

"/" |
"%" |
"*" {
	fprintf(tokenout, "<MULOP, %s>\n", yytext);
	fprintf(logout, "Line# %d: Token <MULOP> Lexeme %s found\n", line_count, yytext);
}

"++" |
"--" {
	fprintf(tokenout, "<INCOP, %s>\n", yytext);
	fprintf(logout, "Line# %d: Token <INCOP> Lexeme %s found\n", line_count, yytext);
}

"<" |
"<=" |
">" |
">=" |
"==" |
"!=" {

	fprintf(tokenout, "<RELOP, %s>\n", yytext);
	fprintf(logout, "Line# %d: Token <RELOP> Lexeme %s found\n", line_count, yytext);
}

"=" {
		fprintf(tokenout, "<ASSIGNOP, %s>\n", yytext);
		fprintf(logout, "Line# %d: Token <ASSIGNOP> Lexeme %s found\n", line_count, yytext);
	}



"&&" |
"||" {
		fprintf(tokenout, "<LOGICOP, %s>\n", yytext);
		fprintf(logout, "Line# %d: Token <LOGICOP> Lexeme %s found\n", line_count, yytext);
	}


"&" |
"|" |
"^" |
"<<" |
">>" {
	fprintf(tokenout, "<BITOP, %s>\n", yytext);
	fprintf(logout, "Line# %d: Token <BITOP> Lexeme %s found\n", line_count, yytext);
}


"(" {
	fprintf(tokenout, "<LPAREN, %s>\n", yytext);
	fprintf(logout, "Line# %d: Token <LPAREN> Lexeme %s found\n", line_count, yytext);
}

")" {
	fprintf(tokenout, "<RPAREN, %s>\n", yytext);
	fprintf(logout, "Line# %d: Token <RPAREN> Lexeme %s found\n", line_count, yytext);
}

"[" {
	fprintf(tokenout, "<LSQUARE, %s>\n", yytext);
	fprintf(logout, "Line# %d: Token <LSQUARE> Lexeme %s found\n", line_count, yytext);
}

"]" {
	fprintf(tokenout, "<RSQUARE, %s>\n", yytext);
	fprintf(logout, "Line# %d: Token <RSQUARE> Lexeme %s found\n", line_count, yytext);
}

"{" {
	symboltable.EnterScope();
	fprintf(tokenout, "<LCURL, %s>\n", yytext);
	fprintf(logout, "Line# %d: Token <LCURL> Lexeme %s found\n", line_count, yytext);
}

"}" {
	symboltable.ExitScope();
	fprintf(tokenout, "<RCURL, %s>\n", yytext);
	fprintf(logout, "Line# %d: Token <RCURL> Lexeme %s found\n", line_count, yytext);
}

"!" {
	fprintf(tokenout, "<NOT, %s>\n", yytext);
	fprintf(logout, "Line# %d: Token <NOT> Lexeme %s found\n", line_count, yytext);
}

"," {
	fprintf(tokenout, "<COMMA, %s>\n", yytext);
	fprintf(logout, "Line# %d: Token <COMMA> Lexeme %s found\n", line_count, yytext);
}

";" {
	fprintf(tokenout, "<SEMICOLON, %s>\n", yytext);
	fprintf(logout, "Line# %d: Token <SEMICOLON> Lexeme %s found\n", line_count, yytext);
}


{CONST_INT} {
	fprintf(tokenout,"<CONST_INT, %s>\n", yytext);
	fprintf(logout,"Line# %d: Token <CONST_INT> Lexeme %s found\n",line_count,yytext);
}


{FLOAT} {
	fprintf(tokenout,"<CONST_FLOAT, %s>\n", yytext);
	fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
}
{CONST_CHAR} {
	string str=char_converter(yytext);
	fprintf(tokenout,"<CONST_CHAR, %s>\n", str.c_str());
	fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %s found\n",line_count,str.c_str());
}

{SINGLELINE_STRING} {
	string str = char_converter(yytext);
	fprintf(tokenout, "<SINGLE LINE STRING, %s>\n", str.c_str());
	fprintf(logout, "Line# %d: Token <SINGLE LINE STRING> Lexeme %s found\n", line_count, yytext);
}

{MULTILINE_BROKEN_STRING} {
	string str = char_converter(yytext);
	
	fprintf(tokenout, "<MULTI LINE STRING, %s>\n", str.c_str());
	fprintf(logout, "Line# %d: Token <MULTI LINE STRING> Lexeme %s found\n", line_count, yytext);
	string cs=string(yytext);
	for(size_t i = 0; i < cs.size(); i++)
		if(cs[i]=='\n')
			line_count++;
}

{IDENTIFIER} {
	fprintf(tokenout, "<ID, %s>\n", yytext);
	fprintf(logout, "Line# %d: Token <ID> Lexeme %s found\n", line_count, yytext);

	SymbolInfo* a=new SymbolInfo();	
	a->setName(yytext);
    a->setType("ID");	
	bool ok =symboltable.Insert(*a);

	if(ok)
	{
		symboltable.PrintAllScopeTable(logout);
	}
	else
	{
		fprintf(logout, "\t%s already exisits in the current ScopeTable\n", yytext);
	}
}

{SINGLE_LINE_COMMENT} {
	string str = yytext;
	if(str[str.size()-1] == '\n')
	{
		str.pop_back();
		line_count++;
	}

	if(str[str.size()-1] == '\r')
		str.pop_back();
	
	//line_count++;
	fprintf(logout, "Line# %d: Token <SINGLE LINE COMMENT> Lexeme %s found\n", line_count, str.c_str());

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
	fprintf(logout, "Error at line# %d: TOO_MANY_DECIMAL_POINTS %s\n", line_count, yytext);err_count++;
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
    fprintf(logout, "Error at line# %d: UNRECOGNIZED_CHAR %s\n", line_count, yytext);err_count++;
}



%%

int main(int argc, char** argv) {
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
}
