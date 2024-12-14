//#include<bits/stdc++.h>
#pragma once
using namespace std;
#define ll unsigned long long
///
class SymbolInfo
{
private:
    string name;
    string type;// token type
    SymbolInfo* next;
    ///new types for syntax and semantic analysis///
    int startLine,endLine;//for parse tree
    string dataType;// datatype of var or return type of func
    bool isArray;
    int idType;// var or func
    vector<pair<string,string>>parameter_list;//{datatype,name}
    vector<SymbolInfo*>childList;

public:
    static const int NO_TYPE= 0;
    static const int VARIABLE = 1;
    static const int DECLARED_FUNCTION = 2;
    static const int DEFINED_FUNCTION = 3;

    bool getIsArray()
    {
        return isArray;
    }
    void setIsArray(bool x)
    {
        isArray=x;
    }
    int getIdType()
    {
        return idType;
    }
    void setIdType(int idType)
    {
        this->idType=idType;
    }
    int getStartLine()
    {
        return startLine;
    }
    int getEndLine(){
        return endLine;
    }
    void setStartLine(int x)
    {
        startLine=x;
    }
    void setEndLine(int x){
        endLine=x;
    }
    void addChild(SymbolInfo* s)
    {
        childList.push_back(s);
    }
    vector <SymbolInfo*> getChildList()
    {
        return childList;
    }
    void setDataType(string s)
    {
        dataType=s;
    }
    string getDataType()
    {
        return dataType;
    }
    void addParameter(string s1,string s2)
    {
        parameter_list.push_back({s1,s2});
    }
    vector<pair<string,string>> getParameterList()
    {
        return parameter_list;
    }
    void clearParameterList()
    {
        parameter_list.clear();
    }


    SymbolInfo()
    {
        name="";
        type="";
        next=nullptr;
        startLine=0;
        endLine=0;
        this->dataType = "";
        this->idType = NO_TYPE;
        this->isArray = false;
        this->parameter_list.clear();
    }
    SymbolInfo(string name, string type)
    {
        this->name = name;
        this->type = type;
        this->next = nullptr;
        startLine=0;
        endLine=0;
        this->dataType = "";
        this->idType = NO_TYPE;
        this->isArray = false;
        this->parameter_list.clear();
    }

    SymbolInfo(SymbolInfo *s){
        this->name = s->name;
        this->type = s->type;
        this->next = s->next;
        this->startLine=s->startLine;
        this->endLine=s->endLine;
        this->dataType = s->dataType;
        this->idType = s->idType;
        this->isArray = s->isArray;
        this->parameter_list = s->parameter_list;
    }

    SymbolInfo(string name, string type, string dataType,int startLine,int endLine, int idType = NO_TYPE, bool isArray=false)
    {
        this->name = name;
        this->type = type;
        this->next = nullptr;
        this->startLine=startLine;
        this->endLine=endLine;
        this->dataType = dataType;
        this->idType = idType;
        this->isArray = isArray;
        this->parameter_list.clear();
    }
    SymbolInfo(string name, string type,int startLine,int endLine)
    {
        this->name = name;
        this->type = type;
        this->next = nullptr;
        this->startLine=startLine;
        this->endLine=endLine;
        this->dataType = "";
        this->idType = NO_TYPE;
        this->isArray = false;
        this->parameter_list.clear();
    }

    string getName()
    {
        return name;
    }
    void setName(string s)
    {
        name=s;
    }
    string getType()
    {
        return type;
    }
    void setType(string s)
    {
        type=s;
    }
    SymbolInfo* getNext()
    {
        return next;
    }
    void setNext(SymbolInfo* s)
    {
        next=s;
    }


};

class ScopeTable
{
private:
    SymbolInfo** HashTable;
    ScopeTable* parent_scope;
    int sz;
    //static int ScopeTableCnt;
    int ScopeTableNum;
public:

    unsigned long long SDBMHash(string str)
    {
        unsigned long long  hash = 0;
        unsigned long long  i = 0;
        unsigned long long  len = str.length();

        for (i = 0; i < len; i++)
        {
            hash = (str[i]) + (hash << 6) + (hash << 16) - hash;
        }

        return hash;
    }

