%{
#include<bits/stdc++.h>
#include "1905037_symboltable.h"
#define YYSTYPE SymbolInfo*

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
extern int line_count;
FILE *logout;
FILE *parseout;
FILE *errorout;
SymbolTable *table = new SymbolTable(30);


void yyerror(char *s)
{
	//write your code
}

void fixLineNum(SymbolInfo* s)
{
	vector<SymbolInfo*>v=s->getChildList();
	if(v.size()>0)
	{
		
		for(int i=0;i<v.size();i++)
		{
			fixLineNum(v[i]);
		}
		s->setStartLine(v[0]->getStartLine());
		s->setEndLine(v.back()->getEndLine());
	}
}
void PrintFullParseTree(SymbolInfo* s,string overhead="")
{
	fprintf(parseout,"%s",overhead.c_str());
	fprintf(parseout,"%s: ",s->getType().c_str());
	vector<SymbolInfo*>v=s->getChildList();
	/*if(s->getType()=="ID"&&s->getIdType()==SymbolInfo::DECLARED_FUNCTION)
	{
		cout<<s->getDataType()<<","<<endl;
		vector<pair<string,string>>v=s->getParameterList();
		for(int i=0;i<v.size();i++)
		{
			cout<<v[i].first<<endl;
		}
		cout<<"done\n";
	}*/
	if(v.size()>0)
	{
		for(int i=0;i<v.size();i++)
		{
			fprintf(parseout,"%s ",v[i]->getType().c_str());
		}
		fprintf(parseout,"\t<Line: %d-%d>\n",s->getStartLine(),s->getEndLine());
		for(int i=0;i<v.size();i++)
		{
			PrintFullParseTree(v[i],overhead+" ");
		}
	}
	else
	{
		fprintf(parseout,"%s ",s->getName().c_str());
		fprintf(parseout,"\t<Line: %d>\n",s->getStartLine());
	}
}
void deleteParseTree(SymbolInfo* s)
{
	vector<SymbolInfo*>v=s->getChildList();
	for(int i=0;i<v.size();i++)
	{
		deleteParseTree(v[i]);
	}
	delete s;
}
void varListFrom_declaration_list(SymbolInfo* node,vector<SymbolInfo*>&vect)
{
	vector<SymbolInfo*>v=node->getChildList();
	if(v.size()==3||v.size()==6)
	{
		SymbolInfo* id=v[2];//ID
		if(table->Insert(*id)==true)
		{
			//id=table->Lookup(*v[2]);//reference in symboltable
			//v[2]=id;
			id->setIdType(SymbolInfo::VARIABLE);
			if(v.size()==6)
			{
				id->setIsArray(true);
			}
			vect.push_back(id);
			varListFrom_declaration_list(v[0],vect);
		}
		else
		{
			fprintf(errorout,"Line# %d: Redefinition of %s\n",line_count, id->getName().c_str());
		}
	}
	else///time to end this recursion
	{
		SymbolInfo* id=v[0];//ID
		if(table->Insert(*id)==true)
		{
			//id=table->Lookup(*v[2]);//reference in symboltable
			//v[2]=id;
			id->setIdType(SymbolInfo::VARIABLE);
			if(v.size()==4)
			{
				id->setIsArray(true);
			}
			vect.push_back(id);
		}
		else
		{
			fprintf(errorout,"Line# %d: Redefinition of %s\n",line_count ,id->getName().c_str());
		}
	}
}
void setTypeOfDeclaredVar(SymbolInfo* type,vector<SymbolInfo*> vars)
{
	if(type->getName()=="void")
	{
		fprintf(errorout,"Line# %d: Variables cannot be of type void\n",line_count);
		return;
	}
	for(int i=0;i<vars.size();i++)
	{
		vars[i]->setDataType(type->getName());
	}
}

void declareFunction(SymbolInfo* returnType,SymbolInfo* funcName,vector<SymbolInfo*>& parameter_list)
{
	if(table->Lookup(*funcName)==nullptr)
	{
		table->Insert(*funcName);
		funcName->setIdType(SymbolInfo::DECLARED_FUNCTION);
		funcName->setDataType(returnType->getName());
		for(int i=0;i<parameter_list.size();i++)
		{
			if(parameter_list[i]->getType()!="void")
				funcName->addParameter(parameter_list[i]->getType(),"");///continue from here
			else
			{
				fprintf(errorout,"Line# %d: Function parameters cannot be of type void\n",line_count);
			}
		}
	}
	else
	{
		SymbolInfo* demo=table->Lookup(*funcName);
		if(demo->getIdType()==SymbolInfo::DECLARED_FUNCTION||demo->getIdType()==SymbolInfo::DEFINED_FUNCTION)
		{
			fprintf(errorout,"Line# %d: Redeclaration of %s\n",line_count,demo->getName().c_str());
		}
	}
}

void GetParameterListFromNode(SymbolInfo* node,vector<SymbolInfo*>&vect)
{///now
	vector<SymbolInfo*>children=node->getChildList();
	int sz=children.size();
	if(sz==0) return;
	SymbolInfo* demo;
	if(children.size()%2==0)
	{
		demo=new SymbolInfo(children[sz-1]->getName(),children[sz-2]->getName());//type int float or void from type_specifier
	}
	else 
	{
		demo=new SymbolInfo("",children[sz-1]->getName());//type int float or void from type_specifier
	}
	vect.push_back(demo);
	if(children.size()<=2)
	{
		reverse(vect.begin(),vect.end());
	}
	else
	{///end the recursion
		GetParameterListFromNode(children[0],vect);
	}
}



void defineFunction(SymbolInfo* returnType,SymbolInfo* funcName,vector<SymbolInfo*>& parameter_list)
{
	SymbolInfo* demo=table->Lookup(*funcName);
	if(demo==nullptr)
	{
		table->Insert(*funcName);
		demo=table->Lookup(*funcName);
	}
	else
	{
		if(demo->getIdType()==SymbolInfo::DECLARED_FUNCTION)
		{
			if(demo->getDataType()!=returnType->getName())
			{
				fprintf(errorout,"Line# %d: Return type mismatch with function declaration in function %s\n",line_count,funcName->getName().c_str());
				return;
			}
			vector<pair<string, string> > params = demo->getParameterList();
			if(params.size()!=parameter_list.size())
			{
				fprintf(errorout,"Line# %d: Number of argument mismatch for  %s\n",line_count,funcName->getName().c_str());
				return;
			}
			for(int i=0;i<parameter_list.size();i++)
			{
				if(params[i].first!=parameter_list[i]->getType())
				{
					fprintf(errorout,"Line# %d: conflicting argument types for  %s\n",line_count,funcName->getName().c_str());
					return;
				}
			}
		}
		else
		{
			fprintf(errorout,"Line# %d: Multiple declaration of  %s\n",line_count,funcName->getName().c_str());
			return;
		}
	}
	if(demo->getIdType()==SymbolInfo::DEFINED_FUNCTION)
	{
		fprintf(errorout,"Line# %d: redefinition of %s\n",line_count,demo->getName().c_str());
		return;
	}
	demo->setIdType(SymbolInfo::DEFINED_FUNCTION);
	demo->setDataType(returnType->getName());
	demo->clearParameterList();
	for(int i=0;i<parameter_list.size();i++)
	{
		if(parameter_list[i]->getName()=="")
		{
			fprintf(errorout,"Line# %d: need variable name for %s\n",line_count,demo->getName().c_str());
			return;
		}
		//table.Insert(new SymbolInfo(parameter_list[i]->getName(),"ID",parameter_list[i]->getType(),line_count,line_count));
		demo->addParameter(parameter_list[i]->getType(),parameter_list[i]->getName());
	}
}

%}

