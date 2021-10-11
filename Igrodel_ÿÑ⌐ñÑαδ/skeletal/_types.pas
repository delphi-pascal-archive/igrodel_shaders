// ========================================== //
// _types.pas                                 //
// ------------------------------------------ //
// Author: Georgy Moshkin (tmtlib@narod.ru)   //
// ========================================== //

unit _types;

interface

uses math;

type TVector4s = array[0..3] of single;
     TVector3s = array[0..2] of single;
     TVector2s = array[0..1] of single;

type TMatrix4x4raw = packed array [0..3, 0..3] of Single;

type TMatrix4x4s = object
                    data:TMatrix4x4raw;
                   end;

type TQuaternion = object
                    data: TVector4s;
                   end;

function angle2quat(angles:TVector3s):TQuaternion;
procedure quatInverse(var quat:TQuaternion);
function slerp(q1,q2:TQuaternion; interp:single):TQuaternion;
function Q_Lerp(q1, q2: TQuaternion; t: single): TQuaternion;
Procedure setRotationQuat(var Matrix:TMatrix4x4s;quat:TQuaternion);

procedure setrotationradians(var matrix:TMatrix4x4s;angles:TVector3s);
procedure settranslation(var matrix:TMatrix4x4s;trans:TVector3s);
procedure PostMultiply(var m1:TMatrix4x4s; m2:TMatrix4x4s);
function transform3(this_vector:TVector3s;matrix:Tmatrix4x4s):TVector3s;

Procedure InverseRotateVect(var pVect:TVector3s; matrix:TMatrix4x4s);
Procedure InverseTranslateVect(var pVect:TVector3s; matrix:TMatrix4x4s);


implementation

function angle2quat(angles:TVector3s):TQuaternion;
var angle             : single;
    sr,sp,sy,cr,cp,cy : single;
    crcp,srsp         : single;

begin
     angle:=angles[2]*0.5;
     sy:=sin( angle );
     cy:=cos( angle );
     angle:= angles[1]*0.5;
     sp:= sin( angle );
     cp:= cos( angle );
     angle:= angles[0]*0.5;
     sr:= sin( angle );
     cr:= cos( angle );

     crcp:= cr*cp;
     srsp:= sr*sp;

     result.data[0]:=sr*cp*cy-cr*sp*sy;
     result.data[1]:=cr*sp*cy+sr*cp*sy;
     result.data[2]:=crcp*sy-srsp*cy;
     result.data[3]:=crcp*cy+srsp*sy;
end;

procedure quatInverse(var quat:TQuaternion);
begin
with quat do
 begin
  data[0]:=-data[0];
  data[1]:=-data[1];
  data[2]:=-data[2];
  data[3]:=-data[3];
 end;
end;


function slerp(q1,q2:TQuaternion; interp:single):TQuaternion;

var i      : integer;
    a,b    : single;

    cosom       : single;
    sclq1,sclq2 : single;
    omega,sinom : single;

