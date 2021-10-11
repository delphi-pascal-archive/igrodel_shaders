// http://www.cnt.ru/users/snab/tmt/
// OPENGL FONT UNIT FOR TMT PASCAL
// by Georgy Moshkin
// 2003
// v1.0

unit _font;

interface

uses _2d, dglOpengl, _bitop, glbmpx;

var fontTex:GLUINT;

procedure LoadFont;
procedure GLTEXTXY(x,y:integer;x1,y1:single;marazm:string);

implementation

function CreateTexture(Width, Height : Integer; pData : Pointer) : glUint;
var Texture : glUint;
begin
  glGenTextures(1, @Texture);
  glBindTexture(GL_TEXTURE_2D, Texture);
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);  {Texture blends with object background}

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST); { only first two can be used }
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST); { all of the above can be used }

(*
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); { only first two can be used }
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); { all of the above can be used }
*)

  glTexImage2D(GL_TEXTURE_2D, 0, 4, Width, Height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pData);

  result :=Texture;
end;

procedure putppz(i,j:integer;font:pointer);
var  PixelR : ^Byte;
     PixelG : ^Byte;
     PixelB : ^Byte;
     PixelA : ^Byte;
begin
  PixelR:=Pointer(Cardinal(font) + 4*(i*128 + j));
  PixelG:=Pointer(Cardinal(font) + 4*(i*128 + j)+1);
  PixelB:=Pointer(Cardinal(font) + 4*(i*128 + j)+2);
  PixelA:=Pointer(Cardinal(font) + 4*(i*128 + j)+3);
  PixelR^:=255;
  PixelG^:=255;
  PixelB^:=255;
  PixelA^:=255;
end;

procedure loadfont;
var  tempd:byte;
     fil:file of byte;
     font:pointer;
     i,j,k:integer;

begin
 GetMem(Font, 128*128*4);
 FillChar(Font^, 128*128*4, 0);          // Fill image with dark grey

 assignFile(fil,'8x8.fnt');
 reset(fil);

 for k:=0 to 255 do
  for i:=0 to 7 do
   begin
    read(fil,tempd);
    for j:=0 to 7 do
     if ReadBit(tempd,j) then putppz(i+(k div 16)*8,j+k*8-(k div 16)*128,font);
   end;

 closeFile(fil);
 FontTex:=CreateTexture(128, 128, Font);
end;

procedure GLTEXTXY(x,y:integer;x1,y1:single;marazm:string);
var i,j,k,l,m:integer;
begin
 glDisable(GL_LIGHTING);
// glColor4f(1,1,1,1);
 glEnable(GL_BLEND);
 glBlendFunc(GL_SRC_ALPHA, GL_ONE);
 // glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
 // glBlendFunc(GL_ONE,GL_ONE);
 glEnable(GL_TEXTURE_2D);
 glBindTexture(GL_TEXTURE_2D, FontTex);

 i:=8;
 j:=8;
 k:=1;
 m:=8;

 for l:=0 to length(Marazm)-1 do
  begin
   k:=ord(Marazm[l+1]);
   PreciseSprTx(
    0 + l*(m) + x*(i) + x1,
    0         + y*(j) + y1,
    m + l*(m) + x*(i) + x1,
    m         + y*(j) + y1,
     ( k*8-(k div 16)*128 ) / 128,
           ( (k div 16)*8 ) / 128,
   ( j+k*8-(k div 16)*128 ) / 128,
         ( i+(k div 16)*8 ) / 128);
  end;


 glDisable(GL_BLEND);  
end;

end.