%code requires
{
	#include "1905037_symboltable.h"
	#define YYSTYPE SymbolInfo*

}


%token  IF ELSE FOR WHILE DO INT CHAR FLOAT DOUBLE VOID RETURN DEFAULT CONTINUE PRINTLN ADDOP MULOP RELOP LOGICOP INCOP DECOP ASSIGNOP NOT
%token  LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON CONST_INT CONST_FLOAT CONST_CHAR ID
%start  start

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE



%%

start : program
	{
		//write your code in this block in all the similar blocks below
		fprintf(logout,"start : program\n");
		$$=new SymbolInfo("","start");
		$$->addChild($1);
		fixLineNum($$);
		PrintFullParseTree($$);
	}
	;

program : program unit 
	{
		fprintf(logout,"program : program unit\n");
		$$=new SymbolInfo("","program");
		$$->addChild($1);
		$$->addChild($2);
	}
	| unit
	{
		fprintf(logout,"program : unit\n");
		$$=new SymbolInfo("","program");
		$$->addChild($1);
	}
	;
	
unit : var_declaration
	{
		fprintf(logout,"unit : var_declaration\n");
		$$=new SymbolInfo("","unit");
		$$->addChild($1);
	}
	| func_declaration
	{
		fprintf(logout,"unit : func_declaration\n");
		$$=new SymbolInfo("","unit");
		$$->addChild($1);
	}
	| func_definition
	{
		fprintf(logout,"unit : func_definition\n");
		$$=new SymbolInfo("","unit");
		$$->addChild($1);
	}
	;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
	{
		fprintf(logout,"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n");
		$$=new SymbolInfo("","func_declaration");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);$$->addChild($4);$$->addChild($5);$$->addChild($6);///cahnge kora lagte pare
		vector<SymbolInfo*>v;
		GetParameterListFromNode($4,v);
		declareFunction($1,$2,v);
		for(int i=0;i<v.size();i++)
			delete v[i];
	}
	| type_specifier ID LPAREN RPAREN SEMICOLON
	{
		fprintf(logout,"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n");
		$$=new SymbolInfo("","func_declaration");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);$$->addChild($4);$$->addChild($5);///cahnge kora lagte pare
		vector<SymbolInfo*>v;
		//GetParameterListFromNode($4,v);
		declareFunction($1,$2,v);
	}
	;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement
	{///now
		fprintf(logout,"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n");
		$$=new SymbolInfo("","func_definition");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);$$->addChild($4);$$->addChild($5);$$->addChild($6);///cahnge kora lagte pare
		vector<SymbolInfo*>v;
		GetParameterListFromNode($4,v);
		defineFunction($1,$2,v);
		for(int i=0;i<v.size();i++)
			delete v[i];
	}
	| type_specifier ID LPAREN RPAREN compound_statement
	{
		fprintf(logout,"func_definition : type_specifier ID LPAREN RPAREN compound_statement\n");
		$$=new SymbolInfo("","func_definition");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);$$->addChild($4);$$->addChild($5);///cahnge kora lagte pare
		vector<SymbolInfo*>v;
		//GetParameterListFromNode($4,v);
		defineFunction($1,$2,v);
		//for(int i=0;i<v.size();i++)
			//delete v[i];
	}
	;				


