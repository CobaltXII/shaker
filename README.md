# Shaker

Shaker is a GLSL sandbox for the desktop.

## Building

You need to link OpenGL and SDL2 in order to build Shaker. The following command should suffice for most systems and compilers.

```bash
clang++ shaker.cpp -o shaker -O3 -lSDL2 -lGL
```

On Apple systems, you may need to use this command instead, based on your compiler vendor.

```bash
clang++ shaker.cpp -o shaker -O3 -lSDL2 -framework OpenGL
```

I don't use GNU/Linux or Windows, so I wouldn't know where to find the OpenGL or SDL include files. You'll probably have to modify the include paths. Other than that, Shaker is (probably) cross-compatible.

## Usage

Once you have compiled Shaker successfully, it is trivial to use it. Simply pass a filename as an argument to Shaker. You can optionally pass a width and a height (you must specify both if you are to specify any).

```bash
./shaker fragment.glsl
```

or, this is also valid

```bash
./shaker fragment.glsl 800 600
```

## Example

Let's make a fragment shader that will display some scrolling rainbow colors. First, we will define our `main` function, which will be called for every individual pixel, every individual frame.

```c
void main()
{
	// To do, scrolling rainbow colors
}
```

To start, let's fill the screen with just a solid red color. Remember, the variable `glx_FragColor` is passed back to OpenGL, and is 4-dimensional (red, green, blue, alpha).

```c
void main()
{
	glx_FragColor = vec4(1.0f, 0.0f, 0.0f, 1.0f);
}
```

Shaker provides the variable `glx_FragCoord`, so we can use that to color our screen based on the position of the fragment (or pixel). Shaker also provides the variable `glx_Resolution`, which tells us the size of the window.

```c
void main()
{
	glx_FragColor = vec4
	(
		glx_FragCoord.x / glx_Resolution.x, 
		glx_FragCoord.y / glx_Resolution.y, 

		0.0f, 

		1.0f
	);
}
```

Cool, we have a red, green and yellow rectangle filling our screen. Let us add some blue to the mixture. You can see how solid colors are pretty boring. Shaker provides the `glx_Time` variable, which returns the time in seconds since Shaker started running your shader. Let's use this to make some pulsing colors.

```c
void main()
{
	glx_FragColor = vec4
	(
		glx_FragCoord.x / glx_Resolution.x, 
		glx_FragCoord.y / glx_Resolution.y, 

		abs(sin(glx_Time * 2.0f)), 

		1.0f
	);
}
```

Awesome, now we are getting somewhere. We can go even further by using the modulus operation to scroll the gradient across the screen really quickly.

```c
void main()
{
	glx_FragColor = vec4
	(
		mod(glx_FragCoord.x + glx_Time * 500.0f, glx_Resolution.x) / glx_Resolution.x, 
		mod(glx_FragCoord.y + glx_Time * 500.0f, glx_Resolution.y) / glx_Resolution.y, 

		abs(sin(glx_Time * 2.0f)), 

		1.0f
	);
}
```

There you have it, scrolling rainbow colors. We have not even scratched the surface of what is possible with just fragment shaders. Take a look at Shadertoy to see awesome examples of things that can be done with just fragment shaders.

## Technical

Shaker requires a machine that supports a minimum of OpenGL 3.2 Core. This is basically almost every machine. I chose to use OpenGL 3.2 Core for reasons specific to my machine.

Shaker provides 4 input/output variables to every call to a GLSL fragment shader. The variable `out vec4 glx_FragColor` is the color of the current fragment, in RGBA format. The variable `in vec4 glx_FragCoord` is the 4-dimensional position of the current fragment. The variable `in vec2 glx_Resolution` is the size of the OpenGL drawable. The variable `in float glx_Time` is the time in seconds since Shaker started running.

## License

Shaker is licensed under the GNU GPLv3. SDL2 is licensed under the zlib license.
