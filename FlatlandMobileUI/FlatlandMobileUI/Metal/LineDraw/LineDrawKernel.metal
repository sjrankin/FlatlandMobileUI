//
//  LineDrawKernel.metal
//  LineDrawKernel
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

#include <metal_stdlib>
using namespace metal;

struct LineParameters
{
    bool IsHorizontal;
    uint HorizontalAt;
    uint VerticalAt;
    uint Thickness;
    float4 LineColor;
};

kernel void DrawLine(texture2d<float, access::read_write> Background [[texture(0)]],
                     constant LineParameters &Parameters [[buffer(0)]],
                     uint2 gid [[thread_position_in_grid]])
{
    float4 BGPixel = Background.read(gid);
    float4 SpPixel = Parameters.LineColor;
    if (Parameters.IsHorizontal)
    {
        if (gid.y < Parameters.HorizontalAt)
        {
            return;
        }
        if (gid.y > Parameters.HorizontalAt + Parameters.Thickness - 1)
        {
            return;
        }
    }
    else
    {
        if (gid.x < Parameters.VerticalAt)
        {
            return;
        }
        if (gid.x > Parameters.VerticalAt + Parameters.Thickness - 1)
        {
            return;
        }
    }
    float LineAlpha = SpPixel.a;
    if (LineAlpha == 0.0)
    {
        return;
    }
    if (LineAlpha == 1.0)
    {
        Background.write(SpPixel, gid);
    }
    else
    {
        float FinalRed = (SpPixel.r * LineAlpha) + (BGPixel.r * (1.0 - LineAlpha));
        float FinalGreen = (SpPixel.g * LineAlpha) + (BGPixel.g * (1.0 - LineAlpha));
        float FinalBlue = (SpPixel.b * LineAlpha) + (BGPixel.b * (1.0 - LineAlpha));
        Background.write(float4(FinalRed, FinalGreen, FinalBlue, 1.0), gid);
    }
}
