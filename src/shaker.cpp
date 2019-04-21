/*

Shaker is a GLSL sandbox for the desktop.

You need to link OpenGL and SDL2 in order to build Shaker. The following command should suffice 
for most systems and compilers.

	clang++ shaker.cpp -o shaker -O3 -lSDL2 -lGL

On Apple systems, you may need to use this command instead, based on your compiler vendor.

	clang++ shaker.cpp -o shaker -O3 -lSDL2 -framework OpenGL

I don't use GNU/Linux or Windows, so I wouldn't know where to find the OpenGL or SDL include 
files. You'll probably have to modify the include paths. Other than that, Shaker is (probably) 
cross-compatible.

Once you have compiled Shaker successfully, it is trivial to use it. Simply pass a filename as an
argument to Shaker. You can optionally pass a width and a height (you must specify both if you are
to specify any).

	./shaker fragment.glsl

or, this is also valid

	./shaker fragment.glsl 800 600

Shaker requires a machine that supports a minimum of OpenGL 3.2 Core. This is basically almost 
every machine. I chose to use OpenGL 3.2 Core for reasons specific to my machine.

Shaker is licensed under the GNU GPLv3. SDL2 is licensed under the zlib license.

*/

#include <vector>
#include <utility>
#include <sstream>
#include <fstream>
#include <iostream>

#include <SDL2/SDL.h>

/*
   use 1 if you want to use vsinc (around 60 fps, following display refresh),
   else 0  (unlimited fps)
*/

#define SHAKER_VSINC 0

#define DEFAULT_WIDTH  1280
#define DEFAULT_HEIGHT  720

/*

For some reason, Apple has deprecated OpenGL since macOS 10.14. However, the API still functions
perfectly, Apple has just dropped support for updating it.

*/



#define GL_SILENCE_DEPRECATION

#ifdef Linux
#include <iostream>
/*  mandatory */
#define GL3_PROTOTYPES 1
#define GL_GLEXT_PROTOTYPES
#include <GL/glew.h>
#include <GL/gl.h>

/* adapt to your needs */
#define MY_GL_MAJOR_VERSION  4
#define MY_GL_MINOR_VERSION  5

#else
/*  Windows or maybe Mac OS X*/
#define MY_GL_MAJOR_VERSION  3
#define MY_GL_MINOR_VERSION  2
#include <OpenGL/GL3.h>
#endif


static int gl_w = DEFAULT_WIDTH;
static int gl_h = DEFAULT_HEIGHT;


/*

Vertex shader.

*/

