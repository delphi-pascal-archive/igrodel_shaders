// ========================================== //
// _model.pas                                 //
// ------------------------------------------ //
// Author: Georgy Moshkin (tmtlib@narod.ru)   //
// ========================================== //

unit _model;

interface

uses _types, _strman, glbmpx, dglopengl;

// ����� ��� ������� Bone ����� ������� (���) ������� Weight
type TWeight=record
              boneNum : integer;  // ����� �����
              weight : single; // ������� �������
             end;

// ������� ����� ����������, ������� � ������ �
// ������������ �������� �� �� ������
type TVert=record
            coord:TVector3s; // ���������� �������
            norm:TVector3s;  // �������, ��������� �� �������
            parents:array  of TWeight; // ������ ������, �������� �� �������
           end;

// �������
type TPoligon=record
               BMPname   : string;   // ��� ����� � ���������
               vertnum   : integer;  // ���������� ������ (3 �� 4)
               vert      : array [0..3] of Integer; // ������ �� ������� ������� � ���������

               texcoord  : array [0..3] of TVector2s; // ������ � �����������
                                                      // ������������

               glTex     : GLUINT;   // OpenGL-������ ������������� ��������

               hasUV     : boolean;  // ������� ������� ��������
              end;

// ������ �������
type TNode=record
            name:string; // �������� �����, ������� �������� � �������
            parent:integer; // ������ �����, � �������� ��������� ������
           end;

// ����� ������� (������� ��������� �������)
type TBonePos=record
               trans:TVector3s; // �����������
               rot:TVector3s;   // �������

               m_absolute:TMatrix4x4s; // ���������� ������� �����
               m_relative:TMatrix4x4s; // ������������� ������� �����

               quat:TQuaternion; // ���������� �����
              end;

// ���� ��������
type TFrame=record
             bones:array of TBonePos; // ������ � ��������� ������
            end;

// �������� ���������
type TAction=record
              name      : string;  // �������� �������� ��� ����� ��������
              fps       : single;  // �������� ��������
              framesNum : integer; // ���������� ������ ��������

              frames : array of TFrame; // ������ � ������� ��������
             end;

// ��������� ��������
type TSkelAnimState=record
                     prevFrame:integer; // ���������� ����
                     nextFrame:integer; // ��������� ����

                     prevAction:integer; // ���������� ��������
                     nextAction:integer; // ��������� ��������

                     skelTime:single; // ����� (�������� �� ���� ��
                                      //        ������� �����
                                      //        ���������� � ���������
                                      //        ������)

                     CurrentPose: TFrame; // ������� ���� ���������
                                          // � ������ ������������
                                          // �� ������� skelTime


                     // ������ ���������� ������ ��� �������� � ������
                     shaderAbsoluteMat: packed array[0..31] of TMatrix4x4raw;
                    end;

// ��������� �������� ���������
type TSkelAnim=record
                Actions: array of TAction; // ������ ��������, ��������� ���������

                nodes  : array of TNode; // �������� �������������� �������� �������
                                         // (��� � ���� �����������)

                nodesNum  : integer; // ���������� �������� � �������

                referencePose: array of TBonePos; // reference-������� �������
                                                   // (���� ����������������� ������)
               end;

// ������ ��������� ������� ��:
// - �������� �����
// - ���������
// - ������
// - �������� ��������������� ������
// - ��������� ��������
type TModel=record
                fname:string; // ��� �����
                poligons:array of TPoligon; // ��������
                vertex:array of TVert; // �������
                localized:array of TVert; // ���������� ������ (�������� ���������������)
                skelanim:TSkelAnim; // ��������� �������� ������

                VBOlink: TGLUINT;
                VBOsize: integer;
               end;

type TModels = array of TModel; // ������ �������

var BlenderElapsed:single; // ����� � ������������� ����� �������

procedure loadTextures(var models:TModels;path:string);
procedure prepareSkeletalAnimation(var models:TModels);

procedure ResetSkelAnimState(var xState:TSkelAnimState;nodesNum:integer);
procedure AnimateModel(Models:TModels;ModelIndex:integer; ActionNum:integer;aDelta:integer; var xState:TSkelAnimState;playOnce:boolean);
procedure CopyBonesForShader(var xState:TSkelAnimState);



implementation

procedure ResetSkelAnimState(var xState:TSkelAnimState;nodesNum:integer);
begin
  xState.prevAction:=-1;
  xState.nextAction:=-1;
  xState.skelTime:=0;
  xState.prevFrame:=0;
  xState.nextFrame:=1;
  Setlength(xState.CurrentPose.bones, nodesNum);
