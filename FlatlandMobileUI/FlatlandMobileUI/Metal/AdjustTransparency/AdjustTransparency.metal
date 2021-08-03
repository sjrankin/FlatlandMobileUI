//
//  AdjustTransparency.metal
//  AdjustTransparency
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

#include <metal_stdlib>
using namespace metal;

struct TransparencyParameters0
{
    float Threshold;
};

kernel void AdjustTransparency0(texture2d<float, access::read> Source [[texture(0)]],
                                texture2d<float, access::write> Target [[texture(1)]],
                                constant TransparencyParameters0 &Parameters [[buffer(0)]],
                                uint2 gid [[thread_position_in_grid]])
{
    float4 SourceColor = Source.read(gid);
    if (SourceColor.a < Parameters.Threshold)
    {
        Target.write(float4(0.0, 0.0, 0.0, 0.0), gid);
    }
    else
    {
        SourceColor.a = 1.0;
        Target.write(SourceColor, gid);
    }
}