    ScopeTable(int n,int scopeTableNum)
    {
        //cout<<'\t'<<"ScopeTable# "<<ScopeTableCnt<<" created"<<endl;
        sz=n;
        HashTable=new SymbolInfo*[sz];
        for(int i=0;i<sz;i++)
            HashTable[i]=new SymbolInfo();
        parent_scope=nullptr;
        ScopeTableNum=scopeTableNum;
    }
    int getScopeTableNum()
    {
        return ScopeTableNum;
    }
    ScopeTable* getParent()
    {
        return parent_scope;
    }
    void setParent(ScopeTable* s)
    {
        parent_scope=s;
    }
    bool Insert(SymbolInfo& s)
    {
        if(Lookup(s)==nullptr)
        {
            int cnt=1;
            ll hashval=SDBMHash(s.getName())%sz;
            SymbolInfo* it=HashTable[hashval];
            while(it->getNext()!=nullptr)
            {
                cnt++;
                it=it->getNext();
            }
            it->setNext(&s);
            it=it->getNext();
            //cout<<it->getName()<<",,,"<<endl;
            it->setNext(nullptr);
            //cout<<'\t'<<"Inserted in ScopeTable# "<<ScopeTableNum<<" at position "<<hashval+1<<", "<<cnt<<endl;
            return true;
        }
        else
        {
            //cout<<'\t'<<"'"<<s.getName()<<"'"<<" already exists in the current ScopeTable"<<endl;
            return false;
        }
    }
    SymbolInfo* Lookup(SymbolInfo& s, bool f=false)
    {
        int cnt=0;
        ll hashval=SDBMHash(s.getName())%sz;
        //cout<<hashval<<"#val"<<endl;
        SymbolInfo* it = HashTable[hashval];
        while(it!=nullptr)
        {
            //cout<<cnt++<<",,";cout<<"Found "<<it->getName()<<endl;
            if(it->getName()==s.getName())
            {
                //if(f)cout<<'\t'<<"'"<<s.getName()<<"'"<<" found in ScopeTable# "<<ScopeTableNum<<" at position "<<hashval+1<<", "<<cnt<<endl;
                return it;
            }
            it=it->getNext();
            cnt++;
        }
        return nullptr;
    }
    bool Delete(SymbolInfo& s)
    {
        int cnt=1;
        SymbolInfo* et=Lookup(s);
        if(et!=nullptr)
        {
            ll hashval=SDBMHash(s.getName())%sz;
            SymbolInfo* it=HashTable[hashval];
            while(it->getNext()!=et)
            {
                it=it->getNext();
                cnt++;
            }
            it->setNext(et->getNext());
            //cout<<'\t'<<"Deleted "<<"'"<<s.getName()<<"'"<<" from ScopeTable# "<<ScopeTableNum<<" at position "<<hashval+1<<", "<<cnt<<endl;
            return true;
        }
        else
        {
            //cout<<'\t'<<"Not found in the current ScopeTable"<<endl;
            return false;
        }
    }
    void print(FILE* fout)
    {
        fprintf(fout,"\tScopeTable# %d\n", ScopeTableNum);
        //cout<<'\t'<<"ScopeTable# "<<ScopeTableNum<<endl;
        for(int i=0; i<sz; i++)
        {
            //cout<<'\t'<<i+1<<"--> ";
            SymbolInfo* it=HashTable[i];
            bool flag=0;
            if(it->getNext()!=nullptr)
                flag=1;
            if(flag)
                fprintf(fout,"\t%d--> ", i+1);
            while(it->getNext()!=nullptr)
            {
                fprintf(fout,"<%s,%s> ", it->getNext()->getName().c_str(),it->getNext()->getType().c_str());
                //cout<<"<"<<it->getNext()->getName()<<","<<it->getNext()->getType()<<"> ";
                it=it->getNext();
            }
            if(flag)
                fprintf(fout,"\n", ScopeTableNum);
        }
    }

    ~ScopeTable()
    {
        //cout<<'\t'<<"ScopeTable# "<<ScopeTableNum<<" removed"<<endl;
        for(int i=0;i<sz;i++)
        {
            delete HashTable[i];
        }
        delete[] HashTable;
    }
};
//int ScopeTable::ScopeTableCnt=1;
class SymbolTable
{
private:
    int sz;
    ScopeTable* current;
    int ScopeTableCnt;
public:

    SymbolTable(int x)
    {
        sz=x;
        ScopeTableCnt =1;
        current=new ScopeTable(sz,ScopeTableCnt);
        ScopeTableCnt++;
    }
    void EnterScope()
    {
        ScopeTable* it=current;
        current=new ScopeTable(sz,ScopeTableCnt);
        ScopeTableCnt++;
        current->setParent(it);
    }
    bool ExitScope()
    {
        if(current->getParent()!=nullptr)
        {
            ScopeTable* it=current;
            current=current->getParent();
            delete it;
            return true;
        }
        else
        {
            //cout<<'\t'<<"ScopeTable# 1 cannot be removed"<<endl;
            return false;
        }
    }
    bool Insert(SymbolInfo& s)
    {
        return current->Insert(s);
    }
    bool Remove(SymbolInfo& s)
    {
        return current->Delete(s);
    }
    SymbolInfo* Lookup(SymbolInfo& s)
    {
        ScopeTable* it=current;
        while(it!=nullptr)
        {
            SymbolInfo* et=it->Lookup(s,true);
            if(et!=nullptr)
                return et;
            it=it->getParent();
        }
        //cout<<'\t'<<"'"<<s.getName()<<"'"<<" not found in any of the ScopeTables"<<endl;
        return nullptr;
    }
    void PrintCurrentScopeTable(FILE* fout)
    {
        current->print(fout);
    }
    void PrintAllScopeTable(FILE* fout)
    {
        ScopeTable* it=current;
        while(it!=nullptr)
        {
            it->print(fout);
            it=it->getParent();
        }
    }
    ~SymbolTable()
    {
        while(current!=nullptr)
        {
            ScopeTable* it=current;
            current=current->getParent();
            delete it;
        }
    }

};
/*int main()
{
    SymbolTable symboltable(n);
    SymbolInfo* a=new SymbolInfo();
    a->setName(tokens[1]);
    a->setType(tokens[2]);
    symboltable.Insert(*a);

}*/

