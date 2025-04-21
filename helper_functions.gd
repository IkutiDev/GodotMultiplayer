class_name HelperFunctions
extends Node

static func ClientInterpolate(global_position : Vector2, target_position : Vector2, delta : float, lerp_speed : float = 25) -> Vector2:
	if target_position == Vector2.INF:
		return global_position
		
	if (global_position - target_position).length_squared() > 100 * 100:
		return target_position
		
	return lerp(target_position, global_position, pow(0.5, delta * lerp_speed))
