{
 -------------------------------------------------------------------------------
 OpenGL 2D FONT/SPRITE for TMT Pascal 4.01
 -------------------------------------------------------------------------------
 Version:  1.1a
 Date:     2003
 Author:   Georgy Moshkin
 Homepage: http://www.cnt.ru/users/snab/tmt/
 ===============================================================================
}


// History:
// 1.1a small fix
// 1.1 - small fixes
// 1.0 - first release of 2D sprite engine

unit _2d;
interface
uses dglOpengl;

var scrWidth,scrHeight:integer;
    fntWidth,fntHeight:integer;
(*const scrWidth=632; // Change this
      scrHeight=453;*)
Procedure SprUseSize(xs,ys:integer);
Procedure DrawSprXY(x,y,x2,y2,Rot:single);
Procedure GL_TXT(str:string;x,y,width,height:single);
Procedure GL_WRITE(str:string;x,y:single);
Procedure PrecisePutPixel(x,y:integer;r,g,b,a:byte);
Procedure PreciseSpr(x,y,x2,y2:single);
Procedure PreciseSprTx(x,y,x2,y2,u,v,u2,v2:single);

Procedure x2Dmode(w,h,m:integer);
Procedure xRestore;

implementation

Procedure x2Dmode(w,h,m:integer);
begin
  glMatrixMode(GL_PROJECTION);  // Switch to the projection matrix
  glPushMatrix();               // Save current projection matrix
  glLoadIdentity();

  case m of
  0:glOrtho(0, w, h, 0 , 1000, -1000);
  1:glOrtho(-w/2, w/2, -h/2, h/2 , 1000, -1000);  // Change the projection matrix using an orthgraphic projection
  end;

  glMatrixMode(GL_MODELVIEW);  // Return to the modelview matrix
  glPushMatrix();              // Save the current modelview matrix
  glLoadIdentity();
end;

Procedure xRestore;
begin
  glMatrixMode(GL_PROJECTION);  //Switch to projection matrix
  glPopMatrix();                // Restore the old projection matrix
  glMatrixMode(GL_MODELVIEW);   // Return to modelview matrix
  glPopMatrix();
end;



Procedure SprUseSize(xs,ys:integer);
begin
scrWidth:=xs;
scrHeight:=ys;
end;

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Procedure PrecisePutPixel(x,y:integer;r,g,b,a:byte);
begin
//  glOrthoMode;
//  glPushAttrib(GL_ALL_ATTRIB_BITS);

  glDisable(GL_TEXTURE_2D);
  glDisable(GL_LIGHTING);
      glPointSize(15);
      glBegin(GL_POINTS);
    glColor4b(r,g,b,a);
    glVertex2f(x, scrHeight-y);
      glEnd();

//  glPopAttrib;

//  glPerspectiveMode;
end;

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Procedure PreciseSpr(x,y,x2,y2:single);
begin

//  glOrthoMode;

      glBegin(GL_QUADS);
glTexCoord2f(0,0);glVertex2f(x,y+y2);
glTexCoord2f(1,0);glVertex2f(x+x2,y+y2);
glTexCoord2f(1,1);glVertex2f(x+x2, y);
glTexCoord2f(0,1);glVertex2f(x, y);
      glEnd();

//      glPerspectiveMode;
end;


Procedure PreciseSprTx(x,y,x2,y2,u,v,u2,v2:single);
begin
//  glOrthoMode;


      glBegin(GL_QUADS);
        glTexCoord2f( u, v);glVertex2f(x, y);
        glTexCoord2f( u, v2);glVertex2f(x, y2);
        glTexCoord2f( u2, v2);glVertex2f(x2,y2);
        glTexCoord2f( u2, v);glVertex2f(x2,y);
      glEnd();

//  glPerspectiveMode;
end;


// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Procedure DrawSprXYtx(x,y,x2,y2,Rot,u,v,u2,v2:single);
begin

//  glOrthoMode;
      glTranslatef(x, y, {zOrder}0);

      glRotatef(Rot,0,0,-1);
      glTranslatef(-x2/2, {- Window.CaptionBarHeight}{scrHeight}-y2/2, {zOrder}0);

      glBegin(GL_QUADS);
        glTexCoord2f( u, v2);     glVertex2f(0, 0);
        glTexCoord2f( u, v);     glVertex2f(0, y2);
        glTexCoord2f( u2,v);     glVertex2f(x2,y2);
        glTexCoord2f( u2,v2);     glVertex2f(x2, 0);
      glEnd();

//      glPerspectiveMode;
end;


// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Procedure DrawSprXY(x,y,x2,y2,Rot:single);
begin

DrawSprXYtx(x,y,x2,y2,Rot,0,0,1,1);

end;

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Procedure GL_TXT(str:string;x,y,width,height:single);
var i:byte;
    ch:char;
    az,kord:glfloat;
begin
  for i:=1 to length(str) do
  begin
    ch:=str[i];
    if ch<>' ' then
    begin
        kord:=10/1024;
    az:=kord*(ord(ch)-33);

 DrawSprXYtx(x+(i-1)*width,y,width,height,0,az,0,az+kord,1);
   end;
   end;
end;

Procedure GL_WRITE(str:string;x,y:single);
begin
GL_TXT(str,x,y,fntwidth,fntheight);
end;

begin // Default screen size (used to calculate sprites) compatible to 1.1
scrWidth:=640;
scrHeight:=480;
fntwidth:=8;
fntheight:=16;
end.