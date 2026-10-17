extends Node
## Calibration knobs for Marco A. Values are empirical approximations
## (manual does not fix exact rates). Tune here without rewriting logic.

# --- Vehicle ---
const MAX_SPEED := 280.0
const ACCEL_RATE := 90.0
const BRAKE_RATE := 160.0
const STEER_RATE := 2.4
const STEER_DEADZONE := 0.12
const ROAD_HALF_WIDTH := 0.92
## Lateral penalty when leaving the road (milder than car hit). Empirical.
const OFFROAD_SPEED_PENALTY := 0.35
const OFFROAD_DRAG := 40.0

# --- Road / pseudo-3D ---
const SEGMENT_LENGTH := 200.0
const ROAD_SEGMENTS := 500
const DRAW_DISTANCE := 150
const CAMERA_DEPTH := 0.84
const ROAD_WIDTH := 2000.0
const RUMBLE_LENGTH := 3
const CURVE_STRENGTH := 0.003
const CAMERA_HEIGHT := 1000.0

# --- Traffic ---
const TRAFFIC_SPAWN_INTERVAL := 0.85
const TRAFFIC_MAX_ACTIVE := 12
const TRAFFIC_MIN_SPEED_FACTOR := 0.35
const TRAFFIC_MAX_SPEED_FACTOR := 0.72
const TRAFFIC_LANE_POSITIONS := [-0.55, -0.18, 0.18, 0.55]
## Empirically approximated collision speed loss (manual: car hit > roadside).
const COLLISION_SPEED_FACTOR := 0.28
const COLLISION_COOLDOWN := 0.85
const OVERTAKE_PLAYER_Z := 0.0

# --- Display (Atari 2600-like internal resolution) ---
const BASE_RESOLUTION := Vector2i(160, 192)
const PLAYER_SCREEN_Y_RATIO := 0.78