parameter_list  : parameter_list COMMA type_specifier ID
	{///now
		fprintf(logout,"parameter_list  : parameter_list COMMA type_specifier ID\n");
		$$=new SymbolInfo("","parameter_list");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);$$->addChild($4);
	}
	| parameter_list COMMA type_specifier
	{
		fprintf(logout,"parameter_list  : parameter_list COMMA type_specifier\n");
		$$=new SymbolInfo("","parameter_list");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);
	}
	| type_specifier ID
	{
		fprintf(logout,"parameter_list  : type_specifier ID\n");
		$$=new SymbolInfo("","parameter_list");
		$$->addChild($1);$$->addChild($2);
	}
	| type_specifier
	{
		fprintf(logout,"parameter_list  : type_specifier\n");	
		$$=new SymbolInfo("","parameter_list");
		$$->addChild($1);
	}
	;

 		
compound_statement : LCURL{ table->EnterScope();  } statements RCURL
	{
		fprintf(logout,"compound_statement : LCURL statements RCURL\n");
		$$=new SymbolInfo("","compound_statement");
		$$->addChild($1);$$->addChild($3);$$->addChild($4);
		table->PrintAllScopeTable(logout);
		table->ExitScope();
	}
	
	| LCURL { table->EnterScope();  } RCURL
	{
		fprintf(logout,"compound_statement : LCURL RCURL\n");
		$$=new SymbolInfo("","compound_statement");
		$$->addChild($1);$$->addChild($3);
		table->PrintAllScopeTable(logout);
		table->ExitScope();
	}
	;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
	{
		fprintf(logout,"var_declaration : type_specifier declaration_list SEMICOLON\n");
		$$=new SymbolInfo("","var_declaration");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);
		vector<SymbolInfo*>vars;
		varListFrom_declaration_list($2,vars);
		setTypeOfDeclaredVar($1,vars);
		//$2->setDataType($1->getName());
	}
	;
 		 
type_specifier : INT
	{
		fprintf(logout,"type_specifier : INT\n");
		$$=new SymbolInfo("int","type_specifier");
		$$->addChild($1);
		//vector<SymbolInfo*>v;
		//v=$$->getChildList();
		//fprintf(parseout,"%s",v[0]->getName().c_str());
	}
	| FLOAT
	{
		fprintf(logout,"type_specifier : FLOAT\n");
		$$=new SymbolInfo("float","type_specifier");
		$$->addChild($1);
	}
	| VOID
	{
		fprintf(logout,"type_specifier : VOID\n");
		$$=new SymbolInfo("void","type_specifier");
		$$->addChild($1);
	}
	;
 		