const char gl_array_vertex_shader_source[] = 
{
    0x23, 0x76, 0x65, 0x72, 0x73, 0x69, 0x6f, 0x6e, 0x20, 0x33, 0x33, 0x30,
    0x20, 0x63, 0x6f, 0x72, 0x65, 0x0a, 0x0a, 0x6c, 0x61, 0x79, 0x6f, 0x75,
    0x74, 0x20, 0x28, 0x6c, 0x6f, 0x63, 0x61, 0x74, 0x69, 0x6f, 0x6e, 0x20,
    0x3d, 0x20, 0x30, 0x29, 0x20, 0x69, 0x6e, 0x20, 0x76, 0x65, 0x63, 0x33,
    0x20, 0x5f, 0x5f, 0x70, 0x6f, 0x73, 0x3b, 0x0a, 0x0a, 0x76, 0x6f, 0x69,
    0x64, 0x20, 0x6d, 0x61, 0x69, 0x6e, 0x28, 0x29, 0x0a, 0x7b, 0x0a, 0x09,
    0x67, 0x6c, 0x5f, 0x50, 0x6f, 0x73, 0x69, 0x74, 0x69, 0x6f, 0x6e, 0x20,
    0x3d, 0x20, 0x76, 0x65, 0x63, 0x34, 0x28, 0x5f, 0x5f, 0x70, 0x6f, 0x73,
    0x2e, 0x78, 0x2c, 0x20, 0x5f, 0x5f, 0x70, 0x6f, 0x73, 0x2e, 0x79, 0x2c,
    0x20, 0x5f, 0x5f, 0x70, 0x6f, 0x73, 0x2e, 0x7a, 0x2c, 0x20, 0x31, 0x2e,
    0x30, 0x66, 0x29, 0x3b, 0x0a, 0x7d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

const char* gl_vertex_shader_source = (const char*)gl_array_vertex_shader_source;

/*

Fragment shader header.

*/

const char gl_array_fragment_shader_header[] = 
{
	0x23, 0x76, 0x65, 0x72, 0x73, 0x69, 0x6f, 0x6e, 0x20, 0x33, 0x33, 0x30,
	0x20, 0x63, 0x6f, 0x72, 0x65, 0x0a, 0x0a, 0x6f, 0x75, 0x74, 0x20, 0x76,
	0x65, 0x63, 0x34, 0x20, 0x67, 0x6c, 0x78, 0x5f, 0x46, 0x72, 0x61, 0x67,
	0x43, 0x6f, 0x6c, 0x6f, 0x72, 0x3b, 0x0a, 0x0a, 0x75, 0x6e, 0x69, 0x66,
	0x6f, 0x72, 0x6d, 0x20, 0x76, 0x65, 0x63, 0x32, 0x20, 0x67, 0x6c, 0x78,
	0x5f, 0x52, 0x65, 0x73, 0x6f, 0x6c, 0x75, 0x74, 0x69, 0x6f, 0x6e, 0x3b,
	0x0a, 0x0a, 0x75, 0x6e, 0x69, 0x66, 0x6f, 0x72, 0x6d, 0x20, 0x66, 0x6c,
	0x6f, 0x61, 0x74, 0x20, 0x67, 0x6c, 0x78, 0x5f, 0x54, 0x69, 0x6d, 0x65,
	0x3b, 0x0a, 0x0a, 0x23, 0x64, 0x65, 0x66, 0x69, 0x6e, 0x65, 0x20, 0x67,
	0x6c, 0x78, 0x5f, 0x46, 0x72, 0x61, 0x67, 0x43, 0x6f, 0x6f, 0x72, 0x64,
	0x20, 0x67, 0x6c, 0x5f, 0x46, 0x72, 0x61, 0x67, 0x43, 0x6f, 0x6f, 0x72,
	0x64, 0x0a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

const char* gl_fragment_shader_header = (const char*)gl_array_fragment_shader_header;

/*

Load std::string from file.

*/

std::string loadfile(std::string path)
{
std::ifstream _in_file(path);

if (!_in_file.is_open())
{
std::cout << "Could not load \"" << path << "\"." << std::endl;

exit(3);
}

std::stringstream _str_buffer;

_str_buffer << _in_file.rdbuf() << "\0";

return _str_buffer.str();
}

/*

Entry point.

*/

int main(int argc, char** argv)
{
    /*
        Parse command line input.
    */

    const char* usr_fragment_path;

    if (argc == 2)
    {
        usr_fragment_path = argv[1];
    }
    else if (argc == 4)
    {
        gl_w = atoi(argv[2]);
        gl_h = atoi(argv[3]);

        usr_fragment_path = argv[1];
    }
    else
    {
        std::cout << "Usage: shaker <fragment-path> [width, height]" << std::endl;
        exit(7);
    }

    /*
        Initialize SDL2.
    */

    if (SDL_Init(SDL_INIT_EVERYTHING) < 0)
    {
        std::cout << "Could not initialize SDL." << std::endl;
        exit(1);
    }


    SDL_Window* sdl_window = SDL_CreateWindow
    (
        (std::string("Shaker - ") + usr_fragment_path).c_str(),
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
        gl_w, gl_h,
        SDL_WINDOW_OPENGL | SDL_WINDOW_ALLOW_HIGHDPI | SDL_WINDOW_RESIZABLE
    );

    if (sdl_window == NULL)
    {
        std::cout << "Could not create a SDL_Window." << std::endl;
        exit(2);
    }

    /*
        Request OpenGL 3.2.
    */

    int gl_success = 0;

    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);

    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, MY_GL_MAJOR_VERSION);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, MY_GL_MINOR_VERSION);

    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);

    /*
        Initialize OpenGL.
    */

    SDL_GLContext gl_context = SDL_GL_CreateContext(sdl_window);

    if (gl_context == NULL)
    {
        std::cout << "Could not create a SDL_GLContext." << std::endl;
        exit(2);
    }

#ifdef Linux
        glewExperimental = GL_TRUE;
        glewInit();
