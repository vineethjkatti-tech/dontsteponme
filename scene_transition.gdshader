shader_type canvas_item;

// 0.0 = completely clear, 1.0 = completely covered in black dots
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float diamond_pixel_size = 16.0;

void fragment() {
    // Break the screen into a pixel grid
    vec2 grid_pos = floor(FRAGCOORD.xy / diamond_pixel_size);
    vec2 cell_uv = fract(FRAGCOORD.xy / diamond_pixel_size) - vec2(0.5);
    
    // Calculate distance from center of each dot
    float dist = length(cell_uv);
    
    // Wave offset across screen for a dynamic wipe
    float screen_gradient = (UV.x + UV.y) * 0.25;
    float threshold = clamp((progress * 1.5) - screen_gradient, 0.0, 1.0);
    
    if (dist < threshold * 0.75) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0); // Black dot
    } else {
        COLOR = vec4(0.0, 0.0, 0.0, 0.0); // Transparent
    }
}