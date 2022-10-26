const std = @import("std");

pub const HSLAType = struct {
  hue: u16,
  saturation: f16,
  lightness: f16,
  alpha: f16,
};

pub const RGBAType = struct {
  red: u8,
  green: u8,
  blue: u8,
  alpha: f16,
};

const Color = struct {
  hsla: ?HSLAType,
  rgba: ?RGBAType,

  // fn toHex(self: *Color) []const u8 {
    
  // }
};

pub fn fromRGBA(red: u8, green: u8, blue: u8, alpha: f16) Color {
  return Color {
    .rgba = RGBAType {
      .red = red,
      .green = green,
      .blue= blue,
      .alpha = alpha
    },
    .hsla = null,
  };
}

inline fn maxRGB(red: f16, green: f16, blue: f16) f16 {
  return @maximum(red, @maximum(green, blue));
}
inline fn minRGB(red: f16, green: f16, blue: f16) f16 {
  return @minimum(red, @minimum(green, blue));
}
pub fn rgbaToHsla(rgb: RGBAType) HSLAType {
  var red: f16 = @intToFloat(f16, rgb.red) / 255;
  var green: f16 = @intToFloat(f16, rgb.green) / 255;
  var blue: f16 = @intToFloat(f16, rgb.blue) / 255;

  const cmax: f16 = maxRGB(red, green, blue);
  const cmin: f16 = minRGB(red, green, blue);
  const lightness: f16 = (cmax + cmin) / 2;
  const delta = cmax - cmin;

  if (delta == 0) {
    return HSLAType {
      .hue = 0,
      .saturation = 0,
      .lightness = lightness,
      .alpha = rgb.alpha
    };
  }
  
  var hue: f16 = 0;

  if (cmax == red) {
    if (green < blue) {
      hue = ((green - blue) / delta + 6) * 60;
    } else {
      hue = ((green - blue) / delta) * 60;
    }
  } else if (cmax == green) {
    hue = ((blue - red) / delta + 2) * 60;
  } else if (cmax == blue) {
    hue = ((red - green) / delta + 4) * 60;
  } else unreachable;

  if (hue < 0) hue += 360;

  const saturation = 
    if (lightness > 0.5) 
      delta / (2 - cmax - cmin)
      else delta / (cmax + cmin);

  return HSLAType {
    .hue = @floatToInt(u16, @round(hue)),
    .saturation = @round(saturation * 100_0) / 100_0,
    .lightness = @round(lightness * 100_0) / 100_0,
    .alpha = rgb.alpha
  };
}

const testing = std.testing;

test "RGBA to HSLA" {
  // rgb(0, 0, 255)
  try testing.expectEqual(
    HSLAType {
      .hue = 240,
      .saturation = 1,
      .lightness = 0.5,
      .alpha = 0.5,
    },
    rgbaToHsla(RGBAType {
      .red = 0,
      .green = 0,
      .blue = 255,
      .alpha = 0.5,
    }),
  );


  // rgb(255, 0, 0)
  try testing.expectEqual(
    HSLAType {
      .hue = 0,
      .saturation = 1,
      .lightness = 0.5,
      .alpha = 0.7,
    },
    rgbaToHsla(RGBAType {
      .red = 255,
      .green = 0,
      .blue = 0,
      .alpha = 0.7,
    }),
  );

  // rgb(245, 245, 245)
  try testing.expectEqual(
    HSLAType {
      .hue = 0,
      .saturation = 0,
      .lightness = 0.961,
      .alpha = 0.2,
    },
    rgbaToHsla(RGBAType {
      .red = 245,
      .green = 245,
      .blue = 245,
      .alpha = 0.2,
    }),
  );

  // rgb(51, 51, 51)
  try testing.expectEqual(
    HSLAType {
      .hue = 0,
      .saturation = 0,
      .lightness = 0.20,
      .alpha = 1,
    },
    rgbaToHsla(RGBAType {
      .red = 51,
      .green = 51,
      .blue = 51,
      .alpha = 1,
    }),
  );

  // rgb(255, 105, 180)
  try testing.expectEqual(
    HSLAType {
      .hue = 330,
      .saturation = 1,
      .lightness = 0.706,
      .alpha = 1,
    },
    rgbaToHsla(RGBAType {
      .red = 255,
      .green = 105,
      .blue = 180,
      .alpha = 1,
    }),
  );

  // rgb(229, 241, 205)
  try testing.expectEqual(
    HSLAType {
      .hue = 80,
      .saturation = 0.564,
      .lightness = 0.875,
      .alpha = 1,
    },
    rgbaToHsla(RGBAType {
      .red = 229,
      .green = 241,
      .blue = 205,
      .alpha = 1,
    }),
  );

  // rgb(17, 18, 153)
  try testing.expectEqual(
    HSLAType {
      .hue = 240,
      .saturation = 0.8,
      .lightness = 0.334,
      .alpha = 1,
    },
    rgbaToHsla(RGBAType {
      .red = 17,
      .green = 18,
      .blue = 153,
      .alpha = 1,
    }),
  );

  // rgb(76, 175, 80)
  try testing.expectEqual(
    HSLAType {
      .hue = 122,
      .saturation = 0.394,
      .lightness = 0.492,
      .alpha = 1,
    },
    rgbaToHsla(RGBAType {
      .red = 76,
      .green = 175,
      .blue = 80,
      .alpha = 1,
    }),
  );

  // rgb(255, 20, 147)
  try testing.expectEqual(
    HSLAType {
      .hue = 328,
      .saturation = 1,
      .lightness = 0.539,
      .alpha = 1,
    },
    rgbaToHsla(RGBAType {
      .red = 255,
      .green = 20,
      .blue = 147,
      .alpha = 1,
    }),
  );

  // rgb(181, 68, 25)
  try testing.expectEqual(
    HSLAType {
      .hue = 17,
      .saturation = 0.758,
      .lightness = 0.404,
      .alpha = 1,
    },
    rgbaToHsla(RGBAType {
      .red = 181,
      .green = 68,
      .blue = 25,
      .alpha = 1,
    }),
  );
}