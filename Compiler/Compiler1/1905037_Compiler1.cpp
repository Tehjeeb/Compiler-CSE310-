#include<bits/stdc++.h>
using namespace std;
#define ll unsigned long long

class SymbolInfo
{
private:
    string name;
    string type;
    SymbolInfo* next;
public:
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
    SymbolInfo()
    {
        name="";
        type="";
        next=nullptr;
    }
};
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
class ScopeTable
{
private:
    SymbolInfo** HashTable;
    ScopeTable* parent_scope;
    int sz;
    static int ScopeTableCnt;
    int ScopeTableNum;
public:
    ScopeTable(int n)
    {
        cout<<'\t'<<"ScopeTable# "<<ScopeTableCnt<<" created"<<endl;
        sz=n;
        HashTable=new SymbolInfo*[sz];
        for(int i=0;i<sz;i++)
            HashTable[i]=new SymbolInfo();
        parent_scope=nullptr;
        ScopeTableNum=ScopeTableCnt++;
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
            cout<<'\t'<<"Inserted in ScopeTable# "<<ScopeTableNum<<" at position "<<hashval+1<<", "<<cnt<<endl;
            return true;
        }
        else
        {
            cout<<'\t'<<"'"<<s.getName()<<"'"<<" already exists in the current ScopeTable"<<endl;
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
                if(f)cout<<'\t'<<"'"<<s.getName()<<"'"<<" found in ScopeTable# "<<ScopeTableNum<<" at position "<<hashval+1<<", "<<cnt<<endl;
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
            cout<<'\t'<<"Deleted "<<"'"<<s.getName()<<"'"<<" from ScopeTable# "<<ScopeTableNum<<" at position "<<hashval+1<<", "<<cnt<<endl;
            return true;
        }
        else
        {
            cout<<'\t'<<"Not found in the current ScopeTable"<<endl;
            return false;
        }
    }
    void print()
    {
        cout<<'\t'<<"ScopeTable# "<<ScopeTableNum<<endl;
        for(int i=0; i<sz; i++)
        {
            cout<<'\t'<<i+1<<"--> ";
            SymbolInfo* it=HashTable[i];
            while(it->getNext()!=nullptr)
            {
                cout<<"<"<<it->getNext()->getName()<<","<<it->getNext()->getType()<<"> ";
                it=it->getNext();
            }
            cout<<endl;
        }
    }

    ~ScopeTable()
    {
        cout<<'\t'<<"ScopeTable# "<<ScopeTableNum<<" removed"<<endl;
        for(int i=0;i<sz;i++)
        {
            delete HashTable[i];
        }
        delete[] HashTable;
    }
};
int ScopeTable::ScopeTableCnt=1;
class SymbolTable
{
private:
    int sz;
    ScopeTable* current;
public:

    SymbolTable(int x)
    {
        sz=x;
        current=new ScopeTable(sz);
    }
    void EnterScope()
    {
        ScopeTable* it=current;
        current=new ScopeTable(sz);
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
            cout<<'\t'<<"ScopeTable# 1 cannot be removed"<<endl;
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
        cout<<'\t'<<"'"<<s.getName()<<"'"<<" not found in any of the ScopeTables"<<endl;
        return nullptr;
    }
    void PrintCurrentScopeTable()
    {
        current->print();
    }
    void PrintAllScopeTable()
    {
        ScopeTable* it=current;
        while(it!=nullptr)
        {
            it->print();
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
int main()
{
    freopen("sample_input.txt", "r", stdin);
    freopen("sample_output.txt", "w", stdout);
    int n,command_no=0;
    cin>>n;
    SymbolTable symboltable(n);

    string str,x;
    getline (cin,str);
    while(true)
    {
        command_no++;
        SymbolInfo* a=new SymbolInfo();
        getline (cin,str,'\n');
        if(str.back()=='\r')
        {
            str=str.substr(0,str.size()-1);
        }
        cout<<"Cmd "<<command_no<<": "<<str<<endl;
        int cnt=0;
        stringstream X(str);
        string tokens[3];
        while (getline(X, x, ' '))
        {
            if(cnt<3)
                tokens[cnt]=x;
            cnt++;
        }
        if(tokens[0]=="I")
        {
            if(cnt!=3)
            {
                cout<<'\t'<<"Number of parameters mismatch for the command "<<tokens[0]<<endl;
                continue;
            }
            a->setName(tokens[1]);
            a->setType(tokens[2]);
            symboltable.Insert(*a);
            //symboltable.PrintCurrentScopeTable();
        }
        else if(tokens[0]=="L")
        {
            if(cnt!=2)
            {
                cout<<'\t'<<"Number of parameters mismatch for the command "<<tokens[0]<<endl;
                continue;
            }
            a->setName(tokens[1]);
            a->setType("");
            symboltable.Lookup(*a);
        }
        else if(tokens[0]=="D")
        {
            if(cnt!=2)
            {
                cout<<'\t'<<"Number of parameters mismatch for the  command "<<tokens[0]<<endl;
                continue;
            }
            a->setName(tokens[1]);
            a->setType("");
            symboltable.Remove(*a);
        }
        else if(tokens[0]=="P")
        {
            if(cnt!=2)
            {
                cout<<'\t'<<"Number of parameters mismatch for the command "<<tokens[0]<<endl;
                continue;
            }
            if(tokens[1]=="C")
                symboltable.PrintCurrentScopeTable();
            else if(tokens[1]=="A")
                symboltable.PrintAllScopeTable();
        }
        else if(tokens[0]=="S")
        {
            if(cnt!=1)
            {
                cout<<'\t'<<"Number of parameters mismatch for the command "<<tokens[0]<<endl;
                continue;
            }
            symboltable.EnterScope();
        }
        else if(tokens[0]=="E")
        {
            if(cnt!=1)
            {
                cout<<'\t'<<"Number of parameters mismatch for the command "<<tokens[0]<<endl;
                continue;
            }
            symboltable.ExitScope();
        }
        else if(tokens[0]=="Q")
        {
            break;
        }
    }
}
