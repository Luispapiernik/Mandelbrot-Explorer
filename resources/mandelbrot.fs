#version 330 core

#define DEFINE_INTERPOLATE_FUNCTION(N)                         \
float interpolate_##N(float x, Segment segments[N]) {          \
    for (int i = 0; i < N - 1; i++) {                          \
        if (segments[i].x <= x && x <= segments[i + 1].x) {    \
            float colorLength = segments[i + 1].iColor - segments[i].fColor; \
            float xLength = segments[i + 1].x - segments[i].x; \
            return segments[i].fColor + colorLength * (x - segments[i].x) / xLength; \
        }                                                     \
    }                                                         \
    return segments[N - 1].fColor;                            \
}

// Inputs from the vertex shader
in vec2 fragTexCoord;  // Texture coordinates
in vec4 fragColor;     // Vertex color
in vec2 coord;         // Vertex position

// geometry shader inputs
uniform int screenWidth;
uniform int screenHeight;
uniform int maxIterations;
uniform vec2 xi;
uniform vec2 xf;
uniform vec2 yi;
uniform vec2 yf;

// color shader inputs
uniform int redSegmentsSize;
uniform int greenSegmentsSize;
uniform int blueSegmentsSize;
uniform int invertColor;
uniform int smoothVelocity;
uniform vec3 colors[30];

out vec4 finalFragColor;

struct Segment {
    float x;
    float iColor;
    float fColor;
};

Segment[10] redSegments;
Segment[10] greenSegments;
Segment[10] blueSegments;

// Generate interpolate functions for different sizes
DEFINE_INTERPOLATE_FUNCTION(10)

vec3 split(float number) {
    // 8193 = 2^13 + 1
    float temp = 8193.0 * number;
    float high = temp - (temp - number);
    float low = number - high;
    return vec3(high, low, 0);
}

vec3 quickTwoSum(float a, float b) {
    float s = a + b;
    float err = b - (s - a);
    return vec3(s, 0, err);
}

vec3 twoSum(float a, float b) {
    float s = a + b;
    float v = s - a;
    float err = (a - (s - v)) + (b - v);
    return vec3(s, 0, err);
}

vec3 quickTwoDiff(float a, float b) {
    float s = a - b;
    float err = (a - s) - b;
    return vec3(s, 0, err);
}

vec3 twoDiff(float a, float b) {
    float s = a - b;
    float v = s - a;
    float err = (a - (s - v)) - (b + v);
    return vec3(s, 0, err);
}

vec3 twoProd(float a, float b) {
    float p = a * b;
    vec3 aSplit = split(a);
    vec3 bSplit = split(b);
    float err = ((aSplit.x * bSplit.x - p) + aSplit.x * bSplit.y + aSplit.y * bSplit.x) + aSplit.y * bSplit.y;
    return vec3(p, 0, err);
}

// vec3 sum(vec3 a, vec3 b) {
//     float s1, s2, t1, t2;

//     vec3 result_1 = twoSum(a.x, b.x);
//     s1 = result_1.x;
//     s2 = result_1.z;

//     vec3 result_2 = twoSum(a.y, b.y);
//     t1 = result_2.x;
//     t2 = result_2.z;
//     s2 += t1;

//     vec3 result_3 = quickTwoSum(s1, s2);
//     s1 = result_3.x;
//     s2 = result_3.z;
//     s2 += t2;

//     vec3 result_4 = quickTwoSum(s1, s2);
//     s1 = result_4.x;
//     s2 = result_4.z;

//     return vec3(s1, s2, 0);
// }
vec3 sum(vec3 a, vec3 b) {
    float s1, s2, t1, t2;
    float error = 0.0;
    float u = 0.5 * 1.1920928955078125e-7; // 2^-23 for 32-bit float

    vec3 result_1 = twoSum(a.x, b.x);
    s1 = result_1.x;
    s2 = result_1.z;
    error = max(error, u * abs(s1));

    vec3 result_2 = twoSum(a.y, b.y);
    t1 = result_2.x;
    t2 = result_2.z;
    error = max(error, u * abs(t1));
    
    s2 += t1;
    error = max(error, u * abs(s2));

    vec3 result_3 = quickTwoSum(s1, s2);
    s1 = result_3.x;
    s2 = result_3.z;
    error = max(error, u * abs(s1));
    
    s2 += t2;
    error = max(error, u * abs(s2));

    vec3 result_4 = quickTwoSum(s1, s2);
    s1 = result_4.x;
    s2 = result_4.z;
    error = max(error, u * abs(s1));

    return vec3(s1, s2, error);
}

// vec3 sub(vec3 a, vec3 b) {
//     float s1, s2, t1, t2;

//     vec3 result_1 = twoDiff(a.x, b.x);
//     s1 = result_1.x;
//     s2 = result_1.z;

