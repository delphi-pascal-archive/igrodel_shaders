// ========================================== //
// _smdloader.pas                             //
// ------------------------------------------ //
// Author: Georgy Moshkin (tmtlib@narod.ru)   //
// ========================================== //

unit _smdloader;

interface

uses _model, _types, _strman, sysutils;

procedure SMD_addModel(var models:TModels; fname:string);
procedure SMD_addAnimation(var Models:TModels; fname:string);

implementation

procedure SMD_addModel(var models:TModels; fname:string);
var f:text;
    s:string;
    i,j,k:integer;
    modelIndex:integer;
begin

  DecimalSeparator:='.';

 setlength(models,length(models)+1);
 modelIndex:=length(models)-1;

 assignFile(f,fname);
 reset(f);

 repeat
  readln(f,s);
 until s='nodes';

 i:=0;
 setlength(models[modelIndex].skelanim.nodes,i);


 repeat
  readln(f,s);
  if s<>'end' then
   begin
    setlength(models[modelIndex].skelanim.nodes,i+1);
    models[modelIndex].skelanim.nodes[i].name:=StringWordGet(s, '"', 2);
    models[modelIndex].skelanim.nodes[i].parent:=StrToInt(StringWordGet (s, '"', 3));
    inc(i);
   end;
 until s='end';

 models[modelIndex].skelanim.nodesNum:=length(models[modelIndex].skelanim.nodes);
 setLength(models[modelIndex].skelanim.referencePose,
           models[modelIndex].skelanim.nodesNum);

 repeat
  readln(f,s);
 until s='time 0';

 i:=0;


repeat
 readln(f,s);
 if s<>'end' then
 with models[modelIndex].skelanim.referencePose[i] do
  begin
   trans[0]:=strtofloatdef(StringWordGet(trim(s),' ',2),0);
   trans[1]:=strtofloatdef(StringWordGet(trim(s),' ',3),0);
   trans[2]:=strtofloatdef(StringWordGet(trim(s),' ',4),0);
   rot[0]:=strtofloatdef(StringWordGet(trim(s),' ',5),0);
   rot[1]:=strtofloatdef(StringWordGet(trim(s),' ',6),0);
   rot[2]:=strtofloatdef(StringWordGet(trim(s),' ',7),0);
   quat:=angle2quat(rot);
   inc(i);
  end;
until s='end';

repeat
 readln(f,s);
until s='triangles';

i:=0;
setlength(models[modelIndex].poligons,i);
setlength(models[modelIndex].vertex,0);

repeat
 readln(f,s);

 if s<>'end' then
  begin
   setlength(models[modelIndex].poligons,i+1);
   models[modelIndex].poligons[i].BMPname:=s;
   models[modelIndex].poligons[i].vertnum:=3;

   for j:=0 to 2 do
    begin
     setlength(models[modelIndex].vertex,
               length(models[modelIndex].vertex)+1);
     k:=length(models[modelIndex].vertex)-1;

     readln(f,s);

     setlength(models[modelIndex].vertex[k].parents,1);
     models[modelIndex].vertex[k].parents[0].boneNum:=strToInt(StringWordGet(trim(s),' ',1));
     models[modelIndex].vertex[k].parents[0].weight:=1;

     models[modelIndex].vertex[k].coord[0]:=strtofloatdef(StringWordGet(trim(s),' ',2),0);
     models[modelIndex].vertex[k].coord[1]:=strtofloatdef(StringWordGet(trim(s),' ',3),0);
     models[modelIndex].vertex[k].coord[2]:=strtofloatdef(StringWordGet(trim(s),' ',4),0);
     models[modelIndex].vertex[k].norm[0]:=strtofloatdef(StringWordGet(trim(s),' ',5),0);
     models[modelIndex].vertex[k].norm[0]:=strtofloatdef(StringWordGet(trim(s),' ',6),0);
     models[modelIndex].vertex[k].norm[0]:=strtofloatdef(StringWordGet(trim(s),' ',7),0);

     models[modelIndex].poligons[i].texcoord[j][0]:=strtofloatdef(StringWordGet(trim(s),' ',8),0);
     models[modelIndex].poligons[i].texcoord[j][1]:=strtofloatdef(StringWordGet(trim(s),' ',9),0);

     models[modelIndex].poligons[i].vert[j]:=k;

    end;
   inc(i);
  end;
until s='end';

closeFile(f);
end;


procedure SMD_addAnimation(var Models:TModels; fname:string);
var f:text;
    s:string;
    i,j:integer;
    modelIndex:Integer;
    actionIndex:Integer;
begin

  DecimalSeparator:='.';

assignFile(f,fname);
reset(f);

modelIndex:=length(models)-1;

setlength(models[modelIndex].skelanim.Actions,
          length(models[modelIndex].skelanim.Actions)+1);
actionIndex:=length(models[modelIndex].skelanim.Actions)-1;

models[modelIndex].skelanim.Actions[actionIndex].name:=fname;
models[modelIndex].skelanim.Actions[actionIndex].fps:=15; // default

repeat
 readln(f,s);
until s='skeleton';

s:='';
i:=0;
j:=0;

repeat
 readln(f,s);
 if s='end' then break;
 if StringWordGet (s, ' ', 1) = 'time' then
  begin
   i:=0;
   inc(j);
   setlength(models[modelIndex].skelanim.Actions[actionIndex].frames,j);
  end
 else
  begin
   inc(i);

   setlength(models[modelIndex].skelanim.Actions[actionIndex].frames[j-1].bones, i);

   with models[modelIndex].skelanim.Actions[actionIndex].frames[j-1] do
    begin
     bones[i-1].trans[0]:=strtofloatdef(StringWordGet(trim(s),' ',2),0);
     bones[i-1].trans[1]:=strtofloatdef(StringWordGet(trim(s),' ',3),0);
     bones[i-1].trans[2]:=strtofloatdef(StringWordGet(trim(s),' ',4),0);
     bones[i-1].rot[0]:=strtofloatdef(StringWordGet(trim(s),' ',5),0);
     bones[i-1].rot[1]:=strtofloatdef(StringWordGet(trim(s),' ',6),0);
     bones[i-1].rot[2]:=strtofloatdef(StringWordGet(trim(s),' ',7),0);
     bones[i-1].quat:=angle2quat(bones[i-1].rot);
    end;


  end;

models[modelIndex].skelanim.Actions[actionIndex].framesNum:=
      length(models[modelIndex].skelanim.Actions[actionIndex].frames);  

until false;

closeFile(f);
end;



end.

