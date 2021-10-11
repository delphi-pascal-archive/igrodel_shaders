// Shader author: Tristan Dean (twixn@twixn.com)
// c++ version avilable at www.codesampler.com
// Tranlation to Delphi by Georgy Moshkin
// WWW: http://www.igrodel.ru

unit unit1;

interface

uses Windows,
     dglOpengl,
     glbmpx,
     shader,
     _model,
     _smdloader,
     _smd2loader,
     _render,
     _types,
     _mmtime,
     _font,
     _ws;

// ��� �������� ����� ������� ������� �� example.dpr
var unit1keydown: array[0..255] of Boolean;


procedure unit1BeforeStart;
procedure unit1Render;
procedure unit1BeforeExit;

implementation

var
    Shaders: array of GLhandleARB; // ������ ��� �������� ������ �� �������


    // ������ �� ��������� ������ � ��������� ������
    shader_boneMat: glInt;

    // ������ �� ������ � ��������� �������
    shader_myTexture:array[0..7] of glInt;

var models:TModels; // ������ � �������� � ������� ��������� ��������

// ������ � ����������� ������� ��������� ��������
// (� ������ ������ ����� 301 ��������)
var skelstate:array[0..300-1] of TSkelAnimState;



var
    ShaderWorks:boolean=true;

function IntToStr(Num : Integer) : String;  // using SysUtils increase file size by 100K
begin
  Str(Num, result);
end;


procedure unit1BeforeStart;
var vertex: GLhandleARB;
    fragment: GLhandleARB;
    i: integer;
begin

  // �������� ������ 8x8, ����������������� ��
  // ����������� ������������ ����� DOS
  LoadFont;

  // ��������� ��������� � ����������� ������
  vertex := LoadShaderFromFile('.\shaders\vertex12.txt', GL_VERTEX_SHADER_ARB);
  fragment := LoadShaderFromFile('.\shaders\fragment.txt', GL_FRAGMENT_SHADER_ARB);

  SetLength(Shaders, 1);

  // �������� ������ �� �������� ��������� ���������
  Shaders[0]:=LinkPrograms([vertex,fragment]);


  // �������� ������ ��� ������ ������� � ��������
  shader_boneMat := glGetUniformLocationARB(Shaders[0], PGLcharARB(PChar('boneMat')));

  for  i:= 0 to 7 do
  shader_myTexture[i] := glGetUniformLocationARB(Shaders[0], PGLcharARB(PChar('myTexture'+intToStr(i))));

  // ��������� ������ � �������� (Half-Life 1)

  smd_AddModel(models,'.\models\c_marine.smd');
  smd_AddAnimation(models,'.\models\run.smd');


  // Half-Life 2 (beta version loader)
//  smd2_AddModel(models,'.\hl2models\police.smd');
//  smd2_AddAnimation(models,'.\hl2models\deploy.smd');


  // ��������� �������� ������
  LoadTextures(models,'.\textures\');

  // �������������� ��������� ��������
  PrepareSkeletalAnimation(models);


  randomize;
  // ��� ������� ��������� ������ ��������� ����� ���������� �����
  for i := 0 to length(skelstate) - 1 do
    begin
     ResetSkelAnimState(SkelState[i],Models[0].skelanim.nodesNum);
     skelState[i].prevFrame:=0;
     skelState[i].nextFrame:=random(21); // ����� ���������� �����
     skelState[i].prevAction:=0;
     skelState[i].nextAction:=0;
     skelState[i].skelTime:=random(100)/100; // ��������� ����� ��������
    end;

 // �������������� �����������-������   
 mmtimeAlloc;

 makeVBO(Models[0]);


end;

var j:integer=10;

procedure unit1Render;
var i:integer;
begin


 // ������� ������ � ������
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
 glLoadIdentity();

 // ��������� ������
 gluLookAt(0,-250,100, // ������ �������
           0,0,0,    // ���� �������
           0,0,1);    // ��� � ��� ����

    glRotatef(gettickcount/100,0,0,1);
 // ������ ������� ���������
 // �������������� �����, �����
 // ��������� ��������� �������� �
 // Render-�.

 // ������� ������ �����, ��������� ����� �������
 BlenderElapsed:=mmtimeElapsed;

 glUseProgramObjectARB(Shaders[0]); // �������� ������ Shaders[0]

     if unit1keydown[VK_ADD]=true then j:=j+1;
     if unit1keydown[VK_SUBTRACT]=true then j:=j-1;

     if j<1 then j:=1;
     if j>300 then j:=300;
        

     // ���������� ������� ������� �������
     for i:= 0 to 7 do
      glUniform1iARB(shader_myTexture[i],i);

     // ������ glBindTexture ��� ������������ ������� 
     for i:= 0 to 7 do
      begin
       glActiveTexture(GL_TEXTURE0+i);
     	 glBindTexture(GL_TEXTURE_2D, i+1);
      end;

     for i := 0 to j- 1 do
      begin


     AnimateModel(models,
                0,
                0,
                1,
                skelState[i], // ������ ������ ���������� �������� i-���� ���������
                false);


     CopyBonesForShader(skelState[i]); // �������� ������� ������ � ��������� ������

     // ���������� ������� ������ �������
     glUniformMatrix4fv( shader_boneMat, 32, false,@skelState[i].shaderAbsoluteMat);


       glPushMatrix;
       glTranslatef((30+5*i)*sin((j+6.28)*i/j),
                    (30+5*i)*cos((j+6.28)*i/j),0); // ��������������� ������
       renderVBO(models[0]);
       glPopMatrix;


      end;


 // ���������� ��������, ����� ��� �� ������ �� ����� ������
 glUseProgramObjectARB(0);

 glColor3f(1,1,1);
 glActiveTexture(GL_TEXTURE0);

 // ����� ������
 // - - -
 glOrthoMode(); // ������� � ��������������� ��������
 glDisable(GL_DEPTH_TEST); // ���������� ����� �������
 GLTEXTXY(2,1,0,0,'Optimized skeletal animation v1.2');
 GLTEXTXY(2,2,0,0,'Models rendered: '+intToStr(j));
 GLTEXTXY(2,3,0,0,'Use keys: +/- to add/decrease models count');

 glEnable(GL_DEPTH_TEST);
 glPerspectiveMode; // ������� ������� � 3D �����


  glFlush();                           // Flush The GL Rendering Pipeline

end;

procedure unit1BeforeExit;
begin
  // �������� �����������-�������
  mmtimeFree;

  // �������� ������� ��� ������
  glDeleteObjectARB( Shaders[0] );

  glDeleteBuffersARB(1, @Models[0].VBOlink);

end;

end.