declaration_list : declaration_list COMMA ID
	{
		fprintf(logout,"declaration_list : declaration_list COMMA ID\n");
		$$=new SymbolInfo("","declaration_list");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);
	}
	| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
	{
		fprintf(logout,"declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n");
		$$=new SymbolInfo("","declaration_list");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);$$->addChild($4);$$->addChild($5);$$->addChild($6);
	}
	| ID
	{
		fprintf(logout,"declaration_list : ID\n");
		$$=new SymbolInfo("","declaration_list");
		$$->addChild($1);
	}
	| ID LTHIRD CONST_INT RTHIRD
	{
		fprintf(logout,"declaration_list : ID LTHIRD CONST_INT RTHIRD\n");
		$$=new SymbolInfo("","declaration_list");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);$$->addChild($4);
	}
	;
 		  
statements : statement
	{
		fprintf(logout,"statements : statement\n");
		$$=new SymbolInfo("","statements");
		$$->addChild($1);
	}
	| statements statement
	{
		fprintf(logout,"statements : statements statement\n");
		$$=new SymbolInfo("","statements");
		$$->addChild($1);$$->addChild($2);
	}
	;
	   
statement : var_declaration
	{
		fprintf(logout,"statement : var_declaration\n");
		$$=new SymbolInfo("","statement");
		$$->addChild($1);
	}
	| expression_statement
	{
		fprintf(logout,"statement : expression_statement\n");
		$$=new SymbolInfo("","statement");
		$$->addChild($1);
	}
	| compound_statement
	{
		fprintf(logout,"statement : compound_statement\n");
		$$=new SymbolInfo("","statement");
		$$->addChild($1);
	}
	| FOR LPAREN expression_statement expression_statement expression RPAREN statement
	{
		fprintf(logout,"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n");
		$$=new SymbolInfo("","statement");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);$$->addChild($4);$$->addChild($5);$$->addChild($6);$$->addChild($7);
	}
	| IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
	{
		fprintf(logout,"statement : IF LPAREN expression RPAREN statement\n");
		$$=new SymbolInfo("","statement");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);$$->addChild($4);$$->addChild($5);
	}
	| IF LPAREN expression RPAREN statement ELSE statement
	{
		fprintf(logout,"statement : IF LPAREN expression RPAREN statement ELSE statement\n");
		$$=new SymbolInfo("","statement");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);$$->addChild($4);$$->addChild($5);$$->addChild($6);$$->addChild($7);
	}
	| WHILE LPAREN expression RPAREN statement
	{
		fprintf(logout,"statement : WHILE LPAREN expression RPAREN statement\n");
		$$=new SymbolInfo("","statement");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);$$->addChild($4);$$->addChild($5);
	}
	| PRINTLN LPAREN ID RPAREN SEMICOLON
	{
		fprintf(logout,"statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n");
		$$=new SymbolInfo("","statement");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);$$->addChild($4);$$->addChild($5);
	}
	| RETURN expression SEMICOLON
	{
		fprintf(logout,"statement : RETURN expression SEMICOLON\n");
		$$=new SymbolInfo("","statement");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);
	}
	;
	  
expression_statement : SEMICOLON
	{
		fprintf(logout,"expression_statement : SEMICOLON\n");
		$$=new SymbolInfo("","expression_statement");
		$$->addChild($1);
	}		
	| expression SEMICOLON
	{
		fprintf(logout,"expression_statement : expression SEMICOLON\n");
		$$=new SymbolInfo("","expression_statement");
		$$->addChild($1);$$->addChild($2);
	}
	;
	  
variable : ID		
	{
		fprintf(logout,"variable : ID\n");
		$$=new SymbolInfo("","variable");
		$$->addChild($1);
	}
	| ID LTHIRD expression RTHIRD
	{
		fprintf(logout,"variable : ID LTHIRD expression RTHIRD\n");
		$$=new SymbolInfo("","variable");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);$$->addChild($4);
	}
	;
	 
expression : logic_expression	
	{
		fprintf(logout,"expression : logic_expression\n");
		$$=new SymbolInfo("","expression");
		$$->addChild($1);
	}
	| variable ASSIGNOP logic_expression 
	{
		fprintf(logout,"expression : variable ASSIGNOP logic_expression\n");
		$$=new SymbolInfo("","expression");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);
	}	
	;
			
logic_expression : rel_expression 
	{
		fprintf(logout,"logic_expression : rel_expression\n");
		$$=new SymbolInfo("","logic_expression");
		$$->addChild($1);
	}
	| rel_expression LOGICOP rel_expression 
	{
		fprintf(logout,"logic_expression : rel_expression LOGICOP rel_expression\n");
		$$=new SymbolInfo("","logic_expression");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);
	}
	;
			
