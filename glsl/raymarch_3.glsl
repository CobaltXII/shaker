// Epsilon constant.

float epsilon = 1e-5f;

// Signed distance function for a box.

float sdf_box(vec3 position, vec3 box)
{
	vec3 d = abs(position) - box;

  	return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}

// Signed distance function for a sphere.

float sdf_sphere(vec3 position, float radius)
{
	return length(position) - radius;
}

// Union operator.

float op_union(float d1, float d2) 
{  
	return min(d1, d2); 
}
// Signed distance function for the scene.

float sdf_scene(vec3 position)
{
	return sdf_sphere(position, 1.0f);
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

// Estimate the surface normal of the scene at position.

vec3 estimate_normal(vec3 position)
{
	return normalize
	(
		vec3
		(
			sdf_scene(vec3(position.x + epsilon, position.y, position.z)) -
			sdf_scene(vec3(position.x - epsilon, position.y, position.z)),

			sdf_scene(vec3(position.x, position.y + epsilon, position.z)) -
			sdf_scene(vec3(position.x, position.y - epsilon, position.z)),

			sdf_scene(vec3(position.x, position.y, position.z + epsilon)) -
			sdf_scene(vec3(position.x, position.y, position.z - epsilon))
		)
	);
}

// Calculate the illumination of a point.

vec2 point_illumination(vec3 camera, vec3 position, vec3 light)
{
	vec3 surface_normal = estimate_normal(position);

	vec3 light_normal = normalize(light - position);

	vec3 camera_normal = normalize(camera - position);

	vec3 reflected_normal = normalize(reflect(-light_normal, surface_normal));

	return vec2
	(
		dot(light_normal, surface_normal),

		dot(reflected_normal, camera_normal)
	);
}

// Calculate the color of a point using the Phong illumination model.

vec3 phong_illumination(vec2 p_i, vec3 k_d, vec3 k_s, vec3 k_l, vec3 k_i, float k_r)
{
	if (p_i.x < 0.0f)
	{
		return vec3(0.0f, 0.0f, 0.0f);
	}
	
	if (p_i.y < 0.0f)
	{
		return k_i * (k_d * p_i.x);
	}

	return k_i * (k_d * p_i.x + k_s * pow(p_i.y, k_r));
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

	vec3 pos = eye + dist * dir;

	vec3 k_a = vec3(0.1f, 0.1f, 0.1f);
	vec3 k_d = vec3(0.2f, 0.2f, 0.7f);
	vec3 k_s = vec3(1.0f, 1.0f, 1.0f);

	float k_r = 16.0f;

	// Ambient lighting.

	vec3 color = k_a;

	// Apply first light.

	vec3 light_1_pos = vec3
	(
		4.0f * sin(glx_Time), 

		2.0f, 

		4.0f * cos(glx_Time)
	);

	vec3 light_1_col = vec3(0.1f, 0.2f, 0.8f) * abs(sin(glx_Time * 2.0f)) * 4.0f;

	color += phong_illumination
	(
		point_illumination(eye, pos, light_1_pos), 

		k_d,
		k_s,

		light_1_pos,
		light_1_col,

		k_r
	);

	// Apply second light.

	vec3 light_2_pos = vec3
	(
		4.0f * cos(glx_Time), 

		2.0f * sin(glx_Time), 

		4.0f * sin(glx_Time)
	);

	vec3 light_2_col = vec3(0.8f, 0.2f, 0.1f) * abs(sin(glx_Time * 1.2f)) * 4.0f;

	color += phong_illumination
	(
		point_illumination(eye, pos, light_2_pos), 

		k_d,
		k_s,

		light_2_pos,
		light_2_col,

		k_r
	);

	// Apply third light.

	vec3 light_3_pos = vec3
	(
		4.0f * sin(glx_Time), 

		4.0f * cos(glx_Time), 

		4.0f * sin(glx_Time)
	);

	vec3 light_3_col = vec3(0.2f, 0.8f, 0.1f) * abs(sin(glx_Time * 1.4f)) * 4.0f;

	color += phong_illumination
	(
		point_illumination(eye, pos, light_3_pos), 

		k_d,
		k_s,

		light_3_pos,
		light_3_col,

		k_r
	);

	glx_FragColor = vec4(color, 1.0f);
}