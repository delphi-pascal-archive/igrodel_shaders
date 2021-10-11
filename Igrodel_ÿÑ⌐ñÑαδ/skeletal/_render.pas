// Author: Georgy Moshkin

unit _render;

interface
uses _model,_types,dglopengl;

var CurrentTex:GLUINT;
var noState:TSkelAnimState;

procedure Render(models:TModels;modelIndex:integer;xState:TSkelAnimState);
procedure RenderForShader(models:TModels;modelIndex:integer;ShaderVarAddr:glInt);

procedure makeVBO(var myModel:TModel);
procedure renderVBO(myModel:TModel);

implementation

type TVertexForVBO=packed record
                           ts,tt,tr,tq : single;  // T4F
                           r,g,b,a     : single;  // C4F
                           nx,ny,nz    : single;  // N3F
                           x,y,z,w     : single;  // V4F
                          end;

type PVertexForVBO=^TVertexForVBO;

procedure renderVBO(myModel:TModel);
var i:integer;
begin
 i:=0;
 glBindBufferARB(GL_ARRAY_BUFFER_ARB, myModel.VBOlink);
 glInterleavedArrays(GL_T4F_C4F_N3F_V4F, 0,nil);
 glDrawArrays(GL_TRIANGLES,0,3*length(myModel.poligons));
end;

procedure makeVBO(var myModel:TModel);
var i,j:integer;
    pVertex:PVertexForVBO;
    tempData:pointer;
    totalBones:integer;
begin


 glGenBuffersARB(1, @myModel.VBOlink);
 glBindBufferARB(GL_ARRAY_BUFFER_ARB, myModel.VBOlink);


 myModel.VBOsize:=3*length(myModel.poligons)*sizeof(TVertexForVbo);
 getMem(tempData, myModel.VBOsize);

 for i:=0 to length(myModel.poligons)-1 do
  begin

    for j := 0 to 2 do
     begin

    pVertex :=Pointer(Integer(tempData) + (i*3+j)*sizeof(TVertexForVbo));

    pVertex^.ts:=myModel.poligons[i].texcoord[j][0];
    pVertex^.tt:=myModel.poligons[i].texcoord[j][1];
    pVertex^.nx:=myModel.vertex[
                                        myModel.poligons[i].vert[j]
                                       ].norm[0];
    pVertex^.ny:=myModel.vertex[
                                        myModel.poligons[i].vert[j]
                                       ].norm[1];
    pVertex^.nz:=myModel.vertex[
                                        myModel.poligons[i].vert[j]
                                       ].norm[2];

    pVertex^.x:=myModel.localized[
                                        myModel.poligons[i].vert[j]
                                       ].coord[0];
    pVertex^.y:=myModel.localized[
                                        myModel.poligons[i].vert[j]
                                       ].coord[1];
    pVertex^.z:=myModel.localized[
                                        myModel.poligons[i].vert[j]
                                       ].coord[2];

    pVertex^.w:=(myModel.poligons[i].glTex)/255;

    totalBones:=length(myModel.vertex[
                                        myModel.poligons[i].vert[j]
                                       ].parents);

    pVertex^.tr:=myModel.vertex[
                                        myModel.poligons[i].vert[j]
                                       ].parents[0].boneNum/255;

    pVertex^.tq:=myModel.vertex[
                                        myModel.poligons[i].vert[j]
                                       ].parents[0].weight;

    if totalBones>1 then
     begin

      pVertex^.r:=myModel.vertex[
                                          myModel.poligons[i].vert[j]
                                         ].parents[1].boneNum/255;

      pVertex^.g:=myModel.vertex[
                                          myModel.poligons[i].vert[j]
                                         ].parents[1].weight;
     end
      else
     begin
      pVertex^.r:=0;
      pVertex^.g:=0;
     end;

    if totalBones>2 then
     begin

      pVertex^.b:=myModel.vertex[
                                          myModel.poligons[i].vert[j]
                                         ].parents[2].boneNum/255;

      pVertex^.a:=myModel.vertex[
                                          myModel.poligons[i].vert[j]
                                         ].parents[2].weight;
     end
      else
     begin
      pVertex^.b:=0;
      pVertex^.a:=0;
     end;



       end;





  end;



 glBufferDataARB( GL_ARRAY_BUFFER_ARB,
                  myModel.VBOsize,
                  tempData,
                  GL_STATIC_DRAW_ARB );


 freeMem(tempData);