end;


procedure loadTextures(var models:TModels;path:string);
var i,j,modelIndex:integer;
    loaded:boolean;
begin

 for modelIndex := 0 to length(models) - 1 do
    for i:=0 to length(models[modelIndex].poligons)-1 do // ��� ���� ���������
     begin

      loaded:=false; // ��� ��� ��������� �������� ������������� �������

      for j:=0 to i-1 do // ��������� ��������, ������� ��� ��������� ���� �������� �������
       if models[modelIndex].poligons[j].BMPname=models[modelIndex].poligons[i].BMPname then // ���� ����� ���������, �� ��������� ������ �� �����
        begin
         loaded:=true; // �������, ��� �������� ��� ���������
         models[modelIndex].poligons[i].gltex:=models[modelIndex].poligons[j].gltex; //���������� ID ����������� ����� ��������
         break; //���������� ���� for (������� �� �����)
        end;

      if not loaded then // ���� ��-���� �� ���������, �� ��������:
       begin
           models[modelIndex].poligons[i].hasUV:=true;
        if models[modelIndex].poligons[i].BMPname<>'NOTEXTURE' then
         LoadTexture(path+models[modelIndex].poligons[i].BMPname, models[modelIndex].poligons[i].glTex)
        else
           models[modelIndex].poligons[i].hasUV:=false;
       end;

     end;

end;

procedure prepareSkeletalAnimation(var models:TModels);
var i,j,k,modelIndex:integer;
    zzz,fff:TVector3s;
    mmm:TMatrix4x4s;
    w:single;
begin

for modelIndex := 0 to length(models) - 1 do
 begin

  with models[modelIndex].skelanim do
      for k:=0 to nodesNum -1 do
       begin
        SetRotationRadians(referencePose[k].m_relative, referencePose[k].rot);
        SetTranslation(referencePose[k].m_relative,referencePose[k].trans);

        referencePose[k].quat:=angle2quat(referencePose[k].rot);

        if nodes[k].parent<>-1 then
          begin
           referencePose[k].m_absolute:=referencePose[
                                                     nodes[k].parent
                                                     ].m_absolute;
           PostMultiply(referencePose[k].m_absolute,
                        referencePose[k].m_relative);
          end
            else referencePose[k].m_absolute:=referencePose[k].m_relative


       end;

  with models[modelIndex].skelanim do
    for i:=0 to length(Actions)-1 do
     for j:=0 to length(Actions[i].frames)-1 do
      for k:=0 to nodesNum -1 do
       begin
        SetRotationRadians(Actions[i].frames[j].bones[k].m_relative, Actions[i].frames[j].bones[k].rot);
        SetTranslation(Actions[i].frames[j].bones[k].m_relative,Actions[i].frames[j].bones[k].trans);

        Actions[i].frames[j].bones[k].quat:=angle2quat(Actions[i].frames[j].bones[k].rot);

        if nodes[k].parent<>-1 then
          begin
           Actions[i].frames[j].bones[k].m_absolute:=Actions[i].frames[j].bones[
                                                        nodes[k].parent
                                                                ].m_absolute;
           PostMultiply(Actions[i].frames[j].bones[k].m_absolute,
                        Actions[i].frames[j].bones[k].m_relative);
          end
            else Actions[i].frames[j].bones[k].m_absolute:=Actions[i].frames[j].bones[k].m_relative


       end;

 setlength(models[modelIndex].localized, length (models[modelIndex].vertex));

 for i:=0 to length (models[modelIndex].vertex)-1 do
  begin

   models[modelIndex].localized[i]:=models[modelIndex].vertex[i];

   fff[0]:=0;
   fff[1]:=0;
   fff[2]:=0;
   for k:=0 to length(models[modelIndex].localized[i].parents)-1 do
    begin
     zzz:=models[modelIndex].vertex[i].coord;

     mmm:=models[modelIndex].skelanim.referencePose[
                          models[modelIndex].vertex[i].parents[k].boneNum
                                         ].m_absolute;

                      w:=models[modelIndex].localized[i].parents[k].weight;
//                      w:=1;

     InverseTranslateVect(zzz,mmm);
     InverseRotateVect(zzz,mmm);

     fff[0]:=fff[0]+zzz[0]*w;
     fff[1]:=fff[1]+zzz[1]*w;
     fff[2]:=fff[2]+zzz[2]*w;
    end;

    models[modelIndex].localized[i].coord:=fff;
  end;

 end;