begin
     a:=0;
     b:=0;

     for i:=0 to 3 do begin
                           a:=a+( q1.data[i]-q2.data[i] )*( q1.data[i]-q2.data[i] );
                           b:=b+( q1.data[i]+q2.data[i] )*( q1.data[i]+q2.data[i] );
                      end;

     if ( a > b ) then quatInverse(q2);

     cosom:=q1.data[0]*q2.data[0]+q1.data[1]*q2.data[1]
           +q1.data[2]*q2.data[2]+q1.data[3]*q2.data[3];

     if (( 1.0+cosom ) > 0.00000001 ) then begin{#}
     if (( 1.0-cosom ) > 0.00000001 ) then begin
                                                omega:= arccos( cosom );
                                                sinom:= sin( omega );
                                                sclq1:= sin(( 1.0-interp )*omega )/sinom;
                                                sclq2:= sin( interp*omega )/sinom;
                                           end else
                                                   begin
                                                        sclq1:= 1.0-interp;
                                                        sclq2:= interp;
                                                   end;
                                           for i:=0 to 3 do
                                           result.data[i]:=sclq1*q1.data[i]
                                                           +sclq2*q2.data[i];
                                           end{#} else
                                                    with result do
                                                      begin
                                                           data[0]:=-q1.data[1];
                                                           data[1]:=q1.data[0];
                                                           data[2]:=-q1.data[3];
                                                           data[3]:=q1.data[2];

                                                           sclq1:= sin(( 1.0-interp )*0.5*PI );
                                                           sclq2:= sin( interp*0.5*PI );

                                                           for i:=0 to 2 do
                                                           data[i]:=sclq1*q1.data[i]
                                                                     +sclq2*data[i];
                                                      end;

                                                  end;




procedure setrotationradians(var matrix:TMatrix4x4s;angles:TVector3s);
var cr,sr,cp,sp,cy,sy,
    srsp,crsp         : single;
begin
     cr:= cos(angles[0]);
     sr:= sin(angles[0]);
     cp:= cos(angles[1]);
     sp:= sin(angles[1]);
     cy:= cos(angles[2]);
     sy:= sin(angles[2]);

     with matrix do
      begin
       data[0][0]:=cp*cy;
       data[0][1]:=cp*sy;
       data[0][2]:=-sp
      end;

     srsp:= sr*sp;
     crsp:= cr*sp;

   with matrix do
    begin
     data[1][0]:= srsp*cy-cr*sy;
     data[1][1]:= srsp*sy+cr*cy;
     data[1][2]:= sr*cp;

     data[2][0]:= crsp*cy+sr*sy;
     data[2][1]:= crsp*sy-sr*cy;
     data[2][2]:= cr*cp;
    end;

end;

procedure settranslation(var matrix:TMatrix4x4s;trans:TVector3s);
begin
 matrix.data[3,0]:=trans[0]; // 12
 matrix.data[3,1]:=trans[1]; // 13
 matrix.data[3,2]:=trans[2]; // 14
end;

Procedure InverseRotateVect(var pVect:TVector3s; matrix:TMatrix4x4s);
var temp : TVector3s{4};
begin
     temp:=pVect;

     with matrix do
      begin
       temp[0]:= pVect[0]*data[0,0]+pVect[1]*data[0,1]+pVect[2]*data[0,2];
       temp[1]:= pVect[0]*data[1,0]+pVect[1]*data[1,1]+pVect[2]*data[1,2];
       temp[2]:= pVect[0]*data[2,0]+pVect[1]*data[2,1]+pVect[2]*data[2,2];
      end;

     pVect:=temp;
end;

////////////////////////////////////////////////////////////////////////////////
Procedure InverseTranslateVect(var pVect:TVector3s; matrix:TMatrix4x4s);
var temp : TVector3s{4};
begin
     temp:=pVect;

     temp[0]:= pVect[0]-matrix.data[3,0];
     temp[1]:= pVect[1]-matrix.data[3,1];
     temp[2]:= pVect[2]-matrix.data[3,2];

     pVect:=temp;
end;

////////////////////////////////////////////////////////////////////////////////
function transform3(this_vector:TVector3s;matrix:Tmatrix4x4s):TVector3s;
var our_vector:TVector3s;
begin
  with matrix do
   begin
    result[0]:= this_vector[0]*data[0,0]+this_vector[1]*data[1,0]+this_vector[2]*data[2,0]+data[3,0];
    result[1]:= this_vector[0]*data[0,1]+this_vector[1]*data[1,1]+this_vector[2]*data[2,1]+data[3,1];
    result[2]:= this_vector[0]*data[0,2]+this_vector[1]*data[1,2]+this_vector[2]*data[2,2]+data[3,2];
   end;
end;


Procedure setRotationQuat(var Matrix:TMatrix4x4s;quat:TQuaternion);
begin

with Matrix do
  begin
     data[0,0]:= ( 1.0 - 2.0*quat.data[1]*quat.data[1] - 2.0*quat.data[2]*quat.data[2]);
     data[0,1]:= ( 2.0*quat.data[0]*quat.data[1] + 2.0*quat.data[3]*quat.data[2] );
     data[0,2]:= ( 2.0*quat.data[0]*quat.data[2] - 2.0*quat.data[3]*quat.data[1] );

     data[1,0]:= ( 2.0*quat.data[0]*quat.data[1] - 2.0*quat.data[3]*quat.data[2] );
     data[1,1]:= ( 1.0 - 2.0*quat.data[0]*quat.data[0] - 2.0*quat.data[2]*quat.data[2] );
     data[1,2]:= ( 2.0*quat.data[1]*quat.data[2] + 2.0*quat.data[3]*quat.data[0] );

     data[2,0]:= ( 2.0*quat.data[0]*quat.data[2] + 2.0*quat.data[3]*quat.data[1] );
     data[2,1]:= ( 2.0*quat.data[1]*quat.data[2] - 2.0*quat.data[3]*quat.data[0] );
     data[2,2]:= ( 1.0 - 2.0*quat.data[0]*quat.data[0] - 2.0*quat.data[1]*quat.data[1] );
  end;

end;

////////////////////////////////////////////////////////////////////////////////
procedure PostMultiply(var m1:TMatrix4x4s; m2:TMatrix4x4s);
var temp:TMatrix4x4s;
begin

// 0 [0,0]
// 1 [0,1]
// 2 [0,2]
// 3 [0,3]

// 4 [1,0]
// 5 [1,1]
// 6 [1,2]
// 7 [1,3]

// 8 [2,0]
// 9 [2,1]
// 10 [2,2]
// 11 [2,3]

// 12 [3,0]
// 13 [3,1]
// 14 [3,2]
// 15 [3,3]

     temp.data[0,0]:= m1.data[0,0]*m2.data[0,0] + m1.data[1,0]*m2.data[0,1] + m1.data[2,0]*m2.data[0,2];
     temp.data[0,1]:= m1.data[0,1]*m2.data[0,0] + m1.data[1,1]*m2.data[0,1] + m1.data[2,1]*m2.data[0,2];
     temp.data[0,2]:= m1.data[0,2]*m2.data[0,0] + m1.data[1,2]*m2.data[0,1] + m1.data[2,2]*m2.data[0,2];
     temp.data[0,3]:= 0;

     temp.data[1,0]:= m1.data[0,0]*m2.data[1,0] + m1.data[1,0]*m2.data[1,1] + m1.data[2,0]*m2.data[1,2];
     temp.data[1,1]:= m1.data[0,1]*m2.data[1,0] + m1.data[1,1]*m2.data[1,1] + m1.data[2,1]*m2.data[1,2];
     temp.data[1,2]:= m1.data[0,2]*m2.data[1,0] + m1.data[1,2]*m2.data[1,1] + m1.data[2,2]*m2.data[1,2];
     temp.data[1,3]:= 0;

     temp.data[2,0]:= m1.data[0,0]*m2.data[2,0] + m1.data[1,0]*m2.data[2,1] + m1.data[2,0]*m2.data[2,2];
     temp.data[2,1]:= m1.data[0,1]*m2.data[2,0] + m1.data[1,1]*m2.data[2,1] + m1.data[2,1]*m2.data[2,2];
     temp.data[2,2]:= m1.data[0,2]*m2.data[2,0] + m1.data[1,2]*m2.data[2,1] + m1.data[2,2]*m2.data[2,2];
     temp.data[2,3]:= 0;

     temp.data[3,0]:= m1.data[0,0]*m2.data[3,0] + m1.data[1,0]*m2.data[3,1] + m1.data[2,0]*m2.data[3,2] + m1.data[3,0];
     temp.data[3,1]:= m1.data[0,1]*m2.data[3,0] + m1.data[1,1]*m2.data[3,1] + m1.data[2,1]*m2.data[3,2] + m1.data[3,1];
     temp.data[3,2]:= m1.data[0,2]*m2.data[3,0] + m1.data[1,2]*m2.data[3,1] + m1.data[2,2]*m2.data[3,2] + m1.data[3,2];
     temp.data[3,3]:= 1;

     m1:=temp;
end;




function Q_Add(q1, q2: TQuaternion): TQuaternion;
begin
  Result.data[0] := q1.data[0] + q2.data[0];
  Result.data[1] := q1.data[1] + q2.data[1];
  Result.data[2] := q1.data[2] + q2.data[2];
  Result.data[3] := q1.data[3] + q2.data[3];
end;

function Q_Sub(q1, q2: TQuaternion): TQuaternion;
begin
  Result.data[0] := q1.data[0] - q2.data[0];
  Result.data[1] := q1.data[1] - q2.data[1];
  Result.data[2] := q1.data[2] - q2.data[2];
  Result.data[3] := q1.data[3] - q2.data[3];
end;

function Q_Dot(q1, q2: TQuaternion): single;
begin
  Result := q1.data[0] * q2.data[0] + q1.data[1] * q2.data[1] + q1.data[2] * q2.data[2] + q1.data[3] * q2.data[3];
end;

function Q_Mult(q: TQuaternion; d: single): TQuaternion;
begin
  Result.data[0] := q.data[0] * d;
  Result.data[1] := q.data[1] * d;
  Result.data[2] := q.data[2] * d;
  Result.data[3] := q.data[3] * d;
end;

function Q_Lerp(q1, q2: TQuaternion; t: single): TQuaternion;
begin
  if Q_Dot(q1, q2) < 0 then
    Result := Q_Sub(q1, Q_Mult(Q_Add(q2, q1), t))
  else
    Result := Q_Add(q1, Q_Mult(Q_Sub(q2, q1), t));
end;





end.
