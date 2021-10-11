// Shader author: Tristan Dean (twixn@twixn.com) 
// c++ version avilable at www.codesampler.com
// Tranlation to Delphi by Georgy Moshkin
// WWW: http://www.igrodel.ru

unit unit1;

interface

uses Windows,
     dglOpengl,
     glbmpx,
     shader;

procedure unit1BeforeStart;
procedure unit1Render;
procedure unit1BeforeExit;

implementation

var
    testTexture: gluInt;    // �������� �����
    heightTexture: gluInt;  // ����� ����� �������� �����

    Shaders: array of GLhandleARB; // ������ ��� �������� ������ �� �������


    shader_testTexture: glInt; // ������ �� �������� �����
    shader_heightTexture: glInt; // ������ �� �������� � ������ �����
    shader_eye: glInt; // ������ �� ������� ������

    shader_tangent: glInt;  // ��� �������: ��������� ������� ��������� ��������
    shader_normal: glInt;   // � ��������� ������������
    shader_binormal: glInt;

    shader_Strength: glInt; // ��� ����������� �������� �������

var
 g_fSpinX:single; // ��� �������� ������
 g_fSpinY:single;
 mousePos:TPOINT;
 oldMousePos:TPOINT;

var
    ShaderWorks:boolean=true;



procedure unit1BeforeStart;
var vertex: GLhandleARB;
    fragment: GLhandleARB;
begin

 //------------------
 // �������� �������:

 loadTexture('.\textures\heightmap.hwl',heightTexture); // ����� �����
 loadTexture('.\textures\texturemap.hwl',testTexture);  // ������� ��������

 //-------------------
 // �������� ��������:

 // �������� ���������� � fragment-���� �������
  vertex := LoadShaderFromFile('.\shaders\vertex_shader.txt', GL_VERTEX_SHADER_ARB);
  fragment := LoadShaderFromFile('.\shaders\fragment_shader.txt', GL_FRAGMENT_SHADER_ARB);

  SetLength(Shaders, 1);

  // "��������" ��������
  Shaders[High(Shaders)] := LinkPrograms( [vertex, fragment ] );

  // �������� ������ �� UNIFORM ����������,
  // ����������� ������ �������:

  shader_testTexture:= glGetUniformLocationARB( Shaders[0], 'TestTexture' );
  shader_HeightTexture:= glGetUniformLocationARB( Shaders[0], 'HeightTexture' );
  shader_Eye:=glGetUniformLocationARB( Shaders[0], 'Eye' );
  shader_Tangent:=glGetUniformLocationARB( Shaders[0], 'Tangent' );
  shader_Normal:=glGetUniformLocationARB( Shaders[0], 'Normal' );
  shader_BiNormal:=glGetUniformLocationARB( Shaders[0], 'BiNormal' );

  shader_Strength:=glGetUniformLocationARB( Shaders[0], 'Strength' );


end;

procedure setShaderConstants;
begin

	// �������� ������� ������ �� �������� �����
	glUniform1iARB( shader_testTexture, 0);

  // �������� ������� ������ �� �������� � ������ �����
	glUniform1iARB( shader_heightTexture, 1);

  // �������� ������� ���������� ������ (���������)
	glUniform4fARB( shader_eye, 0.0, 0.0, 0.0, 1.0);

  // �������� �����������, ��������, ����������
  // (��� ����� ��������� - �� �������� �������
  // ������� ���-������ �������)
	glUniform4fARB( shader_tangent, 1.0, 0.0, 0.0, 0.0 );
	glUniform4fARB( shader_normal, 0.0, 0.0, 1.0, 0.0 );
	glUniform4fARB( shader_binormal, 0.0, 1.0, 0.0, 0.0 );

  // ��������� �� ������ (��������� �� ����� ����� ����� � �������)
  // ��� ��������� �������� �� true
  if false then
   glUniform1fARB( shader_strength, 1+sin(gettickcount/100) )
  else
   glUniform1fARB( shader_strength,1);

end;


procedure unit1Render;
var i:integer;
begin


 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
 glLoadIdentity();

	glTranslatef( 0.0, 0.0, -4.0 );

   // �������� ������

    oldMousePos:=mousePos;
    GetCursorPos(mousePos);

    g_fSpinX:=g_fSpinX+oldMousePos.X-MousePos.X;
    g_fSpinY:=g_fSpinY+oldMousePos.Y-MousePos.Y;

    glRotatef( -g_fSpinY, 1.0, 0.0, 0.0 );
    glRotatef( -g_fSpinX, 0.0, 1.0, 0.0 );


 // ���� ������� ��������, �� ...
 if ShaderWorks=true then
  begin
		glUseProgramObjectARB( Shaders[0] ); // ��������� �������
		setShaderConstants(); // �������� ������ �������
 end
  else
   glUseProgramObjectARB( 0 ); // ���� ������� �� �������� - ��������� ������



   glColor3f(1,1,1);

    glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, testTexture);

    glActiveTexture(GL_TEXTURE1);
		glBindTexture(GL_TEXTURE_2D, heightTexture);

                   for i:= 0 to 0 do
                                   begin
   // ������ �������
   glBegin(GL_QUADS);
    glTexCoord2f(0,0);
    glVertex3f(-1,-1,0);

    glTexCoord2f(1,0);
    glVertex3f(1,-1,0);

    glTexCoord2f(1,1);
    glVertex3f(1,1,0);

    glTexCoord2f(0,1);
    glVertex3f(-1,1,0);
   glEnd;


                            end;

  glFlush();                           // Flush The GL Rendering Pipeline

end;

procedure unit1BeforeExit;
begin
  // �������� ������� ��� ������
  glDeleteObjectARB( Shaders[0] );
end;

end.
