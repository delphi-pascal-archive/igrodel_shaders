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
    testTexture: gluInt;    // текстура стены
    heightTexture: gluInt;  // карта высот текстуры стены

    Shaders: array of GLhandleARB; // массив для хранения ссылок на шейдеры


    shader_testTexture: glInt; // ссылка на текстуру стены
    shader_heightTexture: glInt; // ссылка на текстуру с картой высот
    shader_eye: glInt; // ссылка на позицию камеры

    shader_tangent: glInt;  // три вектора: описывают систему координат текстуры
    shader_normal: glInt;   // в трёхмерном пространстве
    shader_binormal: glInt;

    shader_Strength: glInt; // для регулировки мощности эффекта

var
 g_fSpinX:single; // для вращения мышкой
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
 // Загрузка текстур:

 loadTexture('.\textures\heightmap.hwl',heightTexture); // карта высот
 loadTexture('.\textures\texturemap.hwl',testTexture);  // обычная текстура

 //-------------------
 // Загрузка шейдеров:

 // загрузка вершинного и fragment-ного шейдера
  vertex := LoadShaderFromFile('.\shaders\vertex_shader.txt', GL_VERTEX_SHADER_ARB);
  fragment := LoadShaderFromFile('.\shaders\fragment_shader.txt', GL_FRAGMENT_SHADER_ARB);

  SetLength(Shaders, 1);

  // "линковка" программ
  Shaders[High(Shaders)] := LinkPrograms( [vertex, fragment ] );

  // получаем ссылки на UNIFORM переменные,
  // находящиеся внутри шейдера:

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

	// Передача шейдеру ссылки на текстуру стены
	glUniform1iARB( shader_testTexture, 0);

  // Передача шейдеру ссылки на текстуру с картой высот
	glUniform1iARB( shader_heightTexture, 1);

  // Передача шейдеру координаты камеры (упрощенно)
	glUniform4fARB( shader_eye, 0.0, 0.0, 0.0, 1.0);

  // Передача касательных, нормалей, бинормалей
  // (ещё более упрощенно - на практике придётся
  // сделать что-нибудь покруче)
	glUniform4fARB( shader_tangent, 1.0, 0.0, 0.0, 0.0 );
	glUniform4fARB( shader_normal, 0.0, 0.0, 1.0, 0.0 );
	glUniform4fARB( shader_binormal, 0.0, 1.0, 0.0, 0.0 );

  // Пульсация по синусу (домножаем на число карту высот в шейдере)
  // для включения замените на true
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

   // вращение мышкой

    oldMousePos:=mousePos;
    GetCursorPos(mousePos);

    g_fSpinX:=g_fSpinX+oldMousePos.X-MousePos.X;
    g_fSpinY:=g_fSpinY+oldMousePos.Y-MousePos.Y;

    glRotatef( -g_fSpinY, 1.0, 0.0, 0.0 );
    glRotatef( -g_fSpinX, 0.0, 1.0, 0.0 );


 // Если шейдеры включены, то ...
 if ShaderWorks=true then
  begin
		glUseProgramObjectARB( Shaders[0] ); // ВКЛЮЧЕНИЕ шейдера
		setShaderConstants(); // передача данных шейдеру
 end
  else
   glUseProgramObjectARB( 0 ); // Если галочка не отмечена - выключаем шейдер



   glColor3f(1,1,1);

    glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, testTexture);

    glActiveTexture(GL_TEXTURE1);
		glBindTexture(GL_TEXTURE_2D, heightTexture);

                   for i:= 0 to 0 do
                                   begin
   // рисуем квадрат
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
  // удаление шейдера при выходе
  glDeleteObjectARB( Shaders[0] );
end;

end.
