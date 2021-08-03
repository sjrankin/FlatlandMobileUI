//
//  LinesDrawKernel.metal
//  LinesDrawKernel
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

struct LineArray
{
    uint Count;
    constant LineParameters *Lines;
};

/// Draw lines on the passed texture.
kernel void DrawLines(texture2d<float, access::read_write> Background [[texture(0)]],
                      constant LineArray &Parameters [[buffer(0)]],
                      uint2 gid [[thread_position_in_grid]])
{
    for (int Index = 0; Index < int(Parameters.Count); Index++)
    {
        if (Parameters.Lines[Index].IsHorizontal)
        {
            if (gid.y < Parameters.Lines[Index].HorizontalAt)
            {
                continue;
            }
            if (gid.y > Parameters.Lines[Index].HorizontalAt + Parameters.Lines[Index].Thickness - 1)
            {
                continue;
            }
        }
        else
        {
            if (gid.x < Parameters.Lines[Index].VerticalAt)
            {
                return;
            }
            if (gid.x > Parameters.Lines[Index].VerticalAt + Parameters.Lines[Index].Thickness - 1)
            {
                return;
            }
        }
        float4 BGPixel = Background.read(gid);
        float4 SpPixel = Parameters.Lines[Index].LineColor;
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
}
