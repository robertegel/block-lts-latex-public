#import "../heatmaps/lib/blocks.typ": draw_blocks

#let latex_textwidth_factor = 0.7
#let margin = 1mm

#set page(width: auto, height: auto, margin: margin)
#set text(font: "New Computer Modern", size: 10pt)
#show math.equation: set text(font: "New Computer Modern Math")
#show raw: set text(font: "New Computer Modern Mono")

#let params = (
  grid: true,
  label_id: true,
  label_id_outer: true,
  // latex KOMA script textwidth -> resulting fig_width
  latex_fig_width: 157.49817mm * latex_textwidth_factor - margin, 
  //
  // case heatmap: true
  // 
  heatmap: false,
  inp: "johanna_scalar64",
  cmap: color.map.mako.rev(),
  // cmap: color.map.crest,
  label_percent: true,
  label_percent_outer: false,
  round_digits: 0,
  //
  // case heatmap: false
  // 
  nx: 37,
  ny: 30,
  blocksizeX: 7,
  blocksizeY: 7,
  nOuterLayers: 2,
)

#draw_blocks(params)