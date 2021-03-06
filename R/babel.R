
#' @title Babel - compiler for writing next generation JavaScript
#'
#' @description Babel is a tool that helps you write code in the latest version of
#'  JavaScript. When your supported environments don't support certain features
#'  natively, Babel will help you compile those features down to a supported version.
#'
#' @param input Path to JavaScript file.
#' @param options Options for babel, see \url{https://babeljs.io/docs/en/options}.
#' @param output Path where to write transformed code.
#'
#' @return a \code{character}.
#' @export
#'
#' @name babel
#'
#' @examples
#' \dontrun{
#'
#'   # Template literals are not supported in ES5
#'   babel("var filename = `${Date.now()}.png`;")
#'
#'   # Arrow function neither
#'   babel("[1, 2, 3].map((n) => n + 1);")
#'
#' }
babel_file <- function(input, options = babel_options(), output = NULL) {
  input <- normalizePath(path = input, mustWork = TRUE)
  input <- readLines(con = input, encoding = "UTF-8")
  result <- babel(code = input, options = options)
  if (!is.null(output)) {
    writeLines(text = result, con = output)
  }
  return(invisible(result))
}

#' @param code Character vector where each element represent a line of JS code.
#'
#' @rdname babel
#'
#' @export
#'
#' @importFrom V8 v8
babel <- function(code, options = babel_options()) {
  ctx <- v8()
  ctx$source(file = system.file("assets/babel/babel.min.js", package = "jstools"))
  ctx$assign("code", paste(code, collapse = "\n"))
  ctx$assign("options", options)
  ctx$eval("var output = Babel.transform(code, options);")
  ctx$get("output.code")
}



#' @param presets Preset to use, default to \code{"es2015"}.
#' @param sourceType Default to \code{"script"} : parse the file using the ECMAScript Script grammar.
#' @param ... Other options to use, see \url{https://babeljs.io/docs/en/options} for details.
#'
#' @export
#'
#' @rdname babel
#'
babel_options <- function(presets = list("es2015"), sourceType = "script", ...) {
  list(
    presets = presets,
    sourceType = sourceType,
    ...
  )
}


babel_addin <- function() {
  context <- rstudioapi::getSourceEditorContext()
  babel_file(input = context$path, output = context$path)
}


