
#Part 1: package creation and development (steps only run when setting up)
library(devtools)
create_package("/Users/b1082752/Library/Mobile Documents/com~apple~CloudDocs/WORK TEMP/12_openscience/r2bids") #only necessary once
use_github()
usethis::use_pkgdown() # create yml
#Readme File
use_readme_rmd()
devtools::build_readme()


#Part 2: authoring
usethis::use_vignette("A_Example_with_toy_data") # Authoring vignettes
usethis::use_r("write_metadata.R") # Authtoring functions


#Part 3: Sticker creation
library(hexSticker)
imgurl <- "logo/bids_brain_grey.png"
sticker(imgurl, package="r2bids", s_x=1, s_y=1, s_width=0.75, h_fill="white",
        p_size=40, p_y = 1, p_color="blue", p_family="sans", p_fontface="bold",
        url="xaverfuchs.github.io/r2bids", u_size = 5, u_color = "blue",
        h_color="blue",
        white_around_sticker = T,
        filename="logo/logoimg.png")
usethis::use_logo(img = "logo/logoimg.png")




#Part 5: create Namespace
devtools::document()


#Part 6: install and load
#use_r()
load_all() #load functions of package
install() #install the package



#Part 4: Website creation
pkgdown::build_site()

# Github commands
usethis::use_github()
usethis::use_pkgdown_github_pages() #this does not work for me
#usethis::create_from_github("xaverfuchs/rabBITS", fork = FALSE)


#git setup
use_git_config(user.name = "xaverfuchs", user.email = "xfuchs@gmx.de")









