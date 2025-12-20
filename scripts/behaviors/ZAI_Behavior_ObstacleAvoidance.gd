extends ZAI_Behavior

class_name ZAI_Behavior_ObstacleAvoidance

@export var feelerLength:float = 0
@export var feelerWidth:float = 25

@export var debugFeelers:bool = false

var targetPosition:Vector2 = Vector2.ZERO
var rightDirn:Vector2 = Vector2.ZERO

func update(delta: float) -> Vector2:
	super.update(delta)
	
	var desired_velocity:Vector2 = Vector2.ZERO
	
	#feelerLength = parentCharacter.velocity.length()
	
	var charVelocityNormalized:Vector2 = parentCharacter.velocity.normalized()
	targetPosition = parentCharacter.global_position + charVelocityNormalized * feelerLength
	var targetPositionHalfWay:Vector2 = parentCharacter.global_position + charVelocityNormalized * feelerLength * 0.5
	rightDirn = -parentCharacter.velocity.orthogonal().normalized()
	
	var obstacles:Array[ZAI_Obstacle] = ZAIManager.get_obstacles()
	obstacles.sort_custom(obstacle_custom_sort)
	for obstacle in obstacles:
		if lineIntersectsCircle(targetPosition, targetPositionHalfWay, obstacle) or\
			lineIntersectsCircle(targetPosition + rightDirn * feelerWidth, targetPositionHalfWay + rightDirn * feelerWidth, obstacle) or\
			lineIntersectsCircle(targetPosition + rightDirn * -feelerWidth, targetPositionHalfWay + rightDirn * -feelerWidth, obstacle):
				var dirn:Vector2 = obstacle.global_position - parentCharacter.global_position
				var angleDiff:float = dirn.angle_to(parentCharacter.velocity)
				dirn = dirn.orthogonal()
				if angleDiff<0:
					desired_velocity = dirn.normalized() * parentCharacter.max_speed
				else:
					desired_velocity = -dirn.normalized() * parentCharacter.max_speed
				break
			
	return desired_velocity

func debug_draw() -> void:
	var local_target:Vector2 = to_local(targetPosition)
	if debugFeelers:
		draw_line(Vector2.ZERO, local_target, debugColor, 2)
		draw_line(to_local(parentCharacter.global_position + rightDirn * feelerWidth), to_local(targetPosition + rightDirn * feelerWidth), debugColor, 2)
		draw_line(to_local(parentCharacter.global_position + rightDirn * -feelerWidth), to_local(targetPosition + rightDirn * -feelerWidth), debugColor, 2)

func segment_intersects_circle(p1: Vector2, p2: Vector2, center: Vector2, radius: float) -> bool:
	var seg:Vector2 = p2 - p1
	var t:float = (center - p1).dot(seg) / seg.length_squared()
	t = clamp(t, 0.0, 1.0)

	var closest:Vector2 = p1 + seg * t
	return closest.distance_squared_to(center) <= radius * radius

func lineIntersectsCircle(ahead :Vector2, ahead2 :Vector2, obstacle :ZAI_Obstacle)->bool:
	var dist1:float = (ahead - obstacle.global_position).length()
	var dist2:float = (ahead2 - obstacle.global_position).length()
	return dist1 <= obstacle.radius || dist2 <= obstacle.radius

func point_orientation(a: Vector2, b: Vector2, p: Vector2) -> float:
	return (b - a).cross(p - a)

func obstacle_custom_sort(obstacleA:ZAI_Obstacle, obstacleB:ZAI_Obstacle):
	var distToA:float = (parentCharacter.global_position - obstacleA.global_position).length_squared()
	var distToB:float = (parentCharacter.global_position - obstacleB.global_position).length_squared()
	
	return distToA < distToB
