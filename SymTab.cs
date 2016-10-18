using System;
 
namespace Tastier { 
public class Obj { // properties of declared symbol
   public string name; // its name
   public int kind;    // var, proc or scope
   public int type;    // its type if var (undef for proc)
   public int level;   // lexic level: 0 = global; >= 1 local
   public int adr;     // address (displacement) in scope 
   public Obj next;    // ptr to next object in scope
   // for scopes
   public Obj outer;   // ptr to enclosing scope
   public Obj locals;  // ptr to locally declared objects
   public int nextAdr; // next free address in scope
}

public class SymbolTable {
   const int // object kinds
      var = 0, proc = 1, scope = 2, constant = 3; 

   const int // types
      undef = 0, integer = 1, boolean = 2;

   public Obj topScope; // topmost procedure scope
   public int curLevel; // nesting level of current scope
   public Obj undefObj; // object node for erroneous symbols
   
   Parser parser;
   
   public SymbolTable(Parser parser) {
      curLevel = -1; 
      topScope = null;
      undefObj = new Obj();
      undefObj.name = "undef";
      undefObj.kind = var;
      undefObj.type = undef;
      undefObj.level = 0;
      undefObj.adr = 0;
      undefObj.next = null;
      this.parser = parser; 
   }

// open new scope and make it the current scope (topScope)
   public void OpenScope() {
      Obj scop = new Obj();
      scop.name = "";
      scop.kind = scope; 
      scop.outer = topScope; 
      scop.locals = null;
      scop.nextAdr = 0;
      topScope = scop; 
      curLevel++;
   }

// close current scope
   public void CloseScope() {
      printIdentifiers();
      topScope = topScope.outer;
      curLevel--;
   }

   public void printIdentifiers() {
      Obj obj, scope;
      scope = topScope;
      // Boilerplate to make comments slightly more visible
      Console.WriteLine("\n;;;;;;;;;;;;;;;;;;;;;;;");
      Console.WriteLine("; Stack Level: {0}", curLevel, scope.level);
      Console.WriteLine(";;;;;;;;;;;;;;;;;;;;;;;");
      while(scope != null) {
        obj = scope.locals;
        while(obj != null) {
          buildLog(scope, obj);
          obj = obj.next;
        }
        scope = scope.outer;
      }
      // End comments
      Console.WriteLine(";;;;;;;;;;;;;;;;;;;;;;;\n");
   }

   public void buildLog(Obj scope, Obj obj) {
      string[] kinds = { "Variable", "Procedure", "Scope", "Constant" };
      string[] types = { "undefined", "int", "boolean" };
      string objKind = kinds[obj.kind];
      string objType = types[obj.type];
      string scopeVisibility = obj.level == 0 ? "Global" : "Local";
      Console.WriteLine("; Name: {0}, Kind: {1}, Type: {2}, Address: {3}, Scope: {4}, Level: {5}", obj.name, objKind, objType, obj.adr, scopeVisibility, obj.level);
   }

// create new object node in current scope
   public Obj NewObj(string name, int kind, int type) {
      Obj p, last; 
      Obj obj = new Obj();
      obj.name = name; obj.kind = kind;
      obj.type = type; obj.level = curLevel; 
      obj.next = null; 
      p = topScope.locals; last = null;
      while (p != null) { 
         if (p.name == name)
            parser.SemErr("name declared twice");
         last = p; p = p.next;
      }
      if (last == null)
         topScope.locals = obj; else last.next = obj;
      if (kind == var || kind == constant)
         obj.adr = topScope.nextAdr++;
      return obj;
   }

// search for name in open scopes and return its object node
   public Obj Find(string name) {
      Obj obj, scope;
      scope = topScope;
      while (scope != null) { // for all open scopes
         obj = scope.locals;
         while (obj != null) { // for all objects in this scope
            if (obj.name == name) return obj;
            obj = obj.next;
         }
         scope = scope.outer;
      }
      parser.SemErr(name + " is undeclared");
      return undefObj;
   }

} // end SymbolTable

} // end namespace