//     vec3 result_2 = twoDiff(a.y, b.y);
//     t1 = result_2.x;
//     t2 = result_2.z;
//     s2 += t1;

//     vec3 result_3 = quickTwoSum(s1, s2);
//     s1 = result_3.x;
//     s2 = result_3.z;
//     s2 += t2;

//     vec3 result_4 = quickTwoSum(s1, s2);
//     s1 = result_4.x;
//     s2 = result_4.z;

//     return vec3(s1, s2, 0);
// }
vec3 sub(vec3 a, vec3 b) {
    float s1, s2, t1, t2;
    float error = 0.0;
    float u = 0.5 * 1.1920928955078125e-7; // 2^-23 for 32-bit float

    // Step 1: twoDiff(a.x, b.x)
    vec3 result_1 = twoDiff(a.x, b.x);
    s1 = result_1.x;
    s2 = result_1.z;
    error = max(error, u * abs(s1)); // Error from high-order difference

    // Step 2: twoDiff(a.y, b.y)
    vec3 result_2 = twoDiff(a.y, b.y);
    t1 = result_2.x;
    t2 = result_2.z;
    error = max(error, u * abs(t1)); // Error from low-order difference

    // Step 3: s2 += t1
    s2 += t1;
    error = max(error, u * abs(s2)); // Error from combining low parts

    // Step 4: First quickTwoSum normalization
    vec3 result_3 = quickTwoSum(s1, s2);
    s1 = result_3.x;
    s2 = result_3.z;
    error = max(error, u * abs(s1)); // Error from first normalization

    // Step 5: s2 += t2
    s2 += t2;
    error = max(error, u * abs(s2)); // Error from adding final error term

    // Step 6: Final quickTwoSum normalization
    vec3 result_4 = quickTwoSum(s1, s2);
    s1 = result_4.x;
    s2 = result_4.z;
    error = max(error, u * abs(s1)); // Error from final normalization

    return vec3(s1, s2, error);
}

vec3 negate(vec3 a) {
    return vec3(-a.x, -a.y, -a.z);
}

// vec3 multiply(vec3 a, vec3 b) {
//     float p1, p2;

//     vec3 result_1 = twoProd(a.x, b.x);
//     p1 = result_1.x;
//     p2 = result_1.z;
//     p2 += a.x * b.y + a.y * b.x;

//     vec3 result_2 = quickTwoSum(p1, p2);
//     p1 = result_2.x;
//     p2 = result_2.z;

//     return vec3(p1, p2, 0);
// }
vec3 multiply(vec3 a, vec3 b) {
    float p1, p2;
    float error = 0.0;
    float u = 0.5 * 1.1920928955078125e-7; // 2^-23 for 32-bit float

    // Step 1: twoProd(a.x, b.x)
    vec3 result_1 = twoProd(a.x, b.x);
    p1 = result_1.x;
    p2 = result_1.z;
    error = max(error, u * abs(p1)); // Error from main product

    // Step 2: p2 += a.x * b.y + a.y * b.x
    float term1 = a.x * b.y;
    float term2 = a.y * b.x;
    error = max(error, u * abs(term1)); // Error from first cross product
    error = max(error, u * abs(term2)); // Error from second cross product
    p2 += term1 + term2;
    error = max(error, u * abs(p2));    // Error from sum

    // Step 3: quickTwoSum for final normalization
    vec3 result_2 = quickTwoSum(p1, p2);
    p1 = result_2.x;
    p2 = result_2.z;
    error = max(error, u * abs(p1));    // Error from final normalization

    return vec3(p1, p2, error);
}

vec3 div(vec3 a, vec3 b) {
    float q1, q2, q3;
    vec3 result;

    q1 = a.x / b.x;
    result = sub(
        a,
        multiply(
            vec3(q1, 0, 0),
            b
        )
    );

    q2 = result.x / b.x;
    result = sub(
        result,
        multiply(
            vec3(q2, 0, 0),
            b
        )
    );

    q3 = result.x / b.x;

    vec3 result_2 = quickTwoSum(q1, q2);
    q1 = result_2.x;
    q2 = result_2.z;

    result = sum(
        vec3(q1, q2, 0),
        vec3(q3, 0, 0)
    );

    return result;
}

// TODO: Implement this
// vec3 sqrt(vec3 a) {
// }

bool isGreater(vec3 a, vec3 b) {
    return a.x > b.x || (a.x == b.x && a.y > b.y);
}

vec2 getCurrentScreenCoordinate() {
    // This is the point we are actually calculating the scape velocity for
    float initial_x = coord.x;
    float initial_y =  coord.y;

    // We need to take into account non square screens
    if (screenHeight > screenWidth){
        initial_x = initial_x * float(screenWidth) / float(screenHeight);
    } else if (screenWidth > screenHeight){
        initial_y = initial_y * float(screenHeight) / float(screenWidth);
    }

    return vec2(initial_x, initial_y);
}

