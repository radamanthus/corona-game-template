local aspectRatio = display.pixelHeight / display.pixelWidth
application =
{
  content =
  {
    width = aspectRatio > 1.5 and 320 or math.ceil( 480 / aspectRatio ),
    height = aspectRatio < 1.5 and 480 or math.ceil( 320 * aspectRatio ),
    scale = "letterbox",
    imageSuffix =
    {
      ["@2"] = 2,
    }
  }
}
