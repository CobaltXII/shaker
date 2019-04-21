void main()
{
	glx_FragColor = vec4
	(
		mod(glx_FragCoord.x + glx_Time * 500.0f, glx_Resolution.x / 2.0f) / glx_Resolution.x * 2.0f, 
		mod(glx_FragCoord.y + glx_Time * 500.0f, glx_Resolution.y / 2.0f) / glx_Resolution.y * 2.0f, 

		abs(sin(glx_Time * 0.1f)), 

		1.0f
	);
}