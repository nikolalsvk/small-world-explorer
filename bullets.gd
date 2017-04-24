
extends Node2D

# This demo is an example of controling a high number of 2D objects with logic and collision without using scene nodes.
# This technique is a lot more efficient than using instancing and nodes, but requires more programming and is less visual

# Member variables
const BULLET_COUNT = 500
const SPEED_MIN = 20
const SPEED_MAX = 60
const PLANETS = [preload("res://blue-planet.png"), 
                 preload("res://gray-planet.png"), 
                 preload("res://orange-planet.png"),
                 preload("res://burning-planet.png"),
                 preload("res://ice-planet.png"),
                 preload("res://magneta-planet.png")]

var bullets = []
var shape


# Inner classes
class Bullet:
	var pos = Vector2()
	var speed = 1.0
	var body = RID()
	var texture = PLANETS[rand_range(0, PLANETS.size())]
	var planet_size = rand_range(32, 62)
	

func _draw():
	for b in bullets:
		var tofs = -b.texture.get_size()*0.5
		b.texture.set_size_override(Vector2(b.planet_size, b.planet_size))
		draw_texture(b.texture, b.pos + tofs)


func _process(delta):
	var width = get_viewport_rect().size.x*2.0
	var mat = Matrix32()
	for b in bullets:
		b.pos.x -= b.speed*delta
		if (b.pos.x < -300):
			b.pos.x += width
		mat.o = b.pos
		
		Physics2DServer.body_set_state(b.body, Physics2DServer.BODY_STATE_TRANSFORM, mat)
	
	update()


func _ready():
	for i in range(BULLET_COUNT):
		var b = Bullet.new()
		b.speed = rand_range(SPEED_MIN, SPEED_MAX)
		b.body = Physics2DServer.body_create(Physics2DServer.BODY_MODE_KINEMATIC)
		Physics2DServer.body_set_space(b.body, get_world_2d().get_space())
		
		shape = Physics2DServer.shape_create(Physics2DServer.SHAPE_CIRCLE)
		Physics2DServer.shape_set_data(shape, b.planet_size*0.5) # Radius
		Physics2DServer.body_add_shape(b.body, shape)
		
		b.pos = Vector2(get_viewport_rect().size * Vector2(randf()*6.0, randf())) # Spread planets
		b.pos.x += get_viewport_rect().size.x # Start outside the viewport
		var mat = Matrix32()
		mat.o = b.pos
		Physics2DServer.body_set_state(b.body, Physics2DServer.BODY_STATE_TRANSFORM, mat)
		
		bullets.append(b)
	
	set_process(true)


func _exit_tree():
	for b in bullets:
		Physics2DServer.free_rid(b.body)
	
	Physics2DServer.free_rid(shape)
	bullets.clear()
