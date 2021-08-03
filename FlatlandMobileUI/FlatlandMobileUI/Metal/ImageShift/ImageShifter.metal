//
//  ImageShifter.metal
//  ImageShifter
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

#include <metal_stdlib>
using namespace metal;

struct ParameterBlock
{
    int XOffset;
    int YOffset;
    uint ImageWidth;
    uint ImageHeight;
};


kernel void HorizontalImageShift(texture2d<float, access::read> Source [[texture(0)]],
                                 texture2d<float, access::write> Target [[texture(1)]],
                                 constant ParameterBlock &Parameters [[buffer(0)]],
                                 uint2 gid [[thread_position_in_grid]])
{
    float4 Pixel = Source.read(gid);
    uint NewX = gid.x + Parameters.XOffset;
    NewX = NewX % Source.get_width();
    uint2 FinalPosition = uint2(NewX, (Parameters.ImageHeight - 1) - gid.y);
    Target.write(Pixel, FinalPosition);
}

kernel void VerticalImageShift(texture2d<float, access::read> Source [[texture(0)]],
                               texture2d<float, access::write> Target [[texture(1)]],
                               constant ParameterBlock &Parameters [[buffer(0)]],
                               uint2 gid [[thread_position_in_grid]])
{
    float4 Pixel = Source.read(gid);
    uint NewY = gid.y + Parameters.YOffset;
    NewY = NewY % Source.get_height();
    uint2 TargetLocation = uint2(gid.x, (Parameters.ImageHeight - 1) - NewY);
    Target.write(Pixel, TargetLocation);
}
