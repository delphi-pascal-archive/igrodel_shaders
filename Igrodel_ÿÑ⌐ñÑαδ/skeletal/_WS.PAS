{
 -------------------------------------------------------------------------------
 OpenGL 2D/3D switching system for TMT Pascal 4.01
 -------------------------------------------------------------------------------
 Version:  1.0a
 Date:     12/28/2002
 Author:   unknown
 Modifications by Georgy Moshkin
 ===============================================================================
}

unit _ws;

interface

uses dglOpengl;

procedure glOrthoMode;
procedure glPerspectiveMode;
procedure SetBounds(FRenderState:boolean);
procedure glInit(doOrthoMode:boolean);



var   SurfaceWidth:integer=640;
      SurfaceHeight:integer=480;
      ALeft:integer=0;
      ATop:integer=0;
      AWidth:integer=640;
      AHeight:integer=480;
      MaxDeapth:integer=5000;


implementation

//  This function changes our projection mode from 3D to 2D
//-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
procedure glOrthoMode;
begin
  glMatrixMode(GL_PROJECTION);  // Switch to the projection matrix
  glPushMatrix();               // Save current projection matrix
  glLoadIdentity();

  glOrtho(0, SurfaceWidth, SurfaceHeight, 0 , 1, -1);  // Change the projection matrix using an orthgraphic projection

  glMatrixMode(GL_MODELVIEW);  // Return to the modelview matrix
  glPushMatrix();              // Save the current modelview matrix
  glLoadIdentity();
end;

//  This function changes our returns our projection mode from 2D to 3D
//-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
procedure glPerspectiveMode;
begin
  glMatrixMode(GL_PROJECTION);  //Switch to projection matrix
  glPopMatrix();                // Restore the old projection matrix
  glMatrixMode(GL_MODELVIEW);   // Return to modelview matrix
  glPopMatrix();                // Restore old modelview matrix
end;


// SetBounds
//-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
procedure SetBounds(FRenderState:boolean);
begin
  glViewport(0, 0, AWidth, AHeight);    // Set the viewport for the OpenGL window
  glMatrixMode(GL_PROJECTION);        // Change Matrix Mode to Projection
  glLoadIdentity();                   // Reset View
  gluPerspective(75.0, SurfaceWidth/SurfaceHeight, 1.0, MaxDeapth);  // Do the perspective calculations. Last value = max clipping depth
  glMatrixMode(GL_MODELVIEW);         // Return to the modelview matrix

  IF (FRenderState) then begin
    glOrthoMode;
  end;
end;


//-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
procedure glInit(doOrthoMode:boolean);
begin
  SetBounds(doOrthoMode);
end;


//-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
procedure SetRenderState(FRenderState:boolean);
begin
  IF (FRenderState) then glOrthoMode
      else glPerspectiveMode;
end;


begin
end.