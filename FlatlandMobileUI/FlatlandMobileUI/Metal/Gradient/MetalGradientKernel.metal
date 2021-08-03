//
//  MetalGradientKernel.metal
//  MetalGradientKernel
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

#include <metal_stdlib>
using namespace metal;

// MARK: - Gradient stop parameter definitions.

/// Parameters for one gradient stop.
struct GradientParameters1P
{
    float4 Color1;
    uint Color1X;
    uint Color1Y;
    uint MaxDistance1;
    float4 TerminalColor1;
};

/// Parameters for two gradient stops.
struct GradientParameters2P
{
    float4 Color1;
    uint Color1X;
    uint Color1Y;
    uint MaxDistance1;
    float4 TerminalColor1;
    
    float4 Color2;
    uint Color2X;
    uint Color2Y;
    uint MaxDistance2;
    float4 TerminalColor2;
};

/// Parameters for three gradient stops.
struct GradientParameters3P
{
    float4 Color1;
    uint Color1X;
    uint Color1Y;
    uint MaxDistance1;
    float4 TerminalColor1;
    
    float4 Color2;
    uint Color2X;
    uint Color2Y;
    uint MaxDistance2;
    float4 TerminalColor2;
    
    float4 Color3;
    uint Color3X;
    uint Color3Y;
    uint MaxDistance3;
    float4 TerminalColor3;
};

/// Parameters for four gradient stops.
struct GradientParameters4P
{
    float4 Color1;
    uint Color1X;
    uint Color1Y;
    uint MaxDistance1;
    float4 TerminalColor1;
    
    float4 Color2;
    uint Color2X;
    uint Color2Y;
    uint MaxDistance2;
    float4 TerminalColor2;
    
    float4 Color3;
    uint Color3X;
    uint Color3Y;
    uint MaxDistance3;
    float4 TerminalColor3;
    
    float4 Color4;
    uint Color4X;
    uint Color4Y;
    uint MaxDistance4;
    float4 TerminalColor4;
};

/// Parameters for five gradient stops.
struct GradientParameters5P
{
    float4 Color1;
    uint Color1X;
    uint Color1Y;
    uint MaxDistance1;
    float4 TerminalColor1;
    
    float4 Color2;
    uint Color2X;
    uint Color2Y;
    uint MaxDistance2;
    float4 TerminalColor2;
    
    float4 Color3;
    uint Color3X;
    uint Color3Y;
    uint MaxDistance3;
    float4 TerminalColor3;
    
    float4 Color4;
    uint Color4X;
    uint Color4Y;
    uint MaxDistance4;
    float4 TerminalColor4;
    
    float4 Color5;
    uint Color5X;
    uint Color5Y;
    uint MaxDistance5;
    float4 TerminalColor5;
};

// MARK: - Utility functions.

/// Determines the distance between the two passed points.
float Distance(uint2 Point1, uint2 Point2)
{
    int XDelta = Point1.x - Point2.x;
    int YDelta = Point1.y - Point2.y;
    XDelta = XDelta * XDelta;
    YDelta = YDelta * YDelta;
    return sqrt(float(XDelta) + float(YDelta));
}

/// Blend two colors together based on a percentage indicating how close spatially `Color1` is
/// from `Color2'. Alpha is also blended.
float4 BlendColorsAndAlpha(float4 Color1, float4 Color2, float PercentFromColor1)
{
    float R = (Color2.r * (1.0 - PercentFromColor1)) + (Color1.r * PercentFromColor1);
    float G = (Color2.g * (1.0 - PercentFromColor1)) + (Color1.g * PercentFromColor1);
    float B = (Color2.b * (1.0 - PercentFromColor1)) + (Color1.b * PercentFromColor1);
    float A = (Color2.a * (1.0 - PercentFromColor1)) + (Color1.a * PercentFromColor1);
    return float4(R, G, B, A);
}

/// Blend two colors together based on a percentage indicating how close spatially `Color1` is
/// from `Color2'. Alpha is set to 1.0.
float4 BlendColors(float4 Color1, float4 Color2, float PercentFromColor1)
{
    float R = (Color2.r * (1.0 - PercentFromColor1)) + (Color1.r * PercentFromColor1);
    float G = (Color2.g * (1.0 - PercentFromColor1)) + (Color1.g * PercentFromColor1);
    float B = (Color2.b * (1.0 - PercentFromColor1)) + (Color1.b * PercentFromColor1);
    return float4(R, G, B, 1.0);
}

// MARK: - One gradient stop functions.

/// Draws a horizontal, linear gradient with a single color.
kernel void MetalGradientKernel1PH(texture2d<float, access::write> Target [[texture(0)]],
                                   constant GradientParameters1P &Parameters [[buffer(0)]],
                                   uint2 gid [[thread_position_in_grid]])
{
    if (gid.y == Parameters.Color1Y)
    {
        Target.write(Parameters.Color1, gid);
        return;
    }
    float4 GColor = float4(0.0, 0.0, 0.0, 1.0);
    if (gid.y < Parameters.Color1Y)
    {
        float Percent = float(gid.y) / float(Parameters.Color1Y);
        GColor = BlendColors(Parameters.Color1, Parameters.TerminalColor1, Percent);
        Target.write(GColor, gid);
    }
    else
    {
        int BottomLength = Target.get_height() - Parameters.Color1Y;
        float Percent = 1.0 - float(gid.y - Parameters.Color1Y) / float(BottomLength);
        GColor = BlendColors(Parameters.Color1, Parameters.TerminalColor1, Percent);
        Target.write(GColor, gid);
    }
}

