function isLight(color) {
    // Convert color to string
    color = color.toString();

    var color_r = color.slice(1,3);
    var color_g = color.slice(3,5);
    var color_b = color.slice(5,7);

    var r = parseInt(color_r, 16);
    var g = parseInt(color_g, 16);
    var b = parseInt(color_b, 16);

    var hsp = Math.sqrt(
      0.299 * (r * r) +
      0.587 * (g * g) +
      0.114 * (b * b)
    );

    if (hsp>127.5) {

      return true;
    }
    else {

      return false;
    }
}

function convertRGBtoHEX(color_r, color_g, color_b) {
  var r = color_r.toString(16);
  var g = color_g.toString(16);
  var b = color_b.toString(16);

  if (r.length == 1)
    r = "0" + r;
  if (g.length == 1)
    g = "0" + g;
  if (b.length == 1)
    b = "0" + b;

  return "#" + r + g + b;
}

function convertHEXtoRGB(color) {
  var color_r = color.toString().slice(1,3);
  var color_g = color.toString().slice(3,5);
  var color_b = color.toString().slice(5,7);
  
  var r = parseInt(color_r, 16);
  var g = parseInt(color_g, 16);
  var b = parseInt(color_b, 16);
  
  return [r, g, b];
}