#endif
        SDL_GL_GetDrawableSize(sdl_window, &gl_w, &gl_h);
#ifdef SHAKER_DEBUG
        std::cout << "OpenGL version: " << glGetString(GL_VERSION) << "." << std::endl;
        std::cout << "OpenGL drawable size: " << gl_w << ", " << gl_h << "." << std::endl;
#endif
        SDL_GL_SetSwapInterval(SHAKER_VSINC);
        /*
                Load and compile shaders.
        */

        int gl_vertex_shader = glCreateShader(GL_VERTEX_SHADER);

        glShaderSource(gl_vertex_shader, 1, &gl_vertex_shader_source, NULL);

        glCompileShader(gl_vertex_shader);

        glGetShaderiv(gl_vertex_shader, GL_COMPILE_STATUS, &gl_success);

        if (!gl_success)
        {
            char gl_info[4096];
            glGetShaderInfoLog(gl_vertex_shader, 4096, NULL, gl_info);
            std::cout << "Could not compile vertex shader." << std::endl;

            std::cout << gl_info << std::endl;

            exit(4);
        }

        std::string gl_fragment_shader_source = std::string(gl_fragment_shader_header) + loadfile(usr_fragment_path);

        const GLchar* gl_char_fragment_shader_source = (const GLchar*)gl_fragment_shader_source.c_str();

        int gl_fragment_shader = glCreateShader(GL_FRAGMENT_SHADER);

        glShaderSource(gl_fragment_shader, 1, &gl_char_fragment_shader_source, NULL);

        glCompileShader(gl_fragment_shader);

        glGetShaderiv(gl_fragment_shader, GL_COMPILE_STATUS, &gl_success);

        if (!gl_success)
        {
            char gl_info[4096];

            glGetShaderInfoLog(gl_fragment_shader, 4096, NULL, gl_info);

            std::cout << "Could not compile fragment shader." << std::endl;
            std::cout << gl_info << std::endl;
            exit(5);
        }

        /*
            Link shaders.
        */

        int gl_shader_program = glCreateProgram();

        glAttachShader(gl_shader_program, gl_vertex_shader);

        glAttachShader(gl_shader_program, gl_fragment_shader);

        glLinkProgram(gl_shader_program);

        glGetProgramiv(gl_shader_program, GL_LINK_STATUS, &gl_success);

        if (!gl_success)
        {
            char gl_info[4096];

            glGetProgramInfoLog(gl_shader_program, 4096, NULL, gl_info);

            std::cout << "Could not link vertex and fragment shaders." << std::endl;
            std::cout << gl_info;
            exit(6);
        }

        /*
            Delete shaders.
        */

        glDeleteShader(gl_vertex_shader);
        glDeleteShader(gl_fragment_shader);

        /*
            Define quadrant vertices and indices.
        */

        float gl_vertices[] =
        {
            0.0f + 1.0f, 0.0f + 1.0f, 0.0f + 0.0f,
            0.0f + 1.0f, 0.0f - 1.0f, 0.0f + 0.0f,
            0.0f - 1.0f, 0.0f - 1.0f, 0.0f + 0.0f,
            0.0f - 1.0f, 0.0f + 1.0f, 0.0f + 0.0f,
        };

        unsigned int gl_indices[] =
        {
            0, 1, 3,
            1, 2, 3
        };

        /*
            Generate the vertex buffer object, vertex array object, and element buffer object.
        */

        unsigned int gl_vbo;
        unsigned int gl_vao;
        unsigned int gl_ebo;

        glGenVertexArrays(1, &gl_vao);

        glGenBuffers(1, &gl_vbo);
        glGenBuffers(1, &gl_ebo);

        glBindVertexArray(gl_vao);

        glBindBuffer(GL_ARRAY_BUFFER, gl_vbo);

        glBufferData(GL_ARRAY_BUFFER, sizeof(gl_vertices), gl_vertices, GL_STATIC_DRAW);

        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, gl_ebo);

        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(gl_indices), gl_indices, GL_STATIC_DRAW);

        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), NULL);

        glEnableVertexAttribArray(0);

        glBindBuffer(GL_ARRAY_BUFFER, 0);

        glUseProgram(gl_shader_program);

        /*
            Enter main loop.
        */

