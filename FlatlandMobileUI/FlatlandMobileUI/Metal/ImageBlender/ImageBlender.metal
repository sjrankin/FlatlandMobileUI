//
//  ImageBlender.metal
//  ImageBlender
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

#include <metal_stdlib>
using namespace metal;


struct ImageBlendParameters
{
    uint XOffset;
    uint YOffset;
    bool FinalAlphaPixelIs1;
    bool HorizontalWrap;
    bool VerticalWrap;
};

//kernel void ImageBlender(texture2d<float, access::read_write> Sprite [[texture(0)]],
kernel void ImageBlender(texture2d<float, access::read> Sprite [[texture(0)]],
                         texture2d<float, access::read_write> Background [[texture(1)]],
                         constant ImageBlendParameters &Parameters [[buffer(0)]],
                         uint2 gid [[thread_position_in_grid]])
{
    uint2 BGPosition = uint2(gid.x + Parameters.XOffset, gid.y + Parameters.YOffset);
    float4 BGPixel = Background.read(BGPosition);
    float4 SpPixel = Sprite.read(gid);
    float SpriteAlpha = SpPixel.a;
    if (BGPixel.a == 0.0)
    {
        //The background is transparent so merely copy the sprite to the background.
        Background.write(SpPixel, BGPosition);
        return;
    }
    if (SpriteAlpha == 0.0)
    {
        //Nothing to do.
        return;
    }
    if (SpriteAlpha == 1.0)
    {
        //The sprite has an alpha of 1, so copy it to the background.
        Background.write(SpPixel, BGPosition);
    }
    else
    {
        //Blend the sprite and background pixels.
        float FinalRed = (SpPixel.r * SpriteAlpha) + (BGPixel.r * (1.0 - SpriteAlpha));
        float FinalGreen = (SpPixel.g * SpriteAlpha) + (BGPixel.g * (1.0 - SpriteAlpha));
        float FinalBlue = (SpPixel.b * SpriteAlpha) + (BGPixel.b * (1.0 - SpriteAlpha));
        if (Parameters.FinalAlphaPixelIs1)
        {
            Background.write(float4(FinalRed, FinalGreen, FinalBlue, 1.0), BGPosition);
        }
        else
        {
            Background.write(float4(FinalRed, FinalGreen, FinalBlue, SpriteAlpha), BGPosition);
        }
    }
}