end;


procedure Render(models:TModels;modelIndex:integer;xState:TSkelAnimState);
var i,j,k:integer;
    fff,zzz:TVector3s;
    mmm:TMatrix4x4s;
    w:single;

begin


if length(xState.currentPose.bones)>0 then
 with xState do
  for j:=0 to length(models[modelIndex].localized)-1 do
    begin
       fff[0]:=0;
       fff[1]:=0;
       fff[2]:=0;

             for k:=0 to length(models[modelIndex].localized[j].parents)-1 do
             begin
                     zzz:=models[modelIndex].localized[j].coord;

                     mmm:=CurrentPose.bones[
                                models[modelIndex].localized[j].parents[k].boneNum
                                                       ].m_absolute;



                    w:=models[modelIndex].localized[j].parents[k].weight;

                    zzz:=Transform3(zzz,mmm);

                    fff[0]:=fff[0]+zzz[0]*w;
                    fff[1]:=fff[1]+zzz[1]*w;
                    fff[2]:=fff[2]+zzz[2]*w;

             end;


       models[modelIndex].vertex[j].coord:=fff;

    end;


 for i:=0 to length(models[modelIndex].poligons)-1 do
  begin

   if models[modelIndex].poligons[i].hasUV then  //Если объект текстурирован
    if (CurrentTex<>models[modelIndex].poligons[i].gltex) then
    begin
     glBindTexture(GL_TEXTURE_2D,models[modelIndex].poligons[i].glTex); // подсовываем нужную текстуру
     CurrentTex:=models[modelIndex].poligons[i].gltex;
    end;

   glBegin(GL_POLYGON); // НАЧИНАЕМ рисовать полигон

    for j:=0 to models[modelIndex].poligons[i].vertnum-1 do
     begin

      // всё как обычно: текстурные координаты, нормаль и сама вершина
      glTexCoord2f(models[modelIndex].poligons[i].texcoord[j][0],
                   models[modelIndex].poligons[i].texcoord[j][1]);

      With models[modelIndex].vertex[models[modelIndex].poligons[i].vert[j]] do
      glNormal3f(norm[0],
                 norm[1],
                 norm[2]);

      With models[modelIndex].vertex[models[modelIndex].poligons[i].vert[j]] do
      glVertex3f(coord[0],
                 coord[1],
                 coord[2]);
     end;
   glEnd;
  end;



end;

procedure RenderForShader(models:TModels;modelIndex:integer;ShaderVarAddr:glInt);
var i,j:integer;
begin

 for i:=0 to length(models[modelIndex].poligons)-1 do
  begin

   if models[modelIndex].poligons[i].hasUV then  //Если объект текстурирован
    if (CurrentTex<>models[modelIndex].poligons[i].gltex) then
    begin
     glBindTexture(GL_TEXTURE_2D,models[modelIndex].poligons[i].glTex); // подсовываем нужную текстуру
     CurrentTex:=models[modelIndex].poligons[i].gltex;
    end;

   glBegin(GL_POLYGON); // НАЧИНАЕМ рисовать полигон
    for j:=0 to models[modelIndex].poligons[i].vertnum-1 do
     begin

         // передаём номер кости, к которой прикреплена вершина
         glVertexAttrib1fARB(ShaderVarAddr,
                             models[modelIndex].localized[models[modelIndex].poligons[i].vert[j]].parents[0].boneNum);

      // всё как обычно: текстурные координаты, нормаль и сама вершина
      glTexCoord2f(models[modelIndex].poligons[i].texcoord[j][0],
                   models[modelIndex].poligons[i].texcoord[j][1]);

      With models[modelIndex].localized[models[modelIndex].poligons[i].vert[j]] do
      glNormal3f(norm[0],
                 norm[1],
                 norm[2]);

      With models[modelIndex].localized[models[modelIndex].poligons[i].vert[j]] do
      glVertex3f(coord[0],
                 coord[1],
                 coord[2]);
     end;
   glEnd;
  end;

end;


end.