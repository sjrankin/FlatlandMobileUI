//
//  Metal2DCircle.metal
//  Metal2DCircle
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

#include <metal_stdlib>
#include <metal_math>
using namespace metal;


struct ShapeParameters
{
    uint CircleRadius;
    float4 BackgroundColor;
    float4 InteriorColor;
    uint BorderWidth;
    float4 BorderColor;
};

kernel void DrawCircle(texture2d<float, access::read_write> Surface [[texture(0)]],
                       constant ShapeParameters &Parameters [[buffer(0)]],
                       uint2 gid [[thread_position_in_grid]])
{
    int CenterX = Surface.get_width() / 2;
    int CenterY = Surface.get_height() / 2;
    if (CenterX != CenterY)
    {
        Surface.write(float4(1.0, 0.5, 0.25, 1.0), gid);
        return;
    }
    int FinalRadius = CenterX;
    if (Parameters.CircleRadius > 0)
    {
        FinalRadius = int(Parameters.CircleRadius);
    }
    int XDelta = CenterX - gid.x;
    int YDelta = CenterY - gid.y;
    int XDelta2 = XDelta * XDelta;
    int YDelta2 = YDelta * YDelta;
    float Distance = sqrt(float(XDelta2 + YDelta2));
    if (Distance > FinalRadius)
    {
        Surface.write(Parameters.BackgroundColor, gid);
    }
    else
    {
        Surface.write(Parameters.InteriorColor, gid);
    }
}
