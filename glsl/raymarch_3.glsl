// Rotation matrices.

mat3 rm_x;
mat3 rm_y;
mat3 rm_z;

// Epsilon constant.

float epsilon = 1e-3f;

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

// Difference operator.

float op_difference(float d1, float d2) 
{ 
	return max(-d1, d2); 
}

// Intersection operator.

float op_intersection(float d1, float d2) 
{
	return max(d1, d2); 
}

// Rotation matrix around the X axis.

mat3 rotate_x(float theta) 
{
    float c = cos(theta);
    float s = sin(theta);

    return mat3
    (
        vec3(1.0f, 0.0f, 0.0f),

        vec3(0.0f, c, -s),

        vec3(0.0f, s, c)
    );
}

// Rotation matrix around the Y axis.

mat3 rotate_y(float theta) 
{
    float c = cos(theta);
    float s = sin(theta);

    return mat3
    (
        vec3(c, 0.0f, s),

        vec3(0.0f, 1.0f, 0.0f),
        
        vec3(-s, 0.0f, c)
    );
}

// Rotation matrix around the Z axis.

mat3 rotate_z(float theta) 
{
    float c = cos(theta);
    float s = sin(theta);

    return mat3
    (
        vec3(c, -s, 0.0f),

        vec3(s, c, 0.0f),
        
        vec3(0.0f, 0.0f, 1.0f)
    );
}

// Signed distance function for the scene.

float sdf_scene(vec3 position)
{
	position = rm_x * rm_y * rm_z * position;

	float domain = 3.0f;

	position = mod(position, vec3(domain, domain, domain)) - 0.5 * vec3(domain, domain, domain);

	return op_intersection(sdf_box(position, vec3(0.5f, 0.5f, 0.5f)), sdf_sphere(position, 0.6f + abs(sin(glx_Time)) * 0.1f));
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
	#define epsilon 1e-2

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

	#undef epsilon
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
	// Generate rotation matrices.

	rm_x = rotate_x(glx_Time / 5.0f);
	rm_y = rotate_y(glx_Time / 5.0f);
	rm_z = rotate_z(glx_Time / 5.0f);

	// Calculate ray direction and collision data. 

	vec3 dir = ray_direction(45.0f, glx_Resolution, glx_FragCoord.xy);

	vec3 eye = vec3(0.0f, 0.0f, 0.0f);

	float dist = shortest_distance(eye, dir, 0.0f, 32.0f);

	if (dist > 128.0f - epsilon)
	{
		glx_FragColor = vec4(0.0f, 0.0f, 0.0f, 1.0f);

		return;
	}

	vec3 pos = eye + dist * dir;

	vec3 nrm = estimate_normal(pos);

	vec3 k_a = nrm * 0.1f;

	vec3 k_d = nrm;

	vec3 k_s = vec3(1.0f, 1.0f, 1.0f);

	float k_r = 16.0f;

	// Ambient lighting.

	vec3 color = k_a;

	// Apply first light.

	vec3 light_1_pos = vec3
	(
		4.0f * sin(glx_Time), 

		0.0f, 

		4.0f * cos(glx_Time)
	);

	light_1_pos += eye;

	vec3 light_1_col = vec3(1.0f, 1.0f, 1.0f) * 1.0f;

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

		4.0f * sin(glx_Time), 

		0.0f
	);

	light_2_pos += eye;

	vec3 light_2_col = vec3(1.0f, 1.0f, 1.0f) * 1.0f;

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
		0.0f, 

		4.0f * cos(glx_Time), 

		4.0f * sin(glx_Time)
	);

	light_3_pos += eye;

	vec3 light_3_col = vec3(1.0f, 1.0f, 1.0f) * 1.0f;

	color += phong_illumination
	(
		point_illumination(eye, pos, light_3_pos), 

		k_d,
		k_s,

		light_3_pos,
		light_3_col,

		k_r
	);

	glx_FragColor = vec4(color - vec3(1.0f, 1.0f, 1.0f) * (dist / 30.0f), 1.0f);
}