end;


procedure AnimateModel(Models:TModels;ModelIndex:integer; ActionNum:integer;aDelta:integer; var xState:TSkelAnimState;playOnce:boolean);
var delta:single;
    i,j,k:integer;
begin

  if length(xState.currentPose.bones)=0 then exit;

 with Models[modelIndex].SkelAnim do
  begin

  with xState do
  if prevAction<>ActionNum then
   begin
//    prevAction:=-1;
//    nextAction:=-1;
//   skelTime:=0;
//   prevFrame:=nextFrame+1;
//    if nextFrame>Actions[nextAction].framesNum-1 then prevFrame:=0;
    nextFrame:=0;
   end;

   with xState do
    begin
     nextAction:=ActionNum;
     if prevAction=-1 then prevAction:=ActionNum;
     if nextAction=-1 then nextAction:=ActionNum;
   end;


    // smooth hack
//  with xState do
//  if prevAction<>nextAction then
//  delta:= BlenderElapsed * Actions[xState.nextAction].fps / 10000  // smooth hack
//   else
    delta:= BlenderElapsed * Actions[xState.nextAction].fps / 1000;

    xState.skelTime:=xState.skelTime + delta;

                  if xState.skelTime>1 then
                   begin

                     with xState do
                      begin
                       skelTime:=0;
                       prevAction:=nextAction;
//??? v
                      prevFrame:=nextFrame;

                       nextFrame:=nextFrame+aDelta;

                         if nextFrame>Actions[nextAction].framesNum-1 then
                          if not PlayOnce then //hack
                          begin
                           prevAction:=nextAction; // HACK
                           nextFrame:=0; // DOUBLEHACK MOD 0 - reference.
                          end
                           else
                          begin
                           nextAction:=prevAction; // big hack
                           nextFrame:=prevFrame; // hack
                          end;

                          if nextFrame<0{1 DOUBLEHACKED} then
                          begin
                           prevAction:=nextAction; // HACK
                           nextFrame:=Actions[nextAction].framesNum-1;
                          end;

//                    prevFrame:=nextFrame;
// hack:

 (*

  temp comment

                         if Actions[nextAction].frames[nextFrame].anglesUpdated then
                          for i:=0 to nodesNum-1 do
                           begin
                            Actions[nextAction].frames[nextFrame
                                  ].bones[i].quat.fromAngles(Actions[nextAction].frames[nextFrame].bones[i].rot);
                            Actions[nextAction].frames[nextFrame].anglesUpdated:=false;
                           end;
*)

                      end; {xState end}
                     end;




     for i:=0 to nodesNum-1 do
      for j:=0 to 2 do
       with xState do
         currentPose.bones[i].trans[j]:=Actions[prevAction].frames[prevFrame].bones[i].trans[j]+
                                       (Actions[nextAction].frames[nextFrame].bones[i].trans[j]-
                                       Actions[prevAction].frames[prevFrame].bones[i].trans[j])*skelTime;


      for i:=0 to nodesNum-1 do
       with xState do
         currentPose.bones[i].quat:=q_lerp(Actions[prevAction].frames[prevFrame].bones[i].quat,
                                  Actions[nextAction].frames[nextFrame].bones[i].quat,
                                  skelTime);

    for i:=0 to nodesNum-1 do
     with xState do
     begin
       setRotationQuat(CurrentPose.bones[i].m_relative,CurrentPose.bones[i].quat);
       SetTranslation(CurrentPose.bones[i].m_relative,CurrentPose.bones[i].trans);
     end;




   for i:=0 to nodesNum-1 do
    with xState do
    if nodes[i].parent<>-1 then
      begin
       CurrentPose.bones[i].m_absolute:=CurrentPose.bones[nodes[i].parent
                                                           ].m_absolute;
       PostMultiply(CurrentPose.bones[i].m_absolute, CurrentPose.bones[i].m_relative);
       end
        else CurrentPose.bones[i].m_absolute:=CurrentPose.bones[i].m_relative

  end;



end;


procedure CopyBonesForShader(var xState:TSkelAnimState);
var i:integer;
begin

 for i := 0 to length(xState.CurrentPose.bones) - 1 do
  xState.shaderAbsoluteMat[i]:=xState.CurrentPose.bones[i].m_absolute.data;

end;


end.
