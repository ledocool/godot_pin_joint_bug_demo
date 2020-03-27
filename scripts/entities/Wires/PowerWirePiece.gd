extends RigidBody2D
class_name WirePiece

func Enable():
# warning-ignore:unsafe_property_access
	$AnimatedSprite.frame = 1

func Disable():
# warning-ignore:unsafe_property_access
	$AnimatedSprite.frame = 0

func GetRightAnchor():
	return $RightAnchor
	
func GetLeftAnchor():
	return $LeftAnchor
	
func GetBody():
	return self
