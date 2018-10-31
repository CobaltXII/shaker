// Epsilon constant.

float epsilon = 1e-5f;

// Signed distance function for a sphere.

float sdf_sphere(vec3 position)
{
	return length(position) - 1.0f;
}

// Signed distance function for the scene.

float sdf_scene(vec3 position)
{
	return sdf_sphere(position);
}

// Return the shortest distance from the camera to the scene within the bounds
// of start and end.

float shortest_distance(vec3 camera, vec3 direction, float start, float end)
{
	float depth = start;

	for (int i = 0; i < 256; i++)
	{
		float dist = sdf_scene(camera + depth * direction);

		if (dist < epsilon)
		{
			return depth;
		}

		depth += dist;

		if (depth >= end)
		{
			return end;
		}
	}

	return end;
}

// Calculate the direction that a ray at coords should be travelling in.

vec3 ray_direction(float field_of_view, vec2 size, vec2 coords)
{
	vec2 xy = coords - size / 2.0f;

	float z = size.y / tan(radians(field_of_view) / 2.0f);

	return normalize(vec3(xy, -z));
}

// The main function of the fragment shader.

void main()
{
	vec3 dir = ray_direction(45.0f, glx_Resolution, glx_FragCoord.xy);

	vec3 eye = vec3(0.0f, 0.0f, 5.0f);

	float dist = shortest_distance(eye, dir, 0.0f, 128.0f);

	if (dist > 128.0f - epsilon)
	{
		glx_FragColor = vec4(0.0f, 0.0f, 0.0f, 1.0f);

		return;
	}

	glx_FragColor = vec4(1.0f, 0.0f, 0.0f, 1.0f);
}