#ifdef USE_SDL_MOUSE_BUTTONS
        /* FIXME : all variables below are unused */
        Uint32 sdl_mouse_x = 0;
        Uint32 sdl_mouse_y = 0;
        SDL_bool sdl_mouse_l = SDL_FALSE;
        SDL_bool sdl_mouse_r = SDL_FALSE;
#endif
        Uint32 sdl_iteration = 0;

        SDL_bool sdl_running = SDL_TRUE;

        while (sdl_running == SDL_TRUE)
        {
            Uint32 sdl_time_start = SDL_GetTicks();

            /*
                Handle events.

            */

            SDL_Event e;

            while (SDL_PollEvent(&e))
            {
                if (e.type == SDL_QUIT)
                {
                    sdl_running = SDL_FALSE;
                }
                else if (e.type == SDL_WINDOWEVENT)
                {
                    switch( e.window.event)
                    {
                        case SDL_WINDOWEVENT_RESIZED:
                            gl_w = e.window.data1;
                            gl_h = e.window.data2;
#ifdef SHAKER_DEBUG
                            std::cout << "Window resized, width = " << gl_w << " , height = " << gl_h << std::endl;
#endif
                        break;

                        default:
                            break;
                    }
                }
#ifdef USE_SDL_MOUSE_BUTTONS
                else if (e.type == SDL_MOUSEMOTION)
                {
                    sdl_mouse_x = e.motion.x;
                    sdl_mouse_y = e.motion.y;
                }
                else if (e.type == SDL_MOUSEBUTTONDOWN)
                {
                    if (e.button.button == SDL_BUTTON_LEFT)
                    {
                        sdl_mouse_l = SDL_TRUE;
                    }
                    else if (e.button.button == SDL_BUTTON_RIGHT)
                    {
                        sdl_mouse_r = SDL_TRUE;
                    }
                }
                else if (e.type == SDL_MOUSEBUTTONUP)
                {
                    if (e.button.button == SDL_BUTTON_LEFT)
                    {
                        sdl_mouse_l = SDL_FALSE;
                    }
                    else if (e.button.button == SDL_BUTTON_RIGHT)
                    {
                        sdl_mouse_r = SDL_FALSE;
                    }
                }
#endif  /* USE_SDL_MOUSE_BUTTONS */
                else if (e.type == SDL_KEYDOWN)
                {
                    SDL_Keycode sdl_key = e.key.keysym.sym;

                    if (sdl_key == SDLK_ESCAPE)
                    {
                        sdl_running = SDL_FALSE;
                    }
                }
            }


            /*
                Set up variables.
            */

            int gl_i_resolution_location = glGetUniformLocation(gl_shader_program, "glx_Resolution");

            glUniform2f(gl_i_resolution_location, (float)gl_w, (float)gl_h);

            int gl_i_time_location = glGetUniformLocation(gl_shader_program, "glx_Time");

            glUniform1f(gl_i_time_location, (float)sdl_iteration / 60.0f);

            /*
                Draw quadrant.
            */

            /*  clear the color buffer */
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

            /* set the viewport, when e.g. the window size changed ... */
            glViewport(0, 0, gl_w, gl_h);

            /* draw */
            glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);

            /* render */
            SDL_GL_SwapWindow(sdl_window);

            /*
                Cap framerate.
            */

            Uint32 sdl_time_elapsed = SDL_GetTicks() - sdl_time_start;

#ifdef SHAKER_DEBUG
            if (sdl_iteration % 60 == 0)
            {
                std::cout << "Framerate: " << (1000.0 / sdl_time_elapsed) << std::endl;
            }
#endif

            if (sdl_time_elapsed < (1000.0 / 60.0))
            {
                SDL_Delay((Uint32)((Uint32)(1000.0 / 60.0) - sdl_time_elapsed));
            }

            sdl_iteration++;
        }

        /*
            Clean up SDL2 and OpenGL.
        */

        glDeleteVertexArrays(1, &gl_vao);

        glDeleteBuffers(1, &gl_vbo);
        glDeleteBuffers(1, &gl_ebo);

        SDL_GL_DeleteContext(gl_context);

        SDL_DestroyWindow(sdl_window);

        SDL_Quit();

        /*
            Exit cleanly.
        */
        return 0;
}