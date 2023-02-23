library(stringr)

get.ss.exe.path <- function(os=NULL, ss_version="3.30.21", fname.extra=""){
  
  if(is.null(os)){
    os <- get_os()
  }
  
  if(!(os %in% c("win32", "win64", "win", "osx", "linux"))){
    stop(
      "Unknown OS provided. Must be one of: 'win', 'win32', 'win64', 'osx', 'linux'.
       Note that newer version of SS do not support win32.
      "
    )
  }
  
  if(!(ss_version %in% c("3.24.U", "3.30.21"))){
    stop(
      "Unsupported SS version. Please used either 3.24.U or 3.30.21."
    )
  }
  
  file.extension = ""
  if(os %in% c("win32", "win64", "win")){
    file.extension <- ".exe"
  }
  
  version.components <- stringr::str_split(ss_version, "[.]")[[1]]
  major.version <- version.components[1]
  minor.version <- version.components[2]
  patch.number  <- version.components[3]
  
  if(as.numeric(minor.version) >= 30 & os %in% c("win32", "win64", "win")){
    os <- "win"
  }
  
  exe.dir <- file.path(here::here(), "model", "ss_executables")
  
  version.dir <- paste0("SS_V", major.version, "_", minor.version, "_", patch.number)
  
  if(nchar(fname.extra) > 0){
    fname.extra <- paste0("_", fname.extra)
  } 
  
  ss.file <- paste0("ss_", os, fname.extra, file.extension)
  
  exe.path <- file.path(exe.dir, version.dir, ss.file)
  if(!file.exists(exe.path)){
    warning("Note that this executable does not exist.")
  }
  
  return(exe.path)
  
}

get_os <- function(){
  sysinf <- Sys.info()
  if (!is.null(sysinf)){
    os <- sysinf['sysname']
    if (os == 'Darwin'){
      os <- "osx"
    }else if(os == "windows"){
      if(grepl("64", sysinf["release"])){
        os <- "win64"
      }else{
        os <- "win32"
      }
    }
  } else { ## mystery machine
    os <- .Platform$OS.type
    if (grepl("^darwin", R.version$os))
      os <- "osx"
    if (grepl("linux-gnu", R.version$os))
      os <- "linux"
  }
  return(tolower(os))
}

