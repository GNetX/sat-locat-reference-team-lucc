#' Convert LEDAPS CDR Landsat format images from HDF4 to ENVI format
#'
#' This function converts a Landsat surface reflectance (SR) image from the 
#' Landsat Climate Data Record (CDR) archive into a series of single band 
#' images in ENVI format.
#'
#' Note that this function requires a local GDAL installation. See 
#' http://trac.osgeo.org/gdal/wiki/DownloadingGdalBinaries or 
#' http://trac.osgeo.org/osgeo4w/ to download the appropriate installer for 
#' your operating system.
#'
#' @export
#' @importFrom gdalUtils gdal_translate get_subdatasets
#' @importFrom tools file_path_sans_ext
#' @param x input HDF4 file
#' @param out output file
#' @param overwrite whether to overwrite existing files
unstack_ledapscdr <- function(x, out, overwrite=FALSE) {
    if (!file_test('-d', out)) {
        stop('out must be a directory')
    }
    out_basename <- file_path_sans_ext(basename(x))

    sds <- get_subdatasets(x)
    loc <- regexpr('[a-zA-Z0-9_-]*$', sds)
    out_rasts <- c()
    for (n in 1:length(sds)) {
        start_char <- loc[n]
        stop_char <- start_char + attr(loc, 'match.length')[n]
        band_name <- substr(sds[[n]], start_char, stop_char)
        this_out <- paste0(file.path(out, out_basename), '_', band_name, '.envi')
        if (file.exists(this_out) & overwrite) {
            unlink(this_out)
            if(file.exists(extension(this_out, 'hdr'))) 
                unlink(extension(this_out, 'hdr'))
            if(file.exists(extension(this_out, 'envi.aux.xml'))) 
                unlink(extension(this_out, 'envi.aux.xml'))
            if(file.exists(extension(this_out, 'envi.enp'))) 
                unlink(extension(this_out, 'envi.enp'))
        }
        out_rast <- gdal_translate(x, of="ENVI", sd_index=n, this_out, 
                                   outRaster=TRUE)
        out_rasts <- list(out_rasts, out_rast)
    }
}