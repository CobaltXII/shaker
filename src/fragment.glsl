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