int get_scape_velocity() {
    // In (-1, 1) x (-1, 1)
    vec2 currentScreenCoordinate = getCurrentScreenCoordinate();

    vec3 ddxi = vec3(xi.x, xi.y, 0);
    vec3 ddxf = vec3(xf.x, xf.y, 0);
    vec3 ddyi = vec3(yi.x, yi.y, 0);
    vec3 ddyf = vec3(yf.x, yf.y, 0);

    vec3 splittedInitialX = split((currentScreenCoordinate.x + 1 ) / 2);

    // // We need to take into account the zoom and the translation
    // initial_x = xi + (xf - xi) * (initial_x + 1) / 2;
    vec3 ddx = sum(
        ddxi,
        multiply(
            sub(ddxf, ddxi),
            splittedInitialX
        )
    );

    vec3 splittedInitialY = split((currentScreenCoordinate.y + 1 ) / 2);

    // initial_y = yi + (yf - yi) * (initial_y + 1) / 2;
    vec3 ddy = sum(
        ddyi,
        multiply(
            sub(ddyf, ddyi),
            splittedInitialY
        )
    );

    // float current_x = 0;
    vec3 ddxn = vec3(0, 0, 0);

    // float current_y = 0;
    vec3 ddyn = vec3(0, 0, 0);

    int scape_velocity = 0;

    // float x2, y2;
    vec3 ddx2, ddy2;
    for (int i = 0; i <= maxIterations; i++){
        // x2 = current_x * current_x;
        ddx2 = multiply(ddxn, ddxn);
    
        // y2 = current_y * current_y;
        ddy2 = multiply(ddyn, ddyn);

        // x2 + y2 > 4
        if (isGreater(sum(ddx2, ddy2), vec3(4, 0, 0))){
            break;
        }

        // current_y = 2 * current_x * current_y + initial_y;
        ddyn = sum(
            multiply(
                vec3(2, 0, 0),
                multiply(ddxn, ddyn)
            ),
            ddy
        );

        // current_x = x2 - y2 + initial_x;
        ddxn = sum(
            sub(ddx2, ddy2),
            ddx
        );

        scape_velocity = i;
    }

    return scape_velocity;
}

float get_smooth_scape_velocity() {
    // This is the point we are actually calculating the scape velocity for
    float initial_x = coord.x;
    float initial_y = coord.y;

    // We need to take into account non square screens
    if (screenHeight > screenWidth){
        initial_x = initial_x * float(screenWidth) / float(screenHeight);
    } else {
        initial_y = initial_y * float(screenHeight) / float(screenWidth);
    }

    // We need to take into account the zoom and the translation
    initial_x = xi.x + (xf.x - xi.x) * (initial_x + 1.0) / 2.0;
    initial_y = yi.x + (yf.x - yi.x) * (initial_y + 1.0) / 2.0;

    float current_x = 0.0;
    float current_y = 0.0;
    float scape_velocity = 0.0;

    float x2, y2;
    for (int i = 0; i <= maxIterations; i++){
        x2 = current_x * current_x;
        y2 = current_y * current_y;

        scape_velocity = float(i) + 1.0 - log(log(sqrt(x2 + y2))) / log(2.0);
        if (x2 + y2 > 4.0){
            break;
        }

        current_y = 2.0 * current_x * current_y + initial_y;
        current_x = x2 - y2 + initial_x;
        scape_velocity = float(i);
    }

    return scape_velocity;
}

void main()
{
    float t;
    if (smoothVelocity == 1) {
        t = get_smooth_scape_velocity() / float(maxIterations);
    } else {
        t = get_scape_velocity() / float(maxIterations);
    }

    // initialize red segments
    for (int i = 0; i < redSegmentsSize; i++) {
        redSegments[i] = Segment(colors[i].x, colors[i].y, colors[i].z);
    }

    int realIndex;
    // initialize green segments
    for (int i = 0; i < greenSegmentsSize; i++) {
        realIndex = i + redSegmentsSize;
        greenSegments[i] = Segment(colors[realIndex].x, colors[realIndex].y, colors[realIndex].z);
    }

    // initialize blue segments
    for (int i = 0; i < blueSegmentsSize; i++) {
        realIndex = i + redSegmentsSize + greenSegmentsSize;
        blueSegments[i] = Segment(colors[realIndex].x, colors[realIndex].y, colors[realIndex].z);
    }

    // 1 is true, -1 is false
    float colorParameter = invertColor == 1 ? 1 - t : t;

    vec3 color = vec3(
        interpolate_10(colorParameter, redSegments),
        interpolate_10(colorParameter, greenSegments),
        interpolate_10(colorParameter, blueSegments)
    );

    finalFragColor = vec4(color, 1.0);
}