/// Draws a vertical, linear gradient with a single color.
kernel void MetalGradientKernel1PV(texture2d<float, access::write> Target [[texture(0)]],
                                   constant GradientParameters1P &Parameters [[buffer(0)]],
                                   uint2 gid [[thread_position_in_grid]])
{
    if (gid.x == Parameters.Color1X)
    {
        Target.write(Parameters.Color1, gid);
        return;
    }
    float4 GColor = float4(0.0, 0.0, 0.0, 0.0);
    if (gid.x < Parameters.Color1X)
    {
        float Percent = float(gid.x) / float(Parameters.Color1X);
        GColor = BlendColors(Parameters.Color1, Parameters.TerminalColor1, Percent);
        Target.write(GColor, gid);
    }
    else
    {
        int RightLength = Target.get_width() - Parameters.Color1X;
        float Percent = 1.0 - float(gid.x - Parameters.Color1X) / float(RightLength);
        GColor = BlendColors(Parameters.Color1, Parameters.TerminalColor1, Percent);
        Target.write(GColor, gid);
    }
}

/// Draws a radial gradient with a single color.
kernel void MetalGradientKernel1PR(texture2d<float, access::write> Target [[texture(0)]],
                                   constant GradientParameters1P &Parameters [[buffer(0)]],
                                   uint2 gid [[thread_position_in_grid]])
{
    if ((gid.x == Parameters.Color1X) && (gid.y == Parameters.Color1Y))
    {
        Target.write(Parameters.Color1, gid);
        return;
    }
    float PixelDistance = Distance(gid, uint2(Parameters.Color1X, Parameters.Color1Y));
    float Percent = 1.0 - (PixelDistance / Parameters.MaxDistance1);
    float4 PixelColor = BlendColors(Parameters.Color1, Parameters.TerminalColor1, Percent);
    Target.write(PixelColor, gid);
}

// MARK: Two gradient stop functions.

/// Draws a horizontal, linear gradient with a single color.
kernel void MetalGradientKernel2PH(texture2d<float, access::write> Target [[texture(0)]],
                                   constant GradientParameters2P &Parameters [[buffer(0)]],
                                   uint2 gid [[thread_position_in_grid]])
{
    if (gid.y == Parameters.Color1Y)
    {
        Target.write(Parameters.Color1, gid);
        return;
    }
    if (gid.y == Parameters.Color2Y)
    {
        Target.write(Parameters.Color2, gid);
        return;
    }
    
    float4 GColor = float4(0.0, 0.0, 0.0, 1.0);
    if (gid.y < Parameters.Color1Y)
    {
        float Percent = float(gid.y) / float(Parameters.Color1Y);
        GColor = BlendColors(Parameters.Color1, Parameters.TerminalColor1, Percent);
        Target.write(GColor, gid);
    }
    else
    {
        int BottomLength = Target.get_height() - Parameters.Color1Y;
        float Percent = 1.0 - float(gid.y - Parameters.Color1Y) / float(BottomLength);
        GColor = BlendColors(Parameters.Color1, Parameters.TerminalColor1, Percent);
        Target.write(GColor, gid);
    }
}

/// Draws a vertical, linear gradient with a single color.
kernel void MetalGradientKernel2PV(texture2d<float, access::write> Target [[texture(0)]],
                                   constant GradientParameters2P &Parameters [[buffer(0)]],
                                   uint2 gid [[thread_position_in_grid]])
{
    if (gid.x == Parameters.Color1X)
    {
        Target.write(Parameters.Color1, gid);
        return;
    }
    float4 GColor = float4(0.0, 0.0, 0.0, 0.0);
    if (gid.x < Parameters.Color1X)
    {
        float Percent = float(gid.x) / float(Parameters.Color1X);
        GColor = BlendColors(Parameters.Color1, Parameters.TerminalColor1, Percent);
        Target.write(GColor, gid);
    }
    else
    {
        int RightLength = Target.get_width() - Parameters.Color1X;
        float Percent = 1.0 - float(gid.x - Parameters.Color1X) / float(RightLength);
        GColor = BlendColors(Parameters.Color1, Parameters.TerminalColor1, Percent);
        Target.write(GColor, gid);
    }
}

/// Draws a radial gradient with two colors.
kernel void MetalGradientKernel2PR(texture2d<float, access::write> Target [[texture(0)]],
                                   constant GradientParameters2P &Parameters [[buffer(0)]],
                                   uint2 gid [[thread_position_in_grid]])
{
    if ((gid.x == Parameters.Color1X) && (gid.y == Parameters.Color1Y))
    {
        Target.write(Parameters.Color1, gid);
        return;
    }
    if ((gid.x == Parameters.Color2X) && (gid.y == Parameters.Color2Y))
    {
        Target.write(Parameters.Color2, gid);
        return;
    }
    float Pixel1Distance = Distance(gid, uint2(Parameters.Color1X, Parameters.Color1Y));
    //    float Pixel2Distance = Distance(gid, uint2(Parameters.Color2X, Parameters.Color2Y));
    float Percent1 = 1.0 - (Pixel1Distance / Parameters.MaxDistance1);
    //float Percent2 = 1.0 - (Pixel2Distance / Parameters.MaxDistance2);
    float4 PixelColor = BlendColors(Parameters.Color1, Parameters.TerminalColor1, Percent1);
    Target.write(PixelColor, gid);
}