rel_expression	: simple_expression 
	{
		fprintf(logout,"rel_expression	: simple_expression\n");
		$$=new SymbolInfo("","rel_expression");
		$$->addChild($1);
	}
	| simple_expression RELOP simple_expression
	{
		fprintf(logout,"rel_expression	: simple_expression RELOP simple_expression\n");
		$$=new SymbolInfo("","rel_expression");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);
	}
	;
				
simple_expression : term 
	{
		fprintf(logout,"simple_expression : term\n");
		$$=new SymbolInfo("","simple_expression");
		$$->addChild($1);
	}
	| simple_expression ADDOP term 
	{
		fprintf(logout,"simple_expression : simple_expression ADDOP term\n");
		$$=new SymbolInfo("","simple_expression");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);
	}
	;
					
term : unary_expression
	{
		fprintf(logout,"term : unary_expression\n");
		$$=new SymbolInfo("","term");
		$$->addChild($1);
	}
	|  term MULOP unary_expression
	{
		fprintf(logout,"term : term MULOP unary_expression\n");
		$$=new SymbolInfo("","term");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);
	}
	;

unary_expression : ADDOP unary_expression
	{
		fprintf(logout,"unary_expression : ADDOP unary_expression\n");
		$$=new SymbolInfo("","unary_expression");
		$$->addChild($1);$$->addChild($2);
	}  
	| NOT unary_expression 
	{
		fprintf(logout,"unary_expression : NOT unary_expression\n");
		$$=new SymbolInfo("","unary_expression");
		$$->addChild($1);$$->addChild($2);
	}
	| factor 
	{
		fprintf(logout,"unary_expression : factor\n");	
		$$=new SymbolInfo("","unary_expression");
		$$->addChild($1);
	}
	;
	
factor	: variable
	{
		fprintf(logout,"factor	: variabler\n");
		$$=new SymbolInfo("","factor");
		$$->addChild($1);
	}
	| ID LPAREN argument_list RPAREN
	{
		fprintf(logout,"factor	: ID LPAREN argument_list RPAREN\n");
		$$=new SymbolInfo("","factor");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);$$->addChild($4);
	}
	| LPAREN expression RPAREN
	{
		fprintf(logout,"factor  : LPAREN expression RPAREN\n");
		$$=new SymbolInfo("","factor");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);
	}
	| CONST_INT 
	{
		fprintf(logout,"factor	: CONST_INT\n");
		$$=new SymbolInfo("","factor");
		$$->addChild($1);
	}
	| CONST_FLOAT
	{
		fprintf(logout,"factor	: CONST_FLOAT\n");
		$$=new SymbolInfo("","factor");
		$$->addChild($1);
	}
	| variable INCOP 
	{
		fprintf(logout,"factor	: variable INCOP\n");
		$$=new SymbolInfo("","factor");
		$$->addChild($1);$$->addChild($2);
	}
	| variable DECOP
	{
		fprintf(logout,"factor	: variable DECOP\n");
		$$=new SymbolInfo("","factor");
		$$->addChild($1);$$->addChild($2);
	}
	;
	
argument_list : arguments
	{
		fprintf(logout,"argument_list : arguments\n");
		$$=new SymbolInfo("","argument_list");
		$$->addChild($1);
	}
	|//empty
	{
		fprintf(logout,"\n");
		$$=new SymbolInfo("","argument_list");///problem hoite pare
		//SymbolInfo* demo=new SymbolInfo("","EMPTY");
		$$->addChild(new SymbolInfo("","EMPTY",line_count,line_count));
	}
	;
	
arguments : arguments COMMA logic_expression
	{
		fprintf(logout,"arguments : arguments COMMA logic_expression\n");
		$$=new SymbolInfo("","arguments");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);
	}
	| logic_expression
	{
		fprintf(logout,"arguments : logic_expression\n");
		$$=new SymbolInfo("","arguments");
		$$->addChild($1);
	}
	;
 

%%
int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}


	logout= fopen("log.txt","w");
	parseout= fopen("parsetree.txt","w");
	errorout= fopen("myerror.txt","w");

	yyin = fin;
	yyparse();
	table->PrintAllScopeTable(logout);
	fprintf(logout, "Total lines: %d\n", line_count);
	//fprintf(logout, "Total lexical errors: %d\n", errorCount);
	fclose(yyin);
	fclose(parseout);
	fclose(logout);
	
	return 0;
}

