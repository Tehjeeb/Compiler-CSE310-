%{
#include<bits/stdc++.h>
#include "1905037_symboltable.h"

#define YYSTYPE SymbolInfo*

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
extern int line_count;
int lablecnt=0;
FILE *logout;
FILE *parseout;
FILE *errorout;
FILE *asmout;

SymbolTable *table = new SymbolTable(30);
vector<SymbolInfo*>gv;
int offset=0;

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
				id->setArraySize(stoi(v[4]->getName()));
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
				id->setArraySize(stoi(v[2]->getName()));
			}
			vect.push_back(id);
		}
		else
		{
			fprintf(errorout,"Line# %d: Redefinition of %s\n",line_count ,id->getName().c_str());
		}
	}
}

void setDeclaredVarCode(vector<SymbolInfo*>& vars)
{
	reverse(vars.begin(),vars.end());
	for(int i=0;i<vars.size();i++)
	{
		if (vars[i]->isGlobal())
		{
			fprintf(asmout,"\t%s DW %d",vars[i]->getName().c_str(),vars[i]->getArraySize());
			if (vars[i]->getIsArray())
			{
				fprintf(asmout," DUP(0)\t\t; array %s declared",vars[i]->getName().c_str());
			}
			else
			{
				fprintf(asmout," 0    \t\t; variable %s declared",vars[i]->getName().c_str());
			}
			fprintf(asmout,"\n");
			vars[i]->setAsmName(vars[i]->getName());
		}
		else
		{
			if (vars[i]->getIsArray())
			{
				int n = vars[i]->getArraySize();
				vars[i]->setOffset(offset-2);
				vars[i]->setAsmName("[BP-"+to_string(abs(offset-2))+"]");
				fprintf(asmout,"\t\tSUB SP, %d\t;line %d: array %s of size %d declared\n",(n * 2),line_count,vars[i]->getName().c_str(),n);
				offset-=n*2;
				//codeSegOut << "\t\t; from " << varInfo->getAsmName(0);
				//codeSegOut << " to " << varInfo->getAsmName(n - 1) << endl;
			}
			else
			{
				vars[i]->setOffset(offset-2);
				vars[i]->setAsmName("[BP-"+to_string(abs(offset-2))+"]");
				//cout<<vars[i]->getAsmName()<<"ok"<<endl;
				offset-=2;
				fprintf(asmout,"\t\tSUB SP, 2\t;line %d: %s declared\n",line_count,vars[i]->getName().c_str());
			}
		}
		table->Insert(*vars[i]);
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
				funcName->addParameter(parameter_list[i]->getType(),"");
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
{
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
	{///end the recursion
		reverse(vect.begin(),vect.end());
	}
	else
	{
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
void generateFuncStartCode(string funcName)
{
	fprintf(asmout,"%s PROC\n",funcName.c_str());
    
    if (funcName == "main")
    {
		fprintf(asmout,"\tMOV AX, @DATA\n\t\tmov DS, AX\n\t\t; data segment loaded\n\n");
		fprintf(asmout,"\tPUSH BP\n");
//mainFuncTerminateLabel = newLabel();
        
//isMain = true;
    }else{
//isMain = false;
		fprintf(asmout,"\tPUSH BP\n");//save bp 
    }
	fprintf(asmout,"\tMOV BP, SP\n");
}
void generateFuncEndCode(string funcName)
{
    if (funcName == "main")
    {
		fprintf(asmout,"\tMOV AH, 4CH\n\tINT 21H\n");
        //codeSegOut << "\n\t\t" << mainFuncTerminateLabel << ":" << endl;
    }else{
        //addCommentln("For the case of not returning from a function");
        //genCodeln("\t\tPOP BP");
        //codeSegOut << "\t\tRET\n";
        //isMain = true;
    }
	fprintf(asmout,"%s ENDP\n\n",funcName.c_str());

}
string newLable(){
	lablecnt++;
	return "L"+to_string(lablecnt)+":";
	
}
string addNewlinefunc(){
	string str= "new_line proc\n"
    "\tpush ax\n"
    "\tpush dx\n"
    "\tmov ah,2\n"
    "\tmov dl,cr\n"
    "\tint 21h\n"
    "\tmov ah,2\n"
    "\tmov dl,lf\n"
    "\tint 21h\n"
    "\tpop dx\n"
    "\tpop ax\n"
    "\tret\n"
"new_line endp\n\n";
return str;
}
string addPrintlinefunc(){
	string str= "print_output proc  ;print what is in ax\n"
    "\tpush ax\n"
    "\tpush bx\n"
    "\tpush cx\n"
    "\tpush dx\n"
    "\tpush si\n"
    "\tlea si,number\n"
    "\tmov bx,10\n"
    "\tadd si,4\n"
    "\tcmp ax,0\n"
    "\tjnge negate\n"
    "\tprint:\n"
    "\txor dx,dx\n"
    "\tdiv bx\n"
    "\tmov [si],dl\n"
    "\tadd [si],'0'\n"
    "\tdec si\n"
    "\tcmp ax,0\n"
    "\tjne print\n"
    "\tinc si\n"
    "\tlea dx,si\n"
    "\tmov ah,9\n"
    "\tint 21h\n"
    "\tpop si\n"
    "\tpop dx\n"
    "\tpop cx\n"
    "\tpop bx\n"
    "\tpop ax\n"
    "\tret\n"
    "\tnegate:\n"
    "\tpush ax\n"
    "\tmov ah,2\n"
    "\tmov dl,'-'\n"
    "\tint 21h\n"
    "\tpop ax\n"
    "\tneg ax\n"
    "\tjmp print\n"
	"print_output endp\n"
	"END main\n";
	return str;
}
string relopConverter(string relop){
    if(relop == "!=") return "JNE";
    if(relop == "<=") return "JLE";
    if(relop == "==") return "JE";
    if(relop == ">=") return "JGE";
    if(relop == ">") return "JG";
    if(relop == "<") return "JL";
}
string logicopConverter(string relop){
    if(relop == "||") return "JNE";
    if(relop == "&&") return "JLE";
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

start :{
		fprintf(asmout,".MODEL SMALL\n.STACK 1000h\n.DATA\n\n\tCR EQU 0DH\n\tLF EQU 0AH\n\tnumber DB \"00000$\"\n\n");
	} program
	{
		//cout<<"kwehfb"<<endl;
		//write your code in this block in all the similar blocks below
		fprintf(logout,"start : program\n");
		$$=new SymbolInfo("","start");
		$$->addChild($2);
		fixLineNum($$);
		PrintFullParseTree($$);
		fprintf(asmout,"%s",addNewlinefunc().c_str());
		fprintf(asmout,"%s",addPrintlinefunc().c_str());
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
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN 
	{
		fprintf(logout,"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n");
		$$=new SymbolInfo("","func_definition");

		vector<SymbolInfo*>v;
		GetParameterListFromNode($4,v);
		defineFunction($1,$2,v);
		//for(int i=0;i<v.size();i++)
		//	delete v[i];
		generateFuncStartCode($2->getName());
	} compound_statement {
		generateFuncEndCode($2->getName());
		
		/*$$->addChild($1);*/$$->addChild($2);$$->addChild($3);$$->addChild($4);$$->addChild($5);$$->addChild($7);
		//cout<<$1->getType()<<endl;
	}
	| type_specifier ID LPAREN RPAREN 
	{
		fprintf(logout,"func_definition : type_specifier ID LPAREN RPAREN compound_statement\n");
		$$=new SymbolInfo("","func_definition");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);$$->addChild($4);///cahnge kora lagte pare
		vector<SymbolInfo*>v;
		//GetParameterListFromNode($4,v);
		defineFunction($1,$2,v);
		//for(int i=0;i<v.size();i++)
			//delete v[i];
		generateFuncStartCode($2->getName());
	} compound_statement {
		$$->addChild($6);
		generateFuncEndCode($2->getName());
	}
	;				


parameter_list  : parameter_list COMMA type_specifier ID
	{
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
		setDeclaredVarCode(vars);
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
		//fprintf(logout,"declaration_list : declaration_list COMMA ID\n");
		$$=new SymbolInfo("","declaration_list");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);
	}
	| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
	{
		//fprintf(logout,"declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n");
		$$=new SymbolInfo("","declaration_list");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);$$->addChild($4);$$->addChild($5);$$->addChild($6);
	}
	| ID
	{
		//fprintf(logout,"declaration_list : ID\n");
		$$=new SymbolInfo("","declaration_list");
		$$->addChild($1);
	}
	| ID LTHIRD CONST_INT RTHIRD
	{
		//fprintf(logout,"declaration_list : ID LTHIRD CONST_INT RTHIRD\n");
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
	| FOR LPAREN expression_statement {
		string firstLable=newLable();
		fprintf(asmout,"%s\n",firstLable.c_str());
		$1->setLable(firstLable);
	} expression_statement {
		string secondLable=newLable(),thirdLable=newLable(),fourthLable=newLable();
		//fprintf(asmout,"\tPOP AX \t;getting condition value\n");
		fprintf(asmout,"\tCMP AX, 0 \t;check condition value\n");
		fprintf(asmout,"\tJE %s \t;getting out \n",fourthLable.substr(0,fourthLable.size()-1).c_str());
		fprintf(asmout,"\tJMP %s \t;getting in \n",thirdLable.substr(0,thirdLable.size()-1).c_str());
		fprintf(asmout,"%s\n",secondLable.c_str());
		$2->setLable(secondLable);
		$3->setLable(thirdLable);
		$5->setLable(fourthLable);
	} expression {
		fprintf(asmout,"\tPOP AX  \t;poping cause no semicolon in for 3rd expression\n",$1->getLable().substr(0,$1->getLable().size()-1).c_str());
		fprintf(asmout,"\tJMP %s \t;going to check condition again \n",$1->getLable().substr(0,$1->getLable().size()-1).c_str());
	} RPAREN {
		fprintf(asmout,"%s\n",$3->getLable().c_str());
	} statement
	{
		fprintf(logout,"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n");
		$$=new SymbolInfo("","statement");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);$$->addChild($5);$$->addChild($7);$$->addChild($9);$$->addChild($11);
		fprintf(asmout,"\tJMP %s \t;loop ended so starting again from top in \n",$2->getLable().substr(0,$2->getLable().size()-1).c_str());
		fprintf(asmout,"%s\t;for loop ending tag\n",$5->getLable().c_str());
	}
	| if_prefix %prec LOWER_THAN_ELSE
	{
		fprintf(logout,"statement : IF LPAREN expression RPAREN statement\n");
		$$=new SymbolInfo("","statement");
		$$->addChild($1->getChildList()[0]);$$->addChild($1->getChildList()[1]);$$->addChild($1->getChildList()[2]);$$->addChild($1->getChildList()[3]);$$->addChild($1->getChildList()[4]);
		// get label from $1
		fprintf(asmout,"%s\n",$1->getLable().c_str());
	}
	| if_prefix ELSE {
		string firstLable=newLable();
		fprintf(asmout,"\tJMP %s; \n",firstLable.substr(0,firstLable.size()-1).c_str());
		fprintf(asmout,"%s\n",$1->getLable().c_str());
		$1->setLable(firstLable);
	} statement
	{
		fprintf(logout,"statement : IF LPAREN expression RPAREN statement ELSE statement\n");
		$$=new SymbolInfo("","statement");
		$$->addChild($1->getChildList()[0]);$$->addChild($1->getChildList()[1]);$$->addChild($1->getChildList()[2]);$$->addChild($1->getChildList()[3]);$$->addChild($1->getChildList()[4]);
		$$->addChild($2);$$->addChild($4);

		fprintf(asmout,"%s\n",$1->getLable().c_str());
	}
	| WHILE LPAREN {
		string firstLable=newLable();
		$2->setLable(firstLable);
		fprintf(asmout,"%s\t;while starting tag\n",firstLable.c_str());
	} expression RPAREN {
		string secondLable=newLable();
		fprintf(asmout,"\tPOP AX \t;getting condition value\n");
		fprintf(asmout,"\tCMP AX, 0 \t;check condition value\n");
		fprintf(asmout,"\tJE %s \t;getting out \n",secondLable.substr(0,secondLable.size()-1).c_str());
		$5->setLable(secondLable);
	} statement
	{
		fprintf(logout,"statement : WHILE LPAREN expression RPAREN statement\n");
		$$=new SymbolInfo("","statement");
		$$->addChild($1);$$->addChild($2);$$->addChild($4);$$->addChild($5);$$->addChild($7);
		
		fprintf(asmout,"\tJMP %s \t;getting back\n",$2->getLable().substr(0,$2->getLable().size()-1).c_str());
		fprintf(asmout,"%s\t;while end tag\n",$5->getLable().c_str());
	}
	| PRINTLN LPAREN ID RPAREN SEMICOLON
	{
		fprintf(logout,"statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n");
		$$=new SymbolInfo("","statement");
		$3=table->Lookup(*$3);
		$$->addChild($1);$$->addChild($2);$$->addChild($3);$$->addChild($4);$$->addChild($5);

		fprintf(asmout,"\tMOV AX, %s\n",$3->getAsmName().c_str());
		fprintf(asmout,"\tCALL print_output\n");
		fprintf(asmout,"\tCALL new_line\n");
	}
	| RETURN expression SEMICOLON
	{
		fprintf(logout,"statement : RETURN expression SEMICOLON\n");
		$$=new SymbolInfo("","statement");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);
	}
	;
	  
if_prefix : IF LPAREN expression RPAREN {
	string firstLable = newLable();
	fprintf(asmout,"\tPOP AX \t;line no :%d getting expression value \n",line_count);
	fprintf(asmout,"\tCMP AX, 0\n");
	fprintf(asmout,"\tJE %s\n",firstLable.substr(0,firstLable.size()-1).c_str());
	$3->setLable(firstLable);
} statement {
	$$ = new SymbolInfo("", "if_prefix");
	$$->addChild($1);$$->addChild($2);$$->addChild($3);$$->addChild($4);$$->addChild($6);
	$$->setLable($3->getLable());
}







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
		fprintf(asmout,"\tPOP AX \t ;line no: %d kaj sesh!\n",line_count);
	}
	;
	  
variable : ID		
	{///set offset
		fprintf(logout,"variable : ID\n");
		$$=new SymbolInfo("","variable");
		$1=table->Lookup(*$1);
		$$->addChild($1);
		$$->setAsmName($1->getAsmName());
	}
	| ID LTHIRD expression RTHIRD
	{
		fprintf(logout,"variable : ID LTHIRD expression RTHIRD\n");
		$$=new SymbolInfo("","variable");
		$1=table->Lookup(*$1);
		$$->addChild($1);$$->addChild($2);$$->addChild($3);$$->addChild($4);
		fprintf(asmout,"\tPOP AX \t; index in AX\n");
		fprintf(asmout,"\tSHL AX, 1 \t; offset in AX\n");
		fprintf(asmout,"\tLEA BX, %s \t; base address in BX\n",$1->getAsmName().c_str());
		fprintf(asmout,"\tSUB BX, AX \t; [BX] has var address\n");
		fprintf(asmout,"\tPUSH BX\n");
		$$->setAsmName("[BX]");
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
		fprintf(asmout,"\tPOP AX \t;line no: %d\n",line_count);
		if($1->getAsmName()=="[BX]")
			fprintf(asmout,"\tPOP BX \t;line no: %d loading address \n",line_count);
		fprintf(asmout,"\tMOV %s, AX \t\t\t;line no: %d\n",$1->getAsmName().c_str(),line_count);
		fprintf(asmout,"\tPUSH AX \t;line no: %d\n",line_count);
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
		
		fprintf(asmout,"\tPOP AX \t;line no: %d\n",line_count);
		fprintf(asmout,"\tMOV DX, AX \t;line no: %d\n",line_count);
		fprintf(asmout,"\tPOP AX \t;line no: %d\n",line_count);
		fprintf(asmout,"\tCMP AX, 0 \t;line no: %d\n",line_count);
		string firstLable=newLable(),secondLable=newLable(),thirdLable=newLable(),fourthLable=newLable();
		if($2->getName()=="||")
		{
			fprintf(asmout,"\tJNE %s \t;line no: %d\n",secondLable.substr(0,secondLable.size()-1).c_str(),line_count);
			fprintf(asmout,"\tJMP %s \t;line no: %d\n",firstLable.substr(0,firstLable.size()-1).c_str(),line_count);
			fprintf(asmout,"%s\n",firstLable.c_str());
			fprintf(asmout,"\tMOV AX, DX \t;line no: %d\n",line_count);
			fprintf(asmout,"\tCMP AX, 0 \t;line no: %d\n",line_count);
			fprintf(asmout,"\tJNE %s \t;line no: %d\n",secondLable.substr(0,secondLable.size()-1).c_str(),line_count);
			fprintf(asmout,"\tJMP %s \t;line no: %d\n",thirdLable.substr(0,thirdLable.size()-1).c_str(),line_count);
			fprintf(asmout,"%s\n",secondLable.c_str());
			fprintf(asmout,"\tMOV AX, 1 \t;line no: %d\n",line_count);
			fprintf(asmout,"\tJMP %s \t;line no: %d\n",fourthLable.substr(0,fourthLable.size()-1).c_str(),line_count);
			fprintf(asmout,"%s\n",thirdLable.c_str());
			fprintf(asmout,"\tMOV AX, 0 \t;line no: %d\n",line_count);
			fprintf(asmout,"%s\n",fourthLable.c_str());
			fprintf(asmout,"\tPUSH AX \t;line no: %d saved the logicop result\n",line_count);
		}
		else if($2->getName()=="&&")
		{
			fprintf(asmout,"\tJNE %s \t;line no: %d\n",firstLable.substr(0,firstLable.size()-1).c_str(),line_count);
			fprintf(asmout,"\tJMP %s \t;line no: %d\n",thirdLable.substr(0,thirdLable.size()-1).c_str(),line_count);
			fprintf(asmout,"%s\n",firstLable.c_str());
			fprintf(asmout,"\tMOV AX, DX \t;line no: %d\n",line_count);
			fprintf(asmout,"\tCMP AX, 0 \t;line no: %d\n",line_count);
			fprintf(asmout,"\tJNE %s \t;line no: %d\n",secondLable.substr(0,secondLable.size()-1).c_str(),line_count);
			fprintf(asmout,"\tJMP %s \t;line no: %d\n",thirdLable.substr(0,thirdLable.size()-1).c_str(),line_count);
			fprintf(asmout,"%s\n",secondLable.c_str());
			fprintf(asmout,"\tMOV AX, 1 \t;line no: %d\n",line_count);
			fprintf(asmout,"\tJMP %s \t;line no: %d\n",fourthLable.substr(0,fourthLable.size()-1).c_str(),line_count);
			fprintf(asmout,"%s\n",thirdLable.c_str());
			fprintf(asmout,"\tMOV AX, 0 \t;line no: %d\n",line_count);
			fprintf(asmout,"%s\n",fourthLable.c_str());
			fprintf(asmout,"\tPUSH AX \t;line no: %d saved the logicop result\n",line_count);
		}
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
		fprintf(asmout,"\tPOP AX \t ;line no %d\n",line_count);
		fprintf(asmout,"\tMOV DX, AX \t ;line no %d\n",line_count);
		fprintf(asmout,"\tPOP AX \t ;line no %d\n",line_count);
		fprintf(asmout,"\tCMP AX, DX \t ;line no %d\n",line_count);
		string firstLable=newLable(),secondLable=newLable(),thirdLable=newLable();
		fprintf(asmout,"\t%s %s \t ;line no %d\n",relopConverter($2->getName()).c_str(),firstLable.substr(0,firstLable.size()-1).c_str(),line_count);
		fprintf(asmout,"\tJMP %s \t ;line no %d\n",secondLable.substr(0,secondLable.size()-1).c_str(),line_count);
		fprintf(asmout,"%s\n",firstLable.c_str());
		fprintf(asmout,"\tMOV AX, 1\t ;line no %d\n",line_count);
		fprintf(asmout,"\tJMP %s \t ;line no %d\n",thirdLable.substr(0,thirdLable.size()-1).c_str(),line_count);
		fprintf(asmout,"%s\n",secondLable.c_str());
		fprintf(asmout,"\tMOV AX, 0\t ;line no %d\n",line_count);
		fprintf(asmout,"%s\n",thirdLable.c_str());
		fprintf(asmout,"\tPUSH AX   \t ;line no %d\n",line_count);
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
		fprintf(asmout,"\tPOP AX \t ;line no %d\n",line_count);
		fprintf(asmout,"\tMOV DX, AX \t ;line no %d\n",line_count);
		fprintf(asmout,"\tPOP AX \t ;line no %d\n",line_count);
		if($2->getName()=="-")
			fprintf(asmout,"\tSUB AX, DX \t ;line no %d\n",line_count);
		else
			fprintf(asmout,"\tADD AX, DX \t ;line no %d\n",line_count);
		fprintf(asmout,"\tPUSH AX \t ;line no %d\n",line_count);
	}
	;
					
term : unary_expression
	{///no asm
		fprintf(logout,"term : unary_expression\n");
		$$=new SymbolInfo("","term");
		$$->addChild($1);
	}
	|  term MULOP unary_expression
	{
		fprintf(logout,"term : term MULOP unary_expression\n");
		$$=new SymbolInfo("","term");
		$$->addChild($1);$$->addChild($2);$$->addChild($3);
		fprintf(asmout,"\tPOP AX \t ;line no %d\n",line_count);
		fprintf(asmout,"\tMOV CX, AX \t ;line no %d\n",line_count);
		fprintf(asmout,"\tPOP AX \t ;line no %d\n",line_count);
		fprintf(asmout,"\tCWD \t ;line no %d\n",line_count);
		if($2->getName()=="*")
		{
			fprintf(asmout,"\tMUL CX \t ;line no %d\n",line_count);
			fprintf(asmout,"\tPUSH AX \t ;line no %d\n",line_count);
		}
		else if($2->getName()=="%")
		{
			fprintf(asmout,"\tDIV CX \t ;line no %d\n",line_count);
			fprintf(asmout,"\tPUSH DX \t ;line no %d pushing the remainder\n",line_count);
			//fprintf(asmout,"\tPOP AX \t ;line no %d poping the remainder\n",line_count);
			//fprintf(asmout,"\tPUSH AX \t ;line no %d\n",line_count);
		}
		else if($2->getName()=="/")
		{
			fprintf(asmout,"\tDIV CX \t ;line no %d\n",line_count);
			fprintf(asmout,"\tPUSH AX \t ;line no %d pushing the quotient\n",line_count);
		}
	}
	;

unary_expression : ADDOP unary_expression
	{
		fprintf(logout,"unary_expression : ADDOP unary_expression\n");
		$$=new SymbolInfo("","unary_expression");
		$$->addChild($1);$$->addChild($2);
		if($1->getName()=="-")
		{
			fprintf(asmout,"\tPOP AX \t ;line no %d\n",line_count);
			fprintf(asmout,"\tNEG AX \t ;line no %d\n",line_count);
			fprintf(asmout,"\tPUSH AX \t ;line no %d\n",line_count);
		}
	}  
	| NOT unary_expression 
	{
		fprintf(logout,"unary_expression : NOT unary_expression\n");
		$$=new SymbolInfo("","unary_expression");
		$$->addChild($1);$$->addChild($2);
		fprintf(asmout,"\tPOP AX \t ;line no %d\n",line_count);
		fprintf(asmout,"\tNOT AX \t ;line no %d\n",line_count);
		fprintf(asmout,"\tPUSH AX \t ;line no %d\n",line_count);
	}
	| factor 
	{///no asm
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
		if($1->getAsmName()=="[BX]")
			fprintf(asmout,"\tPOP BX;get address of array variable\n");
		//cout<<$1->getAsmName()<<"nope"<<endl;
		fprintf(asmout,"\tMOV AX, %s \t ;Line: %d save var\n",$1->getAsmName().c_str(),line_count);
		fprintf(asmout,"\tPUSH AX \t ;Line: %d save var\n",line_count);
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
		fprintf(asmout,"\tMOV AX, %s\t;load %s in ax \n",$1->getName().c_str(),$1->getName().c_str());
		fprintf(asmout,"\tPUSH AX\t;save ax \n",$1->getName().c_str(),$1->getName().c_str());
	}
	| CONST_FLOAT
	{
		
	}
	| variable INCOP 
	{
		fprintf(logout,"factor	: variable INCOP\n");
		$$=new SymbolInfo("","factor");
		$$->addChild($1);$$->addChild($2);

		if($1->getAsmName()=="[BX]")
			fprintf(asmout,"\tPOP BX;get address of array variable\n");
		//cout<<$1->getAsmName()<<"nope"<<endl;
		fprintf(asmout,"\tMOV AX, %s \t ;Line: %d save var\n",$1->getAsmName().c_str(),line_count);
		fprintf(asmout,"\tPUSH AX \t ;Line: %d save var\n",line_count);
		fprintf(asmout,"\tINC AX \t ;Line: %d increment var\n",line_count);
		fprintf(asmout,"\tMOV %s, AX \t ;Line: %d decrement var\n",$1->getAsmName().c_str(),line_count);
	}
	| variable DECOP
	{
		fprintf(logout,"factor	: variable DECOP\n");
		$$=new SymbolInfo("","factor");
		$$->addChild($1);$$->addChild($2);
		if($1->getAsmName()=="[BX]")
			fprintf(asmout,"\tPOP BX;get address of array variable\n");
		//cout<<$1->getAsmName()<<"nope"<<endl;
		fprintf(asmout,"\tMOV AX, %s \t ;Line: %d save var\n",$1->getAsmName().c_str(),line_count);
		fprintf(asmout,"\tPUSH AX \t ;Line: %d save var\n",line_count);
		fprintf(asmout,"\DEC AX \t ;Line: %d decrement var\n",line_count);
		fprintf(asmout,"\MOV %s, AX \t ;Line: %d decrement var\n",$1->getAsmName().c_str(),line_count);
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


	logout= fopen("_log.txt","w");
	parseout= fopen("_parsetree.txt","w");
	errorout= fopen("_myerror.txt","w");
	asmout=fopen("code.asm","w");

	yyin = fin;
	yyparse();
	table->PrintAllScopeTable(logout);
	fprintf(logout, "Total lines: %d\n", line_count);
	fclose(yyin);
	fclose(parseout);
	fclose(logout);
	//fclose(asmout);
	return 0;
}

