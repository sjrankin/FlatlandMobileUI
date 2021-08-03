//
//  Splitter.metal
//  Splitter
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

#include <metal_stdlib>
using namespace metal;

struct SplitterParameters
{
    uint FromX;
    uint ToX;
    uint FromY;
    uint ToY;
};

kernel void Splitter(texture2d<float, access::read> Source [[texture(0)]],
                     texture2d<float, access::write> Target [[texture(1)]],
                     constant SplitterParameters &Parameters [[buffer(0)]],
                     uint2 gid [[thread_position_in_grid]])
{
    if ((gid.x < Parameters.FromX) || (gid.x > Parameters.ToX))
    {
        return;
    }
    if ((gid.y < Parameters.FromY) || (gid.y > Parameters.ToY))
    {
        return;
    }
    float4 SourceColor = Source.read(gid);
    uint2 TargetLocation = uint2(gid.x - Parameters.FromX, gid.y - Parameters.FromY);
    Target.write(SourceColor, TargetLocation);
}
